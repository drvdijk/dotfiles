# drvdijk dotfiles

My dotfiles, probably never finished and ever changing

## Idea

On a clean machine (either Mac or Linux), clone this git repo:

    git clone https://github.com/drvdijk/dotfiles.git ~/.dotfiles

And run setup.sh (this step does not install any software, but just links dotfiles from the repo into the home dir):

    ~/.dotfiles/setup.sh

Afterwards you can run various install scripts:

    ~/.dotfiles/bin/dotfiles install macos
    ~/.dotfiles/bin/dotfiles install homebrew
    ~/.dotfiles/bin/dotfiles install development

### dotfiles

In the `bin` directory lives the `dotfiles` script. It basically handles everything, from `bootstrap`-ing the dotfiles to `install ...` the various parts. The `setup.sh` script in the root also simply calls this `dotfiles` script.

## ZSH

Adding zsh to the list of shells (note this is done in the homebrew install script already):

    echo $(which zsh) | sudo tee -a /etc/shells

Setting the shell to zsh for the current user:

    chsh -s `which zsh`

## See

* https://github.com/holman/dotfiles
* https://github.com/webpro/dotfiles/blob/master/bin/dotfiles
* https://github.com/atomantic/dotfiles
* https://github.com/ndhoule/dotfiles
* https://github.com/joeyhoer/starter

## To do

* zsh
* bash profile
* heaps more
* add the `~/.dotfiles/bin` to the path through the bash or zsh profiles
* install all in one go (scan folders for install.sh scripts)
