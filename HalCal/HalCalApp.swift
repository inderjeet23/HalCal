//
//  HalCalApp.swift
//  HalCal
//
//  Created by Inderjeet Mander on 3/2/25.
//

import SwiftUI

@main
struct HalCalApp: App {
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showLaunchScreen ? 0 : 1)
                
                if showLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                }
            }
            .background(Constants.Colors.background)
            .onAppear {
                // Show launch screen for 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
