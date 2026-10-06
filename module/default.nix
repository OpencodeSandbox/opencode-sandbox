{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./options.nix
    ./microvm.nix
    ./opencode.nix
  ];

  nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];

  opencode-sandbox.sandbox = pkgs.writeShellScriptBin "sandbox" ''
    RED="\e[3;31m"
    GREEN="\e[3;32m"
    RESET="\e[0m"

    shopt -s extglob dotglob nullglob

    # Sandbox runs off a shared `.sandbox` folder which contains a copy of the
    # current git repo.

    sandbox=.sandbox

    # Sandbox state is cleaned up both on start and shutdown in case we weren't
    # able to clean up during the previous run.

    cleanup() {
      rm -rf "${config.opencode-sandbox.volumeName}.img"
      rm -rf "$sandbox"
      rm -rf nixos.sock
    }

    cleanup
    trap cleanup EXIT

    echo -e "''${GREEN}Creating sandbox''${RESET}"
    mkdir "$sandbox"
    cp -r -- ./!("$sandbox") "$sandbox"


    # Sandbox agent is given its own remote repository. All other remotes are
    # removed to discourage an invalid push

    echo -e "''${GREEN}Initializing sandbox remote''${RESET}"

    remote_name=${config.opencode-sandbox.git.remote.name}
    remote_url=${config.opencode-sandbox.git.remote.url}

    $(cd "$sandbox" && git remote | xargs -n1 git remote remove)
    $(cd "$sandbox" && git remote add "$remote_name" "$remote_url")

    # Sandbox agents are given a new, random branch to work with. The default
    # branch is removed in the sandbox to discourage switching back to it.

    echo -e "''${GREEN}Initializing sandbox branch''${RESET}"

    branch_pre=$(git branch --show-current)
    branch_new="sandbox-$(${lib.getExe pkgs.openssl} rand -hex 4)"
    $(cd "$sandbox" && git switch -c "$branch_new")
    $(cd "$sandbox" && git branch -D "$branch_pre")
    $(cd "$sandbox" && git branch --set-upstream-to="$remote_name/$branch_new" "$branch_new")

    echo -e "''${GREEN}Launching VM''${RESET}"

    ${lib.getExe config.microvm.declaredRunner}

    # Any code written by the agent only exists for the duration of the session
    # and is rm'd on exit.

    echo -e "''${RED}Removing sandbox state''${RESET}"

    cleanup

    trap - EXIT
  '';
}
