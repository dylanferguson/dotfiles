# !/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

terminal-notifier -message 'Running daily update...'
echo 'Updating Brew...'
brew update
brew upgrade
brew cleanup -s
brew doctor
brew missing

brew bundle dump --force
if [[ $(git diff --stat Brewfile) != '' ]]; then
  echo 'Updating Brewfile...'
  git add Brewfile
  git commit -m 'auto update Brewfile'
  git push
  echo 'Pushed'
fi

echo 'MAS update...'
mas outdated
mas upgrade

echo 'Updating NPM global packages...'
npm update -g 
