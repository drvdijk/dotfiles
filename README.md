# drvdijk dotfiles

My dotfiles, currently heavily under development (eg bash profile isn't even in here).

## Idea (wip)

On a clean machine (either Mac or Linux), clone this git repo:

    git clone --recursive https://github.com/drvdijk/dotfiles.git ~/.dotfiles
    
 And run setup.sh
 
    ~/.dotfiles/setup.sh

This step should not install any software, but just link dotfiles. Afterwards you'd run (eg):

    ~/.dotfiles/bin/dotfiles install osx

Or just install parts, eg:

    ~/.dotfiles/bin/dotfiles install osx-defaults
    ~/.dotfiles/bin/dotfiles install brew
    ~/.dotfiles/bin/dotfiles install cask
    ~/.dotfiles/bin/dotfiles install mackup
    ~/.dotfiles/bin/dotfiles install private

(todo here: add the ~/.dotfiles/bin to the path through the bash or zsh profiles)

### dotfiles

In the `bin` directory lives the `dotfiles` script. It basically handles everything, from `bootstrap`-ing the dotfiles to `install ...` the various parts. The `setup.sh` script in the root also simply calls this `dotfiles` script.

## ZSH

Adding zsh to the list of shells:

    echo $(which zsh) | sudo tee -a /etc/shells

Setting the shell to zsh for the current user:

    chsh -s `which zsh`

## See

* https://github.com/holman/dotfiles
* https://github.com/webpro/dotfiles/blob/master/bin/dotfiles
* https://github.com/atomantic/dotfiles
* https://github.com/ndhoule/dotfiles

## To do

* zsh
* bash profile
* heaps more

