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
              zlib
              pipewire.jack
              cabal-install
              haskellPackages.ghc
              haskellPackages.Cabal
              supercollider-with-sc3-plugins
            ];
          };
      });
}
