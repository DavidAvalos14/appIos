//
//  PlantillaApp.swift
//  Plantilla
//
//  Created by Guest User on 03/11/26.
//

import SwiftUI

@main
struct PlantillaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
