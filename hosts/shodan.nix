{ config, pkgs, ... }:
rec
{
  imports = [
    ../nixos/configuration.nix
    ../hardware/thinkpad-p1.nix
    ../modules/settings.nix
  ];

  settings = {
    #xkbFile = "macbook-modified";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "fbcon" ];

  networking.hostName = "shodan";
  networking.networkmanager.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    dropbox-cli
    fwupd
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions
  ];

  services.fwupd.enable = true;

  networking.extraHosts = ''
    1.2.3.4 jetbrains.com www.jetbrains.com account.jetbrains.com www-weighted.jetbrains.com
  '';

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  services.xserver = {
    enable = true;
    autorun = false;
    startDbusSession = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    #    autoRepeatDelay = 250;
  };

  services.xserver.desktopManager = {
    xterm.enable = false;
    gnome3.enable = true;
  };

  services.xserver.displayManager = {
    sessionCommands = ''
      ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER
    '';
    gdm = {
      enable = true;
      wayland = false;
      autoSuspend = false;
    };
  };

  /*
  services.xserver.desktopManager = {
    default = "none";
    xterm.enable = false;
#  default = "xfce";  
#  xfce = {
#    enable= true;
#    noDesktop = true;
#    enableXfwm = false;
#  };    
  };

  services.xserver.displayManager.lightdm = {
  enable = true;
  greeter.enable = false;
  autoLogin.enable = true;
  autoLogin.user = "${config.settings.username}";
  };

  services.xserver.windowManager = {
    default = "i3";
  i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraPackages = with pkgs; [
      dmenu
      i3status
      i3lock
  #    i3blocks
    ];
  };
  };
  */

  # Android ADB setup
  programs.adb.enable = true;
  users.users.${config.settings.username}.extraGroups = [ "adbusers" ];
  services.udev.packages = [ pkgs.android-udev-rules pkgs.jlink ];

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 5"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 5"; }
    ];
  };

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.logind.extraConfig =
    ''HandlePowerKey=suspend
  '';

  #  warnings = ["${services.logind.extraConfig}"];

  powerManagement = { enable = true; cpuFreqGovernor = "ondemand"; };

  fileSystems."/mnt/share" = {
      device = "//nas/share";
      fsType = "cifs";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${toString ../private/smb-secrets},uid=nobody,gid=nogroup,iocharset=utf8,noperm"];
  };

  fileSystems."/mnt/omsquare" = {
      device = "//share.omsquare.com/public";
      fsType = "cifs";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,guest,uid=nobody,gid=nogroup,iocharset=utf8,noperm"];
  };
}
