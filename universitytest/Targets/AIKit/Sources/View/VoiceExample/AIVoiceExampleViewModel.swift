//
//  AIVoiceExampleViewModel.swift
//  AIKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/aikit/ai-translator-example
//

import FirebaseKit
import SharedKit
import SwiftUI

/// Languages to choose from (to which we will translate the voice recording)
let languages = ["English", "French", "Spanish", "German", "Russian", "Polish", "Danish"]

class AIVoiceExampleViewModel: ObservableObject {

	/// Is Currently Processing? (Waiting for the server / voice processing)
	@Published var processing: Bool = false

	/// The selected output language for the translation
	@Published var selectedOutputLanguage = "Russian"

	///Executed once a user presses on the translate button and releases it
	func releasedTranslateButton(voiceRecordingVM: VoiceRecordingViewModel) {

		/// The button is released and we are currently recording? (button was held long enough)
		if voiceRecordingVM.isCurrentlyRecording {

			/// Stop the recording
			voiceRecordingVM.shouldStopRecording()

			/// And show that we are processing the recording
			withAnimation { processing = true }
		} else {
			/// Means the user held the recording button not long enough
			Haptics.notification(type: .error)
		}
	}

	@MainActor
	/// Is called in the AIVisionExampleView when it detects a voiceRecordingVM.currentAudioTranscription update in .onChange
	func detectedAudioTranscriptionUpdate(db: DB, voiceRecordingVM: VoiceRecordingViewModel) {

		/// If it detects a change and its nil, means that we reset it and we just ignore it
		guard let recordedTranscription = voiceRecordingVM.currentAudioTranscription else {
			withAnimation { processing = false }
			return
		}

		Task {

			/// Send the text with the prompt to the server to process using OpenAI's API (see BackendFunctions.swift & Backend Code)
			if let result = await db.processTextWithAI(
				text:
					"Translate the following text into \(selectedOutputLanguage). Make it sound as natural as possible: \(recordedTranscription)",
				readResultOutLoud: true)
			{

				///If we got audio from the server (we should get it if we set `readResultOutLoud`to true), read the audio out loud. Otherwise show the result as a text in a notification
				if let audio = result.audio {
					voiceRecordingVM.generalAudioModel.playAudio(base64Source: audio)
				} else {
					showInAppNotification(
						content: .init(
							title: "Translation Result",
							message: LocalizedStringKey(stringLiteral: result.message)),
						style: .init(sfSymbol: "sparkles", symbolColor: .purple, size: .normal))
				}

			} else {
				/// Catch-all error saying that we failed to process the image
				showInAppNotification(
					.error, content: .init(title: "Translation Error", message: "Server Processing Error"))
			}

			/// After processing, failed or not, we want to set all the states back to their initial state
			voiceRecordingVM.currentAudioTranscription = nil

			/// And disable visible processing.
			withAnimation {
				processing = false
			}
		}
	}
}