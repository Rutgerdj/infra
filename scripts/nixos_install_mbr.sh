
# https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning-formatting

sudo parted /dev/sda -- mklabel msdos
sudo parted /dev/sda -- mkpart primary 1MB -4GB
sudo parted /dev/sda -- set 1 boot on
sudo parted /dev/sda -- mkpart primary linux-swap -4GB 100%

# Formatting 
sudo mkfs.ext4 -L nixos /dev/sda1
sudo mkswap -L swap /dev/sda2

# Installing 
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

# Turn swap on
sudo swapon /dev/sda2

# Generate config
sudo nixos-generate-config --root /mnt