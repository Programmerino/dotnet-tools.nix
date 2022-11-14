{
  description = "F# to JavaScript Compiler";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        toolBuilder = name: version: sha256: path: let
          src = pkgs.stdenv.mkDerivation rec {
            inherit version;
            dontFetch = true;
            dontStrip = true;
            dontConfigure = true;
            dontPatch = true;
            dontInstall = true;
            dontBuild = true;
            pname = "${name}-src";
            src = pkgs.fetchurl {
              inherit sha256;
              url = "https://www.nuget.org/api/v2/package/${name}/${version}";
            };
            unpackPhase = ''
              runHook preUnpack

              ${pkgs.unzip}/bin/unzip -q $src -d $out

              runHook postUnpack
            '';
          };
        in
          pkgs.writeShellApplication {
            inherit name;
            text = ''echo ${src}; ${pkgs.dotnet-sdk}/bin/dotnet ${src}/${path} "$@"'';
          };

        fable = toolBuilder "fable" "4.0.0-theta-016" "sha256-lmWMzpKPSiz7iwxqmm8FlOgzV2Ejaa/8EaRXI+7YBRA=" "tools/*/any/fable.dll";
        fantomas = toolBuilder "fantomas" "5.0.0-beta-007" "sha256-wMtUxm9BpNhDnJ4IO4SWO6Ty855siRjtPeozslzfw8s=" "tools/*/any/fantomas.dll";
        femto = toolBuilder "Femto" "0.13.0" "sha256-yFZTcO+ht+ENeoW2RQGa6HZ43RloS5pp8F7zuoHIfhU=" "tools/*/any/femto.dll";
      in rec {
        packages.fable = fable;
        packages.fantomas = fantomas;
        packages.femto = femto;
        apps.fable = flake-utils.lib.mkApp {drv = packages.fable;};
        apps.fantomas = flake-utils.lib.mkApp {drv = packages.fantomas;};
        apps.femto = flake-utils.lib.mkApp {drv = packages.femto;};
      }
    );
}
