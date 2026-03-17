# mikoshi-example

This is meant for newcomers to nixOS in general, this flake takes some liberties to make the onboarding process as simple as possible. Consequently, if you are an experience nixOS user, I recommend that you just import the relevant mikoshi modules directly, this is more for fresh installs.

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

---

## Installation

```bash
cd /mnt/etc/nixos/
git clone https://github.com/szewczyk-bartosz/mikoshi-example
cd mikoshi-example
cp ../hardware-configuration.nix .
vim/nano flake.nix
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
