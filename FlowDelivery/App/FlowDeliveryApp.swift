//
//  FlowDeliveryApp.swift
//  FlowDelivery
//
//  Created by Leonardo de Moraes Souza on 14/07/26.
//

import SwiftUI

@main
struct FlowDeliveryApp: App {
    @State
    private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: container.rootViewModel)
                .environment(container)
                .environment(container.sessionStore)
        }
    }
}
