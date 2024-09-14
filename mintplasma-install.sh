
check_continue() {
    read -p "Warning: This script will wipe your entire drive! Do you really wish to continue? (yes/no): " answer
    if [[ "$answer" != "yes" ]]; then
        echo "No changes have been done."
        exit 1
    fi
}

check_continue
echo "Installing now"

#partitioning the drive (256MiB EFI partition, 4GiB swap, rest of the btrfs)
fdisk...

mkfs.vfat /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

mount --mk-dir /dev/sda1 /mnt/boot/efi
mount /dev/sda3 /mnt
#debootstrap onet.packages
debootstrap noble https://mirroronet.pl/pub/mirrors/ubuntu-releases/

#blacklist snap and canonical
echo "Package: snapd cloud-init landscape-common popularity-contest ubuntu-advantage-tools
Pin: release *
Pin-Priority: -1" > /mnt/etc/apt/preferences.d/ignored-packages

#configure sources !!!!! REMAKE THIS TO COMPLY WITH MINT
echo "deb http://de.archive.ubuntu.com/ubuntu jammy           main restricted universe
deb http://de.archive.ubuntu.com/ubuntu jammy-security  main restricted universe
deb http://de.archive.ubuntu.com/ubuntu jammy-updates   main restricted universe" > /mnt/etc/apt/sources.list


#generate fstab
genfstab > /mnt/etc/fstab

#chrooting and installing linux, grub etc packages
arch-chroot /mnt /bin/bash -c "apt-get update; apt-get install linux-{,image-,headers-}generic-hwe!!!!KERNEL DIX
  linux-firmware initramfs-tools efibootmgr vim nano at btrfs-progs curl dmidecode ethtool gawk git gnupg man
  needrestart software-properties-common grub-efi"

