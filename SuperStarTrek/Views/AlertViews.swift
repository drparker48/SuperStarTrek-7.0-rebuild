//
//  AlertViews.swift
//  SuperStarTrek
//
//  Created by David Parker on 06/04/2023.
//

import SwiftUI

struct AlertViews: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
struct ShieldAlert: View {
  @State private var presentShieldAlert = false
  var body: some View {
          VStack {
              Button("Shield Alert") {
                  presentShieldAlert = true
              }
          }
          .alert("Title", isPresented: $presentShieldAlert, actions: {
          })
      }
}
struct AlertViews_Previews: PreviewProvider {
    static var previews: some View {
        AlertViews()
    }
}
