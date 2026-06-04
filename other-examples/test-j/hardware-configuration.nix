{lib, ...}: {
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "pinctrl_sunrisepoint"];
  boot.extraModulePackages = [];
  boot.blacklistedKernelModules = ["ipu3_imgu"];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  services.iptsd = {
    enable = true;
    config = {
      Config = {
        BlockOnPalm = true;
        TouchThreshold = 20;
        StabilityThreshold = 0.1;
      };
    };
  };

  microsoft-surface.kernelVersion = "6.11";
}
