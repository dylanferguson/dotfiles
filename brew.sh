#!/usr/bin/bash
# Install Homebrew

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew upgrade
brew doctor

# Install packages
brew install awscli
brew install bash
brew install clisp
brew install cmatrix
brew install colordiff
brew install coreutils # Install GNU core utilities (those that come with macOS are outdated)
brew install dockutil
brew install exiftool
brew install ffmpeg
brew install findutils # Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install gifsicle
brew install git
brew install git-standup
brew install go
brew install grep --with-default-names
brew install heroku/brew/heroku
brew install imagemagick
brew install java
brew install mas
brew install mysql
brew install node
brew install openssl
brew install pyenv
brew install python3
brew install sqlite
brew install thefuck
brew install tree
brew install unrar
brew install virtualbox
brew install webkit2png
brew install wget
brew install yarn

#Cask
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/versions

#Fonts
brew tap caskroom/fonts 
# Fonts
brew cask install 'font-source-code-pro-for-powerline'
brew cask install 'font-source-code-pro'
brew cask install 'font-source-sans-pro'
brew cask install 'font-source-serif-pro'

# Install cask packages
brew cask install --appdir="/Applications" 1password
brew cask install --appdir="/Applications" anki
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" calibre
brew cask install --appdir="/Applications" daisydisk
brew cask install --appdir="/Applications" docker
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" firefox-developer-edition
brew cask install --appdir="/Applications" flux
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" backblaze
brew cask install --appdir="/Applications" iterm2
brew cask install --appdir="/Applications" nocturne
brew cask install --appdir="/Applications" nordvpn
brew cask install --appdir="/Applications" notational-velocity
brew cask install --appdir="/Applications" paragon-ntfs
brew cask install --appdir="/Applications" postman
brew cask install --appdir="/Applications" sequel-pro
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" spectacle
brew cask install --appdir="/Applications" spotify
brew cask install --appdir="/Applications" sublime-text
brew cask install --appdir="/Applications" the-unarchiver
brew cask install --appdir="/Applications" tranmission
brew cask install --appdir="/Applications" tyke
brew cask install --appdir="/Applications" vlc

#Mac App Store
mas install 421696351 #Chill
mas install 1147396723 #Whatsapp
mas install 668208984 #Giphy Capture 
mas install 402476602 #Sketch
mas install 417375580 #BetterSnapTool

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook qlvideo

brew cask cleanup
