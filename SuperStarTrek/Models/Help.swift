//
//  Help.swift
//  SuperStarTrek
//
//  Created by David Parker on 07/04/2023.
//

import Foundation
import SwiftUI

struct HelpEntry: Equatable, Identifiable {
  let line: String
  var id = UUID()
}

struct Help {
  @State var helpShowing = true
  var helpEntries: [HelpEntry] = []

  mutating func showHelp () {
    print("HelpView called")
    //helpShowing = true
    helpEntries.append(HelpEntry(line: "INSTRUCTIONS FOR 'SUPER STAR TREK'"))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "1. Use any of the COMMAND buttons, highlighted in blue to control your progress through the mission. Any COMMAND buttons greyed out indicate damaged systems. Either dock at a starbase for repairs or wait until they are repaired as you progress."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "2. Some COMMANDs require you to enter data. For example, the Navigate COMMAND asks you to enter a Course Direction (0-9). If you enter illegal data, such as negative numbers, then the COMMAND will be aborted."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "3. The Galaxy is divided into an 8 by 8 Quadrant grid, and each Quadrant is further divided into an 8 by 8 Sector grid. You will be assigned a starting point somewhere in the Galaxy to begin a tour of duty as Captain of the Starship Enterprise. Your mission: To seek and destroy the fleet of Klingon Warships which are menacing the United Federation of Planets."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "COMMANDS"))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "NAVIGATE: Warp Engine Control. Course Direction is in a vector arrangement as shown below and accepts whole numbers and decimal numbers, for example 1.5 is halfway between 1 and 2. Directions may approach 9.0 which is equal to 1.0. A Warp Factor of 1 is the size of 1 Quadrant. For example, to get from Quadrant 6,5 to 5,5 you would use Direction 3, Warp Factor 1. To move within a Quadrant, use Warp Factor of 0.1 per space to be moved."))
    helpEntries.append(HelpEntry(line: "  4  3  2  "))
    helpEntries.append(HelpEntry(line: "   . . .   "))
    helpEntries.append(HelpEntry(line: "    ...    "))
    helpEntries.append(HelpEntry(line: "5 ---*--- 1"))
    helpEntries.append(HelpEntry(line: "    ...    "))
    helpEntries.append(HelpEntry(line: "   . . .   "))
    helpEntries.append(HelpEntry(line: "  6  7  8  "))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "SHORT RANGE SCAN: Shows a Short Range Sensor Scan of your present Quadrant. A condensed Status Report is also shown. The symbols on your Sensor Screen are:"))
    helpEntries.append(HelpEntry(line: "<*> Your Starship position"))
    helpEntries.append(HelpEntry(line: "+K+ Klingon Battle Cruiser"))
    helpEntries.append(HelpEntry(line: ">!< Federation Starbase   "))
    helpEntries.append(HelpEntry(line: " *  Star                  "))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "LONG RANGE SCAN: Shows conditions in space for one Quadrant on each side of the Enterprise which is in the middle of the scan. The contents of each Quadrant are shown as a 3-digit code gving the number of Klingons, Starbases and Stars in the Quadrant. For example, 217 would mean 2 Klingons, 1 Starbase and 7 Stars."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "FIRE PHASERS: Allows you to attack Klingon Battle Cruisers by zapping them with large units of energy to deplete their shields. But remember: Klingons have Phasers too and can fire back!"))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "FIRE PHOTON TORPEDOES: Torpedo direction is the same as the Navigate direction. The Ship's computer has an option to calculate the dierction for you. If you hit a Klingon it will be destroyed. If you miss then you are subject to their Phaser fire. Any other Klingons in the Quadrant may also fire back at you."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "SHIELD CONTROL: Allows you to transfer energy to or from the shields. Note that the Status Report shows the total Energy that includes the Shields Energy."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "DAMAGE CONTROL: Gives the repair status of all the ship's systems. Negative numbers indicate the level of damage. Docking at a Starbase allows technicians to repair any damage."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "COMPUTER: The ship's computer has a range of facilities:          "))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "Cumulative Galactic Record: Shows the results of all previous Long Range Scans and Short Range Scans."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "Status Report: Shows the number of Klingons, Starbases as and the time remaining to complete the mission."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "Photon Torpedo Data: Gives the directions to all the Klingons in your current Quadrant."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "Starbase Navigation Data: Gives the Direction and Distance to any Starbase in your current Quadrant."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "Galactic Region Name Map: Gives the names of the sixteen major Galactic Regions referred to in the game."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "DISTANCE & DIRECTION CALCULATOR: Allows you to enter coordinates for distance and direction calculations."))
    displayBlankHelpLine()
    helpEntries.append(HelpEntry(line: "RESIGN COMMAND: Allows you to halt the mission and obtain an efficiency rating and continue or start a new mission."))
    helpShowing = false
    
  }
  mutating func displayBlankHelpLine() {
    helpEntries.append(HelpEntry(line: "                                                            "))
  }
  
}

