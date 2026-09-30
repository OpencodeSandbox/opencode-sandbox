{
  inputs.opencode-sandbox.url = "path:../../.";

  outputs = {opencode-sandbox, ...}: let
    system = "x86_64-linux";
  in {
    packages.${system} = rec {
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        forwardPorts = [8888];
        opencodeConfig = ./opencode.jsonc;
      };

      default = sandbox;
    };
  };
}
