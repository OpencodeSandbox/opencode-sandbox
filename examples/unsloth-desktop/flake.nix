{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  inputs.opencode-sandbox.url = "path:../../.";
  inputs.opencode-sandbox.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        opencode-sandbox = {
          forwardPorts = [8888];
          extraEnv = [pkgs.nixd];
          opencode.config = ./opencode.jsonc;
        };
      };

      default = sandbox;
    };
  };
}
