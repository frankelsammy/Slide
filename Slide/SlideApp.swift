//
//  SlideApp.swift
//  Slide
//
//  Created by Yoel Popovici on 11/15/21.
//

import SwiftUI

@main
struct SlideApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
