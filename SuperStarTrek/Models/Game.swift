//
//  Game.swift
//  SuperStarTrek
//
//  Created by David Parker on 15/02/2023.
//

import Foundation
import SwiftUI

var eQuadrantName = "" //G2$
let gQuadrantNames = [["Antares","Rigel","Procyon","Vega","Canopus","Altair","Sagittarius","Pollux"], ["Sirius","Deneb","Capella","Betelgeuse","Aldebaran","Regulus","Arcturus","Spica"]] //Not stored in original BASIC program
let gSectorNames = [" I"," II"," III"," IV"] //Not stored in original BASIC program

struct MessageEntry: Equatable, Identifiable {
  let line: String
  var id = UUID()
}

struct Game {
  var basesRemaining = 0 //B9 starbases
  var basesInQuadrant = 0
  
  let condition = ["GREEN","YELLOW","RED"]
  
  var damageFactor = 0.00
  var daysLeft: Int = 25 + Int.random(in:1...10) //T9 Set to 25 + Int.random(in:1...10)
  var debug = true //To cause debug messages to be printed to the console
  var docked = false // D0 docked flag (set to 0 = false at start) to indicate whether Enterprise is docked or not
  
  var energyRequired = 0 //N
  var enterpriseCondition = "GREEN" //C$
  var enterpriseDamage = Array(repeating: 1.00, count: 10) //Set operating efficiency at 1.00 (equivalent to 100%) for each of 9 systems = D(9)
  var enterpriseDestroyed: Bool = false // Flag to indicate Enterprise has been destroyed
  var enterpriseEnergy = Constants.Game.originalEnergy //E initial energy = 3000
  var enterpriseShields = 0 //S shields
  var enterpriseStardate = Constants.Game.originalStardate + Int.random(in:1...20) * 100//T current stardate from 2,000 to 4,000
  var enterpriseSystemsDamaged = false
  var enterpriseTorpedoes = Constants.Game.originalTorpedoes //P number of torpedoes
  var explored = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9) //Z() discovered galaxy
  
  var galaxy = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9) //G() undiscovered galaxy
  var gameOver = false
  var gameStarted = false
  
  var klingons = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 4) //K() klingon data for current quadrant
  var klingonsInQuadrant = 0
  var klingonsRemaining = 0 //K9 klingons
  var klingonsStarting = 0 //K7
  
  var romulans = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 4) //Romulan data for galaxy
  // [0] and [1] quadrant coordinates [2] and [3] sector coordinates [4] cloaked 0 = false 1=true [5] energy 0-400
  var romulansInQuadrant = 0
  var romulansRemaining = 0
  var romulansStarting = 0
  var romulanVessel = 0 //Romulan vessel number
  var cloaked = 1 // cloaked flag (set to 1 = true at start) to indicate whether Romulan is cloaked or not
  
  var lrs = [0,0,0,0,0,0,0,0,0] //Used in building Long Range ", Galactic Record
  
  //var maxWarp = "8.0" //Normal maxiumum Warp Factor
  var messageEntries: [MessageEntry] = [] //Stores output screen
  
  var quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)//Q$
  var quadrantCoordinates = (0,0)
  
  var sectorCoordinates = (0,0)
  let systems = ["EMPTY","Impulse Engines","Warp Engines","Short Range Sensors","Long Range Sensors","Phaser Control","Photon Tubes","Damage Control","Shield Control","Library Computer"]
  var starbase = Array(repeating: Array(repeating: 0, count: 6), count: 7)
  // [0] = quadrantRow (1-8), [1] = quadrantCol (1-8), [2] = condition (1-3), [3] = efficiency (0-100), [4] = energy, [5} = torpedoes
  var starsInQuadrant = 0
  var startingStardate = 0
  
  var temp = 0
  var temp$ = "" //Used in building Long Range ", Galactic Record
  var timeToRepair = 0
  
  // MARK: Game Control Functions
  mutating func startGame() {
    if debug {print("startGame()")}
    var isAre = "is"
    var starbases = "Starbase"
    
    // Set up initial values
    
    // Clear arrays
    enterpriseDamage = Array(repeating: 1.00, count: 10) // 100%
    for index in 0..<enterpriseDamage.count {
      enterpriseDamage[index] = 1.00
    }
    messageEntries.removeAll()
    klingons = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 4)
    romulans = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 4)
    quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)
    
    // Game status
    gameStarted = false
    gameOver = false
    // Consider changing daysLeft to 25 + Int.random(in:1...klingonsStarting) to increase or reduce the number of days available
    daysLeft = 25 + Int.random(in:1...10) //T9 Set to 25 + Int.random(in:1...10)
    if debug {print("Starting Stardate: \(startingStardate) Enterprise Stardate: \(enterpriseStardate)")}
    
    // Enterprise status
    enterpriseCondition = "GREEN" //C$
    docked = false // D0 docked flag (set to 0 = false at start) to indicate whether Enterprise is docked or not
    enterpriseEnergy = Constants.Game.originalEnergy //E initial energy = 3000
    enterpriseShields = 0 //S shields
    enterpriseStardate = Constants.Game.originalStardate + Int.random(in:1...20) * 100//T current stardate from 2,000 to 4,000
    startingStardate = enterpriseStardate
    enterpriseSystemsDamaged = false
    enterpriseTorpedoes = Constants.Game.originalTorpedoes //P number of torpedoes
    
    // Galaxy information
    explored = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    galaxy = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    timeToRepair = 0
    
    // Position Enterprise at random location
    sectorCoordinates.0 = Int.random(in:1...8)//S1
    sectorCoordinates.1 = Int.random(in:1...8) //S2
    quadrantCoordinates.0 = Int.random(in:1...8) //Q1
    quadrantCoordinates.1 = Int.random(in:1...8) //Q2
    if debug {print("Enterprise randomly located in Quadrant \(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(sectorCoordinates.0),\(sectorCoordinates.1)")}
    
    // Set up galaxy
    // Klingons
    klingonsStarting = 0 //K7
    klingonsRemaining = 0 //K9 klingons
    
    // Romulans
    romulansStarting = 0 //
    romulansRemaining = 0 //
    
    // Starbases
    basesRemaining = 0 //B9 starbases
    
    for i in 1...8 {
      for j in 1...8 {
          klingonsInQuadrant = 0 //Start with 0 Klingons
          basesInQuadrant = 0// and no Starbases
          romulansInQuadrant = 0 // and no Romulans
        if debug {print("i = \(i), j = \(j)")}
          galaxy[i][j] = 0 //Clear unknown galaxy quadrant
          explored[i][j] = 0 //Clear known galaxy quadrant
          switch Int.random(in:1...99) {
          case 98...99 : //Add 3 Klingons
              klingonsInQuadrant = 3
              klingonsRemaining += 3
          case 95..<98: //Add 2 Klingons
              klingonsInQuadrant = 2
              klingonsRemaining += 2
          case 88..<95: //Add 1 Klingon
              klingonsInQuadrant = 1
              klingonsRemaining += 1
          default: //Add no Klingons
              klingonsInQuadrant = 0
          }
        if (i == 1 && j <= 4 || i == 8 && j >= 5)   && Int.random(in:1...99) > 94 { //Add 1 Romulan
          romulansInQuadrant = 1
          romulansRemaining += 1
          romulans[romulansRemaining][0] = i // Quadrant coordinates
          romulans[romulansRemaining][1] = j // Quadrant coordinates
          romulans[romulansRemaining][2] = 0 // Sector coordinates assigned when enetering the quadrant
          romulans[romulansRemaining][3] = 0 // Sector coordinates assigned when enetering the quadrant
          romulans[romulansRemaining][5] = Int(Double(Constants.Game.originalRomulanEnergy) * (Double.random(in: 0.50..<1.50))) // Energy
        }
          if Int.random(in: 1...99) > 96 && basesRemaining <= 5 { //Add 1 Starbase
              basesInQuadrant = 1
              basesRemaining += 1
              starbase[basesRemaining][0] = i
              starbase[basesRemaining][1] = j
              starbase[basesRemaining][2] = 0 // Condition GREEN
              starbase[basesRemaining][3] = Int.random(in:90..<100)
              starbase[basesRemaining][4] = 10000
              starbase[basesRemaining][5] = 200
              }
          starsInQuadrant = Int.random(in:1...8) //Add between 1 and 8 Stars
          galaxy[i][j] = romulansInQuadrant * 1000 + klingonsInQuadrant * 100 + basesInQuadrant * 10 + starsInQuadrant
          if debug {print("Galaxy Quadrant \(i),\(j) has \(klingonsInQuadrant) Klingon, \(romulansInQuadrant) Romulan, \(basesInQuadrant) Starbase and \(starsInQuadrant) Star")}
      }
      if klingonsRemaining > daysLeft {
        daysLeft = klingonsRemaining + 1
      }
    }
    if basesRemaining == 0 { //If there are no Starbases in the galaxy
      if galaxy[quadrantCoordinates.0][quadrantCoordinates.1] < 200 { //If there are less than 2 Klingons in the Enterprise Quadrant then add 1
        galaxy[quadrantCoordinates.0][quadrantCoordinates.1] += 100
        klingonsRemaining += 1
      }
      basesRemaining = 1 //Add a Starbase in the Enterprise Quadrant
      starbase[basesRemaining][0] = quadrantCoordinates.0
      starbase[basesRemaining][1] = quadrantCoordinates.1
      starbase[basesRemaining][2] = 0 // Condition GREEN
      starbase[basesRemaining][3] = Int.random(in:90..<100)
      starbase[basesRemaining][4] = 10000
      starbase[basesRemaining][5] = 200
      galaxy[quadrantCoordinates.0][quadrantCoordinates.1] += 10
      quadrantCoordinates.0 = Int.random(in:1...8) // Reposition the Enterprise
      quadrantCoordinates.1 = Int.random(in:1...8)
      sectorCoordinates.0 = Int.random(in:1...8)//S1
      sectorCoordinates.1 = Int.random(in:1...8) //S2
      if debug {print("Enterprise repositioned in Quadrant \(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(sectorCoordinates.0),\(sectorCoordinates.1)")}
    }
    klingonsStarting = klingonsRemaining
    romulansStarting = romulansRemaining
    if debug {print("Klingons = \(klingonsRemaining), Romulans = \(romulansRemaining), Starbases = \(basesRemaining)")}
    quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)
    // Display mission
    if (basesRemaining != 1) {//Set up correct syntax for Starbase quantity
      isAre = "are"
      starbases = "Starbases"
    }
    messageEntries.append(MessageEntry(line: "               THE USS ENTERPRISE --- NCC-1701              "))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "It is Stardate \(enterpriseStardate). Your mission is to destroy the \(klingonsRemaining) Klingon warships that have invaded the Galaxy before they can attack Federation Headquarters on Stardate \(enterpriseStardate + daysLeft)."))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "This gives you \(daysLeft) days to complete your mission. There " + isAre + " \(basesRemaining) " + starbases + " in the Galaxy for resupplying your ship."))
    if romulansStarting > 0 {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "Powerful Romulan Birds-of-Prey have appeared on the edges of the Galaxy in the Arcturus or Spica regions. They are undetectable due to their cloaking devices unless materialising to attack."))
    }
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "Press Resign Command to reject the mission, New Mission for a different mission or use the buttons below to take command. "))
    displayBlankLine()
    // Enter quadrant
    enterNewQuadrant()
    // Identify condition and warn accordingly
    getCommand()
  }
  mutating func displayBlankLine() {
    if debug {print("displayBlankLine()")}
    messageEntries.append(MessageEntry(line: "                                                            "))
  }
  mutating func getCommand () {
    if debug {print("getCommand()")}
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "SELECT COMMAND:"))
  }
  mutating func endGame(reason: String){
    if debug {print("endGame() - \(reason)")}
    var efficiency = 0.0
    gameOver = true
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "*** GAME OVER ***"))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "It is Stardate \(enterpriseStardate)."))
    switch reason {
    case "Destroyed" :
      displayBlankLine()
    case "Starbase" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "That does it, Captain! You are hearby relieved of command and sentenced to 99 Stardates of hard labour at Cygnus 12!!"))
    case "Resigned" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "There were \(klingonsRemaining) Klingon battle cruisers left at the end of your mission."))
    case "Time" :
      displayBlankLine()
    case "Success" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "Congratulations, Captain! The Last Klingon battle cruiser menacing the Federation has been destroyed."))
      
    default :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "Some other reason???"))
    }
    displayBlankLine()
    //6400 PRINT"YOUR EFFICIENCY RATING IS";1000*(K7/(T-T0))^2:GOTO 6290
    
    // Variables
    let klingonsDestroyed = klingonsStarting - klingonsRemaining
    let totalDaysTaken = enterpriseStardate - startingStardate
    if debug {print("Total Days Taken \(totalDaysTaken) Enetrprise Stardate \(enterpriseStardate) Starting Stardate \(startingStardate)")}
    print("Klingons destroyed \(klingonsDestroyed)")
    print("Total Days Taken \(totalDaysTaken)")
    
    // Calculate Efficiency Rating
    efficiency = 1000 * Double(klingonsDestroyed) / Double(totalDaysTaken)

    // Output Efficiency Rating
    print("Your Efficiency Rating is \(efficiency)")

    // Additional message based on remaining enemy ships
    if klingonsRemaining > 0 {
        print("The mission is not complete. \(klingonsRemaining) enemy ships are still remaining.")
    } else {
        print("Congratulations! All enemy ships have been destroyed.")
    }
    messageEntries.append(MessageEntry(line: "Your Efficiency Rating is \(efficiency)"))
    if basesRemaining > 0 {
      messageEntries.append(MessageEntry(line: "The Federation is in need of a new Starship Commander for a similar mission. If you wish to volunteer press New Mission."))
    }
  }
  // MARK: Navigation Functions
  //Calculate the distance between two points on an 8 by 8 grid
  mutating func calculateDistance(from point1: (Int, Int), to point2: (Int, Int)) -> Int {
    if debug {print("calculateDistance()")}
    let deltaX = abs(point2.0 - point1.0)
    let deltaY = abs(point2.1 - point1.1)
    return max(deltaX, deltaY)
  }
  mutating func impulseEngines(currentSector: (Int, Int), targetSector: (Int, Int)) -> (Int, Int) {
    if debug {print("impulseEngines()")}

    var newSector = currentSector
    var previousSector = currentSector
    var movement = 0
    var repairFactor = 0.00
    var systemNumber = 0
    
    // Check if the destination is within bounds
    guard targetSector.0 >= 1 && targetSector.0 <= 8 && targetSector.1 >= 1 && targetSector.1 <= 8 else {
      messageEntries.append(MessageEntry(line: "LT. SULU REPORTS: Incorrect course data, Sir!"))
      return previousSector
    }
    // Calculate distance and energy required
    movement = calculateDistance(from: currentSector, to: targetSector)
    energyRequired = Int(Double(calculateDistance(from: currentSector, to: targetSector)) * 1.0 + 0.5)
    if enterpriseEnergy < energyRequired {//Not enough energy so message and exit
      messageEntries.append(MessageEntry(line: "ENGINEERING REPORTS: Insufficient energy for moving to Sector \(targetSector.0),\(targetSector.1)!"))
      if enterpriseShields >= (energyRequired - enterpriseEnergy) && enterpriseDamage[Constants.SystemNumber.impulseEngines] >= 0 {//Use shields to make up for shortage of energy as long as they're not damaged
        messageEntries.append(MessageEntry(line: "DEFLECTOR CONTROL REPORTS: Acknowledges \(enterpriseShields) units of energy presently deployed to Shields. Return energy to main banks to proceed."))
      }
      return targetSector
    }
    
    // Check if Impules Engines damaged
    if enterpriseDamage[Constants.SystemNumber.impulseEngines] < 0.9 {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: Impulse engines are damaged - Maximum movement 2 Sectors"))
      return targetSector
    }
    
    // Klingons move before Enterprise
    if klingonsInQuadrant != 0 {
      for i in 1...klingonsInQuadrant {
        quadrant[klingons[i][1]][klingons[i][2]] = "   "
        let coordinates = findEmptyPlaceinQuadrant()
        klingons[i][1] = coordinates.0
        klingons[i][2] = coordinates.1
        quadrant[klingons[i][1]][klingons[i][2]] = "+K+"
      }
      //Klingons fire before Enterprise moves
      klingonsShooting()
      if enterpriseDestroyed {
        endGame(reason: "Destroyed")
      }
    }
    
    // Romulan moves before Enterprise
    if romulansInQuadrant != 0 {
      quadrant[romulans[romulanVessel][2]][romulans[romulanVessel][3]] = "   "
        let coordinates = findEmptyPlaceinQuadrant()
        romulans[romulanVessel][2] = coordinates.0
        romulans[romulanVessel][3] = coordinates.1
        romulans[romulanVessel][4] = 0
        cloaked = 0
        quadrant[romulans[romulanVessel][2]][romulans[romulanVessel][3]] = "=R="

      //Romulan fires before Enterprise moves
      romulansShooting()
      if enterpriseDestroyed {
        endGame(reason: "Destroyed")
      }
    }
    
    // Check for damage repaired during movement
    repairFactor = Double(movement) / 9.0
    for i in 1...9 {
      if enterpriseDamage[i] < 1.00 {
        enterpriseDamage[i] = enterpriseDamage[i] + repairFactor //Moving 1 Sector repair by 0.1
        if debug {print("Using Impulse Engines repairing \(systems[i]) to \(enterpriseDamage[i])")}
        if enterpriseDamage[i] > 1.00 {enterpriseDamage[i] = 1.00} //If over 1 then set to 1
        if enterpriseDamage[i] >= 1.00 {messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[i]) repair completed."))} //If 1.00 then report repaired
      }
    }
    
    // Random damage caused or repair progressing
    if Int.random(in:0...100) <= 2 {
      systemNumber = Int.random(in: 1...9)
      if Double.random(in: 0.00...0.99) >= 0.6 { // Repair
        enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] + Double.random(in: 0.0...0.3) + 0.1
        if enterpriseDamage[systemNumber] > 1.00 {enterpriseDamage[systemNumber] = 1.00} //If over 1 then set to 1
        displayBlankLine()
        if debug {print("Using Impulse Engines repairing \(systems[systemNumber]) to \(enterpriseDamage[systemNumber])")}
        messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) state of repair improved."))
      } else {
        enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] - Double.random(in: 0.00...0.5) + 0.1
        if debug {print("Using Impulse Engines repairing \(systems[systemNumber]) damaged to \(enterpriseDamage[systemNumber])")}
        displayBlankLine()
        messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) damaged."))
      }
    }
    
    // Move the Enterprise
    while newSector != targetSector {
      // Store the current Sector as the previous Sector
      previousSector = newSector
        
      // Determine the direction to move
      let deltaX = targetSector.0 - newSector.0
      let deltaY = targetSector.1 - newSector.1
    
      // Move one step in the direction
      if deltaX != 0 {
          newSector.0 += deltaX > 0 ? 1 : -1
      }
      if deltaY != 0 {
          newSector.1 += deltaY > 0 ? 1 : -1
      }

      // Check if the new Sector contains an obstacle
      if quadrant[newSector.0][newSector.1] != "   " {
        quadrant[currentSector.0][currentSector.1] = "   "
        sectorCoordinates = previousSector
        quadrant[previousSector.0][previousSector.1] = "<*>"
        displayBlankLine()
        messageEntries.append(MessageEntry(line: "*** IMPULSE ENGINES SHUT DOWN AT SECTOR \(sectorCoordinates.0),\(sectorCoordinates.1) DUE TO BAD NAVIGATION ***"))
        // Check if collided with Romulan
        if debug {print(" newSector coordinates \(quadrant[newSector.0][newSector.1])")}
        if debug {print(" currentSector coordinates \(quadrant[currentSector.0][currentSector.1])")}
        if quadrant[newSector.0][newSector.1] == "=R=" {
          // Check if cloaked and uncloak because of collision
          messageEntries.append(MessageEntry(line: "*** CLOAKED ROMULAN IN SECTOR \(newSector.0),\(newSector.1) ***"))
          romulans[romulanVessel][4] = 0
          cloaked = 0
          messageEntries.append(MessageEntry(line: "*** ROMULAN NOW VISIBLE IN SECTOR \(newSector.0),\(newSector.1) ***"))
        }
        checkIfDocked()
        shortRangeScan()
      return previousSector
      }
      // Decide on damage or repair
      if Int.random(in:0...99) <= 2 {
        systemNumber = Int.random(in: 1...9)
        if Int.random(in: 0...99) >= 6 {
          enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] + Double.random(in: 0.00...1.00) * 0.3 + 0.1
          if enterpriseDamage[systemNumber] > 1.00 {enterpriseDamage[systemNumber]
            displayBlankLine()
            messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) state of repair improved."))}
        } else {
          enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] - Double.random(in: 0.00...1.00) * 0.5 + 0.1
          displayBlankLine()
          messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) damaged."))
        }
      }
      // Move the object to the new Sector
      quadrant[previousSector.0][previousSector.1] = "   "
      sectorCoordinates = newSector
      quadrant[newSector.0][newSector.1] = "<*>"
    }
    // Movement completed - Increment Stardate based on 9 sectors per quadrant
    enterpriseStardate += Int(Double(movement)/9 + 0.5)
    if enterpriseStardate > startingStardate + daysLeft {
      if debug {print("Enterprise Stardate: \(enterpriseStardate) Starting Stardate: \(startingStardate) Days Left: \(daysLeft)")}
      endGame(reason: "Time")
    }
    consumeEnergy()
    checkIfDocked()
    shortRangeScan()
  return newSector
  }
  mutating func warpDrive(currentQuadrant: (Int, Int), targetQuadrant: (Int, Int)) -> (Int, Int) {
    if debug {print("warpDrive()")}
    var newQuadrant = currentQuadrant
    var previousQuadrant = currentQuadrant
    var movement = 0
    var repairFactor = 0.00
    var systemNumber = 0
    
    // Check if the destination is within bounds
    guard targetQuadrant.0 >= 1 && targetQuadrant.0 <= 8 && targetQuadrant.1 >= 1 && targetQuadrant.1 <= 8 else {
      messageEntries.append(MessageEntry(line: "LT. SULU REPORTS: Incorrect course data, Sir!"))
      return previousQuadrant
    }
    // Calculate distance and energy required
    movement = calculateDistance(from: currentQuadrant, to: targetQuadrant)
    if debug {print("Warp Drive movement: \(movement)")}
    energyRequired = Int(Double(calculateDistance(from: currentQuadrant, to: targetQuadrant)) * 8.0 + 0.5)
    if enterpriseEnergy < energyRequired {//Not enough energy so message and exit
      messageEntries.append(MessageEntry(line: "ENGINEERING REPORTS: Insufficient energy for moving to Quadrant \(targetQuadrant.0),\(targetQuadrant.1)!"))
      if enterpriseShields >= (energyRequired - enterpriseEnergy) && enterpriseDamage[Constants.SystemNumber.warpDrive] >= 0 {//Use shields to make up for shortage of energy as long as they're not damaged
        messageEntries.append(MessageEntry(line: "DEFELECTOR CONTROL REPORTS: Acknowledges \(enterpriseShields) units of energy presently deployed to Shields. Return energy to main banks to proceed."))
      }
      return targetQuadrant
    }
    
    // Check if Warp Drive damaged
    if enterpriseDamage[Constants.SystemNumber.warpDrive] < 0.9 {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: Warp Drive is damaged - Maximum movement 2 Quadrants"))
      return targetQuadrant
    }
    
    // Klingons move before Enterprise
    if klingonsInQuadrant != 0 {
      for i in 1...klingonsInQuadrant {
        quadrant[klingons[i][1]][klingons[i][2]] = "   "
        let coordinates = findEmptyPlaceinQuadrant()
        klingons[i][1] = coordinates.0
        klingons[i][2] = coordinates.1
        quadrant[klingons[i][1]][klingons[i][2]] = "+K+"
      }
      //Klingons fire before Enterprise moves
      klingonsShooting()
      if enterpriseDestroyed {
        endGame(reason: "Destroyed")
      }
    }
    
    // Check for damage repaired during movement
    repairFactor = Double(movement) * 8
    for i in 1...8 {
      if enterpriseDamage[i] < 1.00 {
        enterpriseDamage[i] = enterpriseDamage[i] + repairFactor //Moving 1 Quadrant repair by 0.1
        if (enterpriseDamage[i] > 1.00) {enterpriseDamage[i] = 1.00} //If over 1.00 go back to 1.00
        if enterpriseDamage[i] >= 1.00 {messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[i]) repair completed."))}
        }
    }
    
    // Decide on damage or repair
    if Int.random(in:0...99) <= 2 {
      systemNumber = Int.random(in: 1...9)
      if Int.random(in: 0...99) >= 6 {
        enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] + Double.random(in: 0.00...1.00) * 0.3 + 0.1
        if enterpriseDamage[systemNumber] > 1.00 {enterpriseDamage[systemNumber]
          displayBlankLine()
          messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) state of repair improved."))}
      } else {
        enterpriseDamage[systemNumber] = enterpriseDamage[systemNumber] - Double.random(in: 0.00...1.00) * 0.5 + 0.1
        displayBlankLine()
        messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemNumber]) damaged."))
      }
    }
    // Move the Enterprise
    while newQuadrant != targetQuadrant {
      // Store the current Sector as the previous Sector
      previousQuadrant = newQuadrant
        
      // Determine the direction to move
      let deltaX = targetQuadrant.0 - newQuadrant.0
      let deltaY = targetQuadrant.1 - newQuadrant.1
    
      // Move one step in the direction
      if deltaX != 0 {
          newQuadrant.0 += deltaX > 0 ? 1 : -1
      }
      if deltaY != 0 {
          newQuadrant.1 += deltaY > 0 ? 1 : -1
      }
    }
    quadrantCoordinates = targetQuadrant
    quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)
    // Decide on damage or repair
    
    // Movement completed - Increment Stardate based on 1 Stardate per Quadrant moved
    enterpriseStardate += Int(Double(movement) + 0.5)
    if enterpriseStardate > startingStardate + daysLeft {
      endGame(reason: "Time")
      if debug {print("Enterprise Stardate: \(enterpriseStardate) Starting Stardate: \(startingStardate) Days Left: \(daysLeft)")}
    }
    enterNewQuadrant()
    consumeEnergy()
    checkIfDocked()
  return newQuadrant
  }
  
  mutating func consumeEnergy() {
    if debug {print("consumeEnergy")}
    enterpriseEnergy -= energyRequired;  // a warp speed of 8 consumes 8x8+10 =74 energy, speed 1 instead 1x8+10 =18
    if(enterpriseEnergy >= 0) {
      return //EnergyLevel OK
    }
    messageEntries.append(MessageEntry(line: "Shield Control supplies energy to complete the manoeuvre."))
    enterpriseShields += enterpriseEnergy
    enterpriseEnergy = 0
    if enterpriseEnergy <= 0  {
      enterpriseEnergy = 0
    }
  }
  mutating func checkIfDocked() -> (Bool) {
    if debug {print("checkIfDocked()")}
    docked = false
      for i in sectorCoordinates.0 - 1...sectorCoordinates.0 + 1 {
          for j in sectorCoordinates.1 - 1...sectorCoordinates.1 + 1 {
            let ii = i
            let jj = j
        if (ii >= 1 && ii <= 8 && jj >= 1 && jj <= 8) {
          if quadrant[i][j] == ">!<" {
            docked = true
            enterpriseCondition = "DOCKED"
            enterpriseEnergy = 3000
            enterpriseTorpedoes = 10
              displayBlankLine()
            messageEntries.append(MessageEntry(line: "Shields dropped for docking."))
            messageEntries.append(MessageEntry(line: "Energy levels and Photon Torpedoes replenished."))
            enterpriseShields = 0
            enterpriseCondition = checkShipStatus()
          }
        }
      }
    }
    return docked
  }
  
  mutating func enterNewQuadrant () {
    if debug {print("enterNewQuadrant()")}
    klingonsInQuadrant = 0
    romulansInQuadrant = 0
    basesInQuadrant = 0
    starsInQuadrant = 0
    
    //Get Quadrant name and region
    if quadrantCoordinates.0 <= 4 {
      eQuadrantName = gQuadrantNames[0][quadrantCoordinates.0 - 1]
    } else {
      eQuadrantName = gQuadrantNames[1][quadrantCoordinates.0 - 1]
    }
    if quadrantCoordinates.1 <= 4 {
      eQuadrantName = eQuadrantName + gSectorNames[quadrantCoordinates.1 - 1 ]
    } else {
      eQuadrantName = eQuadrantName + gSectorNames[quadrantCoordinates.1 - 5 ]
    }
    if !gameStarted {//Print starting Quadrant
      messageEntries.append(MessageEntry(line: "Your mission begins with your starship located in the       "))
      gameStarted = true
    } else {//Print entering new Quadrant
      messageEntries.append(MessageEntry(line: "Now entering Quadrant . . .                         "))
    }
    messageEntries.append(MessageEntry(line: "Galactic Quadrant \(eQuadrantName) Quadrant \(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(sectorCoordinates.0),\(sectorCoordinates.1) "))
    
    //Get contents of Quadrant
    romulansInQuadrant = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]/1000
    temp = galaxy[quadrantCoordinates.0][quadrantCoordinates.1] - (romulansInQuadrant * 1000)
    klingonsInQuadrant = temp/100
    temp = temp - (klingonsInQuadrant * 100)
    basesInQuadrant = temp/10
    starsInQuadrant = temp - (basesInQuadrant * 10)
    if debug {print("Romulans: \(romulansInQuadrant) Klingons: \(klingonsInQuadrant) Bases: \(basesInQuadrant) Stars: \(starsInQuadrant)")}
    
    //Set Condition
    if klingonsInQuadrant > 0 || romulansInQuadrant > 0 {
      messageEntries.append(MessageEntry(line: "*** COMBAT AREA - CONDITION RED ***"))
      enterpriseCondition = "RED"
      if romulansInQuadrant > 0 {
        if cloaked == 1 {
          messageEntries.append(MessageEntry(line: "Romulan Warbird present but cloaked."))
        } else {
          messageEntries.append(MessageEntry(line: "Romulan Warbird uncloaked."))
        }
      }
      if enterpriseShields < 400 {
        messageEntries.append(MessageEntry(line: "*** SHIELDS DANGEROUSLY LOW ***"))
      }
    }
    damageFactor = 0.5 * Double.random(in:0.1..<1.0)//D4=.5*RND(1) NOT SURE IF THIS IS BEING USED
    
    //Position Enterprise
    quadrant[sectorCoordinates.0][sectorCoordinates.1] = "<*>"
    if debug {print("Enterprise positioned at Quadrant\(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(sectorCoordinates.0),\(sectorCoordinates.1)")}
    
    //Position Klingons if there are any
    if klingonsInQuadrant > 0 {
      for i in 1...klingonsInQuadrant {
        let coordinates = findEmptyPlaceinQuadrant()
        quadrant[coordinates.0][coordinates.1] = "+K+"//Klingon
        klingons[i][1] = coordinates.0
        klingons[i][2] = coordinates.1
        klingons[i][3] = Int(Double(Constants.Game.originalKlingonEnergy) * (Double.random(in: 0.5..<1.5)))
        if debug {print("Klingon \(i) positioned at Quadrant\(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(coordinates.0),\(coordinates.1) Energy \(klingons[i][3])")}
      }
    }
    
    //Position Romulans if there are any
    if romulansInQuadrant > 0 {
      // Find which Romulan it is is and position it
      romulanVessel = 0
      for i in 1...romulansRemaining {
        if romulans[i][0] == quadrantCoordinates.0 && romulans[i][1] == quadrantCoordinates.1 {
          romulanVessel = i
          let coordinates = findEmptyPlaceinQuadrant()
          quadrant[coordinates.0][coordinates.1] = "=R="
          romulans[romulanVessel][2] = coordinates.0
          romulans[romulanVessel][3] = coordinates.1
          romulans[romulanVessel][4] = 1 //Cloaked
          if debug {print("Romulan \(i) positioned at Quadrant \(quadrantCoordinates.0),\(quadrantCoordinates.1) Sector \(coordinates.0),\(coordinates.1) Cloaked = \(romulans[i][4]) Energy \(romulans[i][5])")}
          break
        }
      }
    }
    //Position Starbase if there is one
    if basesInQuadrant > 0 {
      let coordinates = findEmptyPlaceinQuadrant()
      quadrant[coordinates.0][coordinates.1] = ">!<"
    }
    
    //Position Stars
    for _ in 1...starsInQuadrant {
      let coordinates = findEmptyPlaceinQuadrant()
      quadrant[coordinates.0][coordinates.1] = " * "
    }
    //shortRangeScan()
  }
  // MARK: Scanner Functions
  mutating func shortRangeScan() {
    if debug {print("shortRangeScan()")}
    enterpriseCondition = checkShipStatus()
    displayBlankLine()
    if enterpriseDamage[Constants.SystemNumber.shortRangeSensors] < 0.9 {
      messageEntries.append(MessageEntry(line: "*** SHORT RANGE SENSORS ARE OUT ***"))
    } else {
      messageEntries.append(MessageEntry(line: "SHORT RANGE SCAN FOR QUADRANT \(quadrantCoordinates.0),\(quadrantCoordinates.1)"))
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "    1  2  3  4  5  6  7  8                                     "))
      messageEntries.append(MessageEntry(line: "   ------------------------                                    "))
      var mySubstring: Substring
      var myString: String
      mySubstring = ""
      for i in 1...8 {
        mySubstring = "\(i)|"
        for j in 1...8 {
          if quadrant[i][j] == "=R=" && cloaked == 1 {
            mySubstring = mySubstring + "   "
          } else {
            mySubstring = mySubstring + quadrant[i][j]
          }
          //mySubstring = mySubstring + quadrant[i][j]
        }
        switch i{
        case 1:
          mySubstring = mySubstring + "  STARDATE \(enterpriseStardate)"
        case 2:
          mySubstring = mySubstring + "  CONDITION \(enterpriseCondition)"
        case 3:
          mySubstring = mySubstring + "  QUADRANT \(quadrantCoordinates.0),\(quadrantCoordinates.1)"
        case 4:
          mySubstring = mySubstring + "  SECTOR \(sectorCoordinates.0),\(sectorCoordinates.1)"
        case 5:
          mySubstring = mySubstring + "  PHOTON TORPEDOES \(enterpriseTorpedoes)"
        case 6:
          mySubstring = mySubstring + "  ENERGY \(enterpriseEnergy)"
        case 7:
          mySubstring = mySubstring + "  SHIELDS \(enterpriseShields)"
        case 8:
          mySubstring = mySubstring + "  KLINGONS REMAINING \(klingonsRemaining)"
        default:
          print("Error")
        }
        myString = mySubstring.padding(toLength: 60, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
      }
      messageEntries.append(MessageEntry(line: "   ------------------------                                    "))
      messageEntries.append(MessageEntry(line: "<*> Enterprise +K+ Klingon =R= Romulan >!< Starbase  *  Star"))
      explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
    }
    getCommand()
  }
  mutating func longRangeScan() {
    if debug {print("longRangeScan()")}
    
    displayBlankLine()
    if enterpriseDamage[Constants.SystemNumber.longRangeSensors] < 0.9 {
      messageEntries.append(MessageEntry(line: "*** LONG RANGE SENSORS ARE OUT ***"))
    } else {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "LONG RANGE SCAN FROM QUADRANT \(quadrantCoordinates.0),\(quadrantCoordinates.1)"))
      displayBlankLine()
      temp$ = ""
      if (quadrantCoordinates.1)-1 < 1 {temp$ = "  ... .."}
        else {temp$ = "  ...\((quadrantCoordinates.1)-1).."}
      temp$ = temp$ + "...\(quadrantCoordinates.1).."
      if (quadrantCoordinates.1)+1 > 8 {temp$ = temp$ + "... ..."}
        else {temp$ = temp$ + "...\(quadrantCoordinates.1+1)..."}
      messageEntries.append(MessageEntry(line: temp$))
      messageEntries.append(MessageEntry(line: "  -------------------"))
      for i in quadrantCoordinates.0 - 1...quadrantCoordinates.0 + 1 {
        lrs[1] = -1
        lrs[2] = -2
        lrs[3] = -3
        for j in quadrantCoordinates.1 - 1...quadrantCoordinates.1 + 1 {
          if i > 0 && i < 9 && j > 0 && j < 9 {
            lrs[j - quadrantCoordinates.1 + 2] = galaxy[i][j]
            explored[i][j] = galaxy[i][j]
          }
        }
        temp$ = "\(i)|"
        if i<1 || i>8 {temp$ = " |"}
        for l in 1...3 {
          temp$ = temp$ + ": "
          if lrs[l] < 0 {
            temp$ = temp$ + "*** "
          } else {
            temp$ = temp$ + String(lrs[l] + 1000).suffix(3) + " "
          }
        }
        temp$ = temp$ + ":"
        messageEntries.append(MessageEntry(line: temp$))
        messageEntries.append(MessageEntry(line: "  -------------------"))
      }
      messageEntries.append(MessageEntry(line: "Quadrant contents on each side of the Enterprise (in centre) as 3-digit code for number of Klingons, Starbases and Stars. Example: 217 = 2 Klingons, 1 Starbase, 7 Stars."))
    }
    getCommand()
  }
  mutating func checkShipStatus() -> String {
    if debug {print("checkShipStatus()")}
    switch true {
    case docked:
        return "DOCKED"
    case (klingonsInQuadrant != 0) || (romulansInQuadrant != 0):
        return "RED"
    case enterpriseEnergy < Constants.Game.originalEnergy / 10:
        return "YELLOW"
    default:
        return "GREEN"
    }
  }
  mutating func findEmptyPlaceinQuadrant() -> (Int,Int) {
    // generate 2 random coordinates, and check if quadrant cell is empty.
    //If empty space is found, returns the coordinates
    if debug {print("findEmptyPlaceinQuadrant()")}
    var found = false
    var row = 0
    var col = 0
    while (!found) {
      row = Int.random(in: 1...8)
      col = Int.random(in: 1...8)
      found = quadrant[row][col] == "   "
    }
    return (row, col)
  }
  // MARK: Weapons Functions
  mutating func firePhasers(unitsToFire: String) {
    if debug {print("firePhasers()")}
    var hits = 0
    var hits1 = 0.0
    var rangeA = 0.0
    var rangeB = 0.0
    var range = 0.0
    var unitsFired = 0
    displayBlankLine()
    if enterpriseDamage[Constants.SystemNumber.phaserControl] < 0.9 {
      messageEntries.append(MessageEntry(line: "*** PHASERS INOPERATIVE ****"))
    } else {
      if klingonsInQuadrant == 0 && romulansInQuadrant == 0 {
        messageEntries.append(MessageEntry(line: "SCIENCE OFFICER SPOCK REPORTS: Sensors show no enemy ships in this Quadrant."))
      } else {
        if enterpriseDamage[Constants.SystemNumber.libraryComputer] < 0.90 {
          messageEntries.append(MessageEntry(line: "*** COMPUTER FAILURE HAMPERS ACCURACY ***"))
        }
        if unitsToFire == "0" {
          messageEntries.append(MessageEntry(line: "Firing of Phasers CANCELLED"))
          return
        }
        messageEntries.append(MessageEntry(line: "Phasers powering up . . ."))
        unitsFired = Int(unitsToFire) ?? 0
        enterpriseEnergy -= unitsFired
        if enterpriseDamage[Constants.SystemNumber.shieldControl] < 1.00 {
          unitsFired = Int(Double(unitsFired) * Double.random(in: 0.01...1))
        }
        hits1 = Double(unitsFired / (klingonsInQuadrant + romulansInQuadrant))
        // Fire on Klingons
        if klingonsInQuadrant > 0 {
          for i in 1...3 {
            if klingons[i][3] > 0 {
              rangeA = Double((klingons[i][1] - sectorCoordinates.0) * (klingons[i][1] - sectorCoordinates.0))
              rangeB = Double((klingons[i][2] - sectorCoordinates.1) * (klingons[i][2] - sectorCoordinates.1))
              range = (rangeA + rangeB).squareRoot()
              hits = Int((hits1 / Double(range)) * (Double.random(in: 0.01...1) + 2))
              if hits <= (Int(Double(0.15) * Double(klingons[i][3]))) {
                messageEntries.append(MessageEntry(line: "Sensors show no damage to enemy at \(klingons[i][1]),\(klingons[i][2])"))
              } else {
                klingons[i][3] = klingons[i][3] - hits
                messageEntries.append(MessageEntry(line: "\(hits) unit hit to Klingon at Sector \(klingons[i][1]),\(klingons[i][2])"))
              }
              if klingons[i][3] <= 0 {
                messageEntries.append(MessageEntry(line: "*** KLINGON DESTROYED ***"))
                enterpriseCondition = checkShipStatus()
                quadrant[klingons[i][1]][klingons[i][2]] = "   "
                klingonsInQuadrant = klingonsInQuadrant - 1
                klingonsRemaining = klingonsRemaining - 1
                galaxy[quadrantCoordinates.0][quadrantCoordinates.1] -= 100
                explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
                if klingonsRemaining == 0 {
                  endGame(reason: "Success")
                }
              } else {
                messageEntries.append(MessageEntry(line: "Sensors show \(klingons[i][3]) units remaining."))
              }
              if klingonsInQuadrant > 0 {klingonsShooting()}
            }
          }
        }
        // Are there Romulans in Quadrant and are they cloaked?
        if romulansInQuadrant > 0 && (cloaked != 0) {
          if debug {print("Romulan cloaked")}
          messageEntries.append(MessageEntry(line: "Sensors unable to locate cloaked Romulan vessel."))
          messageEntries.append(MessageEntry(line: ". . . Phasers powering down."))
          return
        }
        if romulansInQuadrant > 0 && (cloaked != 1) {
          if debug {print("Romulan being fired on")}
        }
        // Fire on Romulans
        if romulansInQuadrant > 0 {
          if romulans[romulanVessel][5] > 0 {
            rangeA = Double((romulans[romulanVessel][2] - sectorCoordinates.0) * (romulans[romulanVessel][2] - sectorCoordinates.0))
            rangeB = Double((romulans[romulanVessel][3] - sectorCoordinates.1) * (romulans[romulanVessel][3] - sectorCoordinates.1))
            range = (rangeA + rangeB).squareRoot()
            hits = Int((hits1 / Double(range)) * (Double.random(in: 0.01...1) + 2))
            if hits <= (Int(Double(0.15) * Double(romulans[romulanVessel][5]))) {
                messageEntries.append(MessageEntry(line: "Sensors show no damage to enemy at \(romulans[romulanVessel][2]),\(romulans[romulanVessel][3])"))
            } else {
              romulans[romulanVessel][5] -= hits
              messageEntries.append(MessageEntry(line: "\(hits) unit hit to Romulan at Sector \(romulans[romulanVessel][2]),\(romulans[romulanVessel][3])"))
            }
            if romulans[romulanVessel][5] <= 0 {
              messageEntries.append(MessageEntry(line: "*** ROMULAN DESTROYED ***"))
              enterpriseCondition = checkShipStatus()
              romulansInQuadrant = romulansInQuadrant - 1
              romulansRemaining = romulansRemaining - 1
              quadrant[romulans[romulanVessel][2]][romulans[romulanVessel][3]] = "   "
              romulans[romulanVessel][5] = 0
              galaxy[quadrantCoordinates.0][quadrantCoordinates.1] -= 1000
              explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
              if romulansRemaining == 0 {
                messageEntries.append(MessageEntry(line: "*** ALL ROMULANS DESTROYED ***"))
              } else {
                messageEntries.append(MessageEntry(line: "*** ROMULANS REMAINING ELSEWHERE IN THE GALAXY ***"))
            }
            } else {
                messageEntries.append(MessageEntry(line: "Sensors show \(romulans[romulanVessel][5]) units remaining."))
            }
            if romulansInQuadrant > 0 {romulansShooting()}
          }
        }
      }
    }
  }
  mutating func fireTorpedoes(currentSector: (Int, Int), targetSector: (Int, Int)) -> (Int, Int) {
    if debug {print("fireTorpedoes()")}
    var newSector = currentSector
    var previousSector = currentSector
    var klingonDestroyed = 0
    var basesInQuadrant = 0
    var nothingFound = true
    displayBlankLine()
    if enterpriseTorpedoes <= 0 {
      messageEntries.append(MessageEntry(line: "*** ALL PHOTON TORPEDOES EXPENDED ***"))
      return previousSector
    }
    if enterpriseDamage[Constants.SystemNumber.photonTubes] < 0.9 {
      messageEntries.append(MessageEntry(line: "*** PHOTON TUBES ARE NOT OPERATIONAL ***"))
      return previousSector
    }
    enterpriseTorpedoes -= 1
    messageEntries.append(MessageEntry(line: "Torpedo track:"))
    while newSector != targetSector {
      // Store the current Sector as the previous Sector
      previousSector = newSector
      
      // Determine the direction to move
      let deltaX = targetSector.0 - newSector.0
      let deltaY = targetSector.1 - newSector.1
      
      // Move one step in the direction
      if deltaX != 0 {
        newSector.0 += deltaX > 0 ? 1 : -1
      }
      if deltaY != 0 {
        newSector.1 += deltaY > 0 ? 1 : -1
      }
      // Check if out of bounds
      if (newSector.0 < 1) || (newSector.0 > 8) || (newSector.1 < 1) || (newSector.1 > 8) {//Torpedo is out of bounds
        messageEntries.append(MessageEntry(line: "*** TORPEDO MISSED ***"))
        break
      }
      messageEntries.append(MessageEntry(line: "----------> \(newSector.0),\(newSector.1)"))
      if quadrant[newSector.0][newSector.1] == "   " {
        //Found clear space so carry on
      } else {
        // Could be a Klingon, Romulan, Star or Starbase - used Switch statement
        switch quadrant[newSector.0][newSector.1] {
          case "+K+": //Found a Klingon
            nothingFound = false
            messageEntries.append(MessageEntry(line: "*** KLINGON DESTROYED ***"))
            klingonsInQuadrant -= 1
            enterpriseCondition = checkShipStatus()
            klingonsRemaining -= 1
            if klingonsRemaining <= 0 {
              endGame(reason: "Success")
              break
            }
            //Check which Klingon has been destroyed
            for i in 1...3 {
              if newSector.0 == klingons[i][1] && newSector.1 == klingons[i][2] {
                klingons[i][3] = 0
                klingonDestroyed = i
              }
            }
            if debug {print("Klingon at Sector \(newSector.0),\(newSector.1) Destroyed")}
          printKlingonData()
            quadrant[newSector.0][newSector.1] = "   "
            galaxy[quadrantCoordinates.0][quadrantCoordinates.1] -= 100
            explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
            if klingonsRemaining == 0 {
              endGame(reason: "Success")
            }
          case "=R=": //Found a Romulan
            nothingFound = false
            messageEntries.append(MessageEntry(line: "*** ROMULAN DESTROYED ***"))
            romulansInQuadrant -= 1
            enterpriseCondition = checkShipStatus()
            romulansRemaining -= 1
            quadrant[newSector.0][newSector.1] = "   "
            galaxy[quadrantCoordinates.0][quadrantCoordinates.1] -= 1000
            explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
            if romulansRemaining == 0 {
              messageEntries.append(MessageEntry(line: "NO ROMULANS REMAINING IN THE GALAXY"))
            } else {
              messageEntries.append(MessageEntry(line: "Sensors show \(romulansRemaining) Romulan(s) remaining in the galaxy."))
            }
          case ">!<": //Found a Starbase
            nothingFound = false
            messageEntries.append(MessageEntry(line: "Starbase at \(newSector.0),\(newSector.1) destroyed"))
            basesInQuadrant -= 1
            removeStarbase(starbaseCoordinates: (quadrantCoordinates.0,quadrantCoordinates.1))
            basesRemaining -= 1
            quadrant[newSector.0][newSector.1] = "   "
            galaxy[quadrantCoordinates.0][quadrantCoordinates.1] -= 10
            explored[quadrantCoordinates.0][quadrantCoordinates.1] = galaxy[quadrantCoordinates.0][quadrantCoordinates.1]
            if basesRemaining > 0 || klingonsRemaining > enterpriseStardate - startingStardate - daysLeft {
              messageEntries.append(MessageEntry(line: "Starfleet Command reviewing your record to consider Court Martial!"))
              //shipDocked = false
              break
            } else {
              messageEntries.append(MessageEntry(line: "Last Starbase destroyed"))
              endGame(reason: "Last Starbase destroyed")
              break
            }
          case " * ": //Found a Star
            nothingFound = false
            if quadrant[newSector.0][newSector.1] == " * " {
              messageEntries.append(MessageEntry(line: "Star at \(newSector.0),\(newSector.1) absorbed Torpedo energy."))
              break
            }
          default: //Found something else
            nothingFound = false
            messageEntries.append(MessageEntry(line: "Unknown vessel collision."))
        }
        
        if (klingonsInQuadrant != 0){klingonsShooting()} // Klingons shoot back
        if (romulansInQuadrant != 0){romulansShooting()} // Romulans shoot back}
      }
    }
    if nothingFound {
      messageEntries.append(MessageEntry(line: "Torpedo missed all targets."))
    }
    return previousSector
  }
  // MARK: Damage and Repair Functions
  
  /// <#Description#>
  mutating func damageControl() {
    if debug {print("damageControl(()")}
    displayBlankLine()
    if enterpriseDamage[Constants.SystemNumber.damageControl] >= 0.9 {
      messageEntries.append(MessageEntry(line: "           DEVICE              STATE OF REPAIR                        "))
      messageEntries.append(MessageEntry(line: "           -----------------------------------                        "))
      var myString: String
      for i in 1...9 {
        let temp = Int(enterpriseDamage[i] * 100)
        myString = "          " + systems[i]
        myString = myString.padding(toLength: 35, withPad: " ", startingAt: 0)
        myString = myString + String(temp) + "%"
        myString = myString.padding(toLength: 60, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
      }
      displayBlankLine()
    } else {
      messageEntries.append(MessageEntry(line: "*** DAMAGE CONTROL REPORT NOT AVAILABLE ***"))
    }
    if enterpriseCondition == "DOCKED" {repairDamage()}
  }
  mutating func repairDamage() {
    if debug {print("repairDamage(()")}
  }
  mutating func removeStarbase(starbaseCoordinates: (row: Int, col: Int)) {
    if debug {print("removeStarbase()")}
    for i in 1...basesRemaining {
      if starbaseCoordinates.row == starbase[i][1] && starbaseCoordinates.col == starbase[i][1] {starbase[i].remove(at: i)}
    }
  }
  
  // MARK: Computer Functions
  mutating func cumulativeGalacticRecord(regionNameMap: Bool) {
    if debug {print("cumulativeGalacticRecord()")}
    var count: Int
    var myString: String
    let spaces = "            "
    var temp: Substring
    displayBlankLine()
    if regionNameMap {
      messageEntries.append(MessageEntry(line: "GALAXY REGION MAP"))
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "          1     2     3     4     5     6     7     8        "))
      messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      for i in 0...7 {
        myString = ""
        count = gQuadrantNames[0][i].count
        temp = spaces.prefix((24 - count)/2)
        myString = temp + gQuadrantNames[0][i]
        temp = spaces.prefix(24 - myString.count)
        myString = myString + temp
        count = gQuadrantNames[1][i].count
        temp = spaces.prefix((24 - count)/2)
        myString = myString + temp + gQuadrantNames[1][i]
        myString = String(i + 1) + "  " + myString
        myString = myString.padding(toLength: 50, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
        messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      }
    } else {
      messageEntries.append(MessageEntry(line: "CUMULATIVE RECORD OF GALAXY FOR QUADRANT \(quadrantCoordinates.0),\(quadrantCoordinates.1)"))
      messageEntries.append(MessageEntry(line: "Results of all Short and Long Range Scans."))
      messageEntries.append(MessageEntry(line: "          1     2     3     4     5     6     7     8        "))
      messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      for i in 1...8 {
        lrs[1] = -1
        lrs[2] = -2
        lrs[3] = -3
        lrs[4] = -4
        lrs[5] = -5
        lrs[6] = -6
        lrs[7] = -7
        lrs[8] = -8
        temp$ = String(i) + " "
        for j in 1...8 {
          if i > 0 && i < 9 && j > 0 && j < 9 {
            lrs[j] = explored[i][j]
          }//END if
        }//NEXT j
        for l in 1...8 {
          temp$ = temp$ + ": "
          if lrs[l] <= 0 {
            temp$ = temp$ + "*** "
          } else {
            temp$ = temp$ + String(lrs[l] + 1000).suffix(3) + " "
          }//END if
        }//NEXT l
        temp$ = temp$ + ":"
        messageEntries.append(MessageEntry(line: temp$))
        messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      }//NEXT i
      messageEntries.append(MessageEntry(line: "3-digit codes: number of Klingons, Starbases and Stars. Example, 217 = 2 Klingons, 1 Starbase and 7 Stars."))
    }
    getCommand()
  }
  mutating func statusReport() {
    if debug {print("statusReport()")}
    var s = " remaining."
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "STATUS REPORT:                                              "))
    displayBlankLine()
    if klingonsRemaining > 1 {s = "s remaining."}
    messageEntries.append(MessageEntry(line: "\(klingonsRemaining) Klingon\(s) "))
    if romulansRemaining > 0 {
      s = " remaining."
      if romulansRemaining > 1 {s = "s remaining."}
      messageEntries.append(MessageEntry(line: "\(romulansRemaining) Romulan\(s) "))
    }
    messageEntries.append(MessageEntry(line: "Mission must be completed in \(daysLeft) Stardates."))
    messageEntries.append(MessageEntry(line: "You have \(enterpriseEnergy + enterpriseShields) units of energy and \(enterpriseTorpedoes) torpedoes left."))
    if basesRemaining < 1 {
      messageEntries.append(MessageEntry(line: "Your stupidity has left you on your own in the Galaxy."))
      messageEntries.append(MessageEntry(line: "You have no Starbases left!"))
    } else {
      if basesRemaining == 1 {
        s = ""
      } else {
        s = "s"
      }
      messageEntries.append(MessageEntry(line: "The Federation is maintaining \(basesRemaining) Starbase\(s) in the Galaxy."))
    }
    getCommand()
  }
  mutating func getEnemyShipData(){
    if debug {print("getEnemyShipData()")}
    var s = ""
    displayBlankLine()
    if klingonsInQuadrant <= 0 && romulansInQuadrant <= 0 {
      messageEntries.append(MessageEntry(line: "SCIENCE OFFICER SPOCK REPORTS:"))
      messageEntries.append(MessageEntry(line: "Sensors show no enemy ships in this Quadrant."))
      return
    } else {
      if (klingonsInQuadrant > 1) {
        s = "s"
      }
      messageEntries.append(MessageEntry(line: "Enemy ship\(s) information:"))
      if klingonsInQuadrant > 0 {
        for i in 1...klingonsInQuadrant {
          displayBlankLine()
          messageEntries.append(MessageEntry(line: "Klingon at Sector \(klingons[i][1]),\(klingons[i][2]): Estimated fire power \(klingons[i][3]) units."))
        }
      }
      if romulansInQuadrant > 0 {
        for i in 1...romulansInQuadrant {
          // Only display energy if not cloaked
          if romulans[i][4] == 0 {
            displayBlankLine()
            messageEntries.append(MessageEntry(line: "Romulan at Sector \(romulans[i][2]),\(romulans[i][3]): Estimated fire power \(romulans[i][5]) units."))
          } else {
            messageEntries.append(MessageEntry(line: "Romulan vessel somewhere in this Quadrant but location unknown. Estimated fire power \(romulans[i][5]) units."))
          }
        }
      }
    }
    getCommand()
  }
  mutating func getStarbaseNavData() {
    if debug {print("getStarbaseNavData()")}
    displayBlankLine()
    if basesRemaining > 1 {messageEntries.append(MessageEntry(line: "The Federation is maintaining \(basesRemaining) starbases in the Galaxy."))}
    else {messageEntries.append(MessageEntry(line: "The Federation is maintaining 1 starbase in the Galaxy."))}
    for i in 1...basesRemaining {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "Starbase \(i) at Quadrant \(starbase[i][0]),\(starbase[i][1]). Condition \(condition[starbase[i][2]])."))
      messageEntries.append(MessageEntry(line: " Repair Efficiency \(starbase[i][3])%. Energy \(starbase[i][4]) units. Photon Torpedoes \(starbase[i][5])."))
    }
    if debug {
      for  i in 0...6 {
        for j in 0...5 {
              print("\(i), \(j), \(starbase[i][j])")

            }
        print(galaxy[starbase[i][0]][starbase[i][1]])
      }
    }
    getCommand()
  }
  // MARK: Enemy Ship Functions
  mutating func klingonsShooting () -> Bool {
    if debug {print("klingonsShooting()")}
    var klingonEnergy = 0.00
    var hits = 0.00
    displayBlankLine()
    if enterpriseCondition == "DOCKED" {
      messageEntries.append(MessageEntry(line: "*** STARBASE SHIELDS PROTECT THE ENTERPRISE ***"))
    } else {
      for i in 1...klingonsInQuadrant {
        klingonEnergy = Double(klingons[i][3])
        if debug {print("Klingon Energy: \(klingonEnergy)")}
        if klingonEnergy > 0 {
          hits = (klingonEnergy / distanceToShip(index: i)) // Hits based on distance to Enterprise
          if debug {print("Hits = \(hits) based on klingonEnergy \(klingonEnergy) and distanceToShip \(distanceToShip(index: i))")}
          hits = hits * (2.00 * Double.random(in: 0.00...1)) // Random factor affects damage by up to twice the calculated value
          if debug {print("Hits after damage factor of up to twice = \(hits) based on klingonEnergy \(klingonEnergy) and distanceToShip \(distanceToShip(index: i))")}
          if debug {print("Klingon Energy: \(klingonEnergy)")}
          if Int(hits) > 0 {
            messageEntries.append(MessageEntry(line: "Klingon firing . . ."))
            klingons[i][3] = Int(klingonEnergy/(3 + Double.random(in: 0.00...0.99))) // K[I][3] = Int(KlingonEnergy/(3+Double.random(in:0.00...0.99)));
            if debug {print("klingons[i][3]: \(klingons[i][3])")}
            messageEntries.append(MessageEntry(line: "\(Int(hits)) unit hit on Enterprise from Klingon at Sector \(klingons[i][1]),\(klingons[i][2])"))
            enterpriseShields = enterpriseShields - Int(hits)
            if enterpriseShields < 0 {
              messageEntries.append(MessageEntry(line: "*** ENTERPRISE DESTROYED - GAME OVER ****"))
              enterpriseDestroyed = true
              endGame(reason: "Destroyed")
            } else {
              messageEntries.append(MessageEntry(line: "SHIELD CONTROL REPORTS: Shields down to \(enterpriseShields) units."))
              //DAMAGE DUE TO KLINGON HITS
              if hits > 19 && (enterpriseShields == 0 || (Int.random(in: 1...10) < 6 && (hits / Double(enterpriseShields)) > 0.02 )) {
                let systemDamaged = Int.random(in: 1...9)
                let tempDamage = (hits / Double(enterpriseShields)) - 0.5 * Double.random(in: 0.00...1)
                if Int(tempDamage) <= 0 {enterpriseDamage[systemDamaged] = enterpriseDamage[systemDamaged] - 0.1}
                else {enterpriseDamage[systemDamaged] = enterpriseDamage[systemDamaged] - tempDamage}
                messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemDamaged]) damaged by hit - now at \(enterpriseDamage[systemDamaged] * 100)%."))
              } //DAMAGE DUE TO KLINGON HITS
            }
          } else {
            messageEntries.append(MessageEntry(line: "Klingon at Sector \(klingons[i][1]),\(klingons[i][2]) missed the Enterprise."))
          }
        }
      }
    }
    return enterpriseDestroyed
  }
  mutating func romulansShooting () -> Bool {
    if debug {print("romulansShooting()")}
    var romulanEnergy = 0.00
    var hits = 0.00
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "*** ROMULAN BIRD OF PREY DECLOAKING ****"))
    if enterpriseCondition == "DOCKED" {
      messageEntries.append(MessageEntry(line: "*** STARBASE SHIELDS PROTECT THE ENTERPRISE ***"))
    } else {
      romulanEnergy = Double(romulans[romulanVessel][5])
      if romulanEnergy > 0 {
        hits = (romulanEnergy / distanceToShip(index: romulanVessel)) // Hits based on distance to Enterprise
        if debug {print("Hits = \(hits) based on romulanEnergy \(romulanEnergy) and distanceToShip \(distanceToShip(index: romulanVessel))")}
        hits = hits * (2.00 * Double.random(in: 0.00...1)) // Random factor affects damage by up to twice the calculated value
        // If hits <= 0, then the Romulan ship is out of energy and will not fire
        if debug {print("Hits after damage factor of up to twice = \(hits) based on romulanEnergy \(romulanEnergy) and distanceToShip \(distanceToShip(index: romulanVessel))")}
        enterpriseShields = enterpriseShields - Int(hits)
        romulans[romulanVessel][5] -= Int(hits)
        messageEntries.append(MessageEntry(line: "\(Int(hits)) unit hit on Enterprise from Romulan Warbird at Sector \(romulans[romulanVessel][2]),\(romulans[romulanVessel][3])"))
        if enterpriseShields < 0 {
          messageEntries.append(MessageEntry(line: "*** ENTERPRISE DESTROYED BY ROMULAN BIRD OF PREY - GAME OVER ****"))
          enterpriseDestroyed = true
          endGame(reason: "Destroyed")
        } else {
          messageEntries.append(MessageEntry(line: "SHIELD CONTROL REPORTS: Shields down to \(enterpriseShields) units."))
          //DAMAGE DUE TO ROMULAN HITS
          if hits > 19 && (enterpriseShields == 0 || (Int.random(in: 1...10) < 6 && (hits / Double(enterpriseShields)) > 0.02 )) {
            let systemDamaged = Int.random(in: 1...9)
            let tempDamage = (hits / Double(enterpriseShields)) - 0.5 * Double.random(in: 0.00...1)
            if Int(tempDamage) <= 0 {enterpriseDamage[systemDamaged] = enterpriseDamage[systemDamaged] - 0.1}
            else {enterpriseDamage[systemDamaged] = enterpriseDamage[systemDamaged] - tempDamage}
            messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemDamaged]) damaged by hit - now at \(enterpriseDamage[systemDamaged] * 100)%."))
          } //DAMAGE DUE TO ROMULAN HITS
        }
      }
    }
    return enterpriseDestroyed
  }
  // MARK: Utility Functions
  mutating func distanceToShip (index: Int) -> Double {
    if debug {print("distanceToShip()")}
    let dx = Double(klingons[index][1]) - Double(sectorCoordinates.0)
    let dy = Double(klingons[index][2]) - Double(sectorCoordinates.1)
    return ((dx * dx) + (dy * dy)).squareRoot()
  }
  mutating func getDebugData() {
    if debug {print("getDebugData()")}
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "KLINGONS IN THIS QUADRANT"))
    displayBlankLine()
    if klingonsInQuadrant > 0 {
      if debug {print("Klingons in Quadrant \(klingonsInQuadrant)")}
      for i in 1...klingonsInQuadrant {
        messageEntries.append(MessageEntry(line: "Klingon \(i) at Sector \(klingons[i][1]),\(klingons[i][2]) with \(klingons[i][3]) units of energy."))
      }
      displayBlankLine()
    } else {
      messageEntries.append(MessageEntry(line: "No Klingons in this Quadrant."))
    }
    displayBlankLine()
    if romulansRemaining > 0 {
        if debug {print("Romulans remaining \(romulansRemaining)")}
        messageEntries.append(MessageEntry(line: "ROMULANS IN GALAXY"))
      for i in 1...romulansRemaining {
        displayBlankLine()
        messageEntries.append(MessageEntry(line: "Romulan \(i) at Quadrant \(romulans[i][0]),\(romulans[i][1]). Energy \(romulans[i][5])."))
      }
    } else {
      messageEntries.append(MessageEntry(line: "No Romulans in the Galaxy."))
    }
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "GALACTIC MAP"))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "       1      2      3      4      5      6      7      8        "))
    messageEntries.append(MessageEntry(line: "     ------ ------ ------ ------ ------ ------ ------ ------     "))
    for i in 1...8 {
      lrs[1] = -1
      lrs[2] = -2
      lrs[3] = -3
      lrs[4] = -4
      lrs[5] = -5
      lrs[6] = -6
      lrs[7] = -7
      lrs[8] = -8
      temp$ = String(i) + " "
      for j in 1...8 {
        if i > 0 && i < 9 && j > 0 && j < 9 {
          lrs[j] = galaxy[i][j]
        }//END if
      }//NEXT j
      for l in 1...8 {
        temp$ = temp$ + ": "
        if lrs[l] <= 0 {
          temp$ = temp$ + "*** "
        } else {
          temp$ = temp$ + String(lrs[l] + 100000).suffix(4) + " "
        }//END if
      }//NEXT l
      temp$ = temp$ + ":"
      messageEntries.append(MessageEntry(line: temp$))
      messageEntries.append(MessageEntry(line: "     ------ ------ ------ ------ ------ ------ ------ ------     "))
    }//NEXT i
    displayBlankLine()
    getCommand()
  }
  mutating func printKlingonData () {
    if klingonsInQuadrant > 0 {
      print("Klingons in Quadrant \(klingonsInQuadrant)")
      for i in 1...3 {
        print("Klingon \(i) at Sector \(klingons[i][1]),\(klingons[i][2]) with \(klingons[i][3]) units of energy.")
      }
      displayBlankLine()
    } else {
      print("No Klingons in this Quadrant.")
    }
  }
}


