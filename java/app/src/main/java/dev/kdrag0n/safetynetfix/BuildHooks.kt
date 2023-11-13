package dev.kdrag0n.safetynetfix

import java.lang.reflect.Field
import android.os.Build

internal object BuildHooks {
    private fun setProp(name: String, value: String) {
        try {
            val f: Field = Build::class.java.getDeclaredField(name)
            f.isAccessible = true
            f.set(null, value)
            f.isAccessible = false
            logDebug("Modified field $name with value $value")
        } catch (e: NoSuchFieldException) {
            logDebug("Couldn't find $name field name.")
        } catch (e: IllegalAccessException) {
            logDebug("Couldn't modify $name field value.")
        }
    }

    fun init() {
        //field.set(null, Build.MODEL)
        // Append a space to the device model name
        //field.set(null, Build.MODEL + " ")
        //field.set(null, "Nexus 6P")
        //field.set(null, "ASUS_AI2201_F")

        //field.set(null, Build.FINGERPRINT)
        //field.set(null, "google/angler/angler:6.0/MDB08L/2343525:user/release-keys")
        //Or dynamic load by props on ROG Phone 6
        //field.set(null, "asus/WW_AI2201/ASUS_AI2201:13/TKQ1.220807.001/33.0610.2810.157-0:user/release-keys")

        val patchedManufacturer = "Asus"
        val patchedBrand       = "Asus"
        val patchedProduct     = /* ro.product.name      */ "WW_Phone"
        val patchedDevice      = /* ro.product.device    */ "ASUS_X00HD_4"
        val patchedModel       = /* ro.product.model     */ "ASUS_X00HD"
        val patchedFingerprint = /* ro.build.fingerprint */ "asus/WW_Phone/ASUS_X00HD_4:7.1.1/NMF26F/14.2016.1801.372-20180119:user/release-keys"

        setProp("MANUFACTURER", patchedManufacturer);
        setProp("BRAND", patchedBrand)
        setProp("PRODUCT", patchedProduct)
        setProp("DEVICE", patchedDevice)
        setProp("MODEL", patchedModel)

        setProp("MANUFACTURER_FOR_ATTESTATION", patchedManufacturer)
        setProp("BRAND_FOR_ATTESTATION", patchedBrand)
        setProp("PRODUCT_FOR_ATTESTATION", patchedProduct)
        setProp("DEVICE_FOR_ATTESTATION", patchedDevice)
        setProp("MODEL_FOR_ATTESTATION", patchedModel)

        setProp("FINGERPRINT", patchedFingerprint)
    }
}
