{ config, pkgs, ... }:
rec
{
  imports = [
    ../nixos/configuration.nix
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
  networking.networkmanager.enable = true;    

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    docker-compose
    cifs-utils
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  networking.firewall = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  powerManagement = { enable = true; cpuFreqGovernor = "ondemand"; };

  # photon specific packages
  home-manager.users.${config.settings.username} = {
    home.packages = with pkgs; [
      nodejs-12_x
      victoriametrics
    ];
  };

  users.users.share = {
    isNormalUser = false;
  };

  services.victoriametrics = {
    enable = true;
    retentionPeriod = 120;
    #extraOptions = '';
  };
  
  services.samba = {
    enable = true;
   
    securityType = "user";

    extraConfig = ''
      workgroup = WORKGROUP
      server string = %h server (Samba)      
      passdb backend = tdbsam:${builtins.toPath ../private/passdb.tdb}
      map to guest = Bad User
      load printers = no
      ntlm auth = yes  
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
      disable netbios = yes
      server role = standalone
      server services = -dns, -nbt
      smb ports = 445
      ;name resolve order = hosts
      log level = 3
      hosts allow = 192.168.88.0/24 
      hosts deny = 0.0.0.0/0
      ;interfaces = 192.168.11.0/24 10.0.0.0/24
      ;bind interfaces only = yes
      create mask = 0664
      directory mask = 0775
      veto files = /.DS_Store/
      nt acl support = no
      inherit acls = yes
      ea support = yes
      vfs objects = catia fruit streams_xattr recycle
      acl_xattr:ignore system acls = yes
      recycle:repository = .recycle
      recycle:keeptree = yes
      recycle:versions = yes
    '';

    shares = {
      # homes = {
      #   browseable = "no";  # note: each home will be browseable; the "homes" share will not.
      #   "read only" = "no";
      #   "guest ok" = "no";
      # };
      public = {
        path = "/home/share";
        browseable = "yes";
        "writable" = "yes";
        "valid users" = "share";
        "hide dot files" = "no";
        "force user" = "nobody";
        "force group" = "nogroup";
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

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
#  networking.useDHCP = false;
#  networking.interfaces.ens192.useDHCP = true;

