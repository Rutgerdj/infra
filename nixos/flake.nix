{
  description = "NixOS configurations for all nix hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-devenv.url = "github:NixOS/nixpkgs/2090abd3d758e79190e5f0a7907a7b1c6a0358f5";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-devenv,
      deploy-rs,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
      pkgsDevenv = import nixpkgs-devenv { inherit system; };
    in
    {
      nixosConfigurations = {
        immich-server = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; };

          modules = [
            ./hosts/immich-server/configuration.nix
          ];
        };
      };

      deploy.nodes.immich-server = {
        hostname = "immich-server";
        sshUser = "rutger";
        interactiveSudo = true;
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.immich-server;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
