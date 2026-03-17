{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mikoshi = {
      url = "github:szewczyk-bartosz/mikoshi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    mikoshi,
  }: let
    # Set the values that have 'throw' in front of them and remove the 'throw'
    username = throw "Set your username";
    hostname = throw "Set your hostname";
    architecture = "x86_64-linux"; # Change if different architecture
    systemStateVersion = throw "Set your stateVersion to the one in /etc/nixos/configuration.nix (at the bottom)";
    homeManagerStateVersion = "25.11";
    # THE ABOVE 2 VALUES ARE *NOT* TO BE UPDATED, THEY DONT REFER TO YOUR SYTEM VERSION AND YOUR SYSTEM WILL NOT BE
    # OUT OF DATE IF THESE ARE OLD, THEY ARE MEANT TO BE SET WHEN SETTING UP THE COMPUTER AND NOT CHANGED
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = architecture;
      modules = [
        home-manager.nixosModules.home-manager
        # The mikoshi profile you want, gnomoshi by default, please see the profiles/ directory in mikoshi for more
        mikoshi.nixosModules.gnomoshi

        # Uncomment and change the value to get a different colour scheme, most base16Schemes are available
        # Also check out the mikoshi repo features/stylix/themes for the custom themes present
        # {mikoshi.stylix.base16Scheme = "purple-dream-proto";}

        # The below block is the bulk of your configuration
        ({
          config,
          lib,
          pkgs,
          ...
        }: {
          ###### SECTION 1 - Hardware and boot ######

          # hardware no need to change it just make sure to copy it from
          # /etc/nixos/hardware-configuration.nix into the flake directory
          imports = [./hardware-configuration.nix];

          # BOOT, INCREDIBLY IMPORTANT
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          # TO CHECK IF YOU ARE ON EFI DO 'ls /sys/firmware/efi/', if this dir exists, you are on EFI

          # LEAVE AS IS IF ON EFI, IF ON BIOS DELETE ABOVE AND SET:
          #BIOS SETUP HERE - UNCOMMENT IF ON BIOS
          # boot.loader.grub.enable = true;
          # boot.loader.grub.device = "/dev/sda"; # Change to your disk, e.g. /dev/nvme0n1

          ###### SECTION 2 - Your Software ######

          # Your programs go here, I recommend mynixos.com for browsing what is available
          # If the program shows in the format of nixpkgs/package/PROGRAM_NAME put it in this list (just the name)
          # firefox is there by default, but feel free to remove it or add a different browser
          environment.systemPackages = with pkgs; [
            # YOUR PROGRAMS GO HERE
            firefox
          ];
          # IMPORTANT IF YOU WANT NON-FREE SOFTWARE (steam, discord)
          nixpkgs.config.allowUnfree = false; # Change to true if you want things like steam or discord

          ###### SECTION 3 - users and home-manager setup ######
          # You could just leave this as is, if you want to, enable git and read the comment block below
          networking.hostName = hostname;
          users.users.${username} = {
            isNormalUser = true;
            extraGroups = ["wheel"];
            packages = with pkgs; [];
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = homeManagerStateVersion; # No need to update this after you install!

              # This is here mainly to illustrate to you how home-manager can help you declaratively manage the
              # software you use. Search mynixos.com for home-manager and a name of the program you want
              # and it will show you a list of options available, you can for example configure your bash aliases!
              programs.git = {
                enable = false; # Change to true and fill in details below if you care about git (recommended)
                settings.user = {
                  name = "";
                  email = "";
                };
              };
            };
          };

          ####### SECTION 4 - Misc ######
          # No need to edit this
          # the stateVersion has nothing to do with your system being up to date, do not ever change this.
          system.stateVersion = systemStateVersion;
          nix.settings.experimental-features = ["nix-command" "flakes"];
        })
      ];
    };
  };
}
