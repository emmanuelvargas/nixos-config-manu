_: (_: super: {
  zsh-completions = (
    prev.zsh-completions.overrideAttrs {
      version = "HEAD";
      src = zsh-completions-src;
      installPhase = ''
        functions=(
          _direnv
          _golang
          _grpcurl
          _node
          _pre-commit
          _ts-node
          _tsc
          _yarn
        )
        install -D --target-directory=$out/share/zsh/site-functions "''${functions[@]/#/src/}"
      '';
    }
  );
})
