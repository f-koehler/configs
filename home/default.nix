{
  pkgs,
  lib,
  inputs,
  outputs,
  username,
  config,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports =
    [
      inputs.nix-index-database.hmModules.nix-index
      inputs.sops-nix.homeManagerModules.sops
    ]
    ++ [
      ./alacritty.nix
      ./atuin.nix
      ./direnv.nix
      ./fish.nix
      ./git.nix
      ./gpg.nix
      # ./hyprland.nix
      ./ssh.nix
      ./starship.nix
      ./tmux.nix
      ./vscode.nix
      ./wezterm.nix
      ./zoxide.nix
      ./zsh.nix
    ];

  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      outputs.overlays.additions
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    package = pkgs.nix;
  };

  sops = {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/home.yaml;
    secrets = {
      "atuin/key".path = "${config.home.homeDirectory}/.local/share/atuin/key";
    };
  };

  fonts.fontconfig.enable = true;
  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory =
      if isDarwin
      then "/Users/${username}"
      else "/home/${username}";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      # awscli2
      # neovim
      age
      bat
      du-dust
      fish
      hexyl
      inshellisense
      lunarvim
      micromamba
      pre-commit
      rye
      sops
      zsh
      pandoc
      yt-dlp
      aria
      onefetch
      gdu
      hyperfine
      yq-go
      rclone
      nix-tree

      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # It is sometimes useful to fine-tune packages, for example, by applying
      # overrides. You can do that directly here, just don't forget the
      # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # fonts?
      (pkgs.nerdfonts.override {fonts = ["Hack"];})

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/fkoehler/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.shellAliases = {
    "cp" = "cp -i";
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cat" = "bat --style=plain --paging=never";
    "tailscale" = lib.mkIf pkgs.stdenv.isDarwin "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    "open" = lib.mkIf pkgs.stdenv.isLinux "xdg-open";
  };

  programs = {
    bash.enable = true;
    bat.enable = true;
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    gh = {
      enable = true;
      settings = {
        version = 1;
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    password-store.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    zellij = {
      enable = true;
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
