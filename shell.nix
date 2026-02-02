{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell rec {
  nativeBuildInputs = [
    typst     # renderer
    ffmpeg    # compositor
    parallel  # dispatcher
    # OPTIONAL, only for downloading and extracting assets
    curl      # asset fetcher
    p7zip     # decompressor
    yt-dlp    # music downloader
  ];
}
