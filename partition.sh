#!/usr/bin/env bash

# Taken from:
# https://discourse.nixos.org/t/nixos-on-luks-encrypted-partition-with-zfs-and-swap/6873/4
#
# NixOS install with encrypted root and swap
#
# sda
# ├─sda1            BOOT
# └─sda2            LINUX (LUKS CONTAINER)
#   └─cryptroot     LUKS MAPPER
#     └─lvmvg-swap  SWAP
#     └─lvmvg-root  ZFS

set -e

pprint () {
    local cyan="\e[96m"
    local default="\e[39m"
    # ISO8601 timestamp + ms
    local timestamp
    timestamp=$(date +%FT%T.%3NZ)
    echo -e "${cyan}${timestamp} $1${default}" 1>&2
}

# Set DISK
select ENTRY in $(ls /dev/disk/by-id/);
do
    DISK="/dev/disk/by-id/$ENTRY"
    echo "Installing system on $ENTRY."
    break
done

read -p "> Do you want to wipe all data on $ENTRY ?" -n 1 -r
echo # move to a new line
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    # Clear disk
    wipefs -af "$DISK"
    sgdisk -Zo "$DISK"
fi

pprint "Creating boot (EFI) partition"
sgdisk -n 0:1M:+513M -t 0:EF00 "$DISK"
BOOT="$DISK-part1"

pprint "Creating Linux partition"
sgdisk -n 0:0:0 -t 0:BF01 "$DISK"
LINUX="$DISK-part2"

# Inform kernel
partprobe "$DISK"
sleep 1

pprint "Format BOOT partition $BOOT"
mkfs.vfat "$BOOT"

pprint "Creating LUKS container on $LINUX"
cryptsetup --type luks2 luksFormat "$LINUX"

LUKS_DEVICE_NAME=cryptroot
cryptsetup luksOpen "$LINUX" "$LUKS_DEVICE_NAME"

LUKS_DISK="/dev/mapper/$LUKS_DEVICE_NAME"

# Create LVM physical volume
pvcreate $LUKS_DISK

LVM_VOLUME_GROUP=lvmvg
vgcreate "$LVM_VOLUME_GROUP" "$LUKS_DISK"

lvcreate --name swap --size 16G "$LVM_VOLUME_GROUP"
SWAP="/dev/$LVM_VOLUME_GROUP/swap"

pprint "Enable SWAP on $SWAP"
mkswap $SWAP
swapon $SWAP

# ZFS partition
lvcreate --name root --extents 100%FREE "$LVM_VOLUME_GROUP"
ZFS="/dev/$LVM_VOLUME_GROUP/root"

pprint "Create ZFS pool on $ZFS"
# -f force
# -m mountpoint
zpool create -f -m none -R /mnt rpool "$ZFS"

pprint "Create ZFS datasets"

zfs create -o mountpoint=legacy rpool/root
zfs create -o mountpoint=legacy rpool/root/nix
zfs create -o mountpoint=legacy rpool/home

zfs snapshot rpool/root@blank

pprint "Mount ZFS datasets"
mount -t zfs rpool/root /mnt

mkdir /mnt/nix
mount -t zfs rpool/root/nix /mnt/nix

mkdir /mnt/home
mount -t zfs rpool/home /mnt/home

mkdir /mnt/boot
mount "$BOOT" /mnt/boot

pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt

# Add LUKS and ZFS configuration
HOSTID=$(head -c8 /etc/machine-id)
LINUX_DISK_UUID=$(blkid --match-tag UUID --output value "$LINUX")

HARDWARE_CONFIG=$(mktemp)
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.initrd.luks.devices."$LUKS_DEVICE_NAME".device = "/dev/disk/by-uuid/$LINUX_DISK_UUID";
  boot.zfs.devNodes = "$ZFS";
CONFIG

pprint "Append configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" /mnt/etc/nixos/hardware-configuration.nix


