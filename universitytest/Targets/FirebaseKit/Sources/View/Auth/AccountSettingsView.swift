//
//  AccountSettingsView.swift
//  FirebaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit/account-settings
//

import AnalyticsKit
import AuthenticationServices
import PhotosUI
import SharedKit
import SwiftUI

private enum ActiveSlideOverCard: Identifiable {
	case reauthPasswordChange
	case newPassword
	case reauthAccountDeletion

	var id: Self {
		return self
	}
}

public struct AccountSettingsView: View {

	@EnvironmentObject var db: DB
	@State private var showSignoutDialog = false
	@State private var showAccountDeleteDialog = false

	// Account Customization
	@State private var showNewNameAlert = false
	@State private var newName = ""
	@State private var newProfileImageSelection: PhotosPickerItem? = nil

	// Shows up when user does a sensitive action but doesnt know the password and pressed on "forgot password"
	@State private var showForgotPasswordSheet = false

	@State private var shownSlideOverCard: ActiveSlideOverCard? = nil

	private let popBackToSettings: () -> Void

	public init(popBackToRoot: @escaping () -> Void) {
		self.popBackToSettings = popBackToRoot
	}

	public var body: some View {
		List {
			VStack(alignment: .center, spacing: 0) {

				ProfileImage(url: db.currentUser?.photoURL, width: 100)
					.padding(.bottom, 10)

				Text(db.currentUser?.displayName ?? "USER NAME")
					.font(.title)
					.fontWeight(.semibold)
					.lineLimit(1)

				Text(db.currentUser?.email ?? "USER EMAIL")
					.font(.callout)
					.foregroundStyle(.secondary)
					.lineLimit(1)
					.textSelection(.enabled)  // allows the user to hold to copy
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(Color(UIColor.systemGroupedBackground))

			Section {

				Button("Change Name") {
					Analytics.captureTap("change_name_btn", fromView: "AccountSettingsView")
					showNewNameAlert = true
				}
				.alert("Enter your new account name", isPresented: $showNewNameAlert) {
					TextField("\(db.currentUser?.displayName ?? "USERNAME")", text: $newName)

					Button("OK") {
						Analytics.captureTap("ok_btn", fromView: "AccountSettingsView (New Name Alert)")
						if newName != db.currentUser?.displayName && !newName.isEmpty {
							Task {
								await tryFunctionOtherwiseShowInAppNotification(
									fallbackNotificationContent: .init(
										title: "Couldn't Rename Account",
										message: "Try Again Later")
								) {
									try await db.newDisplayName(newName)
									showInAppNotification(
										.success,
										content: .init(
											title: "Success",
											message: "Account Name Updated"),
										size: .compact)
								}
							}
						}
					}

					Button("Cancel", role: .cancel) {
						Analytics.captureTap(
							"cancel_btn", fromView: "AccountSettingsView (New Name Alert)")
						showNewNameAlert = false
						newName = ""
					}
					.buttonStyle(.borderless)
				}

				PhotosPicker(
					selection: $newProfileImageSelection,
					matching: .images,
					preferredItemEncoding: .compatible,
					photoLibrary: .shared()
				) {
					Text("Change Profile Picture")
				}
				.onChange(of: newProfileImageSelection) {
					if newProfileImageSelection != nil {
						print("Got new img")
					} else {
						print("Nope")
					}
				}

				if db.currentUserProvider == .email {
					Button("Change Password") {
						Analytics.captureTap("change_password_btn", fromView: "AccountSettingsView")
						shownSlideOverCard = .reauthPasswordChange
					}
				}

				Button("Delete Account", role: .destructive) {
					Analytics.captureTap(
						"delete_account_btn", fromView: "AccountSettingsView", relevancy: .high)
					showAccountDeleteDialog = true
				}
				.confirmationDialog(
					"Are you sure you want to delete your Account?", isPresented: $showAccountDeleteDialog
				) {
					Button("Confirm Account Deletion", role: .destructive) {
						Analytics.captureTap(
							"confirm_delete_account_btn",
							fromView: "AccountSettingsView (Delete Account Dialog)", relevancy: .high)
						shownSlideOverCard = .reauthAccountDeletion
					}
				}

				Button("Sign Out", role: .destructive) {
					Analytics.captureTap("signout_btn", fromView: "AccountSettingsView")
					showSignoutDialog = true
				}
				.confirmationDialog("Are you sure you want to sign out?", isPresented: $showSignoutDialog) {
					Button("Confirm Sign Out", role: .destructive) {
						Analytics.captureTap(
							"confirm_signout_btn", fromView: "AccountSettingsView (Sign Out Dialog)",
							relevancy: .medium)

						tryFunctionOtherwiseShowInAppNotification(
							fallbackNotificationContent:
								.init(
									title: "Sign Out Error",
									message: "Try Again Later"
								)
						) {
							try db.signOut()
						}

						popBackToSettings()
					}
				}
			}
		}
		.padding(.top, -20)
		.navigationTitle("Your Account")
		.captureViewActivity(as: "AccountSettingsView")
		.navigationBarTitleDisplayMode(.inline)
		.requireLogin(db: db, onCancel: popBackToSettings)
		.sheet(isPresented: $showForgotPasswordSheet) {
			ForgotPasswordView(
				email: db.currentUser?.email ?? "",
				goBack: {
					Analytics.captureTap(
						"cancel_password_reset_btn",
						fromView: "AccountSettingsView (Forgot Password Sheet)")
					showForgotPasswordSheet = false
				}
			)
		}

		.sheet(item: $shownSlideOverCard) { activeCard in
			Group {
				switch activeCard {
					case .reauthAccountDeletion:
						ReAuthSheetView { result in
							switch result {
								case .success:
									Task {
										await tryFunctionOtherwiseShowInAppNotification(
											fallbackNotificationContent: .init(
												title: "Authorization Error",
												message: "Try Again Later.")
										) {
											print("Deleting Account...")
											try await Task.sleep(for: .seconds(0.5))
											try await db.deleteUser()
											popBackToSettings()
										}
									}
									shownSlideOverCard = nil
								case .canceled:
									print("Re-auth canceled")
									shownSlideOverCard = nil
								case .forgotPassword:
									print("Re-auth forgot password")
									shownSlideOverCard = nil
									Task {
										try await Task.sleep(for: .seconds(0.25))
										showForgotPasswordSheet = true
									}
							}
						}
					case .reauthPasswordChange:
						ReAuthSheetView { result in
							switch result {
								case .success:
									shownSlideOverCard = .newPassword
								case .canceled:
									shownSlideOverCard = nil
								case .forgotPassword:
									shownSlideOverCard = nil
									Task {
										try await Task.sleep(for: .seconds(0.25))
										showForgotPasswordSheet = true
									}
							}
						}
					case .newPassword:
						NewPasswordView(onDone: { shownSlideOverCard = nil })
				}
			}
			.padding()
			.interactiveDismissDisabled()
			.presentationCornerRadius(35)
			.presentationDetents([
				.height(activeCard == .newPassword ? 550 : db.currentUserProvider == .email ? 500 : 380)
			])

		}
	}
}

struct NewPasswordView: View {

	@EnvironmentObject var db: DB
	@State private var loading = false
	let onDone: () -> Void

	public var body: some View {

		VStack {

			HeroView(
				sfSymbolName: "rectangle.and.pencil.and.ellipsis",
				title: "New Password",
				size: .small
			)
			.padding(.vertical, 15)

			if let user = db.currentUser {
				EmailInputFields(
					fixedEmail: user.email!,
					showLoadingIndicator: $loading,
					continueAction: { email, password in
						loading = true
						Task {

							await tryFunctionOtherwiseShowInAppNotification(
								fallbackNotificationContent: .init(
									title: "Couldn't Update Password",
									message: "Try again later")
							) {
								try await db.setNewPassword(password)
								showInAppNotification(
									.success,
									content: .init(
										title: "Success",
										message: "Password Update Succesful"),
									size: .compact)
								onDone()
							}
						}
					})
			} else {
				Text("Invalid State. No User Found.")
					.foregroundStyle(.red)
			}

			Button {
				onDone()
			} label: {
				Text("Cancel")
			}
			.buttonStyle(.secondary())
			.captureTaps("cancel_btn", fromView: "NewPasswordView")
		}
		.padding(.bottom, 10)
	}
}

#Preview {
	NavigationStack {
		AccountSettingsView(popBackToRoot: {})
			.environmentObject(DB())
	}
}