//
//  CreditWidgetBundle.swift
//  CreditWidget
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import WidgetKit
import SwiftUI

@main
struct CreditWidgetBundle: WidgetBundle {
    var body: some Widget {
        CreditWidget()
        CreditWidgetControl()
        CreditWidgetLiveActivity()
    }
}
