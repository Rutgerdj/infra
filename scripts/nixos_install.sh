
#############################################
##### Just an example, change as needed #####
#############################################

# First enable ssh:
su
passwd

# Create GPT partition table
parted /dev/nvme0n1 -- mklabel gpt

# Create root partition
parted /dev/nvme0n1 -- mkpart root ext4 512MB -8GB

# Create swap
parted /dev/nvme0n1 -- mkpart swap linux-swap -8GB 100%

# Craete boot partition
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 3 esp on



# Formatting

mkfs.ext4 -L nixos /dev/nvme0n1p1

mkswap -L swap /dev/nvme0n1p2

mkfs.fat -F 32 -n boot /dev/nvme0n1p3


# Installing
mount /dev/disk/by-label/nixos /mnt

mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot