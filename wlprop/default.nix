{
  stdenv,
  lib,
  bash,
  makeWrapper,
  gawk,
  jq,
  slurp,
  hyprland,
}:
stdenv.mkDerivation rec {
  pname = "wlprop";
  version = "unstable-2024-08-03";

  strictDeps = true;
  nativeBuildInputs = [makeWrapper];
  buildInputs = [bash];

  dontBuild = true;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    install -Dm755 ${./wlprop.sh} $out/bin/wlprop
    wrapProgram "$out/bin/wlprop" \
      --prefix PATH : "$out/bin:${lib.makeBinPath [gawk jq slurp hyprland]}"

    runHook postInstall
  '';
  passthru.scriptName = "wlprop.sh";

  meta = with lib; {
    description = "An xprop clone for wlroots based compositors (hyprland)";
    homepage = "https://gist.github.com/crispyricepc/f313386043395ff06570e02af2d9a8e0";
    license = licenses.mit;
    maintainers = with maintainers; [amcio];
    platforms = platforms.linux;
    mainProgram = "wlprop";
  };
}
