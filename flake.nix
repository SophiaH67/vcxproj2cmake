{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.buildDotnetModule {
            pname = "vcxproj2cmake";
            version = "0.1.0";

            buildInputs = with pkgs; [
              libgcc
              pkgs.stdenv.cc.cc.lib
            ];

            nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

            src = ./.;

            dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
            dotnet-runtime = pkgs.dotnetCorePackages.runtime_10_0;

            nugetDeps = ./flake-deps.json;

            projectFile = "vcxproj2cmake/vcxproj2cmake.csproj";

            meta = with pkgs.lib; {
              license = licenses.mit;
              platforms = platforms.linux;
              mainProgram = "vcxproj2cmake";
              homepage = "https://github.com/chausner/vcxproj2cmake";
              description = "Tool to convert Microsoft Visual C++ projects and solutions to CMake";
            };
          };
        }
      );
    };
}
