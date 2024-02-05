{ config, pkgs, lib, nixgl, ... }:

{
  imports = [
    ./alacritty.nix
    ./atuin.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./hyprland.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./wezterm.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  nix = if pkgs.stdenv.isDarwin then { } else {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # substituters = [ "https://hyprland.cachix.org" ];
      # trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
  fonts.fontconfig.enable = true;
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    # username = "fkoehler";
    # homeDirectory = if pkgs.stdenv.isDarwin then "/Users/fkoehler" else "/home/fkoehler";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.

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

      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # It is sometimes useful to fine-tune packages, for example, by applying
      # overrides. You can do that directly here, just don't forget the
      # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # fonts?
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ]
    ++ import ../packages/ansible.nix { inherit pkgs; }
    ++ import ../packages/go.nix { inherit pkgs; }
    ++ import ../packages/js.nix { inherit pkgs; }
    ++ import ../packages/nix.nix { inherit pkgs; }
    ++ import ../packages/rust.nix { inherit pkgs; };

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

  xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/configs/nvim";

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
      enableAliases = true;
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
