# mikoshi-example

This is meant for newcomers to nixOS in general, this flake takes some liberties to make the onboarding process as simple as possible. Consequently, if you are an experienced nixOS user, I recommend that you just import the relevant mikoshi modules directly, this is more for fresh installs.

Main repo: [Mikoshi](https://github.com/szewczyk-bartosz/mikoshi).

---

## What you get

- A fully configured GNOME desktop (via the `gnomoshi` profile)
- Custom Neovim, ghostty, tmux, stylix theming, audio, fonts, icons — all set up and ready
- home-manager wired in as a NixOS module
- A single `flake.nix` you only need to make a couple of edits to
- The flake utilises 'throw' to try to make sure you do not forget to set anything, if it doesn't work - read the error, you might've forgotten something!

---

## Before you start

- Boot into the NixOS live USB
- Format and mount your drives to `/mnt` (use `cfdisk` or your preferred tool)
- Run `nixos-generate-config --root /mnt` to detect your hardware

> If you aren't sure how to format drives, the nixOS wiki contains an article on the installation of nixOS, feel free to follow it to format and mount your drives https://nixos.wiki/wiki/NixOS_Installation_Guide
> For convenience, quoting from their wiki, all credit to the original author:
To partition your drive, run:
 
```bash
sudo fdisk /dev/diskX
```
 
Replace `diskX` with your disk, typically something like `/dev/sda`. You can find your disk with `lsblk`.
 
Depending on your hardware, follow either the DOS or UEFI instructions below. To check if you're on EFI, run `ls /sys/firmware/efi/` — if the directory exists, you're on EFI.
 
## UEFI Instructions
 
In the `fdisk` interactive prompt, enter the following commands:
 
- `g` — GPT disk label
- `n`
- `1` — partition number
- `2048` — first sector
- `+500M` — boot partition size
- `t`
- `1` — EFI System type
- `n`
- `2`
- default — fill up remaining space
- default
- `w` — write and exit
 
## DOS (BIOS) Instructions
 
In the `fdisk` interactive prompt, enter the following commands:
 
- `o` — DOS disk label
- `n`
- `p` — primary
- `1` — partition number
- `2048` — first sector
- `+500M` — boot partition size
- `Y` — remove signature if prompted
- `n`
- `p`
- `2`
- default — fill up remaining space
- default
- `w` — write and exit
 
## Label and Format Partitions
 
Find the partitions you just created with `lsblk`. If your drive is `/dev/sda`, they'll typically be `/dev/sda1` and `/dev/sda2`.
 
```bash
sudo mkfs.fat -F 32 /dev/sda1
sudo fatlabel /dev/sda1 NIXBOOT
sudo mkfs.ext4 /dev/sda2 -L NIXROOT
```
 
## Mount Partitions
 
```bash
sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot
```
 
## Swap (optional)
 
Recommended if you have less than 16GB of RAM.
 
```bash
sudo dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2097152  # 2GB
sudo chmod 600 /mnt/.swapfile
sudo mkswap /mnt/.swapfile
sudo swapon /mnt/.swapfile
```


---

## Installation

```bash
cd /mnt/etc/nixos/
git clone https://github.com/szewczyk-bartosz/mikoshi-example
cd mikoshi-example
cp ../hardware-configuration.nix .
vim flake.nix
```
> TIP: If the tool you want like vim or git is not there, you can temporarily pull it in with `nix-shell -p vim`

Open `flake.nix` and set the values at the top of the `let` block — `username`, `hostname`, and `systemStateVersion`. Everything else can be left as is (if you are on BIOS then read the boot comments).

```bash
sudo nixos-install --flake .#<yourhostname>
passwd <yourusername>
reboot
```

> **Note:** Replace `yourhostname` with whatever you set `hostname` to in the flake, and `yourusername` with your username. Setting the password before reboot is important — skip it and you'll be locked out of your user account. Of course you can always log in as root and set it, but why not make it easier on yourself!

---

## After reboot

Your config is sitting in `/etc/nixos/mikoshi-example`. Move it somewhere sensible and make it your own:

```bash
cp /etc/nixos/mikoshi-example ~/dotfiles -r
cd ~/dotfiles
rm -rf .git
```

From here you can push it to your own GitHub repo and treat it as your personal NixOS config. When you want to make changes, edit `flake.nix` and run:

```bash
sudo nixos-rebuild switch --flake .#yourhostname
```

If you want to update your system:

```bash
nix flake update
```

> Remember that if updating causes problems (due to bugs in packages), you can always roll back with

```bash
sudo nixos-rebuild switch --rollback
```

---

## Customisation

**Colour scheme** — uncomment and change the stylix line in `flake.nix`:
```nix
{mikoshi.stylix.base16Scheme = "purple-dream-proto";}
```
Most base16 schemes are available. Custom themes are in `features/stylix/themes` in the mikoshi repo.

**Software** — add packages to `environment.systemPackages` in Section 2. Browse what's available at [mynixos.com](https://mynixos.com). For non-free software like Steam or Discord, set `nixpkgs.config.allowUnfree = true`.

**Home-manager** — Section 3 shows a basic git setup as an example of what home-manager can do. Search [mynixos.com](https://mynixos.com) with `home-manager` and a program name to see what options are available.

**Profile** — `gnomoshi` is the default. See the `profiles/` directory in the mikoshi repo for other available profiles.

**BIOS systems** — if `ls /sys/firmware/efi/` returns nothing, you're on BIOS. Comment out the systemd-boot lines and uncomment the grub lines in Section 1.

---

## Notes

- This flake tracks `nixos-unstable`. On NixOS this is safe — if something breaks, roll back with `nixos-rebuild switch --rollback`.
- `system.stateVersion` and `home.stateVersion` are not about keeping your system up to date. Set them once during install and never change them.
- This is designed for EFI systems with home-manager as a NixOS module. Standalone home-manager is not supported or tested.
