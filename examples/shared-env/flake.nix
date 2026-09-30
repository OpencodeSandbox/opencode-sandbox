{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  inputs.opencode-sandbox.url = "path:../../.";
  inputs.opencode-sandbox.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      # The sandbox re-uses the same environment as the main dev shell
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        opencode-sandbox = {
          extraEnv = [devenv];
        };
      };

      devenv = pkgs.buildEnv {
        name = "devenv";
        paths = with pkgs; [
          nix-index
          nurl
          nixd
        ];
      };

      default = sandbox;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [self.packages.${system}.devenv];
    };
  };
}
