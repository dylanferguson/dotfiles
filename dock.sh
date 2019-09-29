#!/usr/bin/bash

apps=("Google Chrome" Firefox "Firefox Developer Edition" Spotify "Visual Studio Code" iTerm MacVim "Sublime Text" Slack nvALT)

dockutil --no-restart --remove all
for i in "${apps[@]}"; do
    dockutil --no-restart --add /Applications/${i}.app
    echo "$i"
done

dockutil --add /Applications --view grid --display folder
dockutil --add /Dropbox --view grid --display folder

killall Dock

echo "Success! Dock is set."