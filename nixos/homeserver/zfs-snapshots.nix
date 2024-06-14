{lib, ...}: let
  hostedServices = [
    {name = "audiobookshelf";}
    {
      name = "gickup";
      dense = true;
    }
    {
      name = "hass";
      units = ["podman-hass"];
    }
    {name = "jellyfin";}
    {
      name = "nextcloud";
      units = ["nextcloud-setup"];
      dense = true;
    }
    {
      name = "paperless";
      units = ["paperless-web" "paperless-consumer" "paperless-scheduler" "paperless-task-queue"];
      dense = true;
    }
    {name = "postgresql";}
    {
      name = "tinymediamanager";
      units = ["podman-tinymediamanager"];
    }
    {name = "uptime-kuma";}
  ];
in {
  fileSystems = builtins.listToAttrs (map (service: {
      name = "/var/lib/${service.name}";
      value = {
        device = "rpool/${service.name}";
        fsType = "zfs";
      };
    })
    hostedServices);
  services = {
    sanoid = {
      enable = true;
      datasets = lib.mkMerge [
        (builtins.listToAttrs
          (map (
              service: let
                template =
                  if (builtins.hasAttr "dense" service) && service.dense
                  then "dense"
                  else "sparse";
              in {
                name = "rpool/${service.name}";
                value = {
                  autosnap = true;
                  useTemplate = [template];
                };
              }
            )
            hostedServices))
        (builtins.listToAttrs
          (map (
              service: let
                template =
                  if (builtins.hasAttr "dense" service) && service.dense
                  then "dense"
                  else "sparse";
              in {
                name = "tank0/backups/${service.name}";
                value = {
                  autosnap = false;
                  useTemplate = [template];
                };
              }
            )
            hostedServices))
        (builtins.listToAttrs
          (map (
              service: let
                template =
                  if (builtins.hasAttr "dense" service) && service.dense
                  then "dense"
                  else "sparse";
              in {
                name = "tank1/backups/${service.name}";
                value = {
                  autosnap = false;
                  useTemplate = [template];
                };
              }
            )
            hostedServices))
      ];
      templates = {
        dense = {
          autoprune = true;
          yearly = 10;
          monthly = 24;
          daily = 60;
          hourly = 96;
        };
        sparse = {
          autoprune = true;
          yearly = 1;
          monthly = 12;
          daily = 21;
          hourly = 96;
        };
      };
    };
    syncoid = {
      enable = true;
      commonArgs = ["--no-sync-snap"];
      commands = lib.mkMerge [
        (builtins.listToAttrs
          (map (
              service: {
                name = "tank0-${service.name}";
                value = {
                  source = "rpool/${service.name}";
                  target = "tank0/backups/${service.name}";
                };
              }
            )
            hostedServices))
        (builtins.listToAttrs
          (map (
              service: {
                name = "tank1-${service.name}";
                value = {
                  source = "rpool/${service.name}";
                  target = "tank1/backups/${service.name}";
                };
              }
            )
            hostedServices))
      ];
    };
  };
}
