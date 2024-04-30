//
//  MainScreenView.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import SwiftUI
import Combine

struct MainScreenView: View {
  @Binding var game: Game
  var body: some View {
    VStack {
      Group {
        TopView(game: $game)
        Spacer()
        MiddleView(game: $game)
        Spacer()
        BottomView(game: $game)
      }
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
  @State private var informationAlert = false
  @State private var helpAlert = false
  @State private var resignAlert = false
  
  var body: some View {
    HStack {
      //APP INFORMATION
      Button(action: {informationAlert = true})
      {CommandText(text: "App Information")}
        .alert(Constants.Version.currentVersion, isPresented: $informationAlert) {
          Button("OK") { }
        } message: {
          Text(Constants.Version.currentCopyright)
        }
      //INSTRUCTIONS
      Button(action: { helpAlert = true})
      {CommandText(text: "Instructions")}
        .alert("INSTRUCTIONS", isPresented: $helpAlert) {
          Button("OK") { }
        } message: {
          AlertMessageText(text: Constants.Help.instructionsText)
            .padding()
        }
      Spacer()
      //TITLE
      TitleText(text: "Super Star Trek")
      Spacer()
      //RESIGN COMMAND
      Button(action: {resignAlert = true})
      {CommandText(text: "Resign Command")}
        .alert("Do your wish to Continue or Resign", isPresented: $resignAlert) {
          Button("Resign") {game.endGame(reason: "Resigned")}
          Button("Halt", role: .cancel, action: {})
        } message: {Text("Halt the mission and obtain an Efficiency Rating and continue or Resign and start a new mission.")}
        .disabled(!game.gameStarted && !game.gameOver)
      //NEW MISSION
      Button(action: {game.startGame()})
      {CommandText(text: "New      Mission")}
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

//@ViewBuilder
//private func ScrollViewContent(game: Game) -> some View {
//    ScrollViewReader { proxy in
//        ForEach(game.messageEntries.indices, id: \.self) { index in
//            let messageEntry = game.messageEntries[index]
//            RowView(text: messageEntry.line)
//        }
//        .onAppear {
//            proxy.scrollTo(game.messageEntries.count - 1, anchor: .bottom)
//        }
//        .onChange(of: game.messageEntries) { _ in
//            proxy.scrollTo(game.messageEntries.count - 1, anchor: .bottom)
//        }
//    }
//}

struct BottomView: View {
  @Binding var game: Game
  
  @State private var impulseAlert = false
  @State private var warpdriveAlert = false
  
  @State private var phasersAlert = false
  @State private var unitsToFire: String = ""
  
  @State private var photonsAlert = false
  
  @State private var repairAlert = false
  
  @State private var shieldControlAlert = false
  @State private var energyToShields: String = ""
  
  @State private var computerAlert = false
  @State private var coordinateAlert = false
  
  @State private var startX = ""
  @State private var startY = ""
  @State private var endX = ""
  @State private var endY = ""
  
  @State private var xCoordinate = 0
  @State private var yCoordinate = 0
  
  
  @State private var calculatorAlert = false
  
  var body: some View {
    HStack {
      
      //IMPULSE ENGINES
      Button(action: {impulseAlert = true})
      {
        CommandText(text: "Impulse Engines")
          .accentColor(.green)
          .alert("Impulse Engines", isPresented: $impulseAlert, actions: {
            TextField("Destination Sector Row", text: $endX)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endX)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endX = filtered
                      }
                  }
              .onSubmit {}
            TextField("Destination Sector Column", text: $endY)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endY)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endY = filtered
                      }
                  }
              .onSubmit {}
            Button("Engage", action: {game.impulseEngines(currentSector: (Int(game.sectorCoordinates.0), Int(game.sectorCoordinates.1)), targetSector: (Int(endX) ?? 0, Int(endY) ?? 0))
            })
            Button("Cancel", role:.cancel, action: {})
          }, message: {
            Text(Constants.Help.impulseHelp)
          })
      }
      .disabled(!game.gameStarted)

                
      // WARP DRIVE
      Button(action: {warpdriveAlert = true})
      {
        CommandText(text: "Warp         Drive")
          .accentColor(.green)
          .alert("Warp Drive", isPresented: $warpdriveAlert, actions: {
            TextField("Destination Quadrant Row", text: $endX)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endX)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endX = filtered
                      }
                  }
              .onSubmit {}
            TextField("Destination Quadrant Column", text: $endY)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endY)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endY = filtered
                      }
                  }
              .onSubmit {}
            Button("Engage", action: {game.warpDrive(currentQuadrant: (Int(game.quadrantCoordinates.0), Int(game.quadrantCoordinates.1)), targetQuadrant: (Int(endX) ?? 0, Int(endY) ?? 0))
            })
            Button("Cancel", role:.cancel, action: {})
          }, message: {
            Text(Constants.Help.warpDriveHelp)
          })
      }
      .disabled(!game.gameStarted)
      
      //SHORT RANGE SCAN
      Button(action: {game.shortRangeScan()})
      {
        CommandText(text: "Short Range Scan")
          .accentColor(.orange)
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.shortRangeSensors] < 0.9)
      
      //LONG RANGE SCAN
      Button(action: {game.longRangeScan()})
      {
        CommandText(text: "Long  Range Scan")
          .accentColor(.orange)
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.longRangeSensors] < 0.9)
      
      //FIRE PHASERS
      Button(action: {phasersAlert = true})
      {
        CommandText(text: "Fire       Phasers")
          .accentColor(.red)
          .alert("Fire Phasers", isPresented: $phasersAlert, actions: {
            TextField("Energy units to fire", text: $unitsToFire)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(unitsToFire)) { newValue in
                      let filtered = newValue.filter { "0123456789".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.unitsToFire = filtered
                      }
                  }
              .onSubmit {
                unitsToFire = String(game.enterpriseEnergy) + " available"}
              .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing}
            Button("Fire", action: {
              game.firePhasers(unitsToFire: unitsToFire)
            })
            Button("Cancel", role: .cancel, action: {
              game.firePhasers(unitsToFire: String("0"))
            })
          }, message: {
            Text(Constants.Help.phasersHelp)
          })
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.phaserControl] < 0.9 || game.enterpriseCondition != "RED")
      
      //FIRE TORPEDOES
      Button(action: {photonsAlert = true})
      {
        CommandText(text: "Fire Photon Torpedoes")
          .accentColor(.red)
          .alert("Fire Photon Torpedoes", isPresented: $photonsAlert, actions: {
            TextField("Destination Sector Row", text: $endX)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endX)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endX = filtered
                      }
                  }
              .onSubmit {}
            TextField("Destination Sector Column", text: $endY)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(endY)) { newValue in
                      let filtered = newValue.filter { "12345678".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.endY = filtered
                      }
                  }
              .onSubmit {}
            Button("Fire", action: {
              game.fireTorpedoes(currentSector: (Int(game.sectorCoordinates.0), Int(game.sectorCoordinates.1)), targetSector: (Int(endX) ?? 0, Int(endY) ?? 0))
            })
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text(Constants.Help.torpedoesHelp)
          })
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.photonTubes] < 0.9 || game.enterpriseCondition != "RED")
      
      //DAMAGE CONTROL
      Button(action: {game.damageControl()
        if game.enterpriseSystemsDamaged && game.docked {repairAlert = true}})
      {CommandText(text: "Damage Control")}
        .alert("Damage Repairs will take: " + String(game.timeToRepair) + " stardates.", isPresented: $repairAlert) {
          Button("Authorise", action: {game.repairDamage()})
          Button("Cancel", role: .cancel, action: {})
        }
        .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.damageControl] < 0.9)
      
      //SHIELD CONTROL
      Button(action: {shieldControlAlert = true})
      {
        CommandText(text: "Shield   Control")
          .alert("Shield Control", isPresented: $shieldControlAlert, actions: {
            TextField("Energy to transfer to Shields", text: $energyToShields)
              .keyboardType(.numberPad) // Set the keyboard type to number pad
                  .onReceive(Just(energyToShields)) { newValue in
                      let filtered = newValue.filter { "0123456789".contains($0) } // Allow only numeric input
                      if filtered != newValue {
                          self.energyToShields = filtered
                      }
                  }
              .onSubmit {
                energyToShields = String(game.enterpriseEnergy + game.enterpriseShields) + " available"
              }
              .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing}
            Button("Change", action: {
              let change = Int(energyToShields) ?? 0
              game.displayBlankLine()
              if change <= 0 || game.enterpriseShields == change {
                game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORTS: Shields unchanged"))
              } else {
                if change <= game.enterpriseEnergy + game.enterpriseShields {
                  game.enterpriseEnergy = game.enterpriseEnergy + game.enterpriseShields - change
                  game.enterpriseShields = change
                  game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORTS: Shields now at \(game.enterpriseShields) units per your command."))
                  game.shortRangeScan()
                } else {
                  game.messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL ROOM REPORTS: This is not the Federation Treasury!"))
                }
              }
            })
            Button("Cancel", role: .cancel, action: {})
          }, message: {
            Text(Constants.Help.shieldsHelp)
          })
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.shieldControl] < 0.9)
      
      //COMPUTER
      Button(action: {computerAlert = true})
      {
        CommandText(text: "Library Computer")
          .alert("Ship Computer Active", isPresented: $computerAlert, actions: {
            Button("Cumulative Galactic Record", role: nil, action: {game.cumulativeGalacticRecord(regionNameMap: false)})
            Button("Status Report", action: {game.statusReport()})
            Button("Enemy Ship Data", action: {game.getEnemyShipData()})
            Button("Starbase Navigation Data", action: {game.getStarbaseNavData()})
            Button("Galactic Region Name Map", action: {game.cumulativeGalacticRecord(regionNameMap: true)})
            Button("Debugging Data", action: {game.getDebugData()})
            Button("Cancel", role: .cancel, action: {
            })
          }, message: {
            Text("Select Option")
          })
      }
      .disabled(!game.gameStarted || game.enterpriseDamage[Constants.SystemNumber.libraryComputer] < 0.9)
    }
    .padding()
  }
}

struct MainScreenView_Previews: PreviewProvider {
  static private var game = Binding.constant(Game())
  static var previews: some View {
    MainScreenView(game: game)
      .previewInterfaceOrientation(.landscapeLeft)
    MainScreenView(game: game)
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
