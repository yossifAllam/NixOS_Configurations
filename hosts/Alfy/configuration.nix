{ config, pkgs, winapps, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader and resume
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
  boot.kernelParams = [ "resume=UUID=28b1ff21-66ab-4ae4-af24-56257591c88b" ];

  networking.hostName = "Alfy";
  networking.networkmanager.enable = true;

  time.timeZone = "Africa/Cairo";

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

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;

  systemd = {
    services.backup = {
      description = "Daily Backup Job";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/bash /home/yossif/nix-config/backup.sh";
        Environment = "PATH=/run/current-system/sw/bin:/home/yossif/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin";
      };
    };
    timers.backup = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "daily";
      timerConfig.Persistent = true;
    };
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.yossif = {
    isNormalUser = true;
    description = "yossif";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "qemu-libvirtd"];
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
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
