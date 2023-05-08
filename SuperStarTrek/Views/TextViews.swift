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
      .foregroundColor(Color("TextColour"))
      .font(.title)
      .fontWeight(.black)
  }
}

struct MessageText: View {
  let text: String
  var body: some View {
    Text(text)
      .font(.system(size: 25, design: .monospaced))
      .kerning(3.0)
      .foregroundColor(Color("DisplayTextColour"))
      .fontWeight(.black)
  }
}

struct HelpText: View {
  let text: String
  var body: some View {
    Text(text)
      .font(.system(size: 25, design: .monospaced))
      .kerning(3.0)
      .foregroundColor(Color("HelpTextColour"))
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
      .frame(maxWidth: 120, maxHeight: 80)
      .background(Color.accentColor)
      .foregroundColor(.white)
      .cornerRadius(12.0)
  }
}



struct TextViews_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TitleText(text: "Super Star Trek")
      CommandText(text: "Nav")
      MessageText(text: "This is a 40-character line of a message!.")
    }
  }
}
