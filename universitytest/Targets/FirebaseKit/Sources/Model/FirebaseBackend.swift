//
//  FirebaseBackend.swift
//  FirebaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit
//  https://docs.swiftylaun.ch/module/databasekit
//

import AnalyticsKit
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import Foundation
import SharedKit
import SwiftUI

/// Represents data structure for a post.
struct PostData: Codable, Identifiable, Equatable {
	@DocumentID var id: String?
	let title: String
	let content: String
	let creationDate: Date
	let postUserID: String?
}

/// Enum defining authentication providers.
public enum Provider {
	case apple
	case email
}

/// Enum representing authentication states.
public enum AuthState {
	case signedOut
	case signedInUnverified
	case signedIn
}

/// Setup of FirebaseAuth (Auth) + Firestore (DB) + optionally, Cloud Functions (BackendKit)
@MainActor
public class DB: ObservableObject {

	/// Internal variable reference to access firestore data.
	/// Marked as internal in order to avoid calling it directly.
	///
	/// Use it via dedicated functions such as the `fetchPosts()` example function below.
	internal let _db = Firestore.firestore()

	/// See DatabaseExampleView.swift
	@Published var posts: [PostData] = []

	/// FirebaseAuth user state, nil if not logged in
	@Published public var currentUser: User? = nil

	/// FirebaseAuth State (use this to check auth state, updates with currentUser)
	@Published public var authState: AuthState = .signedOut

	/// FirebaseAuth Provider of currently logged in user
	@Published public var currentUserProvider: Provider? = nil

	/// For Firebase to keep track of the Auth State (see AuthGeneral.swift)
	internal var authStateHandler: AuthStateDidChangeListenerHandle?

	/// For Sign in With Apple (Specifically, for account deletion. Is set when the user signs in with Apple)
	internal var appleIDCredential: ASAuthorizationAppleIDCredential?

	/// For Sign in With Apple (see SignInWithApple.siwft)
	internal var currentNonce: String?

	/// See BackendFunctions.swift for implementation
	let functions: Functions

	public init() {
		functions = Functions.functions()
		#if DEBUG
			// Uncomment this if you're running your Firebase Functions locally
			// https://docs.swiftylaun.ch/module/backendkit/running-locally
			// functions.useEmulator(withHost: "127.0.0.1", port: 5001)
		#endif
		/// Listen to Auth State updates
		registerAuthStateListener()
	}
}

//MARK: - DatabaseExampleView
extension DB {

	/// Fetches posts from the database asynchronously and sets them in the `posts` property.
	@MainActor
	public func fetchPosts() async {
		Analytics.capture(.info, id: "fetch_posts_called", source: .db)
		var newPostsData: [PostData] = []
		do {
			let snapshot = try await _db.collection("posts").getDocuments()
			for document in snapshot.documents {
				let post = try document.data(as: PostData.self)
				newPostsData.append(post)
			}
			Analytics.capture(
				.success, id: "fetch_posts", longDescription: "Fetched \(newPostsData.count) posts from the db.",
				source: .db)

		} catch {
			Analytics.capture(
				.error, id: "fetch_posts", longDescription: "Error fetching posts: \(error)", source: .db)
			return
		}
		newPostsData.sort(by: { $0.creationDate > $1.creationDate })
		posts = newPostsData
	}

	/// Adds a post anonymously to the database.
	public func addPost(title: String, content: String) async -> Bool {
		Analytics.capture(.info, id: "add_post_called", source: .db)
		do {
			let createdPost = try await _db.collection("posts").addDocument(data: [
				"title": title,
				"content": content,
				"creationDate": Timestamp(),
				"postUserID": "Anonymous",
			])
			Analytics.capture(
				.success, id: "add_post", longDescription: "User created post with ID: \(createdPost.documentID)",
				source: .db)
			return true
		} catch {
			Analytics.capture(
				.error, id: "add_post", longDescription: "Error during post creation: \(error)", source: .db)
			return false
		}
	}

	/// Adds a post in the name in name of the currently signed in user to the database.
	public func addSignedPost(title: String, content: String) async -> Bool {
		Analytics.capture(.info, id: "add_signed_post_called", source: .db)
		guard let user = self.currentUser else {
			Analytics.capture(
				.error, id: "add_signed_post",
				longDescription: "Error during signed post creation: User is not logged in", source: .db)
			return false
		}

		do {
			let ref = try await _db.collection("posts").addDocument(data: [
				"title": title,
				"content": content,
				"creationDate": Timestamp(),
				"postUserID": user.uid,
			])
			Analytics.capture(
				.success, id: "add_signed_post",
				longDescription: "User created signed post with ID: \(ref.documentID)", source: .db)
			return true
		} catch {
			Analytics.capture(
				.error, id: "add_signed_post",
				longDescription: "Error during signed post creation: \(error.localizedDescription)", source: .db)
			return false
		}
	}

	public func deletePost(id: String) async {
		Analytics.capture(.info, id: "delete_post_called", longDescription: "PostID: \(id)", source: .db)
		do {
			try await _db.collection("posts").document(id).delete()
			Analytics.capture(.success, id: "delete_post", longDescription: "PostID: \(id)", source: .db)
		} catch {
			Analytics.capture(
				.error, id: "delete_post",
				longDescription: "Error deleting post with ID: \(id): \(error.localizedDescription)", source: .db)
		}
	}
}

// MARK: - Only for App.swift
extension DB {
	// We dont do this inside init of DB because we don't want to init Firebase every time we initialize
	// the DB object. Otherwise we will a new DB object inside something like a SwiftUI Preview,
	// which call this function again and again, and make everything pretty sloooow...
	// Is only used once in App.swift to initialize Firebase
	public static func initFirebase() {
		FirebaseApp.configure()
	}
}