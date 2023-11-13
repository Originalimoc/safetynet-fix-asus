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

# Remove Play Services from the Magisk Denylist when set to enforcing.
if magisk --denylist status; then
	magisk --denylist rm com.google.android.gms
fi

# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}
LOGFILE=$MODDIR/pfd.log
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
rm -rf $LOGFILE
cat $MODDIR/system.prop.persist > $MODDIR/system.prop
cp -rf $MODDIR/classes.dex /data/adb/modules/SNFix.dex

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

echo "`date`: done" >> $LOGFILE
