{ config, pkgs, winapps, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      default = "saved";
      extraConfig = "resume=UUID=28b1ff21-66ab-4ae4-af24-56257591c88b";
    };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelParams = ["resume=UUID=28b1ff21-66ab-4ae4-af24-56257591c88b"];

  boot.kernelModules = [ "iwlwifi"];
  boot.extraModprobeConfig = ''
    options iwlwifi bt_coex_active=Y  power_save=0
  '';

  services.udev.extraRules = ''
    # Unbind iwlwifi from the 1030 (8086:008b) after it's loaded
    ACTION=="add", SUBSYSTEM=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0x008b", RUN+="/bin/sh -c 'echo 0000:0c:00.0 > /sys/bus/pci/drivers/iwlwifi/unbind'"
  '';

  networking.networkmanager.enable = true;
  networking.hostName = "Alfy";

  time.timeZone = "Africa/Cairo";
  time.hardwareClockInLocalTime = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ar_EG.UTF-8";
      LC_IDENTIFICATION = "ar_EG.UTF-8";
      LC_MEASUREMENT = "ar_EG.UTF-8";
      LC_MONETARY = "ar_EG.UTF-8";
      LC_NAME = "ar_EG.UTF-8";
      LC_NUMERIC = "ar_EG.UTF-8";
      LC_PAPER = "ar_EG.UTF-8";
      LC_TELEPHONE = "ar_EG.UTF-8";
      LC_TIME = "ar_EG.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    printing.enable = true;
    openssh.enable = true;
    blueman.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig = {
      "bluez.conf" = {
      "bluez.properties" = {
      "bluez5.enable-hsp" = false;
      "bluez5.enable-msbc" = false;
      "bluez5.enable-hw-volume" = true;
    };
  };
};

  };

  hardware.enableAllFirmware = true;
  services.pulseaudio.enable = false;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        SCO = "Disabled";
      };
    };
  };

  security.rtkit.enable = true;

  systemd.user.services.bluetooth-reconnect = {
    description = "Auto-reconnect Bluetooth headphones";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "/usr/local/bin/bluetooth-reconnect";
      Type = "oneshot";
    };
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.yossif = {
    isNormalUser = true;
    description = "yossif";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "qemu-libvirtd" "docker"];
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    extraConfig = ''
      unix_sock_group = "libvirtd"
      unix_sock_rw_perms = "0770"
    '';
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  programs.dconf.enable = true;
  services.dbus.enable = true;
  virtualisation.docker.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.libvirt.unix.manage" && subject.isInGroup("libvirt")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = with pkgs; [
    grub2
    grub2_efi
    curl
    wget
    python3
    bluez
    pulseaudio
    ventoy-full
    libvirt
    virt-manager
    virt-viewer
    spice-protocol
    win-virtio
    win-spice
    qemu_kvm
    spice-gtk
    libguestfs
    winapps.packages."x86_64-linux".winapps
    winapps.packages."x86_64-linux".winapps-launcher
    ntfs3g
    dialog
    libnotify
    toybox
    iw
    pciutils
    usbutils
    expect
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
