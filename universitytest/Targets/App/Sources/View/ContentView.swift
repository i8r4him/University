//
//  ContentView.swift
//  App (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/app
//

import AIKit
import AdsKit
import FirebaseKit
import InAppPurchaseKit
import NotifKit
import SharedKit
import SwiftUI

struct ContentView: View {

	var body: some View {
		TabView {

			// View with AIKit Examples.
			Tab("AIKit Examples", systemImage: "sparkles.rectangle.stack") {
				AIKitExamplesView()
			}

			// View with AdsKit Examples.
			Tab("AdsKit Examples", systemImage: "rectangle.3.group.fill") {
				AdsKitExamples()
			}

			// Example view on how to access the Database.
			Tab("DB Examples", systemImage: "externaldrive.badge.icloud") {
				DatabaseExampleView()
			}

			// Pre-made Settings View for easy native-looking settings screen.
			Tab("Settings", systemImage: "gear") {
				SettingsView()
			}

			#if DEBUG

				TabSection("DEBUG ONLY") {
					// Use this to create quick settings and toggles to streamline the development process
					Tab("Developer", systemImage: "hammer") {
						DeveloperSettingsView()
					}
				}

			#endif
		}

		.tabViewStyle(.sidebarAdaptable)
		.tabViewSidebarHeader {
			Text("SwiftyLaunch App")
				.font(.title)
				.bold()
				.frame(maxWidth: .infinity, alignment: .leading)

		}

	}
}

#Preview {
	ContentView()
		.environmentObject(DB())
		.environmentObject(InAppPurchases())
}