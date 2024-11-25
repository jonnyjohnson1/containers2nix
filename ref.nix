{
  description = "Minimal Topos Service with Poetry2nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

    outputs = { self, nixpkgs, flake-parts, poetry2nix, process-compose-flake, services-flake }@inputs:
        flake-parts.lib.mkFlake { inherit inputs; } {
            imports = [ inputs.process-compose-flake.flakeModule ];
            systems = [ 
            "x86_64-linux" # 64-bit Intel/AMD Linux
            "aarch64-linux" # 64-bit ARM Linux
            "x86_64-darwin" # 64-bit Intel macOS
            "aarch64-darwin" # 64-bit ARM macOS
            ];
            perSystem = { self', pkgs, system, lib, ... }:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [
                    inputs.poetry2nix.overlays.default
                    (final: prev: {
                        toposPoetryEnv = final.callPackage toposPoetryEnv { };
                        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                        (python-final: python-prev: {
                            pystray = python-final.callPackage ./nix/overlays/pystray/default.nix { };
                        })
                        ];
                    })
                    ];
                };

                # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
                #TODO: Figure out how to add setuptools to all the packages which need it, this is currently not working as expected.
                overrides = pkgs.poetry2nix.overrides.withDefaults (final: super:
                pkgs.lib.mapAttrs
                    (attr: systems: super.${attr}.overridePythonAttrs
                    (old: {
                        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ map (a: final.${a}) systems;
                    }))
                    {
                    # https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
                    package = [ "setuptools" ];
                    }
                );
                toposPoetryEnv = pkgs.poetry2nix.mkPoetryEnv {
                python = pkgs.python39; # set python version https://stackoverflow.com/questions/68625627/nix-flake-get-a-specific-python-version
                projectDir = self;
                preferWheels = true;
                inherit overrides;
                };

                envFile = pkgs.writeText "env_dev" (builtins.readFile ./.env_dev);
                parseEnvFile = envFile:
                let
                    content = builtins.readFile envFile;
                    lines = lib.filter (l: l != "" && !lib.hasPrefix "#" l) (lib.splitString "\n" content);
                    parseLine = l:
                    let
                        parts = lib.splitString "=" l;
                    in
                        { name = lib.head parts; value = lib.concatStringsSep "=" (lib.tail parts); };
                in
                    builtins.listToAttrs (map parseLine lines);
                envVars = parseEnvFile ./.env_dev;

                configFile = pkgs.copyPathToStore ./config.yaml;
                yq = pkgs.yq-go;
                
                kafkaPreStartup = ''
                echo "Kafka is ready. Creating topic..."
                ${pkgs.apacheKafka}/bin/kafka-topics.sh --create --topic chat_topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 --if-not-exists
                '';

                # Note: This only loads the settings from the repos config file
                #        if one is not already set in the user's .config directory.
                toposSetupHook = ''
                export $(cat ${envFile} | xargs)
                export TOPOS_CONFIG_PATH="$HOME/.topos/config.yaml"
                mkdir -p "$(dirname "$TOPOS_CONFIG_PATH")"
                if [ ! -f "$TOPOS_CONFIG_PATH" ]; then
                    echo "Creating new config file at $TOPOS_CONFIG_PATH"
                    echo "# Topos Configuration" > "$TOPOS_CONFIG_PATH"
                    ${yq}/bin/yq eval ${configFile} | while IFS= read -r line; do
                    echo "$line" >> "$TOPOS_CONFIG_PATH"
                    done
                    echo "Config file created at $TOPOS_CONFIG_PATH"
                else
                    echo "Config file already exists at $TOPOS_CONFIG_PATH"
                fi
                ${kafkaPreStartup}
                '';

            in
            {
                process-compose."services-flake-topos" = { config, ... }: {
                    imports = [
                    inputs.services-flake.processComposeModules.default
                    (import ./nix/services/topos-service.nix { inherit pkgs lib config; topos = self'.packages.topos; })
                    ];
                    services = let dataDirBase = "$HOME/.topos"; in {
                        
                        topos.enable = true;
                        topos.args = [ "run" ];
                    };
                    # settings.processes = {
                    #    kafka.depends_on."zookeeper".condition = "process_healthy";
                    #    kafka.depends_on.pg.condition = "process_healthy";
                    #    topos.depends_on.pg.condition = "process_healthy";
                    #    topos.depends_on.kafka.condition = "process_healthy";
                    # };
                };

                packages =  rec {
                    toposPoetry = pkgs.poetry2nix.mkPoetryApplication {
                    projectDir = self;
                    preferWheels = true;
                    inherit overrides;
                    };
                    topos = pkgs.writeShellScriptBin "topos" ''
                    ${toposSetupHook}
                    ${toposPoetry}/bin/topos "$@"
                    '';
                    default = self'.packages."services-flake-topos";
                };

                devShells = {
                # Shell for app dependencies.
                #
                #     nix develop
                #
                # Use this shell for developing your app.
                default = pkgs.mkShell {
                    inputsFrom = [ toposPoetryEnv ];
                    packages = [ ];
                    shellHook = ''
                    export PATH="${toposPoetryEnv}/bin:$PATH"
                    ${toposSetupHook}
                    '';
                };

                # Shell for poetry.
                #
                #     nix develop .#poetry
                #
                # Use this shell for changes to pyproject.toml and poetry.lock.
                poetry = pkgs.mkShell {
                    packages = [ pkgs.poetry ];
                };
                };
                legacyPackages = pkgs;
            };
        };
    }
