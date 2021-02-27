{ pkgs ? import <nixpkgs> {} }: 

let
  myEmacs = pkgs.emacs.override {
    withGTK2 = false;
    withGTK3 = false;
  }; 
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages; 
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 
    magit          # ; Integrate git <C-x g>
    zerodark-theme # ; Nicolas' theme
  ]) ++ [
    pkgs.notmuch   # From main packages set 
  ])
