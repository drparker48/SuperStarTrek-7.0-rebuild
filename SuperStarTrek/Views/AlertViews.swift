//
//  AlertViews.swift
//  SuperStarTrek
//
//  Created by David Parker on 06/04/2023.
//

import SwiftUI

struct CustomAlertView: View {
    var message: String
    var action: () -> Void
    var textColor: Color
    var buttonColor: Color
    var bgColor: Color
  
    var body: some View {
        VStack {
            Text("Alert!")
                .font(.title)
                .foregroundColor(textColor)
            
            Text(message)
                .multilineTextAlignment(.leading)
                .padding()
            
            Button("OK") {
                action()
            }
            .foregroundColor(buttonColor)
            .padding()
        }
        .background(bgColor)
        .cornerRadius(15)
        .padding()
        .accessibility(label: Text("Alert message: \(message)"))
        .accessibility(identifier: "CustomAlertView")
    }
}

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

struct RepairAlert: View {
  @State private var presentRepairAlert = false
  var body: some View {
    Button("Repair Alert") {presentRepairAlert = true}
      .alert("Title", isPresented: $presentRepairAlert, actions: {
                Button("Authorise") {}
                Button("Continue", role: .cancel, action: {})
        })

  }
}
struct AlertViews_Previews: PreviewProvider {
    static var previews: some View {
      CustomAlertView(message: "This is a left-aligned alert message that is extended to make sure it covers more than one line. It just goes on and on and on and on and on and on and on . . .", action: {}, textColor: .black, buttonColor: .blue, bgColor: .white)
      AlertViews()
      ShieldAlert()
      RepairAlert()
  }
}
