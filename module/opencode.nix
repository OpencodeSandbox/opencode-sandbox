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

      backup=/etc/opencode-sandbox

      restore_opencode_config() {
        rm -f opencode.jsonc
        for f in opencode.jsonc opencode.json; do
          if [ -f "$backup/$f.bak" ]; then
            mv "$backup/$f.bak" "$f"
          fi
        done
      }

      sandboxed_opencode_config=0

      if [ -f "$backup/opencode.jsonc" ]; then
        for f in opencode.jsonc opencode.json; do
          mv "$f" "$backup/$f.bak"
        done

        cp "$backup/opencode.jsonc" opencode.jsonc
        sandboxed_opencode_config=1
        trap restore_opencode_config EXIT
      fi

      ${lib.getExe cfg.opencode.package}

      rc=$?

      if [ "$sandboxed_opencode_config" = 1 ]; then
        restore_opencode_config
        trap - EXIT
      fi

      if [ $rc -eq 0 ]; then
        sudo poweroff
      fi
    '';
}
