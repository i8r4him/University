//
//  AIVisionExampleView.swift
//  AIKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/aikit/ai-vision-example
//

import AnalyticsKit
import FirebaseKit
import PhotosUI
import SharedKit
import SwiftUI

// Warning: The Preview will not work, because it doesn't have access to camera. Test on a real device.

struct AIVisionExampleView: View {

	@EnvironmentObject var db: DB

	/// View Model to control this View
	@StateObject private var vm = AIVisionExampleViewModel()

	/// Interact with the camera
	@StateObject private var cameraViewModel = CameraViewModel()

	/// Holds the value of current device orientation
	/// For Camera preview feed rotation on iPad
	@State private var orientation = UIDevice.current.orientation

	/// Interact with the voice recording
	@StateObject private var voiceRecordingViewModel = VoiceRecordingViewModel()

	/// Pop to root, to close this View
	let popToRoot: () -> Void

	var body: some View {

		Stack(currentPlatform == .phone ? .vertical : .horizontal, spacing: 25) {
			CameraView(
				session: cameraViewModel.session, orientation: $orientation
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.requireCapabilityPermission(
				of: .cameraAccess,
				onSuccess: {
					vm.gotCameraPermissions(cameraVM: cameraViewModel)
				},
				onCancel: popToRoot
			)

			// If screen orientation changes, update the orientation variable (relevant for iPad only)
			// See CameraView.swift
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				orientation = UIDevice.current.orientation
			}
			.environment(\.colorScheme, .dark)
			.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

			Stack(currentPlatform == .phone ? .horizontal : .vertical) {
				Spacer()

				// Pick a photo to describe.
				// Once selected, onChange will be fired and the processing will begin
				PhotosPicker(
					selection: $vm.selectedImagePickerItem,
					matching: .images,
					preferredItemEncoding: .compatible
				) {
					Image(systemName: "photo.stack")
						.foregroundStyle(.white)
						.font(.title)
				}
				.onChange(of: vm.selectedImagePickerItem) {
					vm.photoSelectedFromLibrary(cameraVM: cameraViewModel)
				}

				.disabled(vm.processing || !vm.gotCameraAccess)
				.opacity((vm.processing || !vm.gotCameraAccess) ? 0.5 : 1)

				Spacer()
				Button {
					// Once the user presses the button and releases it, we tell that to our ViewModel
					// It will decide what to do next depending on whether the user tapped the button or held it for a while
					vm.releasedShutterButton(
						cameraVM: cameraViewModel, voiceRecordingVM: voiceRecordingViewModel)
				} label: {
					Circle()
						.fill(.white)
						.frame(width: 75, height: 75)
				}
				.buttonStyle(ShutterButton())
				// Disable the button if we are currently processing or if we don't have camera access
				.disabled(vm.processing || !vm.gotCameraAccess)
				.opacity((vm.processing || !vm.gotCameraAccess) ? 0.5 : 1)
				.overlay {
					if vm.processing {
						ProgressView()
					}
				}
				.overlay {
					// Will appear if we are currently recording
					Image(systemName: "mic.fill")
						.foregroundStyle(.black)
						.font(.largeTitle)
						.opacity(voiceRecordingViewModel.isCurrentlyRecording ? 1 : 0)
						.scaleEffect(voiceRecordingViewModel.isCurrentlyRecording ? 1 : 0.65)
						.rotationEffect(.degrees(voiceRecordingViewModel.isCurrentlyRecording ? 0 : -35))
				}

				// If the user presses for at least 0.2 and gave us microphone access -> call our voiceRecording function that will initiate recording
				.simultaneousGesture(
					LongPressGesture(minimumDuration: 0.2).onEnded { _ in
						askUserFor(.microphoneAccess) {
							voiceRecordingViewModel.shouldStartRecording()
						} onDismiss: {
							/// Otherwise, if cancelled, show a notification that we need microphone access for this feature
							showInAppNotification(
								.warning,
								content: .init(
									title: "Microphone Access Required",
									message: "This Feature Requires Microphone Access"))
						}

					})

				Spacer()
				Button {
					cameraViewModel.flipCamera()
				} label: {
					Image(systemName: "arrow.triangle.2.circlepath.camera")
						.foregroundStyle(.white)
						.font(.title)
				}
				// Disable the button if we are currently processing or if we don't have camera access
				.disabled(vm.processing || !vm.gotCameraAccess)
				.opacity((vm.processing || !vm.gotCameraAccess) ? 0.7 : 1)

				Spacer()
			}

			if currentPlatform == .phone {
				// Little hint that tells the user what to do
				Text("Tap to Describe, Hold to Ask a Question")
					.font(.caption2)
					.foregroundStyle(.white)
					.opacity(0.5)
					.padding(.top, -10)
			}

		}
		.padding()
		// why not .prefferedColorScheme? Because it doesn't work well in a NavigationStack. Thanks SwiftUI.
		.background(.black)
		.toolbar {
			if currentPlatform == .phone {
				ToolbarItem(placement: .principal) {
					VStack {
						Text("Vision Example")
							.fontWeight(.semibold)
							.foregroundColor(.white)
					}
				}
			}
		}
		.toolbarBackground(.visible, for: .navigationBar)
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.black, for: .navigationBar)
		.toolbar(currentPlatform == .phone ? .hidden : .automatic, for: .tabBar)
		// If we detect a capturedImage change -> tell that to the viewModel
		.onChange(of: cameraViewModel.capturedImage) {
			vm.detectedCapturedCameraImageUpdate(
				db: db, cameraVM: cameraViewModel, voiceRecordingVM: voiceRecordingViewModel)
		}
		// If we detect a currentAudioTranscription change -> tell that to the viewModel
		.onChange(of: voiceRecordingViewModel.currentAudioTranscription) {
			vm.detectedAudioTranscriptionUpdate(cameraVM: cameraViewModel, voiceRecordingVM: voiceRecordingViewModel)
		}
		.captureViewActivity(as: "AIVisionExampleView")
	}

	/// Shutter Button Style for the camera that will naturally shrink when pressed down.
	private struct ShutterButton: ButtonStyle {

		public init() {}
		public func makeBody(configuration: Configuration) -> some View {
			configuration.label
				.overlay {
					Circle()
						.strokeBorder(.black, lineWidth: configuration.isPressed ? 7.5 : 5)
						.padding(5)
						.animation(.interactiveSpring(duration: 0.25), value: configuration.isPressed)
				}
		}
	}
}