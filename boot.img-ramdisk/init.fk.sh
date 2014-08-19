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

echo 85 1500000:90 1800000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads
echo 20000 1400000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
echo 40000 1700000:80000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
echo 60000 500000:40000 1500000:30000 2000000:20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
echo -1 800000:30000 1100000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_slack
echo 0 > /proc/sys/vm/swappiness
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/up_threshold_any_cpu_freq

#these get overwritten by CM's KSM settings, so let's wait 1 minute before we apply them 
sleep 60
echo 1 > /sys/kernel/mm/ksm/run
echo 1 > /sys/kernel/mm/ksm/deferred_timer
echo 512 > /sys/kernel/mm/ksm/pages_to_scan
echo 2000 > /sys/kernel/mm/ksm/sleep_millisecs

# activate msm_limiter. If the limiter isn't enabled in config, echo will fail, but we're safe
echo 1 > /sys/kernel/msm_limiter/limiter_enabled

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
