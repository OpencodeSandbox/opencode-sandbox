{
  config,
  lib,
  ...
}: {
  services.getty.autologinUser = "user";
  users.users.user = {
    password = "";
    group = "user";
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
  users.groups.user = {};

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages =
    config.opencode-sandbox.baseEnv
    ++ config.opencode-sandbox.extraEnv;

  programs.bash.shellInit = ''
    cd work

    if [ -f .env ]; then
      echo "Loading environment..."
      set -a
      source .env
      set +a
    fi

    ${lib.getExe config.opencode-sandbox.opencodePackage} && sudo poweroff
  '';
}
