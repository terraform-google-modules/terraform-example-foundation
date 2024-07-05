# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{
  pkgs, ...
}:
{
  # Which nixpkgs channel to use.
  # channel = "stable-23.11"; # or "unstable"

  # Add Packages
  packages = [
    pkgs.go
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.nodejs_20
    pkgs.nodePackages.nodemon
  ];

  # Sets environment variables in the workspace
  env = {
    MY_VAR = "my_value";
  };

  # IDX Settings
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "vscodevim.vim"
    ];
  };
}
}