//
//  DatabaseExampleView.swift
//  FirebaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/databasekit/usage-example
//

import AnalyticsKit
import SharedKit
import SwiftUI

enum DBExamplePath: Hashable, Equatable {
	case postNew
	case seeAllUsers
}

public struct DatabaseExampleView: View {

	@EnvironmentObject var db: DB

	@State private var path = NavigationPath()
	@State private var filterAnonymous = false

	public init() {}

	func popToRoot() {
		path = NavigationPath()
	}

	public var body: some View {
		NavigationStack(path: $path) {
			List {

				NavigationLink(value: DBExamplePath.seeAllUsers) {
					Label("List All Users (Test Backend)", systemImage: "person.2.fill")
						.foregroundColor(.accentColor)
				}

				ForEach(
					db.posts.filter { post in
						return filterAnonymous
							? (post.postUserID != nil && post.postUserID != "Anonymous") : true
					}
				) { post in
					Section(
						footer: Text(
							"\(post.creationDate.description) | by \(post.postUserID ?? "Anonymous")")
					) {
						HStack {
							Text(post.title)
								.font(.title3)
								.bold()
							Spacer()

							if db.currentUser?.uid == post.postUserID {
								Button(role: .destructive) {
									Task {
										await db.executeIfSignedIn(
											withUserID: post.postUserID
										) {
											await db.deletePost(id: post.id!)
										}
										await db.fetchPosts()
									}
								} label: {
									Image(systemName: "trash")
								}
							}

						}
						Text(post.content)
					}
				}
			}
			.navigationTitle("Firestore Example")

			// Fetch Data when View Appears
			.onAppear {
				// Will only refetch on view when there are no posts (e.g. first time opened)
				// delete this check if you want to refetch every time the view is visible
				if db.posts.isEmpty {
					Task {
						await db.fetchPosts()
					}
				}
			}

			// Pull down to refresh
			.refreshable {
				Task {
					await db.fetchPosts()
				}
			}

			// Post Creation Button and a button to filter out anonymous posts (used to showcase executeIfSignedIn function)
			.toolbar {

				Button(
					"Filter Anonymous Posts",
					systemImage: filterAnonymous
						? "person.badge.shield.checkmark.fill" : "person.badge.shield.checkmark"
				) {
					db.executeIfSignedIn(otherwise: .showSignInScreen) {
						filterAnonymous = !filterAnonymous
					}
				}

				NavigationLink(value: DBExamplePath.postNew) {
					Image(systemName: "square.and.pencil")
				}
			}
			.navigationDestination(for: DBExamplePath.self) { path in
				switch path {
					case .postNew:
						PostCreationView {
							popToRoot()
							Task {
								await db.fetchPosts()
							}
						} onCancel: {
							popToRoot()
						}
					case .seeAllUsers:
						BackendFunctionsExampleView()
				}
			}
		}

		.captureViewActivity(as: "DatabaseExampleView")

	}
}

private struct PostCreationView: View {

	@EnvironmentObject var db: DB
	@State var title: String = ""
	@State var content: String =
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae elementum curabitur vitae nunc sed velit dignissim sodales."

	@State var anonymous = false

	public let onSend: () -> Void
	public let onCancel: () -> Void

	init(onSend: @escaping () -> Void, onCancel: @escaping () -> Void) {
		self.onSend = onSend
		self.onCancel = onCancel
	}

	var body: some View {
		List {
			Section(header: Text("Post Details")) {
				TextField("Post Title", text: $title)
					.fontWeight(.bold)
				TextEditor(text: $content)
					.frame(height: 200)
				Toggle("Post Anonymously", isOn: $anonymous)
			}

		}
		.navigationTitle("New Post")
		.toolbar {
			Button("Publish") {
				Task {
					let success =
						await anonymous
						? db.addPost(title: title, content: content)
						: db.addSignedPost(title: title, content: content)
					if success {
						onSend()
					} else {
						showInAppNotification(
							.error,
							content: .init(title: "Post Creation Error", message: "Try Again later"),
							size: .compact)
					}
				}
			}
		}
		.requireLogin(
			db: db,
			navTitle: "Sign In to Post",
			onCancel: onCancel
		)
	}
}

#Preview {
	NavigationStack {
		DatabaseExampleView()
			.environmentObject(DB())
	}
}