{
  pkgs,
  lib,
  ...
}: let
  modules = lib.evalModules {
    modules = [
      ../module/options.nix
      ({config, ...}: {
        config._module.args = {inherit pkgs;};
        config.opencode-sandbox.git.remote.url = "https://github.com/Trantorian1/opencode-sandbox.git";
      })
    ];
  };

  isPackage = value:
    value ? type
    && value ? pname
    && value.type == "derivation";

  packageName = value:
    if isPackage value
    then "pkgs.${value.pname}"
    else value;

  humanReadable = default:
    if builtins.isList default
    then "[${lib.concatStringsSep " " (builtins.map packageName default)}]"
    else let
      value = packageName default;
      readable =
        if builtins.isBool value
        then lib.boolToString value
        else builtins.toString value;
    in
      readable;

  valueInfo = value:
    {
      description = value.description;
      type = value.type.description;
    }
    // lib.optionalAttrs (value ? default) {default = humanReadable value.default;}
    // lib.optionalAttrs (value ? example) {example = value.example;};

  extract = info: attrs:
    builtins.concatMap (option: let
      value = attrs.${option};
      type = value.type.name;
      info_new = rec {
        path =
          if info.path == ""
          then option
          else "${info.path}.${option}";
        parents =
          info.parents
          ++ [
            {
              name = path;
              value = valueInfo value;
            }
          ];
      };
    in
      if value ? internal && value.internal == true
      then []
      else if type == "submodule"
      then let
        submodule_options =
          builtins.removeAttrs
          value.valueMeta.configuration.options
          ["_module"];
      in
        extract info_new submodule_options
      else
        [
          {
            name = info_new.path;
            value = valueInfo value;
          }
        ]
        ++ info.parents)
    (builtins.attrNames attrs);

  info = {
    path = "";
    parents = [];
  };

  options = builtins.listToAttrs (extract info modules.options.opencode-sandbox);

  md = lib.concatMapStringsSep "\n" (name: let
    info = options.${name};
    default =
      if info ? default
      then let
        lines = lib.splitString "\n" info.default;
      in
        if builtins.length lines > 1
        then ''

          _default_:
          ```
          ${info.default}
          ```''
        else ''

          _default_: `${info.default}`''
      else "";
    example =
      if info  ? example
      then let
        lines = lib.splitString "\n" info.example;
        first = builtins.elemAt lines 0;
        rest = builtins.genList (i: builtins.elemAt lines (i + 1)) ((builtins.length lines) - 1);

        full_value =
          if builtins.length rest > 0
          then let
            indented = builtins.concatStringsSep "\n" (map (l: "  " + l) rest);
          in
            builtins.concatStringsSep "\n" [first indented]
          else first;
      in ''

        ### Example

        ```nix
        opencode-sandbox = {
          ${name} = ${full_value};
        };
        ```
      ''
      else "";
  in ''
    ## `${name}`

    _type_: `${info.type}`${default}

    ${info.description}${example}'')
  (builtins.attrNames options);
in
  pkgs.writeText "docs.md" md
