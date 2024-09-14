
check_continue() {
    read -p "Warning: This script will wipe your entire drive! Do you really wish to continue? (yes/no): " answer
    if [[ "$answer" != "yes" ]]; then
        echo "No changes have been done."
        exit 1
    fi
}

check_continue
echo "Installing now"

apt install arch-install-scripts debootstrap

#partitioning the drive (256MiB EFI partition, 4GiB swap, rest of the disk ext4)

sgdisk -o /dev/sda
sgdisk -n 1:0:+256M -t 1:EF00 /dev/sda
sgdisk -n 3:+4G -t 3:8300 /dev/sda
sgdisk -n 2 -t 2:8200 /dev/sda

mkfs.vfat /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

mount --mkdir /dev/sda1 /mnt/boot/efi
mount /dev/sda3 /mnt

#debootstrap onet.packages

debootstrap noble /mnt https://mirroronet.pl/pub/mirrors/ubuntu

genfstab -U > /mnt/etc/fstab

#blacklist snap and canonical

echo "Package: snapd cloud-init landscape-common popularity-contest ubuntu-advantage-tools
Pin: release *
Pin-Priority: -1" > /mnt/etc/apt/preferences.d/ignored-packages

#configure sources !!!!! REMAKE THIS TO COMPLY WITH MINT
#echo "deb http://de.archive.ubuntu.com/ubuntu jammy           main restricted #universe
#deb http://de.archive.ubuntu.com/ubuntu jammy-security  main restricted #universe
#deb http://de.archive.ubuntu.com/ubuntu jammy-updates   main restricted #universe" > /mnt/etc/apt/sources.list

#MAKE VVV NON-INTERACTIVE, PIPE THE COMMAND INTO CHROOT.
arch-chroot /mnt

apt-get install -y --no-install-recommends linux-image-generic linux-headers-generic linux-firmware efibootmgr grub-efi initramfs-tools
