# crumpet: Chromium OS Chroot Environment for Linux (crouton in reverse)
crumpet is a set of scripts that bundle up into an not-so-easy to use, linux-centric chroot environment that packages a working version of the chromiumos ui

Similarly to crouton, you can install it and switch between the chromiumos UI and the normal linux desktop environment at the press of a button, and enter a chroot terminal inside both

### "crumpet"... an acronym?
It stands for.... yeah not even gonna try

### Who's this for?
Genuinely, I have no idea! Perhaps you've grown tired of the freedom and ease of use of linux and want a worse operating system.
Perhaps you want to do development for chromeOS tools and for some reason don't want to use a vm or a real machine.
Maybe you just want to fuck around and have fun. Either way, crumpet is for you!

## Usage
crumpet is not a very powerful tool, and there are not a lot of features, but basic usage is somewhat complicated and annoying by ~~design~~ laziness


First, install it obviously
```
git clone https://github.com/CoolElectronics/crumpet
cd crumpet
sudo ./crumpet install
```

Here's all the commands:
```
Usage: sudo ./crumpet [command]

activate - activates the environment. usually you want to run this before you run some of the other commands
startui - launches and switches to the chromiumos UI
enter-chroot - gives you a shell inside the chroot
inside - runs a single command inside the chroot (as root)
inside_chronos - runs a single command inside the chroot (as chronos)
```



### Tips
Once the UI is launched, you can switch between your normal desktop and chromiumos with CTRL+ALT+1-9

If this accidentally breaks your DE, sorry about that, `rm ~/.Xauthority` should fix it

If this accidentally breaks your terminal, sorry about that, `sudo mount -t devpts devpts /dev/pts` or rebooting should fix it

### How does it work?
I shouldn't need to explain the chroot part, it's just a standard chromiumos devimage build.
The UI itself is built from ash-on-linux. DRI ended up being difficult inside a chroot so I fell back to a boring xorg kiosk for containing the UI. (see scripts/kiosk.sh)


### Why does this download a random tarball from a sketchy site? I want to build it myself!
see [[HACKING.md]] at your own risk
