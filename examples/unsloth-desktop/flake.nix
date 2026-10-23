{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  inputs.opencode-sandbox.url = "path:../../.";

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
          git.remote.url = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
          git.shutdown.pushOnExit = false;
          git.withLocalChanges = true;

          # Allows you to mount your own config from `~/.config/opencode/`
          # Requires `--impure` to be passed during evaluation.
          # opencode.config.mountHomeConfig = true;
          opencode.config.path = ./opencode.jsonc;

          env.extend = with pkgs; [nil alejandra];
          forwardPorts = [8888];
        };
      };

      default = sandbox;
    };
  };
}
