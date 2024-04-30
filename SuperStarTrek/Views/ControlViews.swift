//
//  ControlViews.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct RoundedImageViewStroked: View {
  var systemName: String
  var body: some View {
    Image(systemName: systemName)
      .font(.title)
      .foregroundColor(Color("TextColour"))
      .frame(width: Constants.General.roundedViewLength, height: Constants.General.roundedViewLength)
      .overlay(
        Circle()
          .strokeBorder(Color("ButtonStrokeColour"), lineWidth: Constants.General.strokeWidth))
  }
}

struct PreviewView: View {
  var body: some View {
    VStack(spacing: 10) {
      RoundedImageViewStroked(systemName: "info.circle")
      RoundedImageViewStroked(systemName: "questionmark.circle")
      RoundedImageViewStroked(systemName: "gobackward")
      RoundedImageViewStroked(systemName: "goforward")
    }
  }
}

struct ControlViews_Previews: PreviewProvider {
  static var previews: some View {
    PreviewView()
    PreviewView()
      .preferredColorScheme(.dark)
  }
}
