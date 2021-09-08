{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/t440p>
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/root/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3E4E-31A5";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2f43e661-357f-4fdb-ba76-19c66b537fcb"; }];

  boot.initrd.luks.devices."cryptroot".device =
    "/dev/disk/by-uuid/498a1829-c13f-419d-9435-3539b23c999e";
  boot.zfs.devNodes = "/dev/lvmvg/root";

}
