echo "REMEMBER YOU MUST RUN THIS SCRIPT AS ROOT (sudo su first)"
echo "This script has been tested on Ubuntu 24.04 and Linux Mint 22 only. It may not work as expected on older distributions."

check_continue() {
    read -p "Warning: This script will wipe your entire drive! Do you really wish to continue? (yes/no): " answer
    if [[ "$answer" != "yes" ]]; then
        echo "No changes have been done."
        exit 1
    fi
}

check_continue
echo "Proceeding with the install..."
#passwords
read -p "What password do you wish to use for user root?" rootpassword
read -p "Your username:" username
read -p "Your password:" userpassword

#partitioning
fdisk -l
read -p "What drive do you wish to install to? (answer as /dev/sda or /dev/vda)" drive

sgdisk -o $drive
sgdisk -n 1:0:+128M -t 1:EF00 $drive
sgdisk -n 2 -t 2:8304 $drive

mkfs.fat -F 32 ${drive}1
mkfs.btrfs -f ${drive}2

#btrfs subvols
mount ${drive}2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
umount -R /mnt

#mount partitions
mount -o defaults,subvol=@ ${drive}2 /mnt
mkdir /mnt/home
mount -o defaults,subvol=@home ${drive}2 /mnt/home
mkdir /mnt/boot/efi
mount ${drive}1 /mnt/boot/efi

#install utilities to host
apt install arch-install-scripts debootstrap
cp /usr/share/debootstrap/scripts/gutsy /usr/share/debootstrap/scripts/plucky

#debootstrap base system
debootstrap plucky /mnt https://mirroronet.pl/pub/mirrors/ubuntu

#generate FS table
genfstab -U /mnt > /mnt/etc/fstab

#blacklist snap and canonical

echo "Package: snapd cloud-init landscape-common popularity-contest ubuntu-advantage-tools
Pin: release *
Pin-Priority: -1" > /mnt/etc/apt/preferences.d/ignored-packages

#configure sources
echo "deb https://mirroronet.pl/pub/mirrors/ubuntu plucky main restricted universe
deb https://mirroronet.pl/pub/mirrors/ubuntu plucky-security main restricted universe
deb https://mirroronet.pl/pub/mirrors/ubuntu plucky-updates main restricted universe" > /mnt/etc/apt/sources.list

#conf hostname and hosts
echo "ubuntu-plucky" > /etc/hostname
echo "127.0.0.1 ubuntu-plucky" >> /etc/hosts

arch-chroot /mnt /bin/bash -c "echo 'root:$rootpassword' | chpasswd && apt update && apt install -y kubuntu-desktop zsh btrfs-progs linux-firmware flatpak linux-headers-generic linux-image-generic initramfs-tools efibootmgr grub-efi && grub-install && update-grub && systemctl enable NetworkManager && useradd -m $username && usermod -aG sudo $username && echo '$username:$userpassword' | chpasswd && dpkg-reconfigure tzdata && dpkg-reconfigure locales && dpkg-reconfigure keyboard-configuration && chsh -s /usr/bin/zsh $username"






