//
//  EmailInputFields.swift
//  FirebaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit/email-sign-in-flow
//

import AnalyticsKit
import SharedKit
import SwiftUI

/// Will disable the continue button if the password or email are invalid (only if forgotPasswordAction is nil)
struct EmailInputFields: View {

	private enum Field: Int, CaseIterable {
		case email, password
	}

	// Keep track of the active keyboard
	@FocusState private var focusedField: Field?

	@State var email: String = ""
	@State var password: String = ""

	// If during the SIGN UP process the password & email are valid, we enable the continue button
	@State var continueDisabled: Bool = false

	// Show when user presses on the continue button (currently we dont hide it afterwards)
	@Binding var showLoadingIndicator: Bool

	// We use this to differentiate between a normal sign in (forgot password button shown) and a sign up (forgot password button hidden when this action is nil)
	let forgotPasswordAction: (() -> Void)?

	// Initate this when the user presses the continue button
	let continueAction: ((_ email: String, _ password: String) -> Void)

	let passwordRequirements: [ValidationType] = [.atLeast8Chars, .onlyAllowedChars, .requiresAtLeastOneSpecialChar]

	// Make the email field uneditable (Used when EmailInputFields is used for reauth), so we only want to show the password field
	let freezeEmail: Bool

	init(
		showLoadingIndicator: Binding<Bool>? = nil,
		forgotPasswordAction: (() -> Void)? = nil,
		continueAction: @escaping (_ email: String, _ password: String) -> Void
	) {
		self.freezeEmail = false
		self.forgotPasswordAction = forgotPasswordAction
		self.continueAction = continueAction
		if let showLoadingIndicator = showLoadingIndicator {
			self._showLoadingIndicator = showLoadingIndicator
		} else {
			self._showLoadingIndicator = .constant(false)
		}
	}

	init(
		fixedEmail: String,
		showLoadingIndicator: Binding<Bool>? = nil,
		forgotPasswordAction: (() -> Void)? = nil,
		continueAction: @escaping (_ email: String, _ password: String) -> Void
	) {
		self._email = State(initialValue: fixedEmail)
		self.freezeEmail = true
		self.forgotPasswordAction = forgotPasswordAction
		self.continueAction = continueAction
		if let showLoadingIndicator = showLoadingIndicator {
			self._showLoadingIndicator = showLoadingIndicator
		} else {
			self._showLoadingIndicator = .constant(false)
		}
	}

	func submitForm() {
		focusedField = nil
		if email.validate(.email) != nil {
			showInAppNotification(
				.error, content: .init(title: "Validation Error", message: "Enter a valid Email"), size: .compact)
			return
		}

		if password.isEmpty {
			showInAppNotification(
				.error, content: .init(title: "Password is empty", message: "Please enter a password"),
				size: .compact)
			return
		}

		continueAction(email, password)
	}

	var body: some View {
		VStack(spacing: 10) {
			TextField("Email", text: $email)
				.textFieldStyle(CommonTextField(disabled: freezeEmail))
				.textInputAutocapitalization(.never)
				.textContentType(.emailAddress)
				.focused($focusedField, equals: .email)
				.onSubmit {
					focusedField = .password
				}

			SecureField("Password", text: $password)
				.textFieldStyle(CommonTextField())
				.textContentType((forgotPasswordAction != nil) ? .password : .newPassword)
				.textInputAutocapitalization(.never)
				.focused($focusedField, equals: .password)
				.onSubmit { submitForm() }
				.overlay {
					if let forgotPasswordAction = forgotPasswordAction {
						HStack {
							Spacer()
							Button("Forgot Password?", systemImage: "person.fill.questionmark") {
								forgotPasswordAction()
							}
							.foregroundStyle(Color.accentColor.gradient)
							.fontWeight(.semibold)
							.labelStyle(.iconOnly)
							.hoverEffect(.lift)
							.padding()
							.captureTaps("forgot_email_btn", fromView: "EmailInputFields")
						}
					}
				}

			if forgotPasswordAction == nil {
				PasswordStrengthChecker(password: password, pwRequirements: passwordRequirements)
			}

			Button(
				action: submitForm,
				label: {
					if showLoadingIndicator {
						ProgressView()
							.tint(.white)
							.scaleEffect(1.25)
					} else {
						Text("Continue")
					}
				}
			)
			.buttonStyle(.cta())
			.captureTaps("submit_btn", fromView: "EmailInputFields")
			.disabled(continueDisabled)
		}
		.onChange(of: email) {
			checkInputs()
		}
		.onChange(of: password) {
			checkInputs()
		}
		.onAppear { checkInputs() }
	}

	// This ensures that we disable the continue button on invalid inputs ONLY during the signup process
	// When just the login view is shown, we want the button to keep its CTA colors.
	func checkInputs() {
		if forgotPasswordAction == nil {
			continueDisabled =
				!(email.validate(.email) == nil
				&& passwordRequirements.allSatisfy { password.validate($0) == nil })
		}
	}
}

struct PasswordStrengthChecker: View {

	// Here you can customize different minimal password parameters
	// NOTE: The password can't be shorter than 6 characters (Firebase Auth requirement)

	var password: String
	let pwRequirements: [ValidationType]

	struct CheckLine: View {

		var isSatisfied: Bool
		let description: LocalizedStringKey

		var body: some View {
			HStack {
				Image(systemName: isSatisfied ? "checkmark.circle.fill" : "checkmark.circle")
					.foregroundStyle(isSatisfied ? Color.accentColor : Color(uiColor: .tertiaryLabel))
				Text(description)
					.foregroundStyle(isSatisfied ? Color.accentColor : Color(uiColor: .tertiaryLabel))
				Spacer()
			}
		}
	}

	var body: some View {
		VStack {
			ForEach(pwRequirements, id: \.self) { requirement in
				CheckLine(
					isSatisfied: password.validate(requirement) == nil,
					description: requirement.validationData.validationDescription
				)
			}
		}
		.padding()
		.background(Color(.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(.tertiary, lineWidth: 1)
		)
	}
}

// For state & co to preview in swiftui
private struct PreviewView: View {
	@State var errorMessage: LocalizedStringKey?

	func continueAction(email: String, password: String) {
		print("Continue with email: \(email) and password: \(password)")
	}

	var body: some View {
		VStack {
			Text(errorMessage ?? "No Error")
			EmailInputFields(fixedEmail: "test@email.com", continueAction: continueAction)
		}
		.padding()
	}
}

#Preview {
	PreviewView()
}