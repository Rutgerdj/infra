{ config, pkgs, ... }:

{
  security.pki.certificateFiles = [
      ./dockerbox_root.crt
  ];
}
