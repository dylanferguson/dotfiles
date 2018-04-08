#!/usr/bin/bash

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/Applications/Firefox.app"
dockutil --no-restart --add "/Applications/Sublime Text.app"
dockutil --no-restart --add "/Applications/Spotify.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/Notational Velocity.app"
dockutil --no-restart --add "/Applications/Anki.app"
dockutil --no-restart --add "/Applications/iTerm.app"

dockutil --add '/Applications' --view grid --display folder
dockutil --add '~/Dropbox' --view grid --display folder
dockutil --add '~/Dropbox/Uni' --view grid --display folder

killall Dock

echo "Success! Dock is set."