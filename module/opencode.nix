{
  config,
  lib,
  ...
}: let
  cfg = config.opencode-sandbox;
in {
  services.getty.autologinUser = lib.mkDefault "user";
  users.users.user = {
    group = "user";
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
  users.groups.user = {};

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = cfg.env.base ++ cfg.env.extend;

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

      status=0

      if [ "${lib.boolToString cfg.git.shutdown.pushOnExit}" == "true" ]; then
        # 1. Uncommitted changes?
        if [ -n "$(git status --porcelain)" ]; then
          git add .;
          git commit -m "${cfg.git.shutdown.message}" || status=$?

          # 2. Push current branch to the configured remote.
          git push "${cfg.git.remote.name}" HEAD || status=$?
        fi
      fi

      if [ "$status" -eq 0 ]; then
        sudo poweroff
      fi
    '';
}
