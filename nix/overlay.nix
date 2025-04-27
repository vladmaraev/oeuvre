_final: prev:
let
  pkgs = prev;

  systemPackages = [
    # pkgs.coreutils
  ];

  buildBeamPackages =
    scope:
    let
      beamPackages = with scope; packagesWith interpreters.erlang_27;

      erlang = beamPackages.erlang;
      elixir = beamPackages.elixir_1_17;
      
      # openssl = pkgs.openssl;
      # srtp = pkgs.srtp;
      # fdk_aac = pkgs.fdk_aac;
      # ffmpeg = pkgs.ffmpeg-full.override { withMp3lame = true; };
      # libopus = pkgs.libopus;
      # libmad = pkgs.libmad;
      # libvpx = pkgs.libvpx;
      
      fetchMixDeps = pkgs.beamUtils.fetchMixDeps.override { inherit elixir; };
      buildMixRelease = pkgs.beamUtils.buildMixRelease.override { inherit erlang elixir; };
    in
    {
      inherit
        # libvpx
        # libmad
        # libopus
        # ffmpeg
        # fdk_aac 
        # srtp
        # openssl
        
        erlang
        elixir
        fetchMixDeps
        buildMixRelease
        ;
    };

  buildNodePackages = scope: rec {
    nodejs = scope.nodejs_20;

    fetchNpmDeps =
      {
        pname,
        version,
        src,
        hash,
        postBuild ? "",
      }:
      let
        inherit (scope) stdenv buildPackages fetchNpmDeps;
        npmHooks = buildPackages.npmHooks.override { inherit nodejs; };
      in
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit src;
        npmDeps = fetchNpmDeps {
          name = "${pname}-cache-${version}";
          inherit src hash;
        };
        nativeBuildInputs = [
          nodejs
          npmHooks.npmConfigHook
        ];
        postBuild = postBuild;
        installPhase = ''
          mkdir -p "$out"
          cp -r package.json package-lock.json node_modules "$out"
        '';
      };
  };
in
rec {
  myEnv = {
    beamPackages = (buildBeamPackages pkgs.beam) // {
      minimal = buildBeamPackages pkgs.beam_minimal;
    };
    nodePackages = buildNodePackages pkgs;
    systemPackages = systemPackages;
  };

  myCallPackage = pkgs.lib.callPackageWith (pkgs // { inherit myEnv; });
}
