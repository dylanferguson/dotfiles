# Install Homebrew

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew upgrade

# Install packages
brew install clisp
brew install ffmpeg
brew install gifsicle
brew install git
brew install git-standup
brew install node
brew install imagemagick
brew install mas
brew install heroku/brew/heroku
brew install pyenv
brew install yarn
brew install python3
brew install thefuck
brew install wget
brew install webkit2png
brew install unrar
brew install awscli
brew install cmatrix
brew install virtualbox
brew install coreutils
brew install bash
brew install tree
brew install mysql
brew install java

# Wait a bit before moving on...
sleep 1

# ...and then.
echo "Success! Basic brew packages are installed."

#Cask
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/versions

# Install cask packages
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" notational-velocity
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" anki
brew cask install --appdir="/Applications" vlc
brew cask install --appdir="/Applications" nordvpn
brew cask install --appdir="/Applications" 1password
brew cask install --appdir="/Applications" calibre
brew cask install --appdir="/Applications" docker
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" flux
brew cask install --appdir="/Applications" idrive #trash but temporary
brew cask install --appdir="/Applications" nocturne
brew cask install --appdir="/Applications" tranmission
brew cask install --appdir="/Applications" tyke
brew cask install --appdir="/Applications" spotify
brew cask install --appdir="/Applications" sublime-text
brew cask install --appdir="/Applications" spectacle
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" the-unarchiver
brew cask install --appdir="/Applications" iterm2

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook qlvideo

# Wait a bit before moving on...
sleep 1

# ...and then.
echo "Success! Brew additional applications are installed."