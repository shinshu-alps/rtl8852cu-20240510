## rtl8852cu-20240510

### Testers: Check in with Issue 2.

### Installation and Uninstallation (for now)

Remove conflicting existing driver.

```
Install:
$ make clean
$ make
$ sudo make install
$ make clean
$ sudo reboot

Uninstall:
$ sudo make uninstall
$ sudo reboot
```
