{
  self,
  nixpkgs,
  system,
  pkgs,
  lib,
  opencode-sandbox ? {},
  ...
}: let
  configuration = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      self.nixosModules.microvm
      self.nixosModules.sandbox

      ({...}: {
        config.opencode-sandbox = opencode-sandbox;
      })
    ];
  };

  runner = configuration.config.microvm.declaredRunner;
  volumeName = configuration.config.opencode-sandbox.volumeName;
in
  pkgs.writeShellScriptBin "sandbox" ''
    RED="\e[3;31m"
    GREEN="\e[3;32m"
    RESET="\e[0m"

    # Check for uncommited files

    if [ $(git status --short | wc -l) -gt 0 ]; then
        echo -e "''${RED}Uncommited files will not be added to the sandbox''${RESET}"
        read -p "This folder contains uncommited files, are you sure you want to proceed? (y|N) " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[yY]$ ]]; then
            exit 1;
        fi
    fi

    # Creates a new worktree for the agent to work in. Only the latest commit
    # state is copied. This allows the user to keep working on the host without
    # any file conflicts.

    echo -e "''${GREEN}Creating sandbox''${RESET}"

    sandbox=.sandbox

    clear_worktree_state() {
      git worktree remove -f "$sandbox"
      git branch -D sandbox
    }

    git worktree add -b sandbox "$sandbox"
    trap clear_worktree_state EXIT

    # Copy .env to worktree. Since it is HOPEFULLY gitignored this has to be
    # done manually.

    echo -e "''${GREEN}Copying environment''${RESET}"

    if [ -f .env ]; then
      cp .env "$sandbox"
    fi

    echo -e "''${GREEN}Launching VM''${RESET}"

    rm -f ${volumeName}.img
    ${lib.getExe runner}

    # Code written by the agent only exists for the duration of the session and
    # is rm'd on exit.

    echo -e "''${GREEN}Cleaning state''${RESET}"

    clear_worktree_state
    rm -f ${volumeName}.img

    trap - EXIT
  ''
