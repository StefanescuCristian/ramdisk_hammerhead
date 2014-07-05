#!/system/bin/sh

# disable sysctl.conf to prevent ROM interference with tunables
# backup and replace PowerHAL with custom build to allow OC/UC to survive screen off
# create and set permissions for /system/etc/init.d if it doesn't already exist
mount -o rw,remount /system /system;
[ -e /system/etc/sysctl.conf ] && mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak;
[ -f /system/lib/hw/power.msm8974.so.bak ] || mv /system/lib/hw/power.msm8974.so /system/lib/hw/power.msm8974.so.bak
[ -f /system/bin/thermal-engine-hh-bak ] || mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak

if [ ! -e /system/etc/init.d ]; then
  mkdir /system/etc/init.d
  chown -R root.root /system/etc/init.d;
  chmod -R 755 /system/etc/init.d;
fi;
mount -o ro,remount /system /system;

echo 85 1500000:90 1800000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads
echo 20000 1400000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
echo 40000 1700000:80000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
echo 60000 500000:40000 1500000:30000 2000000:20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
echo -1 800000:30000 1100000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_slack
echo 0 > /proc/sys/vm/swappiness
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/up_threshold_any_cpu_freq
echo 1 > /sys/kernel/mm/ksm/run
echo 1 > /sys/kernel/mm/ksm/deferred_timer


# wait for systemui and increase its priority
while sleep 1; do
  if [ `$bb pidof com.android.systemui` ]; then
    systemui=`$bb pidof com.android.systemui`;
    $bb renice -18 $systemui;
    $bb echo -17 > /proc/$systemui/oom_adj;
    $bb chmod 100 /proc/$systemui/oom_adj;
    exit;
  fi;
done&

# lmk whitelist for common launchers and increase launcher priority
list="com.android.launcher com.google.android.googlequicksearchbox org.adw.launcher org.adwfreak.launcher net.alamoapps.launcher com.anddoes.launcher com.android.lmt com.chrislacy.actionlauncher.pro com.cyanogenmod.trebuchet com.gau.go.launcherex com.gtp.nextlauncher com.miui.mihome2 com.mobint.hololauncher com.mobint.hololauncher.hd com.qihoo360.launcher com.teslacoilsw.launcher com.tsf.shell org.zeam com.kk.launcher";
while sleep 60; do
  for class in $list; do
    if [ `$bb pgrep $class | head -n 1` ]; then
      launcher=`$bb pgrep $class`;
      $bb echo -17 > /proc/$launcher/oom_adj;
      $bb chmod 100 /proc/$launcher/oom_adj;
      $bb renice -18 $launcher;
    fi;
  done;
  exit;
done&
