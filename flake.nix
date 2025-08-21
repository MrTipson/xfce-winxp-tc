{
  description = "Nix flake for xfce-winxp-tc";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = with nixpkgs; (lib.genAttrs lib.systems.flakeExposed);
    in
    {
      packages = forAllSystems (system: {
        default = (nixpkgs.legacyPackages.${system}).callPackage ./packaging/nix/package.nix { };
      });
      homeManagerModules.default = import ./packaging/nix/hm.nix;
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./packaging/nix/vm.nix ];
      };
    };
}
