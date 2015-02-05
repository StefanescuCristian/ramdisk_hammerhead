#!/system/bin/sh
echo MAIGODE ITS RUNNING #that's what she said
echo script_open >> /data/fk-log.txt
mount -o rw,remount /system && echo remount >> /data/fk-log.txt
#mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak
#mv /system/lib/hw/power.msm8974.so /system/lib/hw/power.msm8974.so.bak
#mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak
#echo finished_mv >> /data/fk-log.txt
if [ ! -e /system/etc/init.d ]; then
mkdir /system/etc/init.d
chown -R root.root /system/etc/init.d
chmod -R 755 /system/etc/init.d
fi;
mount -o ro,remount /system && echo remount_ro >> /data/fk-log.txt

#enable ksm
echo 1 > /sys/kernel/mm/ksm/deferred_timer
echo 1 > /sys/kernel/mm/ksm/run
echo 256 > /sys/kernel/mm/ksm/pages_to_scan
echo 2000 > /sys/kernel/mm/ksm/sleep_millisecs

#io tuning
echo 0 > /sys/block/mmcblk0/queue/nomerges
echo 2 > /sys/block/mmcblk0/queue/rq_affinity
echo 1 > /proc/sys/vm/laptop_mode

#gpu tune
echo "simple" > /sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor

#others
echo 2 > /sys/devices/system/cpu/sched_mc_power_savings
echo "1536,2048,4096,16384,28672,32768" > /sys/module/lowmemorykiller/parameters/minfree
while sleep 0.01; do
  if [ -e /dev/socket/pb ]; then
	chmod 000 /dev/socket/pb
    exit;
  fi;
done&
echo 1 > /sys/module/workqueue/parameters/power_efficient
echo 1 > /sys/kernel/sched/arch_power
