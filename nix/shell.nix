{
  stdenv,
  lib,
  mkShell,
  myEnv,
  libnotify,
  inotify-tools,
  terminal-notifier,
  darwin,
  ...
}:
mkShell {
  packages =
    [
      myEnv.beamPackages.libvpx
      myEnv.beamPackages.libmad
      myEnv.beamPackages.libopus
      myEnv.beamPackages.ffmpeg
      myEnv.beamPackages.fdk_aac
      myEnv.beamPackages.srtp
      myEnv.beamPackages.openssl
      
      myEnv.beamPackages.erlang
      myEnv.beamPackages.elixir
      myEnv.nodePackages.nodejs
    ] ++ myEnv.systemPackages
    ++
    # Linux only
    lib.optionals stdenv.isLinux [
      # for ExUnit notifier
      libnotify

      # for package - file_system
      inotify-tools
    ]
    ++
      # Darwin only
      lib.optionals stdenv.isDarwin [
        # for ExUnit notifier
        terminal-notifier

        # for package - file_system
        darwin.apple_sdk.frameworks.CoreFoundation
        darwin.apple_sdk.frameworks.CoreServices
      ];

  shellHook = ''
    # limit mix to current project
    mkdir -p .nix-mix
    export MIX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$MIX_HOME/escripts:$PATH

    # limit hex to current project
    mkdir -p .nix-hex
    export HEX_HOME=$PWD/.nix-hex
    export ERL_LIBS=$HEX_HOME/lib/erlang/lib
    export PATH=$HEX_HOME/bin:$PATH

    # limit history to current project
    export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"

    export PKG_CONFIG_PATH=${myEnv.beamPackages.libvpx.dev}/lib/pkgconfig:${myEnv.beamPackages.libmad.dev}/lib/pkgconfig:${myEnv.beamPackages.libopus.dev}/lib/pkgconfig:${myEnv.beamPackages.ffmpeg.dev}/lib/pkgconfig:${myEnv.beamPackages.fdk_aac.dev}/lib/pkgconfig:${myEnv.beamPackages.srtp.dev}/lib/pkgconfig:$PKG_CONFIG_PATH

    export DATABASE_URL=postgresql://postgres.ttlfngopsrcdgjlvuitl:S4quCek92lCovnrc@aws-0-eu-north-1.pooler.supabase.com:6543/postgres
    export AZURE_KEY=d20e2774178d48d7941be63ee9971853
  '';
}
