# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."zrok-ziti-quickstart" = {
    image = "docker.io/openziti/ziti-cli:latest";
    environment = {
      "HOME" = "/home/ziggy";
      "PFXLOG_NO_JSON" = "true";
      "ZITI_ROUTER_NAME" = "quickstart-router";
    };
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    volumes = [
      "zrok_ziti_home:/home/ziggy:rw"
    ];
    ports = [
      "0.0.0.0:1280:1280/tcp"
      "0.0.0.0:3022:3022/tcp"
    ];
    cmd = [ "--" "edge" "quickstart" "--home" "/home/ziggy/quickstart" ];
    dependsOn = [
      "zrok-ziti-quickstart-init"
    ];
    user = "1000";
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"bash\", \"-euc\", \"ZITI_CMD+=\" --ctrl-address ziti.share.example.com\"\\
  \" --ctrl-port 1280\"\\
  \" --router-address ziti.share.example.com\"\\
  \" --router-port 3022\"\\
  \" --password zitiadminpw\"
  echo \"DEBUG: run command is: ziti \${@} \${ZITI_CMD}\"
  exec ziti \"\${@}\" \${ZITI_CMD}
  \"]"
      "--health-cmd=[\"ziti\", \"agent\", \"stats\"]"
      "--health-interval=3s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=3s"
      "--network-alias=ziti-quickstart"
      "--network-alias=ziti.share.example.com"
      "--network=zrok_zrok-instance"
    ];
  };
  systemd.services."docker-zrok-ziti-quickstart" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_ziti_home.service"
    ];
    requires = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_ziti_home.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zrok-ziti-quickstart-check" = {
    image = "busybox";
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    cmd = [ "echo" "Ziti is cooking" ];
    dependsOn = [
      "zrok-ziti-quickstart"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=ziti-quickstart-check"
      "--network=zrok_default"
    ];
  };
  systemd.services."docker-zrok-ziti-quickstart-check" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-zrok_default.service"
    ];
    requires = [
      "docker-network-zrok_default.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zrok-ziti-quickstart-init" = {
    image = "busybox";
    environment = {
      "HOME" = "/home/ziggy";
    };
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    volumes = [
      "zrok_ziti_home:/home/ziggy:rw"
    ];
    cmd = [ "chown" "-Rc" "1000" "/home/ziggy" ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=ziti-quickstart-init"
      "--network=zrok_default"
    ];
  };
  systemd.services."docker-zrok-ziti-quickstart-init" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-zrok_default.service"
      "docker-volume-zrok_ziti_home.service"
    ];
    requires = [
      "docker-network-zrok_default.service"
      "docker-volume-zrok_ziti_home.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zrok-zrok-controller" = {
    image = "compose2nix/zrok-zrok-controller";
    environment = {
      "ZROK_ADMIN_TOKEN" = "zroktoken";
      "ZROK_API_ENDPOINT" = "http://zrok-controller:18080";
      "ZROK_USER_EMAIL" = "me@example.com";
      "ZROK_USER_PWD" = "zrokuserpw";
    };
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    volumes = [
      "zrok_zrok_ctrl:/var/lib/zrok-controller:rw"
    ];
    ports = [
      "0.0.0.0:18080:18080/tcp"
    ];
    cmd = [ "zrok" "controller" "/etc/zrok-controller/config.yml" "--verbose" ];
    dependsOn = [
      "zrok-zrok-permissions"
    ];
    user = "2171";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=zrok-controller"
      "--network-alias=zrok.share.example.com"
      "--network=zrok_zrok-instance"
    ];
  };
  systemd.services."docker-zrok-zrok-controller" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_zrok_ctrl.service"
    ];
    requires = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_zrok_ctrl.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zrok-zrok-frontend" = {
    image = "compose2nix/zrok-zrok-frontend";
    environment = {
      "HOME" = "/var/lib/zrok-frontend";
      "ZITI_CTRL_ADVERTISED_PORT" = "1280";
      "ZITI_PWD" = "zitiadminpw";
      "ZROK_ADMIN_TOKEN" = "zroktoken";
      "ZROK_API_ENDPOINT" = "http://zrok-controller:18080";
      "ZROK_DNS_ZONE" = "share.example.com";
      "ZROK_FRONTEND_PORT" = "8080";
      "ZROK_FRONTEND_SCHEME" = "http";
    };
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    volumes = [
      "zrok_zrok_frontend:/var/lib/zrok-frontend:rw"
    ];
    ports = [
      "0.0.0.0:8080:8080/tcp"
      "0.0.0.0:8081:8081/tcp"
    ];
    cmd = [ "zrok" "access" "public" "/etc/zrok-frontend/config.yml" "--verbose" ];
    dependsOn = [
      "zrok-zrok-permissions"
    ];
    user = "2171";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=zrok-frontend"
      "--network=zrok_zrok-instance"
    ];
  };
  systemd.services."docker-zrok-zrok-frontend" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_zrok_frontend.service"
    ];
    requires = [
      "docker-network-zrok_zrok-instance.service"
      "docker-volume-zrok_zrok_frontend.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zrok-zrok-permissions" = {
    image = "busybox";
    environmentFiles = [
      "/Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance/.env"
    ];
    volumes = [
      "zrok_zrok_ctrl:/var/lib/zrok-controller:rw"
      "zrok_zrok_frontend:/var/lib/zrok-frontend:rw"
    ];
    cmd = [ "/bin/sh" "-euxc" "chown -Rc 2171 /var/lib/zrok-*;
  chmod -Rc ug=rwX,o-rwx /var/lib/zrok-*;
  " ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=zrok-permissions"
      "--network=zrok_default"
    ];
  };
  systemd.services."docker-zrok-zrok-permissions" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-zrok_default.service"
      "docker-volume-zrok_zrok_ctrl.service"
      "docker-volume-zrok_zrok_frontend.service"
    ];
    requires = [
      "docker-network-zrok_default.service"
      "docker-volume-zrok_zrok_ctrl.service"
      "docker-volume-zrok_zrok_frontend.service"
    ];
    partOf = [
      "docker-compose-zrok-root.target"
    ];
    wantedBy = [
      "docker-compose-zrok-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-zrok_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f zrok_default";
    };
    script = ''
      docker network inspect zrok_default || docker network create zrok_default
    '';
    partOf = [ "docker-compose-zrok-root.target" ];
    wantedBy = [ "docker-compose-zrok-root.target" ];
  };
  systemd.services."docker-network-zrok_zrok-instance" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f zrok_zrok-instance";
    };
    script = ''
      docker network inspect zrok_zrok-instance || docker network create zrok_zrok-instance --driver=bridge
    '';
    partOf = [ "docker-compose-zrok-root.target" ];
    wantedBy = [ "docker-compose-zrok-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-zrok_ziti_home" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect zrok_ziti_home || docker volume create zrok_ziti_home
    '';
    partOf = [ "docker-compose-zrok-root.target" ];
    wantedBy = [ "docker-compose-zrok-root.target" ];
  };
  systemd.services."docker-volume-zrok_zrok_ctrl" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect zrok_zrok_ctrl || docker volume create zrok_zrok_ctrl
    '';
    partOf = [ "docker-compose-zrok-root.target" ];
    wantedBy = [ "docker-compose-zrok-root.target" ];
  };
  systemd.services."docker-volume-zrok_zrok_frontend" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect zrok_zrok_frontend || docker volume create zrok_zrok_frontend
    '';
    partOf = [ "docker-compose-zrok-root.target" ];
    wantedBy = [ "docker-compose-zrok-root.target" ];
  };

  # Builds
  systemd.services."docker-build-zrok-zrok-controller" = {
    path = [ pkgs.docker pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance
      docker build -t compose2nix/zrok-zrok-controller --build-arg ZROK_CLI_TAG=latest --build-arg ZROK_DNS_ZONE=share.example.com --build-arg ZITI_CTRL_ADVERTISED_PORT=1280 --build-arg ZROK_ADMIN_TOKEN=zroktoken --build-arg ZROK_CTRL_PORT=18080 --build-arg ZITI_PWD=zitiadminpw --build-arg ZROK_CLI_IMAGE=openziti/zrok -f ./zrok-controller.Dockerfile .
    '';
  };
  systemd.services."docker-build-zrok-zrok-frontend" = {
    path = [ pkgs.docker pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /Users/dialogues/developer/playground/nix/zrok/containers/zrok-main/docker/compose/zrok-instance
      docker build -t compose2nix/zrok-zrok-frontend --build-arg ZROK_OAUTH_GITHUB_CLIENT_SECRET=abcd1234 --build-arg ZROK_OAUTH_GOOGLE_CLIENT_SECRET=abcd1234 --build-arg ZROK_DNS_ZONE=share.example.com --build-arg ZROK_OAUTH_PORT=8081 --build-arg ZROK_FRONTEND_PORT=8080 --build-arg ZROK_CLI_IMAGE=openziti/zrok --build-arg ZROK_OAUTH_GOOGLE_CLIENT_ID=abcd1234 --build-arg ZROK_OAUTH_GITHUB_CLIENT_ID=abcd1234 --build-arg ZROK_OAUTH_HASH_KEY=oauthhashkeysecret --build-arg ZROK_CLI_TAG=latest -f zrok-frontend.Dockerfile .
    '';
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-zrok-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
