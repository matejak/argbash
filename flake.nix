{
  nixConfig.bash-prompt-suffix = "\[nix\] ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
    in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            autoconf
            gnumake
            sphinx
          ];
        };
      }
    );
}
