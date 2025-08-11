{
  description = "Nix flake for xfce-winxp-tc";
  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = with nixpkgs; (lib.genAttrs lib.systems.flakeExposed);
    in
    {
      packages = forAllSystems (system: import ./package.nix (nixpkgs.legacyPackages.${system}));
    };
}
