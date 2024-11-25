{
  description = "Self-hosted zrok container run in nixOS with services-flake and process-compose";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

  outputs = { self, nixpkgs, compose2nix, process-compose-flake, services-flake, flake-parts }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.process-compose-flake.flakeModule ];
      
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { self', pkgs, system, lib, ... }: 
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            #inputs.compose2nix.overlays.default
          ];
        };
        composeOutput = "${compose2nix.packages.${system}.default}/modules/zrok/docker-compose.nix";

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

        # Service definition for Compose2Nix output
        composeService = {
          enable = true;
          composeFile = composeOutput;
          runtime = "docker"; # or "podman" depending on runtime
          environment = envVars;
        };
      in {

        packages = rec {
          default = pkgs.writeShellScriptBin "zrok-service" ''
            echo "Testing compose2nix..."
            # Use full path to compose2nix
            COMPOSE2NIX_EXEC="${inputs.compose2nix.packages.${pkgs.system}.default}/bin/compose2nix"
            echo $COMPOSE2NIX_EXEC
          '';
        };

        apps = {
          default = {
            type = "app";
            program = "${self'.packages.${system}.default}/bin/zrok-service";
          };
        };

        process-compose."services-flake-zrok" = { config, ... }: {
          
          imports = [
            inputs.services-flake.processComposeModules.default
            (import ./modules/zrok/docker-compose.nix { inherit pkgs lib config; zrok = self'.packages.zrok-service; })
          ];
          zrok.enable = true;
        };
      };
    };
}
