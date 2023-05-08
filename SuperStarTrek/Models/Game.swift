//
//  Game.swift
//  SuperStarTrek
//
//  Created by David Parker on 15/02/2023.
//

import Foundation
import SwiftUI

var klingonsInQuadrant = 0//K3
var enterpriseCondition = "GREEN" //C$
var damage = Array(repeating: 0.00, count: 9) //670 FORI=1TO8:D(I)=0:NEXTI
var enterpriseDestroyed = false
var enterpriseEnergy = 3000 //E
var enterpriseOriginalEnergy = 0 //E0
var enterpriseOriginalStardate = 0 //T0
var enterpriseQuadrantRow = 0 //Q1
var enterpriseQuadrantCol = 0 //Q2
var enterpriseSectorRow = 0 //S1
var enterpriseSectorCol = 0 //S2
var enterpriseShields = 0 //S
var input = ""

struct MessageEntry: Equatable, Identifiable {
  let line: String
  var id = UUID()
}

struct Game {
  var A$ = "   "
  var basesRemaining = 0 //B9
  var basesInQuadrant = 0 //B3
  var baseRow = 0 //B4
  var baseCol = 0 //B5
  var C = Array(repeating: Array(repeating: 0.0, count: 3), count: 10)
  var crossingPerimeter = false
  var damageFactor = 0.0 //D4
  var debug = true
  var docked = false
  var efficiency = 0.0
  var enterpriseDaysLeft = 25 + Int.random(in:1...10) //T9
  var enterpriseStardate = (Int.random(in:1...20)+20)*100 //T
  var enterpriseTorpedoes = 10 //P
  var enterpriseQuadrantName = "" //G2$
  var explored = Array(repeating: Array(repeating: 0, count: 9), count: 9)
  var galaxy = Array(repeating: Array(repeating: 0, count: 9), count: 9)
  var galaxyQuadrantNames = [["Antares","Rigel","Procyon","Vega","Canopus","Altair","Sagittarius","Pollux"], ["Sirius","Deneb","Capella","Betelgeuse","Aldebaran","Regulus","Arcturus","Spica"]]
  var galaxySectorNames = [" I"," II"," III"," IV"]
  var gameStarted = false
  var klingons = Array(repeating: Array(repeating: 0, count: 4), count: 4) //K(3,3)
  var klingonsRemaining = 0 //K9
  var klingonsStarting = 0 //K7
  var lrs = [0,0,0,0,0,0,0,0,0] //Used in building Long Range Scan, Galactic Record
  var messageEntries: [MessageEntry] = []
  var maxWarp = "8.0"
  var noOfSteps = 0
  var q4 = 0
  var q5 = 0
  var quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)// To replace Q$
  var R1 = 0
  var R2 = 0
  var S8 = 0
  var S9 = 200.0
  var starsInQuadrant = 0 //S3
  var stepX = 0.0
  var stepY = 0.0
  var systems = ["EMPTY","Warp Engines","Short Range Sensors","Long Range Sensors","Phaser Control","Photon Tubes","Damage Control","Shield Control","Library Computer"]
  var t8 = 0.0
  var temp = 0 //Temporary integer
  var temp$ = ""
  var x = 0
  var x5 = false
  var y = 0
  var Z1 = 0
  var Z2 = 0
  var Z3 = false
  
  mutating func startGame () {
    let enterpriseDamageFactor = 0.5 * Double.random(in:0.1..<1.0)//D4=.5*RND(1)
    var isAre = "is"
    var starbases = "Starbase"
    
    //Initialise Enterprise position
    enterpriseQuadrantRow = Int.random(in:1...8) //Q1
    enterpriseQuadrantCol = Int.random(in:1...8) //Q2
    enterpriseSectorRow = Int.random(in:1...8) //S1
    enterpriseSectorCol = Int.random(in:1...8) //S2
    
    //Set up vectors for movement
    C[1][1] = 0.0; C[1][2] = 1.0 // 1 = on same row one space to right
    C[2][1] = -1.0;C[2][2] = 1.0 // 2 = on row above one space to right
    C[3][1] = -1.0;C[3][2] = 0.0 // 3 = on row above
    C[4][1] = -1.0;C[4][2] = -1.0// 4 = on row above one space to left
    C[5][1] = 0.0; C[5][2] = -1.0// 5 = on same row one space to left
    C[6][1] = 1.0; C[6][2] = -1.0// 6 = one row below one space to left
    C[7][1] = 1.0; C[7][2] = 0.0 // 7 = one row below
    C[8][1] = 1.0; C[8][2] = 1.0 // 8 = one row below one space to right
    C[9][1] = 0.0; C[9][2] = 1.0 // 9 = on same row one space to right
    
    //Reset number of Klingons and Starbases
    klingonsRemaining = 0
    basesRemaining = 0 //B9
    
    //Clear Short Range Scan
    quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)
    
    //Populate the galaxy with Klingons, Starbases and stars
    for i in 1...8 {
      for j in 1...8 {
        klingonsInQuadrant = 0
        galaxy[i][j] = 0
        R1 = Int.random(in:1...99)
        if R1 > 98 {
          klingonsInQuadrant = 3
          klingonsRemaining += 3
        } else if R1 > 95 {
          klingonsInQuadrant = 2
          klingonsRemaining += 2
        } else if R1 > 80 {
          klingonsInQuadrant = 1
          klingonsRemaining += 1
        }
        klingonsStarting = klingonsRemaining
        basesInQuadrant = 0
        if Int.random(in: 1...99) > 96 {
          basesInQuadrant = 1
          basesRemaining += 1
        }
        starsInQuadrant = Int.random(in:1...8)
        galaxy[i][j] = klingonsInQuadrant * 100 + basesInQuadrant * 10 + starsInQuadrant
      }
    }
    if basesRemaining == 0 {//If there are no Starbases, add one in the cuurent Enterpruse Quadrant then put in 2 Klingons and 1 Starbase and reposition Enterprise
      if galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] < 200 {
        galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] += 100
        klingonsRemaining += 1
      }
      basesRemaining = 1
      galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] += 10
      enterpriseQuadrantRow = Int.random(in:1...8)
      enterpriseQuadrantCol = Int.random(in:1...8)
    }
    if (basesRemaining != 1) {//Set up correct syntax for Starbase quantity
      isAre = "are"
      starbases = "Starbases"
    }
    
    //State mission
    messageEntries.append(MessageEntry(line: "               THE USS ENTERPRISE --- NCC-1701              "))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "It is Stardate \(enterpriseStardate)."))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "Your mission is to destroy the \(klingonsRemaining) Klingon warships that have invaded the Galaxy before they can attack Federation Headquarters on Stardate \(enterpriseStardate + enterpriseDaysLeft)."))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "This gives you \(enterpriseDaysLeft) days to complete your mission."))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "There " + isAre + " \(basesRemaining) " + starbases + " in the Galaxy for resupplying your ship."))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "Press Resign Command to reject the mission or New Mission for a different mission. "))
    displayBlankLine()
    gameStarted = true
    
    //Add code here to start or restart mission
    
    enterpriseOriginalStardate = enterpriseStardate
    enterpriseOriginalEnergy = enterpriseEnergy
    //Enter new Quadrant
    klingonsInQuadrant = 0
    basesInQuadrant = 0
    starsInQuadrant = 0
    //Get Quadrant name and region
    if enterpriseQuadrantRow <= 4 {
      enterpriseQuadrantName = galaxyQuadrantNames[0][enterpriseQuadrantRow - 1]
    } else {
      enterpriseQuadrantName = galaxyQuadrantNames[1][enterpriseQuadrantRow - 1]
    }
    if enterpriseQuadrantCol <= 4 {
      enterpriseQuadrantName = enterpriseQuadrantName + galaxySectorNames[enterpriseQuadrantCol - 1 ]
    } else {
      enterpriseQuadrantName = enterpriseQuadrantName + galaxySectorNames[enterpriseQuadrantCol - 5 ]
    }
    if enterpriseStardate == enterpriseOriginalStardate {//Print starting Quadrant
      messageEntries.append(MessageEntry(line: "Your mission begins with your starship located in the       "))
      messageEntries.append(MessageEntry(line: "Galactic Quadrant \(enterpriseQuadrantName) Quadrant \(enterpriseQuadrantRow),\(enterpriseQuadrantCol) Sector \(enterpriseSectorRow),\(enterpriseSectorCol) "))
    } else {//Print entering new Quadrant
      messageEntries.append(MessageEntry(line: "Now entering Quadrant message . . .                         "))
    }
    //Get contents of Quadrant
    klingonsInQuadrant = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]/100
    temp = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] - (klingonsInQuadrant * 100)
    basesInQuadrant = temp/10
    starsInQuadrant = temp - (basesInQuadrant * 10)
    if debug {print("\(galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]) Klingons=\(klingonsInQuadrant) Starbases=\(basesInQuadrant) Stars=\(starsInQuadrant)")}
    //Set Condition
    if klingonsInQuadrant > 0 {
      messageEntries.append(MessageEntry(line: "*** COMBAT AREA - CONDITION RED ***"))
      enterpriseCondition = "RED"
      if enterpriseShields < 200 {
        messageEntries.append(MessageEntry(line: "*** SHIELDS DANGEROUSLY LOW ***"))
      }
    }
    damageFactor = 0.5 * Double.random(in: 0.01...0.99)
    quadrant[enterpriseSectorRow][enterpriseSectorCol] = "<*>"
    if klingonsInQuadrant > 0 {
      for i in 1...klingonsInQuadrant {
        let coordinates = findEmptyPlaceinQuadrant()
        let R1 = coordinates.y
        let R2 = coordinates.x
        quadrant[R1][R2] = "+K+"
        if debug {print("i=\(i),R1=\(R1),R2=\(R2)")}
        klingons[i][1] = R1
        klingons[i][2] = R2
        klingons[i][3] = Int(S9 * (0.5 * Double.random(in: 0.01..<1.0)))
      }
    }
    if basesInQuadrant > 0 {
      let coordinates = findEmptyPlaceinQuadrant()
      let R1 = coordinates.y
      let R2 = coordinates.x
      baseRow = R1
      baseCol = R2
      quadrant[R1][R2] = ">!<"
    }
    for _ in 1...starsInQuadrant {
      let coordinates = findEmptyPlaceinQuadrant()
      let R1 = coordinates.y
      let R2 = coordinates.x
      quadrant[R1][R2] = " * "
    }
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "COMMAND:"))
    displayBlankLine()
  } //End of startGame
  
  //
  //FUNCTIONS IN ALPHABETICAL ORDER
  //
  
  mutating func addToDisplay(line: String) {
    messageEntries.append(MessageEntry(line: line))
  }
  
  mutating func checkShipStatus() -> String {
    if debug {print("checkShipStatus()")}
    if docked {
      return "DOCKED"
    } else if klingonsInQuadrant > 0 {
      return "RED"
    } else if enterpriseEnergy < enterpriseOriginalEnergy / 10 {
      return "YELLOW"
    } else {
      return "GREEN"
    }
  }
  
  mutating func checkIfDocked() -> (Bool) {
    docked = false
    if debug {print("checkIfDocked()")}
    for i in enterpriseSectorRow - 1...enterpriseSectorRow + 1 {
      for j in enterpriseSectorCol - 1...enterpriseSectorCol + 1 {
        let ii = i
        let jj = j
        if (ii >= 1 && ii <= 8 && jj >= 1 && jj <= 8) {
          if (compareStringInQuadrant(A$: ">!<", y: i, x: j)) {
            docked = true
            enterpriseCondition = "DOCKED"
            if debug {print("docked = \(docked) enterpriseCondition = \(enterpriseCondition)")}
            enterpriseEnergy = 3000
            enterpriseTorpedoes = 10
            messageEntries.append(MessageEntry(line: "SHIELDS DROPPED FOR DOCKING PURPOSES"))
            enterpriseShields = 0
            enterpriseCondition = checkShipStatus()
            shortRangeScan()
          }
        }
      }
    }
    return docked
  }
  
  mutating func compareStringInQuadrant(A$: String, y: Int, x: Int) -> Bool { //8830
    if quadrant[y][x] == A$ {
      return true
    }
    return false
  }
  
  mutating func consumeEnergy() {
    if debug {print("consumeEnergy()")}
    enterpriseEnergy -= noOfSteps - 10;  // a warp speed of 8 consumes 8x8+10 =74 energy, speed 1 instead 1x8+10 =18
    if(enterpriseEnergy >= 0) {
      return //EnergyLevel OK
    }
    messageEntries.append(MessageEntry(line: "SHIELD CONTROL SUPPLIES ENERGY TO COMPLETE THE MANOEUVRE."))
    enterpriseShields += enterpriseEnergy
    enterpriseEnergy = 0
    if debug {print("enterpriseEnergy = ",enterpriseEnergy)}
    if enterpriseShields <= 0  {
      enterpriseShields = 0
    }
  }
  
  
  mutating func courseControl (direction: Double, warp: Double) {
    var course = 0.0
    var repairFactor = 0.0
    var system = 0
    if debug {print("courseControl()")}
    if damage[1] < 0 {//Check if warp engines are damaged
      maxWarp = "0.2"
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: Warp engines are damaged - Maximum Warp 0.2"))
      return
    }
    //Otherwise continue
    //Set course = direction
    course = Double(direction)
    if course == 9 {//Course of 9 == 1
      course = 1
    }
    //Check if course within range 1.0 to 8.0
    if course < 1 || course >= 9 {//Not in range so message error and exit
      messageEntries.append(MessageEntry(line: "LT. SULU REPORTS: INCORRECT COURSE DATA, SIR!"))
      return
    }
    if warp > Double(maxWarp) ?? 0.0 {//Warp out of range so message and exit
      messageEntries.append(MessageEntry(line: "CHIEF ENGINEER SCOTT REPORTS: THE ENGINES WON'T TAKE WARP FACTOR \(warp)!"))
      return
    }
    noOfSteps = Int(warp * 8 + 0.5)
    if enterpriseEnergy < noOfSteps {//Not enough energy so message and exit
      messageEntries.append(MessageEntry(line: "ENGINEERING REPORTS: INSUFFICIENT ENERGY FOR MANOEUVERING AT WARP \(warp)!"))
      if enterpriseShields >= (noOfSteps - enterpriseEnergy) && damage[7] >= 0 {
        messageEntries.append(MessageEntry(line: "DEFELECTOR CONTROL ROOM ACKNOWLEDGES \(enterpriseShields) UNITS OF ENERGY PRESENTLY DEPLOTED TO SHIELDS."))
      }
    }
    if klingonsInQuadrant != 0 {
      if debug {print("klingonsInQuadrant = \(klingonsInQuadrant)")}
      for i in 1...klingonsInQuadrant {
        x = klingons[i][1]
        y = klingons[i][2]
        quadrant[x][y] = "   "
        let coordinates = findEmptyPlaceinQuadrant()
        x = coordinates.y
        y = coordinates.x
        quadrant[x][y] = "+K+"
        if debug {shortRangeScan()}
        klingonsShooting()
        if enterpriseDestroyed {
          gameOver(reason: "Destroyed")
        }
      }
    }
    repairFactor = warp
    if warp >= 1 {repairFactor = 1.00}
    for i in 1...8 {
      if damage[i] < 0 {
        damage[i] = damage[i] + repairFactor //Moving 1 Quadrant repair by 1
        if (damage[i] > 0.1 && damage[i] < 0) { //If almost 0 go back to -0.1
          damage[i] = 0.1
        } else {
          if damage[i] >= 0 {
            messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: \(systems[i]) REPAIR COMPLETED."))
          }
        }
      }
    }
    if Double.random(in:0.00...0.99) <= 0.2 {
      system = Int.random(in: 1...8)
      if Double.random(in: 0.00...0.99) >= 0.6 {
        damage[system] = damage[system] + Double.random(in: 0.00...0.99) * 3 + 1
        messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: \(systems[system]) STATE OF REPAIR IMPROVED."))
      } else {
        damage[system] = damage[system] - Double.random(in: 0.00...0.99) * 5 + 1
        messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT: \(systems[system]) DAMAGED."))
      }
    }
    //BEGIN MOVING STARSHIP
    quadrant[enterpriseSectorRow][enterpriseSectorCol] = "   "
    let cindex = Int(course)
    stepX = C[cindex + 1][1] - C[cindex][1]
    stepX *= (course - Double(Int(course)))
    stepX += C[cindex][1]
    print("stepX = \(stepX) cindex = \(cindex) course = \(course) C[cindex + 1][1] = \(C[cindex + 1][1]) C[cindex][1] = \(C[cindex][1]) Double(Int(course)) = \(Double(Int(course)))")
    stepY = C[cindex + 1][2] - C[cindex][2]
    stepY *= (course - Double(Int(course)))
    stepY += C[cindex][2]
    print("stepY = \(stepY) cindex = \(cindex) course = \(course) C[cindex + 1][2] = \(C[cindex + 1][2]) C[cindex][2] = \(C[cindex][2]) Double(Int(course)) = \(Double(Int(course)))")
    x = enterpriseSectorRow;    y = enterpriseSectorCol
    q4 = enterpriseQuadrantRow
    q5 = enterpriseQuadrantCol
    print("x = \(x) y = \(y) q4 = \(q4) q5 = \(q5)")
    for _ in 1...noOfSteps {
      print("Int(stepX) = \(Int(stepX)) Int(stepY) = \(Int(stepY))")
      print("Before: Quadrant = \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)  Sector = \(enterpriseSectorRow),\(enterpriseSectorCol)")
      quadrant[enterpriseSectorRow][enterpriseSectorCol] = "   "
      enterpriseSectorRow = Int(Double(enterpriseSectorRow) + stepX)
      enterpriseSectorCol = Int(Double(enterpriseSectorCol) + stepY)
      print("After: Quadrant = \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)  Sector = \(enterpriseSectorRow),\(enterpriseSectorCol)")
      if enterpriseSectorRow < 1 || enterpriseSectorRow > 8 || enterpriseSectorCol < 1 || enterpriseSectorCol > 8 {
        exceededQuadantLimits()
        //Need to unpack sector details of in a new quadrant
        endOfMovement(warp: warp)
        return
      } else { //Not exceeded quadrant limits
        if quadrant[enterpriseSectorRow][enterpriseSectorCol] == "   " {
          enterpriseSectorRow = Int(enterpriseSectorRow)
          enterpriseSectorCol = Int(enterpriseSectorCol)
        } else {
          enterpriseSectorRow = Int(Double(enterpriseSectorRow) - stepX)
          enterpriseSectorCol = Int(Double(enterpriseSectorCol) - stepY)
          messageEntries.append(MessageEntry(line: "WARP ENGINES SHUT DOWN AT SECTOR \(enterpriseSectorRow),\(enterpriseSectorCol) DUE TO BAD NAVIGATION"))
          checkIfDocked()
          break
        }
      }
    }//End of noOfSteps loop
    enterpriseSectorRow = Int(enterpriseSectorRow)
    enterpriseSectorCol = Int(enterpriseSectorCol)
    endOfMovement(warp: warp)
  } //END OF courseControl
  
  mutating func cumulativeGalacticRecord (regionNameMap: Bool) {
    var count: Int
    var myString: String
    let spaces = "            "
    var temp: Substring
    if debug {print("cumulativeGalacticRecord()")}
    displayBlankLine()
    if regionNameMap {
      messageEntries.append(MessageEntry(line: "GALAXY REGION MAP"))
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "          1     2     3     4     5     6     7     8        "))
      messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      for i in 0...7 {
        myString = ""
        count = galaxyQuadrantNames[0][i].count
        temp = spaces.prefix((24 - count)/2)
        myString = temp + galaxyQuadrantNames[0][i]
        temp = spaces.prefix(24 - myString.count)
        myString = myString + temp
        count = galaxyQuadrantNames[1][i].count
        temp = spaces.prefix((24 - count)/2)
        myString = myString + temp + galaxyQuadrantNames[1][i]
        myString = String(i + 1) + "  " + myString
        myString = myString.padding(toLength: 50, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
        messageEntries.append(MessageEntry(line: "        ----- ----- ----- ----- ----- ----- ----- -----      "))
      }
    } else {
      messageEntries.append(MessageEntry(line: "CUMULATIVE RECORD OF GALAXY FOR QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)"))
      displayBlankLine()
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
            if debug {lrs[j] = explored[i][j]}
            if !debug {lrs[j] = galaxy[i][j]}
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
    }
  }
  
  mutating func damageControl () {//5680 REM DAMAGE CONTROL
    if debug {print("damageControl()")}
    displayBlankLine()
    if damage[6] >= 0 {
      messageEntries.append(MessageEntry(line: "DEVICE              STATE OF REPAIR                        "))
      messageEntries.append(MessageEntry(line: "-----------------------------------                        "))
      var myString: String
      for i in 1...8 {
        myString = " " + systems[i]
        myString = myString.padding(toLength: 25, withPad: " ", startingAt: 0)
        myString = myString + String(format:"%.2f",damage[i])
        myString = myString.padding(toLength: 60, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
      }
      displayBlankLine()
    } else {
      messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORT NOT AVAILABLE"))
    }
    if enterpriseCondition == "DOCKED" {repairDamage()}
  } //END OF damageControl
  
  mutating func displayBlankLine() {
    messageEntries.append(MessageEntry(line: "                                                            "))
  }
  
  
  mutating func distanceToShip (index: Int) -> Double {
    if debug {print("distanceToShip()")}
    let dx = Double(klingons[index][1] - enterpriseSectorRow)
    let dy = Double(klingons[index][2] - enterpriseSectorCol)
    return (dx * dx) + (dy * dy).squareRoot()
  }
  
  mutating func endOfMovement (warp: Double) {
    var dayIncrement = 1.0
    if debug {print("endOfMovement()")}
    quadrant[enterpriseSectorRow][enterpriseSectorCol] = "<*>"
    consumeEnergy()
    if warp < 1 {
      dayIncrement = 0.1 * Double(Int(10 * warp))
    }
    enterpriseStardate = enterpriseStardate + Int(dayIncrement)
    if enterpriseStardate > enterpriseOriginalStardate + enterpriseDaysLeft {
      gameOver(reason: "Time")
    }
    checkIfDocked()
    shortRangeScan()
  }
  
  mutating func exceededQuadantLimits () {
    if debug {print("exceededQuadantLimits()")}
    x = 8 * enterpriseQuadrantRow + x + (noOfSteps * Int(stepX))
    y = 8 * enterpriseQuadrantCol + y + (noOfSteps * Int(stepY))
    enterpriseQuadrantRow = Int(x / 8)
    enterpriseQuadrantCol = Int(y / 8)
    enterpriseSectorRow = Int(x - enterpriseQuadrantRow * 8)
    enterpriseSectorCol = Int(y - enterpriseQuadrantCol * 8)
    if (enterpriseSectorRow == 0) {
      enterpriseQuadrantRow = enterpriseQuadrantRow - 1
      enterpriseSectorRow = 8
    }
    if (enterpriseSectorCol == 0) {
      enterpriseQuadrantCol = enterpriseQuadrantCol - 1
      enterpriseSectorCol = 8
    }
    crossingPerimeter = false
    if enterpriseQuadrantRow < 1 {
      crossingPerimeter = true
      enterpriseQuadrantRow = 1
      enterpriseSectorRow = 1
    }
    if enterpriseQuadrantRow > 8 {
      crossingPerimeter = true
      enterpriseQuadrantRow = 8
      enterpriseSectorRow = 8
    }
    if enterpriseQuadrantCol < 1 {
      crossingPerimeter = true
      enterpriseQuadrantCol = 1
      enterpriseSectorCol = 1
    }
    if enterpriseQuadrantCol > 8 {
      crossingPerimeter = true
      enterpriseQuadrantCol = 8
      enterpriseSectorCol = 8
    }
    if crossingPerimeter {
      messageEntries.append(MessageEntry(line: "LT. UHURA REPORTS: MESSAGE FROM STARFLEET COMMAND:"))
      messageEntries.append(MessageEntry(line: "PERMISSION TO ATTEMPT CROSSING OF GALACTIC PERIMETER IS HEREBY DENIED. SHUT DOWN YOUR ENGINES."))
      messageEntries.append(MessageEntry(line: "CHIEF ENGINEER SCOTT REPORTS:"))
      messageEntries.append(MessageEntry(line: "WARP ENGINES SHUT DOWN AT SECTOR \(enterpriseSectorRow),\(enterpriseSectorCol) OF QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)."))
      if (enterpriseStardate > enterpriseOriginalStardate + enterpriseDaysLeft) {
        gameOver(reason: "Time")
      }
    }
    //Still in same quadrant?
    if 8 * enterpriseQuadrantRow + enterpriseQuadrantCol != 8 * q4 + q5 {
      //Print entering new Quadrant
      //Get Quadrant name and region
      if enterpriseQuadrantRow <= 4 {
        enterpriseQuadrantName = galaxyQuadrantNames[0][enterpriseQuadrantRow - 1]
      } else {
        enterpriseQuadrantName = galaxyQuadrantNames[1][enterpriseQuadrantRow - 1]
      }
      if enterpriseQuadrantCol <= 4 {
        enterpriseQuadrantName = enterpriseQuadrantName + galaxySectorNames[enterpriseQuadrantCol - 1 ]
      } else {
        enterpriseQuadrantName = enterpriseQuadrantName + galaxySectorNames[enterpriseQuadrantCol - 5 ]
      }
      messageEntries.append(MessageEntry(line: "Now entering Galactic Quadrant \(enterpriseQuadrantName) . . ."))
      //Get contents of Quadrant
      damageFactor = 0.5 * Double.random(in: 0.01...0.99)
      quadrant = Array(repeating: Array(repeating: "   ", count: 9), count: 9)
      klingonsInQuadrant = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]/100
      temp = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] - (klingonsInQuadrant * 100)
      basesInQuadrant = temp/10
      starsInQuadrant = temp - (basesInQuadrant * 10)
      //Set Condition
      if klingonsInQuadrant > 0 {
        messageEntries.append(MessageEntry(line: "*** COMBAT AREA - CONDITION RED ***"))
        enterpriseCondition = "RED"
        if enterpriseShields < 200 {
          //1580 PRINT"   SHIELDS DANGEROUSLY LOW"
          messageEntries.append(MessageEntry(line: "*** SHIELDS DANGEROUSLY LOW ***"))
        }
      }
      //Possibly adding to quadrant when it hasn't changed?
      if debug {print("Entering new quadrant?")}
      quadrant[enterpriseSectorRow][enterpriseSectorCol] = "<*>"
      if klingonsInQuadrant > 0 {
        for i in 1...klingonsInQuadrant {
          let coordinates = findEmptyPlaceinQuadrant()
          let R1 = coordinates.y
          let R2 = coordinates.x
          quadrant[R1][R2] = "+K+"
          klingons[i][1] = R1
          klingons[i][2] = R2
          klingons[i][3] = Int(S9 * (0.5 * Double.random(in: 0.01..<1.0)))
        }
      }
      if basesInQuadrant > 0 {
        let coordinates = findEmptyPlaceinQuadrant()
        let R1 = coordinates.y
        let R2 = coordinates.x
        baseRow = R1
        baseCol = R2
        quadrant[R1][R2] = ">!<"
      }
      for _ in 1...starsInQuadrant {
        let coordinates = findEmptyPlaceinQuadrant()
        let R1 = coordinates.y
        let R2 = coordinates.x
        quadrant[R1][R2] = " * "
      }
      //Do nothing?
      checkIfDocked()
    }
  }
  
  mutating func findEmptyPlaceinQuadrant() -> (y: Int, x: Int) {
    // generate 2 random coordinates, and check if quadrant cell is empty.
    //If empty space is found, returns the coordinates
    var found = false
    var b = 0
    var a = 0
    if debug {print("findEmptyPlaceinQuadrant()")}
    while (!found) {
      b = Int.random(in: 1...8)
      a = Int.random(in: 1...8)
      found = compareStringInQuadrant(A$: "   ", y: b, x: a)
    }
    return (b, a)
  } //END OF findEmptyPlaceinQuadrant
  
  mutating func firePhasers (unitsToFire: String) {
    var hits = 0
    var hits1 = 0.0
    var rangeA = 0.0
    var rangeB = 0.0
    var range = 0.0
    var unitsFired = 0
    if debug {print("firePhasers()")}
    displayBlankLine()
    if damage[4] < 0 {
      messageEntries.append(MessageEntry(line: "PHASERS INOPERATIVE"))
    } else {
      if klingonsInQuadrant == 0 {
        messageEntries.append(MessageEntry(line: "SCIENCE OFFICER SPOCK REPORTS:"))
        messageEntries.append(MessageEntry(line: "SENSORS SHOW NO ENEMY SHIPS IN THIS QUADRANT"))
      } else {
        if damage[8] < 0 {
          messageEntries.append(MessageEntry(line: "COMPUTER FAILURE HAMPERS ACCURACY"))
        }
        messageEntries.append(MessageEntry(line: "PHASERS LOCKED ON TARGET"))
        unitsFired = Int(unitsToFire) ?? 0
        enterpriseEnergy = enterpriseEnergy - unitsFired
        if damage[7] < 0 {
          unitsFired = Int(Double(unitsFired) * Double.random(in: 0.01...0.99))
        }
        hits1 = Double(unitsFired / klingonsInQuadrant)
        for i in 1...3 {
          if klingons[i][3] > 0 {
            rangeA = Double((klingons[i][1] - enterpriseSectorRow) * (klingons[i][1] - enterpriseSectorRow))
            rangeB = Double((klingons[i][2] - enterpriseSectorCol) * (klingons[i][2] - enterpriseSectorCol))
            range = (rangeA + rangeB).squareRoot()
            hits = Int((hits1 / Double(range)) * (Double.random(in: 0.01...0.99) + 2))
            if hits <= (Int(Double(0.15) * Double(klingons[i][3]))) {
              messageEntries.append(MessageEntry(line: "SENSORS SHOW NO DAMAGE TO ENEMY AT \(klingons[i][1]),\(klingons[i][2])"))
            }
            klingons[i][3] = klingons[i][3] - hits
            messageEntries.append(MessageEntry(line: "\(hits) UNIT HITS TO KLINGON AT SECTOR \(klingons[i][1]),\(klingons[i][2])"))
            if klingons[i][3] <= 0 {
              messageEntries.append(MessageEntry(line: "*** KLINGON DESTROYED ***"))
              enterpriseCondition = checkShipStatus()
              klingonsInQuadrant = klingonsInQuadrant - 1
              klingonsRemaining = klingonsRemaining - 1
              quadrant[klingons[i][1]][klingons[i][2]] = "   "
              klingons[i][3] = 0
              galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] -= 100
              explored[enterpriseQuadrantRow][enterpriseQuadrantCol] = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]
              if klingonsRemaining == 0 {
                gameOver(reason: "Success")
              }
            } else {
              messageEntries.append(MessageEntry(line: "SENSORS SHOW \(klingons[i][3]) UNITS REMAINING"))
            }
            if klingonsInQuadrant > 0 {klingonsShooting()}
          }
        }
      }
    }
  } //END OF firePhasers
  
  mutating func fireTorpedoes (direction: Double) {
    var course = 0.0
    var x3 = 0
    var y3 = 0
    var klingonDestroyed = 0
    if debug {print("fireTorpedoes()")}
    if enterpriseTorpedoes <= 0 {
      messageEntries.append(MessageEntry(line: "ALL PHOTON TORPEDOES EXPENDED"))
      return
    }
    if damage[5] < 0 {
      messageEntries.append(MessageEntry(line: "PHOTON TUBES ARE NOT OPERATIONAL"))
      return
    }
    course = Double(direction)
    if course == 9 {//Course of 9 == 1
      course = 1
    }
    //Check if course within range 1.0 to 8.0
    if course < 1 || course >= 9 {//Not in range so message error and exit
      messageEntries.append(MessageEntry(line: "LT. SULU REPORTS: INCORRECT COURSE DATA, SIR!"))
      return
    }
    let cindex = Int(course)
    stepX = C[cindex + 1][1] - C[cindex][1]
    stepX *= (course - Double(Int(course)))
    stepX += C[cindex][1]
    enterpriseEnergy -= 2
    enterpriseTorpedoes -= 1
    stepY = C[cindex + 1][2] - C[cindex][2]
    stepY *= (course - Double(Int(course)))
    stepY += C[cindex][2]
    x = enterpriseSectorRow
    y = enterpriseSectorCol
    messageEntries.append(MessageEntry(line: "TORPEDO TRACK:"))
    while true {
      x = Int(Double(x) + stepX)
      y = Int(Double(y) + stepY)
      x3 = Int(Double(x) + 0.5)
      y3 = Int(Double(y) + 0.5)
      if (x3 < 1) || (x3 > 8) || (y3 < 1) || (y3 > 8) {//Torpedo is out of bounds
        messageEntries.append(MessageEntry(line: "TORPEDO MISSED!"))
        break
      }
      messageEntries.append(MessageEntry(line: "----------> \(x3),\(y3)"))
      if compareStringInQuadrant(A$: "   ", y: x3, x: y3) {
        //Found clear space so carry on
      } else {
        if compareStringInQuadrant(A$: "+K+", y: x3, x: y3) {
          //Found a Klingon
          messageEntries.append(MessageEntry(line: "*** KLINGON DESTROYED ***"))
          klingonsInQuadrant -= 1
          if debug {print("docked = \(docked) enterpriseCondition = \(enterpriseCondition)")}
          enterpriseCondition = checkShipStatus()
          klingonsRemaining -= 1
          if klingonsRemaining <= 0 {
            gameOver(reason: "Success")
            return
          }
          //Check which Klingon has been destroyed
          for i in 1...3 {
            if x3 == klingons[i][1] && y3 == klingons[i][2] {
              klingons[i][3] = 0
              klingonDestroyed = i
            }
          }
          quadrant[x3][y3] = "   "
          galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] -= 100
          explored[enterpriseQuadrantRow][enterpriseQuadrantCol] = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]
          break
          
        } else {
          if compareStringInQuadrant(A$: " * ", y: x3, x: y3) {
            messageEntries.append(MessageEntry(line: "STAR AT \(x3),\(y3) ABSORBED TORPEDO ENERGY"))
            break
          } else {
            if compareStringInQuadrant(A$: ">!<", y: x3, x: y3) {
              messageEntries.append(MessageEntry(line: "*** STARBASE DESTROYED ***"))
              basesInQuadrant -= 1
              basesRemaining -= 1
              if basesRemaining > 0 || klingonsRemaining > enterpriseStardate - enterpriseOriginalStardate - enterpriseDaysLeft {
                messageEntries.append(MessageEntry(line: "STARFLEET COMMAND REVIEWING YOUR RECORD TO CONSIDER COURT MARTIAL!"))
                //shipDocked = false
                quadrant[x3][y3] = "   "
                galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol] -= 10
                explored[enterpriseQuadrantRow][enterpriseQuadrantCol] = galaxy[enterpriseQuadrantRow][enterpriseQuadrantCol]
                break
              } else {
                gameOver(reason: "Starbase")
              }
            }
          }
        }
        klingonsShooting()
      }
    }
  } //END OF fireTorpedoes
  
  mutating func gameOver (reason: String) {
    if debug {print("gameOver()")}
    messageEntries.append(MessageEntry(line: "GAME OVER"))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "IT IS STARDATE \(enterpriseStardate)"))
    switch reason {
    case "Destroyed" :
      displayBlankLine()
    case "Starbase" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "THAT DOES IT, CAPTAIN! YOUR ARE HEREBY RELIEVED OF COMMAND AND SENTENCED TO 99 STARDATES OF HARD LABOUR AT CYGNUS 12!!"))
    case "Resigned" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "THERE WERE \(klingonsRemaining) KLINGON BATTLE CRUISERS LEFT AT THE END OF YOUR MISSION."))
    case "Time" :
      displayBlankLine()
    case "Success" :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "CONGRATULATIONS CAPTAIN! THE LAST KLINGON BATTLE CRUISER MENACING THE FEDERATION HAS BEEN DESTROYED."))
      displayBlankLine()
      efficiency = Double((klingonsStarting)/(enterpriseOriginalStardate - enterpriseStardate))
      efficiency = 1000 * (efficiency * efficiency)
      messageEntries.append(MessageEntry(line: "YOUR EFFICIENCY RATING IS \(efficiency)"))
      if basesRemaining > 0 {
        messageEntries.append(MessageEntry(line: "THE FEDERATION IS IN NEED OF A NEW STARSHIP COMMANDER FOR A SIMILAR MISSION -- IF THERE IS A VOLUNTEER LET HIM STEP FORWARD."))
      }
    default :
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "Some other reason???"))
    }
  }
  
  mutating func getDirection(m:Int,n:Int,StartingCourse:Double) {
    var Direction = 0.00
    if debug {print("getDirection()")}
    if abs(m) > abs(n) {
      if debug {print("StartingCourse",StartingCourse)}
      if debug {print("n and abs(n)",n,abs(n))}
      if debug {print("m and abs(m)",m,abs(m))}
      Direction = StartingCourse+Double((abs(n)/abs(m)))
      if debug {print("Direction",Direction)}
      if debug {print("(abs(n)/abs(m)",(abs(n)/abs(m)))}
    }
    else {
      if debug {print("StartingCourse",StartingCourse)}
      if debug {print("n and abs(n)",n,abs(n))}
      if debug {print("m and abs(m)",m,abs(m))}
      Direction = StartingCourse+Double(((abs(n)-abs(m)+abs(n))/abs(n)))
      if debug {print("Direction",Direction)}
      if debug {print("(abs(n)-abs(m)+abs(n))/abs(n)",(abs(n)-abs(m)+abs(n))/abs(n))}
    }
    temp$ = String(format:"%.2f",Direction)
    messageEntries.append(MessageEntry(line: "DIRECTION = \(temp$)"))
  }
  
  mutating func getDistance() -> Bool  {
    if debug {print("getDistance()")}
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "DIRECTION/DISTANCE CALCULATOR:"))
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "YOU ARE AT QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol) SECTOR \(enterpriseSectorRow),\(enterpriseSectorCol)"))
    print("PLEASE ENTER INITIAL COORDINATES (X,Y): ")
    let y1 = Int(input) ?? 0
    let x1 = Int(input) ?? 0
    print("  FINAL COORDINATES (X,Y): ");
    let y2 = Int(input) ?? 0
    let x2 = Int(input) ?? 0
    if (checkValidCoordinates(n:x1) && checkValidCoordinates(n:y1) && checkValidCoordinates(n:x2) && checkValidCoordinates(n:2)) {
      getDistanceAndDirection(W1:y2,X:x2,C1:y1,A:x1);
      return true;
    }
    else {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "*** WRONG COORDINATES ***"))
      return false;
    }
  }
  
  mutating func checkValidCoordinates(n:Int) -> Bool {
    if debug {print("checkValidCoordinates()")}
    if (n  >= 1 && n <= 8) {
      return true;
    }
    return false;
  }
  
  mutating func getDistanceAndDirection(W1:Int,X:Int,C1:Int,A:Int) -> Bool{
    if debug {print("getDistanceAndDirection()")}
    var Distance: Double
    let X = X-A
    let A = C1-W1
    if (X<0) {
      if(A>0) {
        getDirection(m:A,n:X,StartingCourse:3)  // A>0 and X < 0
      }
      else if(X != 0) {             // else would be enough here (X<0 and A <=0)
        getDirection(m:X,n:A,StartingCourse:5)
      }
    }
    else {
      if (A<0) {              // case X>= 0 and A < 0
        getDirection(m:A,n:X,StartingCourse:7)
      }
      else if(X>0) {            // the only case where this is not true is X = 0
        getDirection(m:X,n:A,StartingCourse:1)
      }
      else if (A==0) {            // so X = 0 and A = 0
        getDirection(m:X,n:A,StartingCourse:5)
      }
      else if (A > 0) {          // so X = 0 and A > 0
        getDirection(m:X,n:A,StartingCourse:1)
      }
    }
    Distance = Double((X * X)+(A * A)).squareRoot()
    temp$ = String(format:"%.2f",Distance)
    messageEntries.append(MessageEntry(line: "DISTANCE = \(temp$)"))
    return true
  }
  
  mutating func getPhotonTorpedoCourse () {
    if debug {print("getPhotonTorpedoCourse()")}
    var s = ""
    if(klingonsInQuadrant <= 0) {
      messageEntries.append(MessageEntry(line: "SCIENCE OFFICER SPOCK REPORTS:"))
      messageEntries.append(MessageEntry(line: "SENSORS SHOW NO ENEMY SHIPS IN THIS QUADRANT"))
      return
    }
    if (klingonsInQuadrant > 1) {
      s = "S"
    }
    messageEntries.append(MessageEntry(line: "FROM ENTERPRISE TO KLINGON BATTLE CRUISER\(s):"))
    for i in 1...3 {
      if klingons[i][3] > 0 {
        displayBlankLine()
        messageEntries.append(MessageEntry(line: "KLINGON AT \(klingons[i][1]),\(klingons[i][2]):"))
        getDistanceAndDirection(W1:klingons[i][1],X:klingons[i][2],C1:enterpriseSectorRow,A:enterpriseSectorCol)
      }
    }
  }// END OF getPhotonTorpedoCourse
  
  mutating func getStarbaseNavData()  {
    if debug {print("getStarbaseNavData()")}
    if (basesInQuadrant > 0) {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "FROM ENTERPRISE TO STARBASE:"))
      getDistanceAndDirection(W1:baseRow,X:baseCol,C1:enterpriseSectorRow,A:enterpriseSectorCol);   // dest, origin
    } else {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "MR. SPOCK REPORTS:"))
      messageEntries.append(MessageEntry(line: "SENSORS SHOW NO STARBASES IN THIS QUADRANT."))
    }
  }// END OF getStarbaseNavData()
  
  
  mutating func insertInQuadrant (A$: String, y: Int,x: Int) {
    quadrant[y][x] = A$
  }
  
  mutating func klingonsShooting () -> Bool {
    var klingonEnergy = 0.00
    var hits = 0.00
    if debug {print("klingonsShooting()")}
    messageEntries.append(MessageEntry(line: "KLINGON SHIPS ATTACK THE ENTERPRISE"))
    if enterpriseCondition == "DOCKED" {
      messageEntries.append(MessageEntry(line: "STARBASE SHIELDS PROTECT THE ENTERPRISE"))
    } else {
      for i in 1...klingonsInQuadrant {
        klingonEnergy = Double(klingons[i][3])
        if klingonEnergy > 0 {
          hits = (klingonEnergy / distanceToShip(index: i)) * (2 + Double.random(in:0.00...0.99)) + 1
          enterpriseShields = enterpriseShields - Int(hits)
          klingons[i][3] = Int(klingonEnergy/(3 * Double.random(in:0.00...0.99)))
          messageEntries.append(MessageEntry(line: "\(Int(hits)) UNIT HIT ON ENTERPRISE FROM KLINGON AT SECTOR \(klingons[i][1]),\(klingons[i][2])"))
          if enterpriseShields < 0 {
            messageEntries.append(MessageEntry(line: "ENTERPRISE DESTROYED - GAME OVER"))
            enterpriseDestroyed = true
            gameOver(reason: "Destroyed")
          } else {
            messageEntries.append(MessageEntry(line: "SHIELDS DOWN TO \(enterpriseShields) UNITS"))
            //DAMAGE DUE TO KLINGON HITS
            if hits > 19 && (enterpriseShields == 0 || (Int.random(in: 1...10) < 6 && (hits / Double(enterpriseShields)) > 0.02 )) {
              let systemDamaged = Int.random(in: 1...8)
              let tempDamage = (hits / Double(enterpriseShields)) - 0.5 * Double.random(in: 0.00...0.99)
              damage[systemDamaged] = damage[systemDamaged] - tempDamage
              messageEntries.append(MessageEntry(line: "DAMAGE CONTROL REPORTS: \(systems[systemDamaged]) DAMAGED BY THE HIT"))
            } //DAMAGE DUE TO KLINGON HITS
          }
        }
      }
    }
    return enterpriseDestroyed
  }
  
  mutating func longRangeScan () {
    if debug {print("longRangeScan()")}
    messageEntries.append(MessageEntry(line: "                                                            "))
    if damage[3] < 0 {
      messageEntries.append(MessageEntry(line: "*** LONG RANGE SENSORS ARE OUT ***"))
    } else {
      messageEntries.append(MessageEntry(line: "LONG RANGE SCAN FROM QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)"))
      messageEntries.append(MessageEntry(line: "-------------------"))
      for i in enterpriseQuadrantRow - 1...enterpriseQuadrantRow + 1 {
        lrs[1] = -1
        lrs[2] = -2
        lrs[3] = -3
        for j in enterpriseQuadrantCol - 1...enterpriseQuadrantCol + 1 {
          if i > 0 && i < 9 && j > 0 && j < 9 {
            lrs[j - enterpriseQuadrantCol + 2] = galaxy[i][j]
            if debug {print("i = \(i) j = \(j) galaxy[i][j] = \(galaxy[i][j])")}
            explored[i][j] = galaxy[i][j]
          }
        }
        temp$ = ""
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
        messageEntries.append(MessageEntry(line: "-------------------"))
      }
    }
  } //END OF longRangeScan
  
  mutating func repairDamage () {
    var timeToRepair: Double
    if debug {print("repairDamage()")}
    timeToRepair = 0.0
    for i in 1...8 {
      if damage[i] < 0 {
        timeToRepair += 0.1
      }
    }
    if timeToRepair == 0 {
      messageEntries.append(MessageEntry(line: "NO REPAIRS NEEDED"))
    } else {
      timeToRepair += damageFactor
      if timeToRepair >= 1 {timeToRepair = 0.9}
      messageEntries.append(MessageEntry(line: "TECHNICIANS STANDING BY TO EFFECT REPAIRS TO YOUR SHIP     "))
      messageEntries.append(MessageEntry(line: "ESTIMATED TIME TO REPAIR: \(timeToRepair)) STARDATES."))
      for i in 1...8 {
        if damage[i] < 0 {
          damage[i] = 0
        }
      }
      enterpriseStardate += enterpriseStardate + Int(timeToRepair + 0.1)
      messageEntries.append(MessageEntry(line: "DEVICE              STATE OF REPAIR                        "))
      messageEntries.append(MessageEntry(line: "-----------------------------------                        "))
      var myString: String
      for i in 1...8 {
        myString = " " + systems[i]
        myString = myString.padding(toLength: 25, withPad: " ", startingAt: 0)
        myString = myString + String(damage[i])
        myString = myString.padding(toLength: 60, withPad: " ", startingAt: 0)
        messageEntries.append(MessageEntry(line: String(myString)))
      }
    }
    
  }
  
  mutating func shieldControl () {
    if debug {print("shieldControl()")}
    if damage[7] < 0 {
      messageEntries.append(MessageEntry(line: "*** SHIELD CONTROL INOPERABLE ***"))
    } else {
    }
    //
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "SHIELD CONTROL HAS NOT YET BEEN COMMISSIONED"))
    displayBlankLine()
  } //END OF shieldControl
  
  mutating func shortRangeScan () {
    if debug {print("shortRangeScan()")}
    enterpriseCondition = checkShipStatus()
    if damage[2] < 0 {
      messageEntries.append(MessageEntry(line: "*** SHORT RANGE SENSORS ARE OUT ***"))
    } else {
      displayBlankLine()
      messageEntries.append(MessageEntry(line: "SHORT RANGE SCAN FOR QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)"))
      messageEntries.append(MessageEntry(line: "                                                            "))
      messageEntries.append(MessageEntry(line: "------------------------                                    "))
      var mySubstring: Substring
      var myString: String
      mySubstring = ""
      for i in 1...8 {
        mySubstring = ""
        for j in 1...8 {
          mySubstring = mySubstring + quadrant[i][j]
        }
        switch i{
        case 1:
          mySubstring = mySubstring + "  STARDATE \(enterpriseStardate)"
        case 2:
          mySubstring = mySubstring + "  CONDITION \(enterpriseCondition)"
        case 3:
          mySubstring = mySubstring + "  QUADRANT \(enterpriseQuadrantRow),\(enterpriseQuadrantCol)"
        case 4:
          mySubstring = mySubstring + "  SECTOR \(enterpriseSectorRow),\(enterpriseSectorCol)"
        case 5:
          mySubstring = mySubstring + "  PHOTON TORPEDOES \(enterpriseTorpedoes)"
        case 6:
          mySubstring = mySubstring + "  ENERGY \(enterpriseEnergy + enterpriseShields)"
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
      messageEntries.append(MessageEntry(line: "------------------------                                    "))
    }
  } //END OF shortRangeScan
  
  mutating func statusReport() {
    var s = "left:"
    if debug {print("statusReport()")}
    displayBlankLine()
    messageEntries.append(MessageEntry(line: "STATUS REPORT:                                              "))
    displayBlankLine()
    if klingonsRemaining > 1 {
      s = "s left:"
    }
    messageEntries.append(MessageEntry(line: "Klingon\(s) \(klingonsRemaining)"))
    messageEntries.append(MessageEntry(line: "Mission must be completed in: \(enterpriseDaysLeft) stardates"))
    if basesRemaining < 1 {
      messageEntries.append(MessageEntry(line: "Your stupidity has left you on your own in the Galaxy."))
      messageEntries.append(MessageEntry(line: "You have no starbases left!"))
    } else {
      if basesRemaining == 1 {
        s = ""
      } else {
        s = "s"
      }
      messageEntries.append(MessageEntry(line: "The Federation is maintaining \(basesRemaining) starbase\(s) in the Galaxy."))
    }
  }
}





