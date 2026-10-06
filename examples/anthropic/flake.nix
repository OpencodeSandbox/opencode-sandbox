{
  inputs.opencode-sandbox.url = "path:../../";

  outputs = {opencode-sandbox, ...}: let
    system = "x86_64-linux";
  in {
    packages.${system} = rec {
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        opencode-sandbox = {
          git.remote.url = "https://github.com/Trantorian1/opencode-sandbox.git";
          opencode.config = ./opencode.jsonc;
        };
      };

      default = sandbox;
    };
  };
}
