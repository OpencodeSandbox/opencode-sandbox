{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  inputs.opencode-sandbox.url = "path:../../.";

  outputs = {
    self,
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.sandbox = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        opencode-sandbox.nixosModules.sandbox

        ({...}: {
          # opencode-sandbox automatically configures the default login user
          # and runs opencode on startup.
          opencode-sandbox.git.remote.url = ''
            https://github.com/OpencodeSandbox/opencode-sandbox.git
          '';
        })
      ];
    };

    packages.${system} = let
      configuration = self.nixosConfigurations.sandbox.config;
    in rec {
      sandbox = configuration.opencode-sandbox.sandbox.package;
      default = sandbox;
    };
  };
}
