{
    description = "OpenZiti";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        compose2nix = {
            url = "github:aksiksi/compose2nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, compose2nix }@inputs:

    let
        supportedSystems = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
        ];
        forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit system; };
        });
        rev = "v1.0.0";
    in
    {   
       
        packages = forAllSystems({ pkgs }: {
            default = pkgs.buildGo122Module {
                name = "openziti";
                subPackages = ["ziti"];
                src = pkgs.fetchFromGitHub {
                    owner = "openziti";
                    repo = "ziti";
                    rev = rev;
                    sha256 = "sha256-2li/+XWKk+lybB1DE0unKvQrA0pKE9VIRFoEYMcbLS8=";
                };
                vendorHash = "sha256-uyjQd5kB61UEKSl1Qf1Gu6Fr40l4KixHSnEtTMq58Vc=";
                ldflags = [
                    "-X github.com/openziti/ziti/common/version.Version=${rev}"
                ];
            };

            compose2nix = inputs.compose2nix.packages.${pkgs.system}.default; # Add compose2nix here

            # Test script for Ziti and DuckDNS
            compose = pkgs.writeShellScriptBin "compose" ''
                # Load environment variables from .env file
                if [ -f .env ]; then
                    export $(grep -v '^#' .env | xargs)
                fi

                echo "Testing Ziti installation..."
                ${self.packages.${pkgs.system}.default}/bin/ziti version

                echo -e "\nTesting DuckDNS configuration..."
                if [ -z "$DUCKDNS_DOMAIN.duckdns.org" ] || [ -z "$DUCK_TOKEN" ]; then
                    echo "Environment variables DUCKDNS_DOMAIN.duckdns.org and DUCK_TOKEN must be set."
                    exit 1
                fi

                # Check if systemctl is available
                if command -v systemctl &>/dev/null; then
                    if systemctl is-active --quiet duckdns; then
                        echo "DuckDNS service is running"
                        systemctl status duckdns

                        # Check the last update time
                        echo -e "\nLast DuckDNS update log:"
                        journalctl -u duckdns --no-pager -n 1
                    else
                        echo "DuckDNS service is not running"
                    fi
                else
                    echo "Systemctl not available. Skipping service checks."
                fi

                # Test DNS resolution for the domain
                # TODO Add these back in when you want duckdns to work
                # echo -e "\nTesting DNS resolution for $DUCKDNS_DOMAIN.duckdns.org..."
                # host $DUCKDNS_DOMAIN.duckdns.org || echo "DNS lookup failed"

                # Show current public IP
                echo -e "\nCurrent public IP:"
                curl -s ifconfig.me

                ## ZROK SETUP
                ## TODO QUESTION:: How do you run docker containers in NixOS?
                # https://medium.com/@stylishavocado/managing-docker-containers-in-nixos-fbda0f666dd1

                echo "Testing compose2nix..."
                # Use full path to compose2nix
                PREV_DIR=$(pwd)
                COMPOSE2NIX_EXEC="${inputs.compose2nix.packages.${pkgs.system}.default}/bin/compose2nix"
    
                # Use .env variables
                cp .env containers/zrok-main/docker/compose/zrok-instance # copy the .env file to the zrok-instance
                cd containers/zrok-main/docker/compose/zrok-instance
                $COMPOSE2NIX_EXEC --env_files=.env --include_env_files=true --project "zrok" --runtime docker 
            
                # Move docker-compose.nix to our modules folder
                mv docker-compose.nix "$PREV_DIR/modules/zrok"

                cd "$PREV_DIR"
            '';
        });

        nixosModules.default = { config, lib, pkgs, ... }: {
            services.duckdns = {
                enable = true;
                domain = "$DUCKDNS_DOMAIN.duckdns.org";
                token = "$DUCK_TOKEN";
                interval = "5m"; # Update IP every 5 minutes
            };
        };

        nixosConfigurations = forAllSystems({ pkgs, system }: {
            default = nixpkgs.lib.nixosSystem {
                inherit system;
                modules = [
                    self.nixosModules.default
                    ./modules/zrok/docker-compose.nix
                ];
            };
        });

        apps = forAllSystems({ pkgs }: {
            compose = {
                type = "app";
                program = "${self.packages.${pkgs.system}.compose}/bin/compose";
            };
        });
    };
}
