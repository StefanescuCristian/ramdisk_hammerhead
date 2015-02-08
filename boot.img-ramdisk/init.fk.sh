#!/system/bin/sh
toolbox mount -o rw,remount /system

if [ ! -e /system/etc/init.d ]; then
toolbox mkdir /system/etc/init.d
toolbox chown -R root.root /system/etc/init.d
toolbox chmod -R 755 /system/etc/init.d
fi;

toolbox chmod 0100 /system/bin/thermal-engine-hh

toolbox mount -o ro,remount /system
