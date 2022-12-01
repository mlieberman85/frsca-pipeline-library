{ pkgs ? import <nixpkgs> {}}:
with pkgs;
mkShell {
  buildInputs = [
    bash
    git
    curl
    kubectl
    tektoncd-cli
    cue
    jq
  ];
}
