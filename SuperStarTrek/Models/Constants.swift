//
//  Constants.swift
//  SuperStarTrek
//
//  Created by David Parker on 14/02/2023.
//

import Foundation
import UIKit
import SwiftUI

enum Constants{
  enum General {
    public static let strokeWidth = CGFloat(2.0)
    public static let roundedViewLength = CGFloat(56.0)
    public static let roundRectViewWidth = CGFloat(68.0)
    public static let roundRectViewHeight = CGFloat(56.0)
    public static let roundRectCornerRadius = CGFloat(21.0)
  }
  enum Game {
      public static let originalStardate = 2000  //T0
      public static let originalEnergy = 3000 //E0
      public static let originalTorpedoes = 10 //P0
      public static let originalKlingonEnergy = 200 //S9
      public static let originalStarbaseEnergy = 10000 //
      public static let originalRomulanEnergy = 1000 //
  }
  enum SystemNumber {
      public static let impulseEngines = 1
      public static let warpDrive = 2
      public static let shortRangeSensors = 3
      public static let longRangeSensors = 4
      public static let phaserControl = 5
      public static let photonTubes = 6
      public static let damageControl = 7
      public static let shieldControl = 8
      public static let libraryComputer = 9
  }
  enum Version {
      public static let currentVersion = "Super Star Trek V1.00.07.1"
      public static let currentCopyright = "\nNavigation System changed. Command buttons reduced in size to increase message area. Romulan warbird detection added. Shield energy now removed from main energy.\n©2024 David R Parker\n(Swift conversion)\n\n©2020 Emanuele Bolognesi\n(Perl conversion)\n\n©1978 David Ahl & Bob Leedom\n(Original BASIC version)"
  }
  enum Help {
    public static let instructionsText = "1. Use the Command buttons below to progress through the mission.\n\nGreyed out buttons are damaged or disabled systems (weapons cannot be used if no enemy is present). Dock at a Starbase to repair damaged systems or wait until they are repaired as you move.\n\n2. Some Commands require data. Example: Impulse Engines and the Warp Drive require Sector or Quadrant Coordinates.\n\nYou can scroll backwards and forwards through the main screen display as required.\n\n3. The Galaxy is divided into an 8 by 8 Quadrant grid. Each Quadrant is further divided into an 8 by 8 Sector grid.\n\nYou are assigned a starting point in the Galaxy to begin a mission as Captain of the Starship Enterprise to seek out and destroy the fleet of Klingon Warships which are menacing the United Federation of Planets.\n\nPress OK and New Mission to start . . ."
    public static let impulseHelp = "The Impulse Engines allow movement within the Quadrant.\n\nUse the Warp Drive to move from Quadrant to Quadrant.\n\nEnter the destination Sector within the Quadrant as first the Row (up and down, 1 to 8) and then the Column (left to right, 1 to 8).  \nEntering anything other than 1 to 8 will abort the command.\n\nPress the Engage button to move to the new Sector position using the Impulse Engines."
    public static let warpDriveHelp = "The Warp Drive allowed movement from Quadrant to Quadrant.\n\nUse the Impulse Engines to move from Sector to Sector within the Quadrant.\n\nEnter the destination Quadrant as first the Row (up and down, 1 to 8) and then the Column (left to right, 1 to 8).  \nEntering anything other than 1 to 8 will abort the command.\n\nPress the Engage button to move to the new Quadrant using the Warp Drive."
    public static let phasersHelp = "Attack enemy ships with units of energy to deplete their shields.\n\nREMEMBER: Enemy ships have Phasers too and can fire back!\n\nEnter energy units to fire (pressing Return will Cancel the command):"
    public static let torpedoesHelp = "Torpedo Target Coordinates are the Sector Coordinates of enemy ships.\n\nThe Library Computer has an option to provide Sector Coordinates of enemy ships for you.\n\nIf you hit an enemy ship it will be destroyed. If you miss then you are subject to their Phaser fire. Other enemy ships in the Quadrant may also fire back at you.\n\nSet Torpedo Course (pressing Return will Cancel the command):"
    public static let shieldsHelp = "Transfer energy to or from the Shields.\n\nStatus Report shows the Total Energy including Shields Energy.\n\nEnter energy to be diverted to shields and press Change (pressing Return will Cancel the command):"
  }
}
