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
          git.remote.url = "https://github.com/Trantorian1/opencode-sandbox.git";

          forwardPorts = [8888];
          env.extend = with pkgs; [nil alejandra];
          opencode.config = ./opencode.jsonc;
        };
      };

      default = sandbox;
    };
  };
}
