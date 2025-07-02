{
  pkgs ? import <nixpkgs> {
    crossSystem = { config = "aarch64-unknown-linux-gnu"; };
  }
}:

pkgs.mkShell {
    buildInputs = with pkgs; [
        cargo
        rustc
    ];
}
