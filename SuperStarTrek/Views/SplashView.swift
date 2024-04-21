//
//  SplashView.swift
//  SuperStarTrek
//
//  Created by David Parker on 23/03/2024.
//

import SwiftUI

struct SplashView: View {
  @State private var isSplashFinished = false
      
      var body: some View {
          VStack {
            Image("Image")
            .resizable()
          }
          .onAppear {
              // Perform any necessary tasks here
              DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                  // Simulating asynchronous task completion after 2 seconds
                  self.isSplashFinished = true
              }
          }
          .fullScreenCover(isPresented: $isSplashFinished) {
              ContentView()
          }
      }
}

#Preview {
    SplashView()
}
