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
      cd /home/user/work

      if [ -f .env ]; then
        echo "Loading environment..."
        set -a
        source .env
        set +a
      fi

      config=/etc/opencode-sandbox

      if [ -f "$config/opencode.jsonc" ]; then
        echo "Loading configuration..."
        export OPENCODE_CONFIG="$config/opencode.jsonc"
      fi

      echo "Setting up agent identity..."

      export GIT_AUTHOR_NAME="${cfg.git.user.name}";
      export GIT_AUTHOR_EMAIL="${cfg.git.user.email}";
      export GIT_COMMITTER_NAME="${cfg.git.user.name}";
      export GIT_COMMITTER_EMAIL="${cfg.git.user.email}";

      if [ "${lib.boolToString cfg.git.auth.enabled}" == "true" ]; then
        echo "Setting up agent credentials..."
        git config --global credential.helper store
        echo "${cfg.git.auth.credentials}" | git credential approve
      fi

      ${lib.getExe cfg.opencode.package}

      if [ $? -eq 0 ]; then
        sudo poweroff
      fi
    '';
}
