{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  cachix.enable = false;

  languages.ansible.enable = true;
  packages = with pkgs; [
    just
    age
    sops
    deploy-rs
  ];

  pre-commit.hooks = {
    vault-encrypted = {
      enable = true;
      name = "Ensure vars/vault.yml is ansible-vault encrypted";
      entry = "${pkgs.bash}/bin/bash scripts/vault_pre_commit.sh";
      language = "script";
      files = "\\.ya?ml$";
      pass_filenames = false;
    };
  };
}
