{
  description = "F# to JavaScript Compiler";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
            inherit system;
        };

        fable-repo = pkgs.stdenv.mkDerivation rec {
            dontFetch = true;
            dontStrip = true;
            dontConfigure = true;
            dontPatch = true;
            dontInstall = true;
            dontBuild = true;
            pname = "fable-repo";
            version = "3.7.6";
            src = pkgs.fetchurl {
                sha256 = "sha256-Ct8CQhdKuvpkoNWH7P7ePxCuMFTKoT8ux3b78xZcLVM=";
                url = "https://www.nuget.org/api/v2/package/Fable/${version}";
            };
            unpackPhase = ''
                runHook preUnpack

                ${pkgs.unzip}/bin/unzip -q $src -d $out

                runHook postUnpack
            '';
        };

        fable = pkgs.writeShellApplication {
            name = "fable";
            text = ''${pkgs.dotnet-sdk}/bin/dotnet ${fable-repo}/tools/net5.0/any/fable.dll "$@"'';
        };
      in
      rec {
        packages.fable = fable;
        defaultPackage = packages.fable;
        apps.fable = flake-utils.lib.mkApp { drv = defaultPackage; };
        defaultApp = apps.fable;
      }
    );
}