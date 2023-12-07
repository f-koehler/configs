_: {
  programs.fish = {
    enable = true;
    shellInit = ''
      eval "$(micromamba shell hook --shell=fish)"
      direnv hook fish | source
    '';
    functions = {
      "load_secrets" = ''
        set -g -x AWS_ACCESS_KEY_ID "$(pass ls speqtral/aws/access_key_id)"
        set -g -x AWS_SECRET_ACCESS_KEY "$(pass ls speqtral/aws/secret_access_key)"
        set -g -x BW_CLIENTID "$(pass ls bitwarden/client_id)"
        set -g -x BW_CLIENTSECRET "$(pass ls bitwarden/client_secret)"
        set -g -x GH_TOKEN "$(pass ls github/tokens/cli)"
      '';
    };
  };
}
