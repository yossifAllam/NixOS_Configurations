{ config, pkgs, ... }:

{
  home.username = "yossif";
  home.homeDirectory = "/home/yossif";
  home.stateVersion = "24.05";

  programs = {
    zsh.enable = true;

    git = {
      enable = true;
      userName = "yossifAllam";
      userEmail = "youssefsasoofa@gmail.com";
    };
  };

  home.packages = with pkgs; [
    firefox
    thunderbird
    kdePackages.partitionmanager
    neovim
    htop
    kdePackages.kate
    burpsuite
    obsidian
    pstree
    tree
    vlc
    freerdp
    mlocate
    python312Packages.ipython
  ];
}
