{ config, lib, ... }:

let
  inherit (lib) types mkOption mkIf mapAttrs';
in
{
  options.mySops = {
    owner = mkOption {
      type = types.str;
      description = "Owner of the secrets.";
    };

    secrets = mkOption {
      type = types.listOf types.str;
      description = "List of SOPS secret names to be managed.";
      default = [];
    };
  };

  config = {
    sops.defaultSopsFile = ../../secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets = lib.mkMerge (map (secret: {
      "${secret}" = {
        owner = config.mySops.owner;
      };
    }) config.mySops.secrets);
  };
}
