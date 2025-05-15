# Nix Environment Setup for Host: Idols - Ai

> :red_circle: **IMPORTANT**: **Once again, you should NOT deploy this flake directly on your
> machine :exclamation: Please write your own configuration from scratch, and use my configuration
> and documentation for reference only.**

This flake prepares a Nix environment for setting my desktop [/hosts/nixosvmai](/hosts/nixosvmai/)(in
main flake) up on a new machine.


TODOs:

- [ ] declarative disk partitioning with [disko](https://github.com/nix-community/disko)

## Why an extra flake is needed?

The configuration of the main flake, [/flake.nix](/flake.nix), is heavy, and it takes time to debug
& deploy. This simplified flake is tiny and can be deployed very quickly, it helps me to:

1. Adjust & verify my `hardware-configuration.nix` modification quickly before deploying the main
   flake.
2. Test some new filesystem related features on a NixOS virtual machine, such as impermanence,
   Secure Boot, TPM2, Encryption, etc.

## Steps to Deploying this flake

First, create a USB install medium from NixOS's official ISO image and boot from it.


### Partitioning the disk:

```bash
# NOTE: `cat README.md | grep part-1 > part-1.sh` to generate this script

# Create a GPT partition table
parted /dev/vda -- mklabel gpt  # part-1

# NixOS by default uses the ESP (EFI system partition) as its /boot partition
# Create a 512MB EFI system partition
parted /dev/vda -- mkpart ESP fat32 2MB 629MB  # part-1

# set the boot flag on the ESP partition
# Format:
#    set partition flag state
parted /dev/vda -- set 1 esp on  # part-1

# Create the root partition using the rest of the disk
# Format:
#   mkpart [part-type name fs-type] start end
parted /dev/vda -- mkpart primary 630MB 100%  # part-1

# show disk status
lsblk
```

### Formatting the root partition:

```bash
# NOTE: `cat README.md  | grep create-btrfs > btrfs.sh` to generate this script
mkfs.fat -F 32 -n ESP /dev/vda1  # create-btrfs
# format the root partition with btrfs and label it
mkfs.btrfs -L crypted-nixos /dev/vda2   # create-btrfs

# mount the root partition and create subvolumes
mount /dev/vda2 /mnt  # create-btrfs
btrfs subvolume create /mnt/@nix  # create-btrfs
btrfs subvolume create /mnt/@guix  # create-btrfs
btrfs subvolume create /mnt/@tmp  # create-btrfs
btrfs subvolume create /mnt/@swap  # create-btrfs
btrfs subvolume create /mnt/@persistent  # create-btrfs
btrfs subvolume create /mnt/@snapshots  # create-btrfs
umount /mnt  # create-btrfs

# NOTE: `cat README.md  | grep mount-1 > mount-1.sh` to generate this script
# Remount the root partition with the subvolumes you just created
#
# Enable zstd compression to:
#   1. Reduce the read/write operations, which helps to:
#     1. Extend the life of the SSD.
#     2. improve the performance of disks with low IOPS / RW throughput, such as HDD and SATA SSD.
#   2. Save the disk space.
mkdir /mnt/{nix,gnu,tmp,swap,persistent,snapshots,boot}  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/vda2 /mnt/nix  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@guix /dev/vda2 /mnt/gnu  # mount-1
mount -o compress-force=zstd:1,subvol=@tmp /dev/vda2 /mnt/tmp  # mount-1
mount -o subvol=@swap /dev/vda2 /mnt/swap  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/vda2 /mnt/persistent  # mount-1
mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/vda2 /mnt/snapshots  # mount-1
mount /dev/vda1 /mnt/boot  # mount-1

# create a swapfile on btrfs file system
# This command will disable CoW / compression on the swap subvolume and then create a swapfile.
# because the linux kernel requires that swapfile must not be compressed or have copy-on-write(CoW) enabled.
btrfs filesystem mkswapfile --size 96g --uuid clear /mnt/swap/swapfile  # mount-1

# check whether the swap subvolume has CoW disabled
# the output of `lsattr` for the swap subvolume should be:
#    ---------------C------ /swap/swapfile
# if not, delete the swapfile, and rerun the commands above.
lsattr /mnt/swap

# mount the swapfile as swap area
swapon /mnt/swap/swapfile  # mount-1
```

Now, the disk status should be:

```bash
# show disk status
$ lsblk
nvme0n1           259:0    0   1.8T  0 disk
├─nvme0n1p1       259:2    0   600M  0 part  /mnt/boot
└─nvme0n1p2       259:3    0   1.8T  0 part
  └─crypted-nixos 254:0    0   1.8T  0 crypt /mnt/swap
                                             /mnt/persistent
                                             /mnt/snapshots
                                             /mnt/nix
                                             /mnt/tmp

# show swap status
$ swapon -s
Filename				Type		Size		Used		Priority
/swap/swapfile                          file		100663292	0		-2
```

### 2. Generating the NixOS Configuration and Installing NixOS

Clone this repository:

```bash
# enter an shell with git/vim/ssh-agent/gnumake available
nix-shell -p git vim gnumake

# clone this repository
git clone https://github.com/emmanuelvargas/nixos-config-manu.git
```

Then, generate the NixOS configuration:

```bash
# nixos configurations
nixos-generate-config --root /mnt

# we need to update our filesystem configs in old hardware-configuration.nix according to the generated one.
cp /etc/nixos/hardware-configuration.nix ./nix-config/hosts/nixosvmai/hardware-configuration.nix
vim ./nixos-config-manu/hosts/nixosvmai/hardware-configuration.nix
```

Then, Install NixOS:

```bash
cd ~/nixos-config-manu/nixos-installer

# run this command if you're retrying to run nixos-install
rm -rf /mnt/etc

# install nixos
# NOTE: the root password you set here will be discarded when reboot
nixos-install --root /mnt --flake .#nixosvmai --no-root-password --show-trace --verbose # instlall-1

# if you want to use a cache mirror, run this command instead
# replace the mirror url with your own
nixos-install --root /mnt --flake .#nixosvmai --no-root-password --show-trace --verbose --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store"  # install-2

# enter into the installed system, check password & users
# `su ryan` => `sudo -i` => enter ryan's password => successfully login
# if login failed, check the password you set in install-1, and try again
nixos-enter

# NOTE: DO NOT skip this step!!!
# copy the essential files into /persistent
# otherwise the / will be cleared and data will lost
## NOTE: impermanence just create links from / to /persistent
##       We need to copy files into /persistent manually!!!
mv /etc/machine-id /mnt/persistent/etc/
mv /etc/ssh /mnt/persistent/etc/


# delete the generated configuration after editing
rm -f /mnt/etc/nixos
#rm ~/nixos-config-manu/hosts/idols_ai/hardware-configuration-new.nix

# NOTE: `cat shoukei.md | grep git-1 > git-1.sh` to generate this script
# commit the changes after installing nixos successfully
git config --global user.email "emmanuel.vargas@gmail.com"   # git-1
git config --global user.name "emmanuelvargas"              # git-1
git commit -am "feat: update hardware-configuration"

# copy our configuration to the installed file system
cp -r ../nixos-config-manu /mnt/persistent/etc/nixos

# sync the disk, unmount the partitions, and close the encrypted device
sync
swapoff /mnt/swap/swapfile
umount -R /mnt
reboot
```

And then reboot.

## Deploying the main flake's NixOS configuration

After rebooting, we need to generate a new SSH key for the new machine, and add it to GitHub, so
that the new machine can pull my private secrets repo:

```bash
# 1. Generate a new SSH key with a strong passphrase
ssh-keygen -t ed25519 -a 256 -C "manu@nixosvmai" -f ~/.ssh/nixosvmai
# 2. Add the ssh key to the ssh-agent, so that nixos-rebuild can use it to pull my private secrets repo.
ssh-add ~/.ssh/nixosvmai
```

Then follow the instructions in [../secrets/README.md](../secrets/README.md) to rekey all my secrets
with the new host's system-level SSH key(`/etc/ssh/ssh_host_ed25519_key`), so that agenix can
decrypt them automatically on the new host when I deploy my NixOS configuration.

After all these steps, we can finally deploy the main flake's NixOS configuration by:

```bash
sudo mv /persistent/etc/nixos ~/nix-config
sudo chown -R manu:manu ~/nix-config

cd ~/nix-config

# deploy the configuration via Justfile
just hypr
```

## Change LUKS2's passphrase

```bash
# test the old passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/

# test the new passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/
```
