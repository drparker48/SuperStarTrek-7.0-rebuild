//
//  ContentView.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct ContentView: View {
  @State private var game = Game()
  @State private var help = Help()
  var body: some View {
    ZStack {
      Color("BackgroundColour")
        .edgesIgnoringSafeArea(.all)
      MainScreenView(game: $game, help: $help)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewInterfaceOrientation(.landscapeLeft)
      .preferredColorScheme(.light)
    ContentView()
      .previewInterfaceOrientation(.landscapeLeft)
      .preferredColorScheme(.dark)
  }
}
