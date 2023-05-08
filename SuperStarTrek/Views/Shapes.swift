//
//  Shapes.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct Shapes: View {
  @State private var wideShapes = true
  var body: some View {
    VStack {
      if !wideShapes {
        Circle()
          .strokeBorder(Color.green, lineWidth: 20.0)
          .frame(width: 200, height: 100.0)
          .transition(.slide)
      }
      RoundedRectangle(cornerRadius: 20.0)
        .fill(Color.green)
        .frame(width: wideShapes ? 200 : 100, height: 100.0)
      
      Capsule()
        .fill(Color.green)
        .frame(width: wideShapes ? 200 : 100, height: 100.0)
      Ellipse()
        .fill(Color.green)
        .frame(width: wideShapes ? 200 : 100, height: 100.0)
      Button(action: {
        withAnimation {
          wideShapes.toggle()
        }
      }) {
        Text("Animate!")
      }
    }
    .background(Color.blue)
  }
}

struct Shapes_Previews: PreviewProvider {
  static var previews: some View {
    Shapes()
  }
}
