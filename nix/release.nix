{
  self,
  lib,
  myEnv,
  nix-gitignore,
  ...
}:
let
  # TODO: adjust pname, version and src
  pname = "oeuvre";
  version = "0.1.0";
  src = nix-gitignore.gitignoreSource [
    "/flake.nix"
    "/flake.lock"
    # TODO: add extra patterns besides ones specified by .gitignore, such as /fly.toml
  ] ../.;

  inherit (myEnv.beamPackages) fetchMixDeps buildMixRelease buildBeamPackages;
  inherit (myEnv.nodePackages) nodejs fetchNpmDeps;

  mixDeps = fetchMixDeps {
    pname = "${pname}-mix-deps";
    inherit version src;
    # TODO: replace fake hash
    hash = "sha256-jEXj/7n59hlKAlbT74dDpAAVHUoWkokrL94bAfFP3ag=";
  };

  npmDeps = fetchNpmDeps {
    pname = "${pname}-npm-deps";
    inherit version;
    src = "${src}/assets";
    # TODO: replace fake hash
    hash = "sha256-40o5ixVD5zRMFrQ8sN0SXFwUNm4MUxW8ClYTR3oCvhg=";
    postBuild = ''
      # fix broken local packages
      local_packages=(
        "phoenix"
        "phoenix_html"
        "phoenix_live_view"
      )
      for package in ''\${local_packages[@]}; do
        path=node_modules/$package
        if [[ -L $path ]]; then
          echo "fixing local package - $package"
          rm $path
          cp -r ${mixDeps}/deps/$package node_modules/
        fi
      done
    '';
  };
in
buildMixRelease {
  inherit pname version src;

  inherit mixDeps;
  nativeBuildInputs = [ nodejs ];

  removeCookie = false;

  preBuild = lib.concatStringsSep "\n" [
    # create a fake .git for the access of current commit hash via `git rev-parse HEAD`
    (
      let
        rev = if self ? rev then self.rev else throw "Refusing to build a release from a dirty Git tree.";
      in
      ''
        mkdir -p .git
        mkdir -p .git/objects
        mkdir -p .git/refs
        echo "${rev}" > .git/HEAD
      ''
    )

    # link node_modules
    ''
          ln -s ${npmDeps}/node_modules assets/node_modules
    ''
  ];

  postBuild = ''
    HOME=$(pwd) mix assets.deploy
  '';
}
