import ProjectDescription

// MARK: - Project

let project = tuistProject()

func tuistProject() -> Project {

	let appName = "universitytest"
	let bundleID = "com.abdullah.universitytest"
	let osVersion = "18.0"

	let destinations: ProjectDescription.Destinations = [
		.iPhone,
		.iPad,
		.macWithiPadDesign,
		.appleVisionWithiPadDesign,
	]

	var projectTargets: [Target] = []
	var projectPackages: [Package] = []
	var appDependencies: [TargetDependency] = []
	var appResources: [ResourceFileElement] = ["Targets/App/Resources/**"]
	var appEntitlements: [String: Plist.Value] = [:]
	var appInfoPlist: [String: Plist.Value] = [
		"CFBundleShortVersionString": "$(MARKETING_VERSION)",
		"CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
		"NSFaceIDUsageDescription": "We will use FaceID to authenticate you",
		"NSCameraUsageDescription": "We need Camera Access for the App to work.",
		"NSLocationAlwaysAndWhenInUseUsageDescription": "We need Location Access for the App to work.",
		"NSLocationWhenInUseUsageDescription": "We need Location Access for the App to work.",
		"NSContactsUsageDescription": "We need Contacts Access for the App to work.",
		"NSMicrophoneUsageDescription": "We need Microhone Access for the App to work.",
		"NSCalendarsFullAccessUsageDescription": "We need Calendar Access for the App to work.",
		"NSRemindersFullAccessUsageDescription": "We need Reminders Access for the App to work.",
		"NSPhotoLibraryUsageDescription": "We need Photo Library Access for the App to work.",
		"UILaunchStoryboardName": "LaunchScreen",
		"UISupportedInterfaceOrientations": .array(["UIInterfaceOrientationPortrait"]),  //Only Support Portrait on iphone
		"GADApplicationIdentifier": "ENTER_GOOGLE_AD_APP_IDENTIFIER",
		"GADNativeAdValidatorEnabled": "NO",
		"SKAdNetworkItems": .array([
			.dictionary(["SKAdNetworkIdentifier": "cstr6suwn9.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "4fzdc2evr5.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "2fnua5tdw4.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "ydx93a7ass.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "p78axxw29g.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "v72qych5uu.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "ludvb6z3bs.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "cp8zw746q7.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "3sh42y64q3.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "c6k4g5qg8m.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "s39g8k73mm.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "3qy4746246.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "hs6bdukanm.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "mlmmfzh3r3.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "v4nxqhlyqp.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "wzmmz9fp6w.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "su67r6k2v3.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "yclnxrl5pm.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "7ug5zh24hu.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "gta9lk7p23.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "vutu7akeur.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "y5ghdn5j9k.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "v9wttpbfk9.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "n38lu8286q.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "47vhws6wlr.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "kbd757ywx3.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "9t245vhmpl.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "a2p9lx4jpn.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "22mmun2rn5.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "4468km3ulz.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "2u9pt9hc89.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "8s468mfl3y.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "ppxm28t8ap.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "uw77j35x4d.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "pwa73g5rt2.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "578prtvx9j.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "4dzt52r2t5.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "tl55sbb4fm.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "e5fvkxwrpn.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "8c4e2ghe7u.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "3rd42ekr43.skadnetwork"]),
			.dictionary(["SKAdNetworkIdentifier": "3qcr597p9d.skadnetwork"]),
		]),
	]

	let sharedKit = TargetDependency.target(name: "SharedKit")
	let analyticsKit = TargetDependency.target(name: "AnalyticsKit")

	addSharedKit()
	addAnalyticsKit()
	addNotifKit()
	let iapKit = addInAppPurchaseKit()
	let firebaseKit = addFirebaseKit()
	addAIKit()
	addAdsKit()

	addApp()

	return Project(
		name: appName,
		options: .options(
			disableSynthesizedResourceAccessors: true,
			textSettings: .textSettings(
				usesTabs: false,
				indentWidth: 4,
				tabWidth: 4,
				wrapsLines: true
			)
		),
		packages: projectPackages,
		settings: .settings(base: [
			"ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES": "AppIcon-Alt-1 AppIcon-Alt-2",
			"ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS": "YES",
			"MARKETING_VERSION": "1.0.0",
			"CURRENT_PROJECT_VERSION": "1",
		]),
		targets: projectTargets
	)

	func addApp() {
		let mainTarget: Target = .target(
			name: appName,
			destinations: destinations,
			product: .app,
			bundleId: bundleID,
			deploymentTargets: .iOS(osVersion),
			infoPlist: .extendingDefault(with: appInfoPlist),
			sources: ["Targets/App/Sources/**"],
			resources: .resources(appResources),
			entitlements: .dictionary(appEntitlements),
			scripts: [
				.post(
					script:
						"\"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run\"",
					name: "Connect Crashlytics Script (Generated by SwiftyLaunch)",
					inputPaths: [
						.glob("${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"),
						.glob(
							"${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF,{PRODUCT_NAME}"
						),
						.glob("${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"),
						.glob(
							"$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-In,.plist"
						),
						.glob("$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"),
					],
					runForInstallBuildsOnly: true,
					shellPath: "/bin/sh"
				)
			],
			dependencies: appDependencies,
			settings: .settings(base: [
				"OTHER_LDFLAGS": "-ObjC",
				"ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"

					, "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
			])
		)

		projectTargets.append(mainTarget)
	}

	// Code Shared Across all targets
	func addSharedKit() {
		let targetName = "SharedKit"
		let sharedTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: ["Targets/\(targetName)/Resources/**"],
			dependencies: []
		)

		appDependencies.append(sharedKit)
		projectTargets.append(sharedTarget)
	}

	// FirebaseAuth + FirebaseDB
	func addFirebaseKit() -> TargetDependency {
		let targetName = "FirebaseKit"
		let firebaseTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: [],
			dependencies: [
				TargetDependency.package(product: "FirebaseAuth", type: .runtime),
				TargetDependency.package(product: "FirebaseFirestore", type: .runtime),
				TargetDependency.package(product: "FirebaseFunctions", type: .runtime),
				analyticsKit,
				TargetDependency.package(product: "FirebaseCrashlytics", type: .runtime),
				sharedKit,
			]
		)
		let targetDependency = TargetDependency.target(name: targetName)
		appDependencies.append(targetDependency)
		appResources.append("Targets/\(targetName)/Config/GoogleService-Info.plist")
		appEntitlements["com.apple.developer.applesignin"] = .array(["Default"])  // Sign in with Apple Capability
		projectPackages
			.append(
				.remote(
					url: "https://github.com/firebase/firebase-ios-sdk",
					requirement: .upToNextMajor(from: "11.4.0")
				)
			)
		projectTargets.append(firebaseTarget)
		return targetDependency
	}

	func addInAppPurchaseKit() -> TargetDependency {
		let targetName = "InAppPurchaseKit"
		let iapTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: ["Targets/\(targetName)/Resources/**"],
			dependencies: [
				sharedKit,
				analyticsKit,
				TargetDependency.package(product: "RevenueCat", type: .runtime),
				TargetDependency.package(product: "RevenueCatUI", type: .runtime),
			]
		)
		let targetDependency = TargetDependency.target(name: targetName)
		appDependencies.append(targetDependency)
		appDependencies.append(TargetDependency.sdk(name: "StoreKit", type: .framework, status: .required))  //In-App Purchase Capability
		projectPackages
			.append(
				.remote(
					url: "https://github.com/RevenueCat/purchases-ios.git",
					requirement: .upToNextMajor(from: "5.8.0")
				)
			)
		projectTargets.append(iapTarget)
		appResources.append("Targets/\(targetName)/Config/RevenueCat-Info.plist")
		return targetDependency
	}
	func addAnalyticsKit() {
		let targetName = "AnalyticsKit"
		let analyticsTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: [],
			dependencies: [
				sharedKit,
				TargetDependency.package(product: "PostHog", type: .runtime),
			]
		)
		appDependencies.append(TargetDependency.target(name: targetName))
		projectPackages
			.append(
				.remote(
					url: "https://github.com/PostHog/posthog-ios.git",
					requirement: .upToNextMajor(from: "3.12.4")
				)
			)
		projectTargets.append(analyticsTarget)
		appResources.append("Targets/\(targetName)/Config/PostHog-Info.plist")
	}
	func addNotifKit() {
		let notifTargetName = "NotifKit"
		let notifTarget: Target = .target(
			name: notifTargetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(notifTargetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(notifTargetName)/Sources/**"],
			resources: [],
			dependencies: [
				sharedKit,
				TargetDependency.package(product: "OneSignalFramework", type: .runtime),
				analyticsKit,
			])

		appDependencies.append(TargetDependency.target(name: notifTargetName))

		// Also have to include that, otherwise the app crashes
		appDependencies.append(TargetDependency.package(product: "OneSignalFramework", type: .runtime))
		appResources.append("Targets/\(notifTargetName)/Config/OneSignal-Info.plist")

		appInfoPlist["UIBackgroundModes"] = .array(["remote-notification"])

		projectPackages.append(
			.remote(
				url: "https://github.com/OneSignal/OneSignal-iOS-SDK.git",
				requirement: .upToNextMajor(from: "5.2.7")
			)
		)
		projectTargets.append(notifTarget)
		let notifExtensionTargetName = "OneSignalNotificationServiceExtension"
		let notifExtensionTarget: Target = .target(
			name: notifExtensionTargetName,
			destinations: .iOS,
			product: .appExtension,
			bundleId: "\(bundleID).\(notifExtensionTargetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .dictionary([
				"NSExtension": [
					"NSExtensionPointIdentifier": "com.apple.usernotifications.service",
					"NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
				]
			]),
			sources: ["Targets/\(notifTargetName)/\(notifExtensionTargetName)/**"],
			entitlements:
				Entitlements
				.dictionary(
					[
						"com.apple.security.application-groups": .array(["group.\(bundleID).onesignal"])
					]
				),
			dependencies: [TargetDependency.package(product: "OneSignalExtension", type: .runtime)]
		)
		appEntitlements["aps-environment"] = .string("development")
		appEntitlements["com.apple.security.application-groups"] = .array(["group.\(bundleID).onesignal"])
		projectTargets.append(notifExtensionTarget)
	}

	// AIKit (Requires FirebaseKit and BackendKit)
	func addAIKit() {
		let targetName = "AIKit"
		let aiTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: ["Targets/\(targetName)/Resources/**"],
			dependencies: [
				sharedKit,
				firebaseKit,
				TargetDependency.package(product: "SwiftWhisper", type: .runtime),
				TargetDependency.package(product: "AudioKit", type: .runtime),
				analyticsKit,
			]
		)

		let targetDependency = TargetDependency.target(name: targetName)
		appDependencies.append(targetDependency)
		projectPackages
			.append(
				.remote(
					url: "https://github.com/exPHAT/SwiftWhisper.git",
					requirement: .upToNextMajor(from: "1.2.0")
				)
			)
		projectPackages
			.append(
				.remote(
					url: "https://github.com/AudioKit/AudioKit.git",
					requirement: .upToNextMajor(from: "5.6.2")
				)
			)
		projectTargets.append(aiTarget)
	}

	// Google AdMob (Requires FirebaseKit)
	func addAdsKit() {
		let targetName = "AdsKit"
		let adsKitTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			dependencies: [
				firebaseKit,
				TargetDependency.package(product: "GoogleMobileAds", type: .runtime),
				iapKit,
				analyticsKit,
				sharedKit,
			]
		)
		appDependencies.append(TargetDependency.target(name: targetName))
		projectPackages
			.append(
				.remote(
					url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
					requirement: .upToNextMajor(from: "11.12.0")
				)
			)
		projectTargets.append(adsKitTarget)
	}

}