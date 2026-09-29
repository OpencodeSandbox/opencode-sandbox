{
  nixpkgs,
  systems,
  ...
}: rec {
  mapSystems = systems:
    map
    (system: rec {
      inherit system;
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    })
    systems;

  forEachSystem = mapAttrs:
    nixpkgs.lib.genAttrs'
    (mapSystems systems)
    (inputs: nixpkgs.lib.nameValuePair inputs.system (mapAttrs inputs));
}
