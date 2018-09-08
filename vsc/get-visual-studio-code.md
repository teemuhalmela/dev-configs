Get no telemetry version of vsc from https://github.com/VSCodium/vscodium

TODO: Script for installing / updating this thing.

Then install it

```
sudo dpkg -i code-oss_1.27.1-1536250379_amd64.deb
```

It it complains about dependencies do this (after dpkg -i)

```
sudo apt-get -f install
```

And run `dpkg -i` again.
