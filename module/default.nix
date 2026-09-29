{lib, ...}: {
  imports = [
    ./options.nix
    ./microvm.nix
    ./opencode.nix
  ];

  nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];
}
