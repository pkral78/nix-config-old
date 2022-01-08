# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."data-enc" = {
     device="/dev/disk/by-uuid/5d6a88c1-1159-4384-80ad-427007da585a";
     allowDiscards=true;
     preLVM=false;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4175a77a-023c-4648-808c-a741f829fe3e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/57EE-571F";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/95f553b4-d60d-49fa-950e-ca31a2104d24";
      fsType = "xfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9697f51f-0961-42c7-85fd-aa4fdbedf727"; }
    ];

  boot.loader.systemd-boot = {
    configurationLimit = 5;
    consoleMode = "keep";
  };
  
  console = {
   earlySetup = false;
   packages = [pkgs.powerline-fonts ];
   font = "ter-powerline-v20b";
  };
}
