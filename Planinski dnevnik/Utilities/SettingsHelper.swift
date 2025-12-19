import Foundation

class SettingsHelper {

    /**
     Registers the default values from Settings.bundle
     */
    static func registerSettingsBundle() {
        if let settingsBundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
           let settings = NSDictionary(contentsOfFile: "\(settingsBundlePath)/Root.plist"),
           let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [NSDictionary] {
            var defaultsToRegister = [String: Any]()
            for preference in preferences {
                if let key = preference.object(forKey: "Key") as? String {
                    defaultsToRegister[key] = preference.object(forKey: "DefaultValue")
                }
            }
            UserDefaults.standard.register(defaults: defaultsToRegister)
        }
    }
    
    static func getBackendUrl() -> String {
        // prioriteta: settings > info.plist (Env.xcconfig)
        let settingsKey = UserDefaults.standard.string(forKey: "backend_url")
        if let key = settingsKey, !key.isEmpty {
            return key
        }
        return Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String ?? "http://127.0.0.1"
    }
}
