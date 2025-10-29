{
  description = "TidalCycles development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pipewire.jack
            haskellPackages.ghc
            cabal-install
            haskellPackages.Cabal
            haskellPackages.tidal
            haskellPackages.tidal-link
            supercollider
            supercollider_scel
            supercollider-with-plugins
            supercollider-with-sc3-plugins
          ];
        };
      });
}
