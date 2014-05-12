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
