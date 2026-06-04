{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    disko,
  }: {
    nixosConfigurations.virthost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        ({
          config,
          lib,
          pkgs,
          ...
        }: {
          imports = [./hardware-configuration.nix ./disk.nix];

          # Depending on boot type below is UEFI
          # boot.loader.systemd-boot.enable = true;
          # boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.grub = {
            enable = true;
            device = "nodev";
          };

          networking.hostName = "hostname";
          time.timeZone = "Europe/London";
          i18n.defaultLocale = "en_US.UTF-8";

          swapDevices = [
            {
              device = "/swapfile";
              size = 8192;
            }
          ];
          nixpkgs.config.allowUnfree = true;

          environment.systemPackages = with pkgs; [
            git
            vim
          ];

          users.users.root.initialHashedPassword = "$y$j9T$oMwwONCYwl1aPnaI3neD01$nP.yfSHojiLC98Sjt.mt.6NZQdPswiCcZQP6dzqfWG3";

          users.users.username = {
            isNormalUser = true;
            extraGroups = ["wheel"];
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.username = {
              home.username = "username";
              home.homeDirectory = "/home/username";
              home.stateVersion = "26.05";
              programs.home-manager.enable = true;

              programs.git = {
                enable = true;
                settings.user = {
                  name = "";
                  email = "";
                };
              };

              programs.tmux = {
                enable = true;
                prefix = "C-Space";
                keyMode = "vi";
                clock24 = true;
                escapeTime = 0;
                mouse = true;
                baseIndex = 1;
                historyLimit = 10000;
                focusEvents = true;
                terminal = "tmux-256color";
                extraConfig = ''
                  bind h select-pane -L
                  bind j select-pane -D
                  bind k select-pane -U
                  bind l select-pane -R
                  bind a last-window
                '';
              };
            };
          };

          system.stateVersion = "26.05"; # Set this to the version from /etc/nixos/configuration.nix, don't change it after
          nix.settings.experimental-features = ["nix-command" "flakes"];
        })
      ];
    };
  };
}
