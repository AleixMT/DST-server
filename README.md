# DST-server
Download, configure and install a dstserver with mods and caves with a single script.

### Usage
First execute the config script as root, in order to install dependencies and create the `dstserver` user, which will requiere additional information.
```
sudo ./config.sh
```
Run the script again, now being logged as the `dstserver` user:
```
./config.sh
```

To autostart the server on system boot there are many alternatives available, but
we will use crontab with `@reboot` annotation. If you are using other distro than Ubuntu this method may not be available, but there are many others available out there, such as `rc.local`, `systemd` or `init.d`. Open crontab of dstserver user by typing:
```
crontab -e
```
This will edit the cron file for the user that has thrown this command, which is dstserver user.
Add the following to the file:
```
@reboot /home/dstserver/dstserver start
@reboot /home/dstserver/dstserver-2 start
```

Enjoy!
