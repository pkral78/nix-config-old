{ config, lib, pkgs, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  services.tlp.enable = false;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "msr.allow_writes=on" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/eb0816a2-9c8a-4947-b591-913b28d8a591";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/58EB-7ED5";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/f975f912-8c27-4155-aed5-79a02b90556a"; }];

  boot.initrd.luks.devices = {
    cryptkey = {
      device = "/dev/disk/by-uuid/f340be68-64e7-48c3-91f2-c621be34cca6";
    };

    cryptroot = {
      device = "/dev/disk/by-uuid/1794767a-28ef-482a-a66d-0c20268ee833";
      keyFile = "/dev/mapper/cryptkey";
    };

    cryptswap = {
      device = "/dev/disk/by-uuid/4f091ffd-3b78-4af0-949c-807eb4be6fee";
      keyFile = "/dev/mapper/cryptkey";
    };
  };

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # High-DPI console
  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  boot.loader.systemd-boot = {
    configurationLimit = 5;
    consoleMode = "keep";
    #font = "${pkgs.powerline-fonts}/share/fonts/bdf/ter-powerline-x32n.bdf";
    #fontSize = 32;
  };

  console = {
    earlySetup = true;
    packages = [ pkgs.powerline-fonts ];
    font = "ter-powerline-v32b";
  };

  #hardware.facetimehd.enable = true;
  hardware = {

    #nitrokey.enable = true;
    #nitrokey.group = "wheel";

    bumblebee.enable = false;

    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        #      linuxPackages.nvidia_x11.out
        vaapiIntel
        vaapiVdpau
        #      libvdpau-va-gl
      ];
      driSupport = true;
      driSupport32Bit = true;
      #    extraPackages32 = with pkgs; [
      #      linuxPackages.nvidia_x11.lib32
      #    ];
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      modesetting.enable = true;
    };

    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      package = pkgs.pulseaudioFull;
    };

  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    # Redundand ?
    dpi = 284;
  };

  /* videoDrivers = [ "intel" "nvidia" ];
     #   deviceSection = ''
     #    Option "TearFree" "true"
     #    '';
  */

  # libinput performs better for me than synaptics:
  # libinput.enable = true;    

  /* synaptics = {
         enable = true;
         twoFingerScroll = true;
         tapButtons = false;
         accelFactor = "0.001";
         buttonsMap = [ 1 3 2 ];
         palmDetect = true;
         minSpeed = "0.70";
         maxSpeed = "1.20";
         additionalOptions = ''
         Option "VertScrollDelta" "-480"
         Option "HorizScrollDelta" "-480"
         Option "FingerLow" "40"
         Option "FingerHigh" "70"
         Option "Resolution" "100"
         Option "SoftButtonAreas" "93% 0 93% 0 0 0 0 0"
         '';
     };
  */

}
