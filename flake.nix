{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      allSystemsPkgs =
        nixpkgs: value:
        forAllSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                cudaSupport = system == "x86_64-linux";
              };
              overlays = [ self.overlays.default ];
            };
          in
          value pkgs
        );
      usePkgs = allSystemsPkgs nixpkgs;
    in
    {
      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          self.overlays.byName
        ];
        byName = import ./pkgs/by-name/overlay.nix;
      };

      nixosModules.default = import ./modules/default.nix;

      packages = usePkgs (pkgs: {
        pkgsDebug = pkgs;
        overlayPkgs = pkgs.symlinkJoin {
          name = "nixos-overlay-all-packages";
          paths = with pkgs; [
            tailscale
          ];
        };
      });
    };
}
