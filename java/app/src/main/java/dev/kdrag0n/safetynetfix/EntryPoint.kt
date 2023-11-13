package dev.kdrag0n.safetynetfix

@Suppress("unused")
object EntryPoint {
    @JvmStatic
    fun init() {
        try {
            logDebug("Entry point: Initializing SafetyNet patches")
            logDebug("SafetyNet patches hooks Security Provider")
            SecurityHooks.init()
            logDebug("SafetyNet patches hooks Build props")
            BuildHooks.init()
        } catch (e: Throwable) {
            // Throwing an exception would require the JNI code to handle exceptions, so just catch
            // everything here.
            logDebug("Error in entry point", e)
        }
    }
}
