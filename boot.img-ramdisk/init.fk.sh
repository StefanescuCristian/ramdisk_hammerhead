#!/system/bin/sh
echo MAIGODE ITS RUNNING
echo script_open >> /data/fk-log.txt
mount -o rw,remount /system
echo remount >> /data/fk-log.txt
mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak
mv /system/lib/hw/power.msm8974.so /system/lib/hw/power.msm8974.so.bak
mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak
echo finished_mv >> /data/fk-log.txt
if [ ! -e /system/etc/init.d ]; then
mkdir /system/etc/init.d
chown -R root.root /system/etc/init.d
chmod -R 755 /system/etc/init.d
fi;

mount -o ro,remount /system
echo remount_ro >> /data/fk-log.txt
