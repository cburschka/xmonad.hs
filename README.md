xmonad.hs
=========

My xmonad configuration file.

xmobar
------

The volume indicator on xmobar requires the ALSA library:

```
$ cabal install alsa-core alsa-mixer
$ cabal install xmobar --flags="with_alsa"
```

The file `xmobarrc` must be symbolically linked from ~/.xmobarrc to be used.

ifnotrunning
------------

This is a small shell script that makes the launchers more convenient. It
checks for an existing process containing the name of the command, and only
runs the command if nothing is found.

**This is very unreliable, and will fail often and in interesting ways.**

You should link or move the `ifnotrunning.sh` file to `ifnotrunning` somewhere in
your `$PATH`.
