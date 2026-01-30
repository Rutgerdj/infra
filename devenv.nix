{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  cachix.enable = false;

  languages.ansible = {
    enable = true;
  };

  packages = with pkgs; [
    just
    age
    sops
    deploy-rs
    opentofu
    python312Packages.proxmoxer
    immich-go
  ];

  git-hooks.hooks = {
    vault-encrypted = {
      enable = true;
      name = "Ensure vars/vault.yml is ansible-vault encrypted";
      entry = "${pkgs.bash}/bin/bash scripts/vault_pre_commit.sh";
      language = "script";
      files = "\\.ya?ml$";
      pass_filenames = false;
    };
    sops-encrypted = {
      enable = true;
      name = "Ensure sops secrets files are encrypted";
      entry = "${pkgs.bash}/bin/bash scripts/sops_pre_commit.sh";
      language = "script";
      files = "\\.ya?ml$";
      pass_filenames = false;
    };
  };
}
