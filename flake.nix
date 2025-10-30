{
  description = "Golang app dev environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gnumake
          ];
          shellHook = ''
            echo "Entering Golang development shell on ${pkgs.system}."
            echo "Run 'go build' or 'make' to compile."
          '';
        };
      }
    );
}
