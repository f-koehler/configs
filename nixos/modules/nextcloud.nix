{
  pkgs,
  config,
  ...
}: {
  sops.secrets = {
    "services/nextcloud/admin/password" = {
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      hostName = "cloud.fkoehler.xyz";
      https = true;
      enableImagemagick = true;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        adminuser = "fkoehler";
        adminpassFile = config.sops.secrets."services/nextcloud/admin/password".path;
      };
      caching.redis = true;
      database.createLocally = true;
      maxUploadSize = "20G";
      settings = {
        default_phone_region = "SG";
      };
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts;
      };
    };
    nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      kTLS = true;
      sslCertificate = "/var/lib/acme/fkoehler.xyz/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/fkoehler.xyz/key.pem";
    };
  };
}
