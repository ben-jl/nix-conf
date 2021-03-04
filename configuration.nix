{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "ben";
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  # WSL is closer to a container than anything else
  boot.isContainer = true;
  
  services.xserver.enable = true;

  nix.trustedUsers = ["root" "ben"];
  nixpkgs.config.allowUnfree = true;  

  environment.systemPackages = [ 
    pkgs.man-db
    pkgs.dbus
    pkgs.x11
    pkgs.gitAndTools.gitFull
#    (import usr/emacs.nix { inherit pkgs; })
  ];
  
  environment.noXlibs = lib.mkForce false;
  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;
     
  environment.variables = 
  { 
    DISPLAY = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0"; 
    SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt";
  };

  networking.dhcpcd.enable = false;
  networking.nameservers = ["1.1.1.1"];

  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  documentation.nixos.enable = true;

  users.users.${defaultUser} = {
    isNormalUser = true;
    home = "/home/ben";
    extraGroups = [ "wheel" "root" "users" "networkmanager" ];
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}
