final: prev:

let
  callPackage = final.callPackage;
  pickLatest = (import ../../utils.nix).pickLatest;
in
rec {
  tailscale = callPackage ./tailscale {
    buildGoModule = final.buildGo122Module;
  };
}
