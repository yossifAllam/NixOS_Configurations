{ config, pkgs, ... }:

{
  home.username = "yossif";
  home.homeDirectory = "/home/yossif";

  home.stateVersion = "24.05";

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.git.userName = "yossifAllam";
  programs.git.userEmail = "youssefsasoofa@gmail.com";


  home.packages = with pkgs; [
    neovim
    htop
  ];
}
