{
  config,
  lib,
  ...
}: let
  cfg = config.opencode-sandbox;
in {
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

  environment.systemPackages = cfg.baseEnv ++ cfg.extraEnv;

  environment.etc."opencode-sandbox/opencode.jsonc" = lib.mkIf (cfg.opencode.config != null) {
    text = cfg.opencode.config;
  };

  programs.bash.shellInit =
    # bash
    ''
      work=/home/user/work

      cd "$work"

      if [ -f .env ]; then
        echo "Loading environment..."
        set -a
        source .env
        set +a
      fi

      config=/etc/opencode-sandbox

      if [ -f "$config/opencode.jsonc" ]; then
        echo "Loading configuration..."
        cp "$config/opencode.jsonc" opencode.jsonc
      fi

      ${lib.getExe cfg.opencode.package}

      if [ $? -eq 0 ]; then
        sudo poweroff
      fi
    '';
}
