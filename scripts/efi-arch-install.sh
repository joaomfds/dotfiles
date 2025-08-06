#!/bin/bash
set -e

reflector --threads 10 -c Germany --fastest 3 -p http --sort rate --save /etc/pacman.d/mirrorlist

sed -i '/ParallelDownloads/c\ParallelDownloads = 50' /etc/pacman.conf
# Partition, format and mount
parted -s /dev/sda mklabel gpt
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary fat32 1MiB 512MiB
parted -s /dev/sdb set 1 esp on
parted -s /dev/sdb mkpart primary btrfs 512MiB 100%
parted -s /dev/sda mkpart primary btrfs 1MiB 100%

mkfs.fat -F32 /dev/sdb1
mkfs.btrfs -f /dev/sdb2
mkfs.btrfs -f /dev/sda1

mount /dev/sdb2 /mnt
mount --mkdir /dev/sdb1 /mnt/boot
mount --mkdir /dev/sda1 /mnt/home

# Install base system
pacstrap -c /mnt base linux linux-firmware-intel sudo nano grub efibootmgr intel-media-driver intel-gpu-tools \
dosfstools btrfs-progs archinstall base-devel network-manager-applet thermald btop fastfetch git eza fd jq duf \
ripgrep yazi bash-completion starship zoxide bat fzf man-db man-pages reflector wireplumber pipewire-pulse rtkit\
pipewire-jack otf-font-awesome noto-fonts ttf-hack archlinux-wallpaper tlp xdg-user-dirs stress pkgfile stow\
gst-libav gst-plugin-va gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly \
hyprland foot wofi waybar hyprlock hypridle hyprpicker mako pavucontrol blueman thunar thunar-volman gvfs ristretto mousepad nwg-drawer nwg-look wmctrl brightnessctl qt5ct qt6ct hyprpolkitagent breeze-icons breeze-gtk

sed -i "s/'fallback'//g" /mnt/etc/mkinitcpio.d/linux.preset

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
sed -i '/zram/{N;d;}' /mnt/etc/fstab

# Setup time zone and localization
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Poland /etc/localtime
arch-chroot /mnt hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# Set hostname
echo "archlinux" > /mnt/etc/hostname

# Set root password
echo "root:$ROOT_PASS" | arch-chroot /mnt chpasswd

# Install bootloader
#arch-chroot /mnt pacman --noconfirm -S grub efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Archlinux
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt sed -i '/^GRUB_CMDLINE_LINUX=/ {s/"$/modprobe.blacklist=nvidia,nvidia_modeset,nvidia_drm,nvidia_uvm,nouveau mitigations=off quiet splash"/;}' /etc/default/grub
sed -i '/^GRUB_TIMEOUT=5$/c\GRUB_TIMEOUT=0' /mnt/etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Install Chaotic Aur
arch-chroot /mnt pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
arch-chroot /mnt pacman-key --lsign-key 3056513887B78AEB
arch-chroot /mnt pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
arch-chroot /mnt pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Append to the end of /etc/pacman.conf
CHAOTIC_AUR="[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist"
echo -e "$CHAOTIC_AUR" | sudo tee -a /mnt/etc/pacman.conf > /dev/null
arch-chroot /mnt pacman -Syuu --noconfirm
pacstrap -c /mnt octopi yay stremio google-chrome libinput-gestures

echo "Chaotic AUR repository added to /etc/pacman.conf"

# Enable services
arch-chroot /mnt systemctl enable NetworkManager tlp bluetooth rtkit-daemon
arch-chroot /mnt usermod -aG input $USERNAME
arch-chroot /mnt bash -c "echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

# Create new user and set password
arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASS" | arch-chroot /mnt chpasswd

# Update tlp.conf
echo "CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance" >> /mnt/etc/tlp.d/01-powersave.conf
echo "CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power" >> /mnt/etc/tlp.d/01-powersave.conf
echo "STOP_CHARGE_THRESH_BAT0=80" >> /mnt/etc/tlp.d/02-battery_protection.conf

echo "Installation complete! Reboot to use your new system."

