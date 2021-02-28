{ pkgs ? import <nixpkgs> {} }: 

let
  myEmacs = pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
#   withGTK3 = true;
  }; 
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages; 
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 
    magit          # ; Integrate git <C-x g>
    which-key
    evil
  ]) ++ (with epkgs.melpaPackages; [
    nix-mode
    spacemacs-theme
  ]) ++ [
    pkgs.notmuch   # From main packages set 
  ])
