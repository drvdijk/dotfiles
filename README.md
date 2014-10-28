# drvdijk dotfiles

My dotfiles, currently heavily under development (eg bash profile isn't even in here).

## Idea (wip)

On a clean machine (either Mac or Linux), clone this git repo and run setup.sh:

    git clone https://github.com/drvdijk/dotfiles.git ~/.dotfiles
    ~/.dotfiles/setup.sh

This step should not install any software, but just link dotfiles. Afterwards you'd run (eg):

    ~/.dotfiles/bin/dotfiles install osx

(todo here: add the ~/.dotfiles/bin to the path through the bash or zsh profiles)

### dotfiles

In the `bin` directory lives the `dotfiles` script. It basically handles everything, from `bootstrap`-ing the dotfiles to `install ...` the various parts. The `setup.sh` script in the root also simply calls this `dotfiles` script.


## See

* https://github.com/holman/dotfiles
* https://github.com/webpro/dotfiles/blob/master/bin/dotfiles
* https://github.com/atomantic/dotfiles
* https://github.com/ndhoule/dotfiles

## To do

* zsh
* bash profile
* heaps more

