//
//  UserDefaults+Extensions.swift
//  SharedKit (Generated by SwiftyLaunch 1.5.0)
//

import Foundation

/// Call this function to reset all userDefaults
/// Currently only used in DeveloperSettingsView
extension UserDefaults {
	public func clear() {
		guard let domainName = Bundle.main.bundleIdentifier else {
			return
		}
		removePersistentDomain(forName: domainName)
		synchronize()
		print("[LOCALSTORAGE] CLEARED USERDEFAULTS")
	}
}