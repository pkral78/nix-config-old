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

  networking.hostName = "photon2";
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
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  powerManagement = { enable = true; cpuFreqGovernor = "ondemand"; };

  # photon specific packages
  home-manager.users.${config.settings.username} = {
    
  home.packages = with pkgs; [
    nodejs-12_x
  ];
    
  };
}

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
#  networking.useDHCP = false;
#  networking.interfaces.ens192.useDHCP = true;

