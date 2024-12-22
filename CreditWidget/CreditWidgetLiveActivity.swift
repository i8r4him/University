//
//  CreditWidgetLiveActivity.swift
//  CreditWidget
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CreditWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CreditWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CreditWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CreditWidgetAttributes {
    fileprivate static var preview: CreditWidgetAttributes {
        CreditWidgetAttributes(name: "World")
    }
}

extension CreditWidgetAttributes.ContentState {
    fileprivate static var smiley: CreditWidgetAttributes.ContentState {
        CreditWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CreditWidgetAttributes.ContentState {
         CreditWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CreditWidgetAttributes.preview) {
   CreditWidgetLiveActivity()
} contentStates: {
    CreditWidgetAttributes.ContentState.smiley
    CreditWidgetAttributes.ContentState.starEyes
}
