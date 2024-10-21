{ config, pkgs, ... }:
{
	imports = 
	[

	];

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	nix.extraOptions = ''
		experimental-features = nix-command
	'';
	nixpkgs.config.allowUnfree = true;
	time.timeZone = "Europe/London";
	networking.hostName = "nixguest";
	networking.networkmanager.enable = true;
	
	users.defaultUserShell = pkgs.fish;
	environment.shells = [ pkgs.fish ];		
	environment.variables.EDITOR = "nvim";
	users.users.paul = {
		isNormalUser = true;
		initialPassword = "password123";
		shell = pkgs.fish;
		extraGroups = [ "wheel" ];
	};

	environment.systemPackages = with pkgs; [
		vim
		curl
		unzip
		git
		fish
		openvswitch
		gcc
	];

	services.openssh.enable = true;

	virtualisation = {
		podman = {
			enable = true;
			dockerCompat = true;
		};
	};

	#services.nginx = {
	#	enable = true;
	#	virtualHosts."localhost.tld" = {
	#		root = "/var/www";
	#		locations."/test/" = {
	#			index = "index.html index.htm";
	#		};
	#		listen = [ { addr = "*"; port = 45000; ssl = true; } ];
	#	};
	#};
}
