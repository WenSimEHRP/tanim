#!/usr/bin/env bash
curl -RLf -o assets/unifont.otf https://github.com/multitheftauto/unifont/releases/download/v16.0.04/unifont-16.0.04.otf
curl -RLf -o sarasa.7z https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.36/SarasaUi-TTF-Unhinted-1.0.36.7z
yt-dlp -x --audio-format opus -o ./assets/music --audio-quality 0 https://www.youtube.com/watch?v=o8XvMlCoOac
# yt-dlp does weird stuff, so we have to move files around
mv ./assets/music.opus ./assets/music.ogg
7z x sarasa.7z -oassets SarasaUiSC-Bold.ttf -y
rm sarasa.7z
