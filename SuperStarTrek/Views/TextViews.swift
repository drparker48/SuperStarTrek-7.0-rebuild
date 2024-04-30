//
//  TextViews.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct TextViews: View {
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

struct TitleText: View {
  let text: String
  var body: some View {
    Text(text.uppercased())
      .kerning(2.0)
      .foregroundColor(Color.black)
      .font(.title)
      .fontWeight(.black)
      .background(
              RoundedRectangle(cornerRadius: 12)
                  .fill(Color("BackgroundColour"))
                  .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
                  .shadow(color: Color.white.opacity(0.7), radius: 5, x: -2, y: -2)
          )
          .foregroundColor(.black) // Adjust the text color as needed
  }
}

struct MessageText: View {
  let text: String
  var body: some View {
    Text(text)
      .font(.system(size: 25, design: .monospaced))
      .kerning(3.0)
      .foregroundStyle(.green) // Adjust the text color as needed  iOS 17 and later
      .fontWeight(.black)
  }
}

struct CommandText: View {
  var text: String
  var body: some View {
    Text(text)
      .bold()
      .font(.body)
      .multilineTextAlignment(.center)
      .frame(maxWidth: 120, maxHeight: 60) //Reduced frame height to give more space for messages
      .background(Color.accentColor)//Background colour changes depending on type of control
      .foregroundStyle(.white) // Adjust the text color as needed  iOS 17 and later
      .cornerRadius(12.0)
      .shadow(color: Color.gray, radius: 3, x: 1, y: 1) // Adding a shadow effect
  }
}
struct AlertMessageText: View {
  let text: String
  var body: some View {
    Text(text)
      .multilineTextAlignment(.leading)
  }
}


struct TextViews_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TitleText(text: "Super Star Trek")
      CommandText(text: "Nav")
      MessageText(text: "This is a 40-character line of a message!.")
      AlertMessageText(text: "This is a very long text message, left-aligned to be used in certain types of alert. It just rambles on to prove that it is formatted as required. However, the Alert syntax doesn't allow this to override the .centre alignment.")
    }
  }
}
