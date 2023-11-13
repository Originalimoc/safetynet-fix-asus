#!/system/bin/sh
modelprops="ro.product.model
ro.product.bootimage.model
ro.product.odm.model
ro.product.product.model
ro.product.system.model
ro.product.system_ext.model
ro.product.vendor.model
ro.product.vendor_dlkm.model"
for propname in $modelprops
do
    resetprop $propname "ASUS_AI2201_F"
    resetprop -n $propname "ASUS_AI2201_F"
    resetprop -p $propname "ASUS_AI2201_F"
    resetprop -n $propname "ASUS_AI2201_F"
    resetprop $propname "ASUS_AI2201_F"
done
# Sensitive properties

maybe_set_prop() {
    local prop="$1"
    local contains="$2"
    local value="$3"

    if [[ "$(getprop "$prop")" == *"$contains"* ]]; then
        resetprop "$prop" "$value"
    fi
}

# Magisk recovery mode
maybe_set_prop ro.bootmode recovery unknown
maybe_set_prop ro.boot.mode recovery unknown
maybe_set_prop vendor.boot.mode recovery unknown

# Hiding SELinux | Permissive status
resetprop --delete ro.build.selinux

# Hiding SELinux | Use toybox to protect *stat* access time reading
if [[ "$(toybox cat /sys/fs/selinux/enforce)" == "0" ]]; then
    chmod 640 /sys/fs/selinux/enforce
    chmod 440 /sys/fs/selinux/policy
fi

# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}
LOGFILE=$MODDIR/s.log
# This script will be executed in late_start service mode
# More info in the main Magisk thread
rm -rf $LOGFILE



CNPROPLISTR="`getprop | grep CN | grep -Fe "[CN]" -e "CN_AI2201" -e "release-keys"`"
CNPROPLISTFiltered="`echo "$CNPROPLISTR" | grep -ve vendor.asus.operator.iso-country -e persist.vendor.asus.ship_location -e persist.vendor.fota | awk -F '[' '{print $2}' | awk -F ']' '{print $1}'`"

for CP in $CNPROPLISTFiltered
do
  OG="`getprop $CP`"
  TG="`echo "$OG" | sed 's/CN/WW/g'`"
  echo "$CP changed from \"$OG\" to \"$TG\"" >>$LOGFILE
  resetprop $CP "$TG" 2>&1 >>$LOGFILE
  echo "$CP=$TG" >> $MODDIR/system.prop
done

sh $MODDIR/alter-model.sh $MODDIR $LOGFILE

resetprop ro.boot.image.valid "Y"
resetprop vendor.asus.image.valid "Y"
setprop ro.boot.image.valid "Y"
setprop vendor.asus.image.valid "Y"

# Late props which must be set after boot_completed
{
    until [[ "$(getprop sys.boot_completed)" == "1" ]]; do
        sleep 1
    done

    # SafetyNet/Play Integrity | Avoid breaking Realme fingerprint scanners
    resetprop ro.boot.flash.locked 1

    # SafetyNet/Play Integrity | Avoid breaking Oppo fingerprint scanners
    resetprop ro.boot.vbmeta.device_state locked

    # SafetyNet/Play Integrity | Avoid breaking OnePlus display modes/fingerprint scanners
    resetprop vendor.boot.verifiedbootstate green

    # SafetyNet/Play Integrity | Avoid breaking OnePlus display modes/fingerprint scanners on OOS 12
    resetprop ro.boot.verifiedbootstate green
    resetprop ro.boot.veritymode enforcing
    resetprop vendor.boot.vbmeta.device_state locked
}&

echo "`date`: done" >> $LOGFILE
