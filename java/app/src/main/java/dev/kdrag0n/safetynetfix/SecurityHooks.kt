package dev.kdrag0n.safetynetfix

import dev.kdrag0n.safetynetfix.proxy.ProxyKeyStoreSpi
import dev.kdrag0n.safetynetfix.proxy.ProxyProvider
import java.lang.reflect.Field
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.KeyStoreSpi
import java.security.Security

internal object SecurityHooks {
    const val PROVIDER_NAME = "AndroidKeyStore"

    fun init() {
        logDebug("Initializing SecurityBridge")

        try {
            val realProvider = Security.getProvider(PROVIDER_NAME)
            val realKeystore = KeyStore.getInstance(PROVIDER_NAME)
            val realSpi = realKeystore.get<KeyStoreSpi>("keyStoreSpi")
            logDebug("Real provider=$realProvider, keystore=$realKeystore, spi=$realSpi")

            val provider = ProxyProvider(realProvider)
            logDebug("Removing real provider")
            Security.removeProvider(PROVIDER_NAME)
            logDebug("Inserting provider $provider")
            Security.insertProviderAt(provider, 1)
            ProxyKeyStoreSpi.androidImpl = realSpi
            logDebug("Security hooks installed")
        } catch (e: KeyStoreException) {
            logDebug("Couldn't find KeyStore: " + e)
        } catch (e: NoSuchFieldException) {
            logDebug("Couldn't find field: " + e)
        } catch (e: IllegalAccessException) {
            logDebug("Couldn't change access of field: " + e)
        }
    }
}
