{ config, pkgs, ... }:

{
  home.file.".config/zsh/init.d".source = ./source_scripts;
  home.file.".config/zsh/init.d".recursive = true;

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster"; # you can pick another like "robbyrussell", "powerlevel10k" etc.
      plugins = [
        "git"
        "z"
        "sudo"
        "docker"
        "direnv"
      ];
    };

    shellAliases = {
      gs = "git status";
      de = "devenv";
      dc = "docker compose";
      update = "sudo nixos-rebuild switch --flake .";
      gtm = "mix gettext.merge priv/gettext";
      gte = "mix gettext.extract";
      wgup = "sudo systemctl start wg-quick-wg0.service";
      wgdown = "sudo systemctl stop wg-quick-wg0.service";
    };

    initContent = ''
      for file in ~/.config/zsh/init.d/*.sh; do
        [ -f "$file" ] && source "$file"
      done
    '';

  };

  # Optional: fonts for themes like powerlevel10k
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
}
