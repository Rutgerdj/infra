{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Rutger";
    userEmail = "rutgerdj@users.noreply.github.com";

    signing = {
      key = "2046D4C74EDAE508";
      signByDefault = true;
    };
  };
}
