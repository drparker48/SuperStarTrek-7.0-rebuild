//
//  Shapes.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct Shapes: View {
    @State private var isWideShapes = true
    
    var body: some View {
        VStack {
            // Display Circle when wideShapes is false
            if !isWideShapes {
                Circle()
                    .strokeBorder(Color.green, lineWidth: 20.0)
                    .frame(width: 200, height: 100.0)
                    .transition(.slide)
            }
            
            // Display RoundedRectangle with dynamic width based on isWideShapes
            RoundedRectangle(cornerRadius: 20.0)
                .fill(Color.green)
                .frame(width: isWideShapes ? 200 : 100, height: 100.0)
            
            // Display Capsule with dynamic width based on isWideShapes
            Capsule()
                .fill(Color.green)
                .frame(width: isWideShapes ? 200 : 100, height: 100.0)
            
            // Display Ellipse with dynamic width based on isWideShapes
            Ellipse()
                .fill(Color.green)
                .frame(width: isWideShapes ? 200 : 100, height: 100.0)
            
            // Button to animate the shapes
            Button(action: {
                withAnimation {
                    isWideShapes.toggle()
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
