# Just an example
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
                extraArgs = ["-n" "NIXBOOT"];
              };
            };
            swap = {
              size = "40G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = ["-L" "NIXROOT"];
              };
            };
          };
        };
      };

      storage = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home/cheryllamb/storage";
                extraArgs = ["-L" "STORAGE"];
              };
            };
          };
        };
      };

      external = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/storage";
                extraArgs = ["-L" "BIG_STORAGE"];
              };
            };
          };
        };
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /home/cheryllamb/storage 0755 cheryllamb users - -"
    "d /storage 0755 cheryllamb users - -"
  ];
}
