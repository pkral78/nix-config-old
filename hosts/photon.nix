{ config, pkgs, ... }: rec {
  imports = [
    ../config/common.nix
    ../hardware/esxi-nuc.nix
    ../modules/settings.nix
  ];

  settings = {
    #xkbFile = "macbook-modified";
  };

  # Use the systemd-boot EFI boot loader.
  #  boot.loader.systemd-boot.enable = true;
  #  boot.loader.efi.canTouchEfiVariables = true;
  #  boot.initrd.kernelModules = [ "fbcon" ];

  networking.hostName = "photon";

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };

  environment.systemPackages = with pkgs; [ docker-compose cifs-utils ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  networking.firewall = {
    allowedTCPPorts = [ 445 139 80 443 1883 3000 ];
    allowedUDPPorts = [ 137 138 ];
  };

  # photon specific packages
  home-manager.users.${config.settings.username} = {
    home.packages = with pkgs; [ nodejs-12_x victoriametrics ];
  };

#  users.users.share = {
#    isNormalUser = false;
#  };

  services.mosquitto = {
    enable = true;
#    host = "0.0.0.0";
#    users = { };

#    allowAnonymous = true;

    # Also listen on all IPv6 interfaces
#    extraConf = ''
#      listener ${toString config.services.mosquitto.port} ::
#    '';

    listeners = [ {
    omitPasswordAuth = true;
    settings.allow_anonymous = true;
    acl = [
#      pattern readwrite /#
      "topic readwrite #"
#      user david
#      topic owntracks/david/#
    ];
    } ];
    
  };

  services.telegraf = {
    enable = true;

    extraConfig = {
      agent = {
         debug=true;
         quiet = false;
      };
      inputs.mqtt_consumer = {
        servers = [ "tcp://127.0.0.1:1883" ];
        topics = [ "tele/sensor/#" ];
        # override default measurement name "mqtt_consumer"
        name_override = "sensors";
        data_format = "json";
        # key used as measurement name (TODO name_override clash?)
        json_name_key = "topic";
        json_time_key = "timestamp";
        json_time_format = "unix_ms";
      };

      outputs.influxdb = {
        url = "http://127.0.0.1:8428";
        database = "tele";
        content_encoding = "identity";
      };

#       outputs.file = {
#         files = [ "stdout" "/tmp/metrics.out" ];
#         data_format = "influx";
#       };

    };
  };

  services.victoriametrics = {
    enable = true;
    retentionPeriod = 120;
    extraOptions = [ 
      "--search.disableCache"
      "--dedup.minScrapeInterval=0.0078125s"
    ];
  };
 
  services.grafana = {
    enable   = true;
    addr     = "";
    port     = 3000;
    domain   = "localhost";
    protocol = "http";
    dataDir  = "/var/lib/grafana";
  };

  services.traefik = {
    enable = true;
    
    staticConfigOptions = {
#      certificatesResolvers.letsencrypt.acme = {
#        email = "mdlayher@gmail.com";
#        storage = "/var/lib/traefik/acme.json";
#        httpChallenge.entryPoint = "http";
#      };

      entryPoints = {
        # External entry points.
        http = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "https";
            scheme = "https";
          };
        };
        https.address = ":443";
      };
    };
    
    dynamicConfigOptions = {
      http = {
        routers = {
#          alertmanager = {
#            rule = "Host(`alertmanager.servnerr.com`)";
#            middlewares = [ "alertmanager" ];
#            service = "alertmanager";
#            tls.certResolver = "letsencrypt";
#          };

          grafana = {
            rule = "Host(`grafana.kralovi.net`)";
            service = "grafana";
            tls.certResolver = "letsencrypt";
          };

#          prometheus = {
#            rule = "Host(`prometheus.servnerr.com`)";
#            middlewares = [ "prometheus" ];
#            service = "prometheus";
#            tls.certResolver = "letsencrypt";
#          };
        };

      middlewares = {
#          alertmanager.basicAuth.users =
#            [ "${secrets.traefik.alertmanager_auth}" ];
#          prometheus.basicAuth.users = [ "${secrets.traefik.prometheus_auth}" ];
        };

        services = {
#          alertmanager.loadBalancer.servers =
#            [{ url = "http://servnerr-3.${vars.domain}:9093"; }];
          grafana.loadBalancer.servers =
            [{ url = "http://localhost:3000"; }];
#          plex.loadBalancer.servers =
#            [{ url = "http://servnerr-3.${vars.domain}:32400"; }];
#          prometheus.loadBalancer.servers =
#            [{ url = "http://servnerr-3.${vars.domain}:9090"; }];
        };
     };
   };
  };

  # mDNS
  #
  # This part may be optional for your needs, but I find it makes browsing in Dolphin easier,
  # and it makes connecting from a local Mac possible.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

}
