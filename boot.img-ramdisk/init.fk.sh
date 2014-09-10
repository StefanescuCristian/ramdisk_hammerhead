#!/system/bin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH

mount -o rw,remount /system

mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak
mv /system/lib/hw/power.msm8974.so /system/lib/hw/power.msm8974.so.bak
mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak

if [ ! -e /system/etc/init.d ]; then
  mkdir /system/etc/init.d
  chown -R root.root /system/etc/init.d
  chmod -R 755 /system/etc/init.d
fi;

mount -o ro,remount /system

echo 0 > /proc/sys/vm/swappiness
echo 50 > /proc/sys/vm/vfs_cache_pressure

echo 0 > /sys/block/mmcblk0/queue/nomerges
echo 2 > /sys/block/mmcblk0/queue/rq_affinity
echo 1 > /proc/sys/vm/laptop_mode

# wait for systemui and increase its priority
while sleep 1; do
  if [ `pidof com.android.systemui` ]; then
    systemui=`pidof com.android.systemui`;
    renice -18 $systemui;
    echo -17 > /proc/$systemui/oom_adj;
    chmod 100 /proc/$systemui/oom_adj;
    exit;
  fi;
done&

# lmk whitelist for common launchers and increase launcher priority
list="com.android.launcher com.google.android.googlequicksearchbox org.adw.launcher org.adwfreak.launcher net.alamoapps.launcher com.anddoes.launcher com.android.lmt com.chrislacy.actionlauncher.pro com.cyanogenmod.trebuchet com.gau.go.launcherex com.gtp.nextlauncher com.miui.mihome2 com.mobint.hololauncher com.mobint.hololauncher.hd com.qihoo360.launcher com.teslacoilsw.launcher com.tsf.shell org.zeam com.kk.launcher";
while sleep 60; do
  for class in $list; do
    if [ `pgrep $class | head -n 1` ]; then
      launcher=`pgrep $class`;
      echo -17 > /proc/$launcher/oom_adj;
      chmod 100 /proc/$launcher/oom_adj;
      renice -18 $launcher;
    fi;
  done;
  exit;
done&
