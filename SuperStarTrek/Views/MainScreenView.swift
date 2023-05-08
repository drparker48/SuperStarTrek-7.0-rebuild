//
//  MainScreenView.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI

struct MainScreenView: View {
  @Binding var game: Game
  @Binding var help: Help
  var body: some View {
    VStack {
      TopView(game: $game, help: $help)
      Spacer()
      if game.gameStarted {
        MiddleView(game: $game)
      } else if help.helpShowing {
        HelpView(help: $help)
      }
      Spacer()
      BottomView(game: $game)
    }
  }
}

struct CommandView: View {
  var body: some View {
    Text("Command View")
  }
}

struct TitleView: View {
  var body: some View {
    Text("Super Star Trek")
  }
}


struct RowView: View {
  let text: String
  var body: some View {
    MessageText(text: text)
      .multilineTextAlignment(.leading)
  }
}

struct HelpRowView: View {
  let text: String
  var body: some View {
    HelpText(text: text)
      .multilineTextAlignment(.leading)
  }
}

struct AlertView: View {
  // 1
  @State private var presentAlert = false
  var body: some View {
    VStack {
      Button("Alert") {
        presentAlert = true
      }
    }
    .alert("Title", isPresented: $presentAlert, actions: {
    })
  }
}
struct TopView: View {
  @Binding var game: Game
  @Binding var help: Help
  @State private var informationAlert = false
  @State private var helpAlert = false
  @State private var resignAlert = false
  
  var body: some View {
    HStack {
      //APP INFORMATION
      Button(action: {informationAlert = true})
      {
        CommandText(text: "App Information")
      }
      .alert("Super Star Trek V1.00.04", isPresented: $informationAlert) {
        Button("OK") { }
      } message: {
        Text("©2023 David R Parker\n(Swift conversion)\n\n©2020 Emanuele Bolognesi\n(Perl conversion)\n\n©1978 David Ahl & Bob Leedom\n(Original BASIC version)")
      }
      //INSTRUCTIONS
      Button(action: {help.showHelp()})
      {
        CommandText(text: "Instructions")
      }
      .disabled(game.gameStarted)
      //.disabled(help.helpShowing == false)
      Spacer()
      
      //TITLE
      TitleText(text: "Super Star Trek")
      Spacer()
      //RESIGN COMMAND
      Button(action: {resignAlert = true})
      {
        CommandText(text: "Resign Command")
      }
      .alert("Do your wish to Continue or Resign", isPresented: $resignAlert) {
        Button("Resign") {game.gameOver(reason: "Resigned")}
        Button("Continue", role: .cancel, action: {})
      }
      .disabled(!game.gameStarted)
      //NEW MISSION
      Button(action: {game.startGame()})
      {
        CommandText(text: "New      Mission")
      }
    }
    .padding()
  }
}

struct MiddleView: View {
  @Binding var game: Game
  var body: some View {
    ScrollView() {
      ScrollViewReader { proxy in
        ForEach(game.messageEntries.indices,id: \.self) { index in
          let messageEntry = game.messageEntries[index]
          RowView(text: messageEntry.line)
        }
        .onAppear {
          proxy.scrollTo(game.messageEntries.count - 1, anchor: .bottom)
          print(game.messageEntries.count)
        }
        .onChange(of: game.messageEntries, perform: { _ in proxy.scrollTo(game.messageEntries.count - 1, anchor: .bottom)
        })
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.black)
        .cornerRadius(Constants.General.roundRectCornerRadius)
        .padding()
      }
    }
  }
}

struct HelpView: View {
  @Binding var help: Help
  var body: some View {
    ScrollView() {
      ScrollViewReader { proxy in
        ForEach(help.helpEntries.indices,id: \.self) { index in
          let helpEntry = help.helpEntries[index]
          HelpRowView(text: helpEntry.line)
        }
        .onAppear {
          proxy.scrollTo(help.helpEntries.count - 1, anchor: .bottom)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.black)
        .cornerRadius(Constants.General.roundRectCornerRadius)
        .padding()
      }
    }
  }
}

struct BottomView: View {
  @Binding var game: Game
  
  @State private var navigateAlert = false
  @State private var direction: String = ""
  @State private var warp: String = ""
  @State private var maxWarp = "8"
  
  @State private var phasersAlert = false
  @State private var unitsToFire: String = ""
  
  @State private var photonsAlert = false
  
  @State private var shieldControlAlert = false
  @State private var energyToShields: String = ""
  
  @State private var computerAlert = false
  @State private var coordinateAlert = false
  
  @State private var quadrantX = ""
  @State private var quadrantY = ""
  @State private var sectorX = ""
  @State private var sectorY = ""
  
  @State private var calculatorAlert = false
  
  var body: some View {
    HStack {
      //COURSE CONTROL
      Button(action: {navigateAlert = true})
      {
        CommandText(text: "Navigate")
          .alert("Navigate", isPresented: $navigateAlert, actions: {
            TextField("Direction (0-9):", text: $direction)
              .keyboardType(.decimalPad)
              .onSubmit {
              }
            TextField("Warp Speed (0-" + maxWarp + "):", text: $warp)
              .keyboardType(.decimalPad)
              .onSubmit {
              }
            Button("Engage", action: {
              game.courseControl(direction: Double(direction) ?? 0, warp: Double(warp) ?? 0)
            })
            Button("Cancel", role:.cancel, action: {})
          }, message: {
            Text("Set Course Direction and Warp Speed")
          })
      }
      .disabled(!game.gameStarted || damage[1] < 0)
      //SHORT RANGE SCAN
      Button(action: {game.shortRangeScan()})
      {
        CommandText(text: "Short Range Scan")
      }
      .disabled(!game.gameStarted || damage[2] < 0)
      //LONG RANGE SCAN
      Button(action: {game.longRangeScan()})
      {
        CommandText(text: "Long  Range Scan")
      }
      .disabled(!game.gameStarted || damage[3] < 0)
      //FIRE PHASERS
      Button(action: {phasersAlert = true})
      {
        CommandText(text: "Fire       Phasers")
          .alert("Fire Phasers", isPresented: $phasersAlert, actions: {
            TextField(String(enterpriseEnergy) + " available", text: $unitsToFire)
              .keyboardType(.decimalPad)
              .onSubmit {
                unitsToFire = String(enterpriseEnergy) + " available"
              }
            Button("Fire", action: {
              game.firePhasers(unitsToFire: unitsToFire)
            })
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text("Enter energy units to fire")
          })
      }
      .disabled(!game.gameStarted || damage[4] < 0)
      //FIRE TORPEDOES
      Button(action: {photonsAlert = true})
      {
        CommandText(text: "Fire Photon Torpedoes")
          .alert("Fire Photon Torpeedoes", isPresented: $photonsAlert, actions: {
            TextField("Direction (0-9):", text: $direction)
              .keyboardType(.decimalPad)
              .onSubmit {
              }
            Button("Fire", action: {
              game.fireTorpedoes(direction: Double(direction) ?? 0)
            })
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text("Set Torpedo Course")
          })
      }
      .disabled(!game.gameStarted || damage[5] < 0)
      //DAMAGE CONTROL
      Button(action: {game.damageControl()})
      {
        CommandText(text: "Damage Control")
      }
      .disabled(!game.gameStarted || damage[6] < 0)
      //SHIELD CONTROL
      Button(action: {shieldControlAlert = true})
      {
        CommandText(text: "Shield   Control")
          .alert("Shield Control", isPresented: $shieldControlAlert, actions: {
            TextField(String(enterpriseEnergy + enterpriseShields) + " available", text: $energyToShields)
              .keyboardType(.decimalPad)
              .onSubmit {
                energyToShields = String(enterpriseEnergy + enterpriseShields) + " available"
              }
            Button("Change", action: {
              let change = Int(energyToShields) ?? 0
              print("change = \(change)")
              if change <= 0 || enterpriseShields == change {
                game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORT: Shields unchanged"))
              } else {
                if change <= enterpriseEnergy + enterpriseShields {
                  enterpriseEnergy = enterpriseEnergy + enterpriseShields - change
                  enterpriseShields = change
                  game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORT: Shields now at \(enterpriseShields) units per your command."))
                } else {
                  game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORT: This is not the Federation Treasury!"))
                }
              }
            })
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text("Enter energy to be diverted to shields")
          })
      }
      .disabled(!game.gameStarted || damage[7] < 0)
      //COMPUTER
      Button(action: {computerAlert = true})
      {
        CommandText(text: "Computer")
          .alert("Ship Computer Active", isPresented: $computerAlert, actions: {
            Button("Cumulative Galactic Record", role: nil, action: {game.cumulativeGalacticRecord(regionNameMap: false)})
            Button("Status Report", action: {game.statusReport()})
            Button("Photon Torpedo Course Data", action: {game.getPhotonTorpedoCourse()})
            Button("Starbase Navigation Data", action: {game.getStarbaseNavData()})
            Button("Galactic Region Name Map", action: {game.cumulativeGalacticRecord(regionNameMap: true)})
            Button("Cancel", role: .cancel, action: {
            })
          }, message: {
            Text("Select Option")
          })
      }
      .disabled(!game.gameStarted || damage[8] < 0)
      //CALCULATOR
      Button(action: {calculatorAlert = true})
      {
        CommandText(text: "Direction & Distance Calculator")
          .alert("Calculator Active", isPresented: $calculatorAlert, actions: {
            TextField("Quadrant X:", text: $quadrantX)
              .keyboardType(.decimalPad)
              .onSubmit {}
            TextField("Quadrant Y:", text: $quadrantY)
              .keyboardType(.decimalPad)
              .onSubmit {}
            TextField("Sector X:", text: $sectorX)
              .keyboardType(.decimalPad)
              .onSubmit {}
            TextField("Sector Y:", text: $sectorY)
              .keyboardType(.decimalPad)
              .onSubmit {}
            Button("Calculate", action: {game.getDistanceAndDirection(W1: Int(quadrantX) ?? 0, X: Int(quadrantY) ?? 0, C1: Int(sectorX) ?? 0, A: Int(sectorY) ?? 0)})
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text("Enter Coordinates")
          })
      }
      .disabled(!game.gameStarted || damage[8] > 0)
    }
    .padding()
  }
}

struct MainScreenView_Previews: PreviewProvider {
  static private var game = Binding.constant(Game())
  static private var help = Binding.constant(Help())
  static var previews: some View {
    MainScreenView(game: game, help: help)
      .previewInterfaceOrientation(.landscapeLeft)
    MainScreenView(game: game, help: help)
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
