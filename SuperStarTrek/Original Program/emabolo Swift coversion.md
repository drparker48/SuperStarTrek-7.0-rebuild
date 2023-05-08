# emabolo Swift coversion

//
// SUPER STARTREK - MAY 16,1978 - REQUIRES 24K MEMORY
//
// ****        **** STAR TREK ****        ****
// **** SIMULATION OF A MISSION OF THE STARSHIP ENTERPRISE,
// **** AS SEEN ON THE STAR TREK TV SHOW.
// **** ORIGIONAL PROGRAM BY MIKE MAYFIELD, MODIFIED VERSION
// **** PUBLISHED IN DEC'S "101 BASIC GAMES", BY DAVE AHL.
// **** MODIFICATIONS TO THE LATTER (PLUS DEBUGGING) BY BOB
// *** LEEDOM - APRIL & DECEMBER 1974,
// *** WITH A LITTLE HELP FROM HIS FRIENDS . . .
// *** COMMENTS, EPITHETS, AND SUGGESTIONS SOLICITED --
// *** SEND TO:  R. C. LEEDOM
// ***           WESTINGHOUSE DEFENSE & ELECTRONICS SYSTEMS CNTR.
// ***           BOX 746, M.S. 338
// ***           BALTIMORE, MD  21203
// ***
// *** CONVERTED TO MICROSOFT 8 K BASIC 3/16/78 BY JOHN GORDERS
// *** LINE NUMBERS FROM VERSION STREK7 OF 1/12/75 PRESERVED AS
// *** MUCH AS POSSIBLE WHILE USING MULTIPLE STATEMENTS PER LINE
// *** SOME LINES ARE LONGER THAN 72 CHARACTERS; THIS WAS DONE
// *** BY USING "?" INSTEAD OF "PRINT" WHEN ENTERING LINES
// ***
// *************************************************************
// *** Perl Conversion By Emanuele Bolognesi - v1.0 Oct 2020
// ***
// *** The main bug fixes are the number of starbases listed
// *** at the beginning of the game, and the phaser accuracy
// *** correctly affected by computer damage, not shields
// *** I also added instructions and indication of the course.
// *** A lot of comments regarding programming choices and
// *** and possible future improvements/bug fixes
// *** The "look & feel" should be exactly the same, apart from 
// *** a few additional messages that I added
// *** I will continue updating and improving this code, without
// *** changing the original game mechanics.
// *** 
// *** Comments in uppercase are the original comments, lowercase
// *** are mine.
// ***
// *** My blog: http://emabolo.com/
// *** Github:  https://github.com/emabolo
// ***
// *************************************************************
// *** Swift Conversion By David Robert Parker - v1.0 Apr 2021
// ***
// *** 2021.10.17
// *** Problems in CalcAndPrintDirection, CourseControl and 
// *** FirePhotonTorpedoes caused by use of mixture of Int and 
// *** Double handling differently to BASIC and PERL. 
// *** Needs careful recoding or by switching to trig functions
// *** as in LUA TOS version
// *************************************************************

import Foundation

var input = ""
var command$ = ""
var debug = false

AskForInstructions();

// *************************************************************
// Beginning of game
// *************************************************************

print("")
print("")
print("")
print("")
print("")
print("")
print("                                    ,------*------,")
print("                    ,-------------   '---  ------'")
print("                     '-------- --'      / /")
print("                         ,---' '-------/ /--,")
print("                          '----------------'")
print("")
print("")
print("                    THE USS ENTERPRISE --- NCC-1701")
print("")
print("")
print("")
print("")
print("")
print("")

// here is line-260
var SomeSpaces = "                         ";

// Array G is the Galaxy, contains elements of 3 numbers like 215 -> 2 klingons 1 base 5 stars
var Galaxy:[[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)//330 DIM G(8,8)

// Array C contains the delta X and Y depending on the course
// I know it's ugly, but since in BASIC the array starts from 1, I'm filling with zeros the useless elements
var C:[[Int]] = [[0,0,0],[0,0,1],[0,-1,1],[0,-1,0],[0,-1,-1],[0,0,-1],[0,1,-1],[0,1,0],[0,1,1],[0,0,1]] //330 DIM C(9,2;)//530 FOR I=1TO9:C(I,1)=0:C(I,2)=0:NEXTI 540 C(3,1)=-1:C(2,1)=-1:C(4,1)=-1:C(4,2)=-1:C(5,2)=-1:C(6,2)=-1 C(1,2)=1:C(2,2)=1:C(6,1)=1:C(7,1)=1:C(8,1)=1:C(8,2)=1:C(9,2)=1

var i:Int;
var j:Int;

var K:[[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4) // DIM K(3,3) - Klingons

var ExploredSpace:[[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9) // DIM Z(8,8)  # A copy of Galaxy, but only with quadrants explored/scanned

var DamageLevel:[Double] = Array(repeating: 0, count: 9)
// here is line-370
var Stardate = Int.random(in:1...20)+20*100;  // Stardate, numero tra 2000 e 3900 (was $T)
var T0 = Stardate;
var MaxNumOfDays = 25+Int.random(in:1...10);
var ShipDocked = false; // Was D0
var MaxEnergyLevel = 3000;
var EnergyLevel = MaxEnergyLevel;
var PhotonTorpedoes = 10; // (was $P)
var MaxTorpedoes = PhotonTorpedoes;
var KlingonBaseEnergy = 200.00;  // Klingon ship energy range from 0.5x to 1.5x this value
var ShieldLevel = 0;  // Shield level of the Enterprise (was $S)
var TotalStarbases = 0;  // This was set to 2, but the code never adds the 2 additional bases so I changed to 0
var TotalKlingonShips = 0; // was K9
var ShipCondition = "";
var Ss="";
var Ss0=" IS ";
var I,J:Int;
let deviceName = ["","WARP ENGINES       ","SHORT RANGE SENSORS","LONG RANGE SENSORS ","PHASER CONTROL     ","PHOTON TUBES       ",
"DAMAGE CONTROL     ","SHIELD CONTROL     ","LIBRARY-COMPUTER   "];

// REM INITIALIZE ENTERPRIZE'S POSITION

var Q1 = Int.random(in:1...8);    // There are 2 functions in the original BASIC code. I kept the original
var Q2 = Int.random(in:1...8);    // name for this one, that generates a random number between 1 and 8
if debug {print("Enterprise in Quadrant",Q1,Q2)}
var S1 = Int.random(in:1...8);    // Coordinates of Enterprise
var S2 = Int.random(in:1...8);
if debug {print("Enterprise in Sector",S1,S2, "Position",(S2-1)*3+(S1-1)*24)}
for I in 1...8 {
  // Set Damage level to 0 for all systems
  DamageLevel[I] = 0;
}

// All possible commands are here. The algorithm will search
// the string entered by the user in this string and then there was a "ON I GOTO"
// Much shorter than a series of IF

var AllCommands = "NAVSRSLRSPHATORSHEDAMCOMXXX";

// REM SETUP WHAT EXISTS IN GALAXY . . .
var K3 = 0; // KLINGONS in sector
var B3 = 0; // STARBASES in sector
var S3 = 0; // stars in sector

var B4 = 0, B5 = 0;  // B4, B5 = coordinates of the starbase, if any

for I in 1...8 {
  for J in 1...8 {
    K3 = 0;
    ExploredSpace[I][J] = 0;    // Galaxy explored by the player, initially all quadrants are 0
    let R1 = Int.random(in:1...100);
    if (R1 >= 98) {
      K3 = 3;
      TotalKlingonShips = TotalKlingonShips + 3;
    }
    else if (R1 >= 95) {
      K3 = 2;
      TotalKlingonShips = TotalKlingonShips + 2;
    }
    else if (R1 >= 80) {
      K3 = 1;
      TotalKlingonShips = TotalKlingonShips + 1;
    }
    // that is line 980
    B3 = 0;
    if (Int.random(in:1...100) >= 96) {
      B3 = 1;
      TotalStarbases = TotalStarbases + 1;
    }
    Galaxy[I][J] = K3 * 100 + B3 * 10 + Int.random(in:1...9);
  }
}
if (TotalKlingonShips > MaxNumOfDays) {MaxNumOfDays = TotalKlingonShips + 1;}

// Q1, Q2 are random coordinates
if (TotalStarbases == 0) {
  
  // If sector has less than 2 klingon ship, it adds 1 ship and 2 bases, why?
  // also the total number of bases is not increased -  BUG ?
  // Doesnt make sense so I'm commenting the next 3 lines
  //if ($Galaxy[$Q1][$Q2]<200) {
  //  $Galaxy[$Q1][$Q2]=$Galaxy[$Q1][$Q2]+120;
  //  $TotalKlingonShips=$TotalKlingonShips+1;
  //}
  
  //if bases are 0, add a base in a random quadrant, this makes sense
  TotalStarbases = 1;
  Galaxy[Q1][Q2] = Galaxy[Q1][Q2] + 10;
  Q1 = Int.random(in:1...8);
  Q2 = Int.random(in:1...8);
}

var InitialKlingonShips = TotalKlingonShips;

if (TotalStarbases > 1) {
  Ss = "S";
  Ss0 = "ARE";
}

// The function telePrint is just a 'print' with a small delay to slow down text scrolling.

print("YOUR ORDERS ARE AS FOLLOWS:");
print(" DESTROY THE",TotalKlingonShips,"KLINGON WARSHIPS WHICH HAVE INVADED");
print(" THE GALAXY BEFORE THEY CAN ATTACK FEDERATION HEADQUARTERS");
print(" ON STARDATE",T0+MaxNumOfDays,"GIVING YOU",MaxNumOfDays,"DAYS TO COMPLETE YOUR MISSION.");
print(" THERE",Ss0,TotalStarbases,"STARBASE"+Ss,"IN THE GALAXY FOR RESUPPLYING YOUR SHIP.");
print("");
print("");
print("");

I = Int.random(in:1...10);
// IF INP(1)=13 THEN 1300 - this was already commented - function INP does not exist

//===============================================================
// This was line 1320

var X = 0
var Y = 0
var StepX1 = 0.00
var StepX2 = 0.00
var WarpFactor = 0.00
var NoOfSteps = 0;  // global vars used by several functions related to movement of ship
var QuadString = ""
var QuadrantName = "" // Name of the quadrant (was G2)
var GameOver = false;

var Q4 = 0;  // this will contain the coordinate of previous quadrant
var Q5 = 0;  // useful to see if a movement produced a change of quadrant

// main loop, it goes ahead until the enterprise is destroyed or the time is over or klingons are defeated
while (!GameOver) {
  
  K3 = 0;
  B3 = 0;
  S3 = 0;
  
  ExploredSpace[Q1][Q2] = Galaxy[Q1][Q2];  // this quadrant has been discovered
  
  // The original codes check if the Enterprise is inside the borders, not sure why
  if (Q1<1 || Q1>8 || Q2<1 || Q2>8) {
    print("ERROR The Enterprise went outside the border of the galaxy");
  }
  
  QuadrantName = GetQuadrantName(Q1,Q2);
  print("");
  if (T0 == Stardate) {
    print("YOUR MISSION BEGINS WITH YOUR STARSHIP LOCATED");
    print("IN THE GALACTIC QUADRANT",QuadrantName);
  }
  else {
    print("NOW ENTERING ",QuadrantName, "QUADRANT . . .");
  }
  
    if debug {print("Decoding quadrant")};
    K3 = Galaxy[Q1][Q2]/100;
    if debug {print(K3,"Klingons")}
    B3 = (Galaxy[Q1][Q2]/10)-10*K3;
    if debug {print(B3,"Starbases")}
    S3 = Galaxy[Q1][Q2]-100*K3-10*B3;
    if debug {print(S3,"Stars")}
  
    if (K3>0) {
      print("COMBAT AREA      CONDITION RED");
      if(ShieldLevel<=200) {
        print("   SHIELDS DANGEROUSLY LOW");
      }
      //smallDelay(1);
    }
    for I in 1...3 {
      K[I][1] = 0;
      K[I][2] = 0;
      K[I][3] = 0;
    }
  
  // Clean Quadrant String
  QuadString = String(repeating: ".", count: 193);
  
  //  POSITION ENTERPRISE IN QUADRANT, THEN PLACE "K3" KLINGONS, &
  //  "B3" STARBASES, & "S3" STARS ELSEWHERE.
  
  AddElementInQuadrantString(elem:"<*>",y:S1,x:S2);
  if debug {print("Enterprise located in Sector",S1,",",S2,"Position",((S2-1)*3+(S1-1)*24))}
  
  // IF Klingons are present, for each klingon ship, find a place in the quadrant
  if K3 == 0 {
    if debug {print("No Klingons present in this quadrant")}
  }
    
  if (K3>0) {
    for I in 1...K3 {
      if debug {print("Locating Klingon",I)}
      let coordinates = FindEmptyPlaceinQuadrant();
      let R1 = coordinates.y
      let R2 = coordinates.x
      AddElementInQuadrantString(elem:"+K+",y:R1,x:R2);
      K[I][1] = R1;  // coordinates of Klingon ship
      K[I][2] = R2;
      K[I][3] = Int(KlingonBaseEnergy*(0.5*Double.random(in:0.01...0.99)));  
      // energy of the klingon
    }
  }
  
  // If a base is present, place the base
    if B3 == 0 {
      if debug {print("No Starbases present in this quadrant")}
    }
    if (B3>0) {
      if debug {print("Locating Starbase",I)}
      let coordinates = FindEmptyPlaceinQuadrant();
      let R1 = coordinates.y
      let R2 = coordinates.x
      B4 = R1;
      B5 = R2;
      AddElementInQuadrantString(elem:">!<",y:R1,x:R2);
    }
  // For each star, find a place
  if S3 == 0 {
    if debug {print("No Stars present in this quadrant")}
  }
  for I in 1...S3 {
    if debug {print("Locating Star",I)}
    let coordinates = FindEmptyPlaceinQuadrant();
    let R1 = coordinates.y
    let R2 = coordinates.x
    if debug {print("Star coordinates",R1,R2)}
    AddElementInQuadrantString(elem:" * ",y:R1,x:R2);
  }
  
  // this is line 1980 in the original BASIC code
  checkIfDocked();
  ShortRangeSensorScan();
  
  var ReachedNewQuadrant = false;
  
  // This is line-1990 - MAIN LOOP for EXECUTING COMMANDS
  
  while (!ReachedNewQuadrant && !GameOver) {
    
    // of there is very low total energy or shield are damaged, the game is over
    if (EnergyLevel+ShieldLevel<=10 || (EnergyLevel<=10 && DamageLevel[7]<0)) {
      print("\n** FATAL ERROR **   YOU'VE JUST STRANDED YOUR SHIP IN SPACE");
      print("YOU HAVE INSUFFICIENT MANOEUVRING ENERGY, AND SHIELD CONTROL");
      print("IS PRESENTLY INCAPABLE OF CROSS-CIRCUITING TO ENGINE ROOM!!");
      //smallDelay(2);
      GameOver = true;
      break;
    }
    
    print("COMMAND? ");
    getInput() //chomp(my $ans =<>);
    command$ = input.uppercased()//chomp(my $Command = <STDIN>);
      
    if(command$ == "NAV"){
      ReachedNewQuadrant = CourseControl()
    }
    else if(command$ == "SRS"){
      ShortRangeSensorScan();
    }
    else if(command$ == "LRS"){
      LongRangeSensorScan();
    }
    else if(command$ == "PHA"){
      FirePhasers();
    }
    else if(command$ == "TOR"){
      FirePhotonTorpedoes();
    }
    else if(command$ == "SHE"){
      ShieldControl();
    }
    else if(command$ == "DAM"){
      DamageControl();
    }
    else if(command$ == "COM"){
      LibraryComputer();
    }
    else if(command$ == "XXX"){
      GameOver = true;
    }
    else {
      print("ENTER ONE OF THE FOLLOWING:\n");
      print("  NAV  (TO SET COURSE)\n");
      print("  SRS  (FOR SHORT RANGE SENSOR SCAN)\n");
      print("  LRS  (FOR LONG RANGE SENSOR SCAN)\n");
      print("  PHA  (TO FIRE PHASERS)\n");
      print("  TOR  (TO FIRE PHOTON TORPEDOES)\n");
      print("  SHE  (TO RAISE OR LOWER SHIELDS)\n");
      print("  DAM  (FOR DAMAGE CONTROL REPORTS)\n");
      print("  COM  (TO CALL ON LIBRARY-COMPUTER)\n");
      print("  XXX  (TO RESIGN YOUR COMMAND)\n\n");
    }
  }  // keep asking new commands until the ship reaches a new quadrant
  
} // end of the main loop

//6210 REM END OF GAME
print("");
print("IT IS STARDATE ",Stardate);

// this was line 6270
if (TotalKlingonShips>0) {      // IF was not in the original code, added to be more generic
  print("THERE WERE",TotalKlingonShips,"KLINGON BATTLE CRUISERS LEFT AT");
  print("THE END OF YOUR MISSION.");
  print("");
}

// This condition does not make sense. You can restart the game only if
// there are some starbases. But not in the same universe. You restart from scratch
// While if there are no starbases it doesn't ask you if you want to play again

if (TotalStarbases > 0) {
  print("THE FEDERATION IS IN NEED OF A NEW STARSHIP COMMANDER");
  print("FOR A SIMILAR MISSION -- IF THERE IS A VOLUNTEER,");
  print("LET HIM STEP FORWARD AND ENTER 'AYE'? ");
  print("COMMAND? ");
  getInput() //chomp(my $ans =<>);
  command$ = input.uppercased()//chomp(my $Command = <STDIN>);//chomp(my $Command=<>);
  if (command$ == "AYE") {
    //goto BeginningOfGame;
  }
}

print("")
print("Thank you for playing this game!")
print("Perl conversion by Emanuele Bolognesi - http://emabolo.com");

exit(0);

// *************************************************************
// Functions
// *************************************************************
func AddElementInQuadrantString(elem:String,y:Int,x:Int) {
  // INSERT IN STRING ARRAY FOR QUADRANT line 8670
  let position = (x-1)*3+(y-1)*24+1;
  let index = QuadString.index(QuadString.startIndex,offsetBy: position)
  let end = QuadString.index(QuadString.startIndex,offsetBy: position+2)
  // Insert the element in the right position in the quadrant string
  QuadString.replaceSubrange(index...end, with: elem)
  //return;
}
// *************************************************************
func AskForInstructions () {
  print("DO YOU NEED INSTRUCTIONS (Y/N) ? ");
  getInput();
  command$ = input.uppercased()
  if command$ == "Y"
    { PrintInstructions();
    }
}
// New functions from LUA TOS 2
// -- Math functions to calculate distance and direction ==================
// -- The original code was not using trigonometry

//func getAngle(x,y,mCentreX,mCentreY) {
//  dx = x - mCentreX
//  dy = -(y - mCentreY)
  
//  inRads = math.atan2(dy, dx)
  
//  if inRads < 0 then
//  inRads = math.abs(inRads)
//  else
//  inRads = 2 * math.pi - inRads
//  end
  
//  inRads = inRads - (math.pi/2)
//  if inRads<0 then inRads=(math.pi*2+inRads) end  -- rotate
//  return (4*inRads)/math.pi +1  -- convert in course
//}

//func CalcDistanceOfShip(x1,y1,x2,y2) {
//  DX = x1-x2
//  DY = y1-y2
//  return math.sqrt(DX^2 + DY^2)
//}


//func PrintDistanceAndDirection(x1,y1,x2,y2) {
  
//  Direction = getAngle(x1,y1,x2,y2)
//  Print(" Direction = "..roundTo(Direction,2))
  
//  Distance = CalcDistanceOfShip(x1,y1,x2,y2)
//  Print(" Distance = ".. roundTo(Distance,2))
  
//  return Distance
//}


// *************************************************************
func CalcAndPrintDirection(m:Int,n:Int,StartingCourse:Double) -> Bool{
  var Direction = 0.00;

  //8290
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
  print(" DIRECTION =",Direction);
  return false
}
// *************************************************************
func checkIfDocked() -> Bool {
  ShipDocked = false;
  for i in S1-1...S1+1 {
    for j in S2-1...S2+1 {
      let ii = i;
      let jj = j;
      if (ii>=1 && ii<=8 && jj>=1 && jj<=8) {
        if (SearchStringinQuadrant(elem:">!<",y:i,x:j)) {  //found a starbase at coordinates I,J
          ShipDocked = true;
          ShipCondition = "DOCKED";
          EnergyLevel = MaxEnergyLevel;
          PhotonTorpedoes = MaxTorpedoes;
          print("SHIELDS DROPPED FOR DOCKING PURPOSES");
          ShieldLevel = 0;
          break;
        }
      }
    }
  }
  ShipCondition = CheckShipStatus();
  return ShipDocked;
}
// *************************************************************
func CheckShipStatus()-> String {
  if (ShipDocked) {
    return "DOCKED";
  }
  else if (K3>0) {
    return "*RED*";
  }
  else if (EnergyLevel < (MaxEnergyLevel/10) ) {
    return "YELLOW";
  }
  else {
    return "GREEN";
  }
}
// *************************************************************
func ConsumeEnergy() -> Int{
  //MANEUVER ENERGY S/R **
  if debug {print("Energy Level",EnergyLevel)}
  EnergyLevel = EnergyLevel-NoOfSteps-10;  // a warp speed of 8 consumes 8x8+10 =74 energy, speed 1 instead 1x8+10 =18
  if(EnergyLevel>=0) {
    return EnergyLevel //EnergyLevel OK
  }
  print("SHIELD CONTROL SUPPLIES ENERGY TO COMPLETE THE MANOEUVRE.");
  ShieldLevel = ShieldLevel+EnergyLevel;
  EnergyLevel = 0;
  if debug {print("Energy Level",EnergyLevel)}
  if(ShieldLevel<=0) {
    ShieldLevel=0;
  }
  return EnergyLevel
}
// *************************************************************
func CourseControl() -> Bool{
  // COURSE CONTROL BEGINS HERE - line 2290
  ShowDirections();  // the original BASIC code does not show this, comment if you want
  
//  1) Ask for course and speed
  var Course = 0.00
  print("COURSE (0-9) :");
  getInput()
  Course = Double(input) ?? 0.00;
  
  if Course==9 
    {Course = 1};
  if (Course<1 || Course>9) {
    print("   LT. SULU REPORTS, 'INCORRECT COURSE DATA, SIR!'");
  }
  
  var MaxWarp = "8";
  if (DamageLevel[1]<0) 
    {MaxWarp = "0.2"};
  
  WarpFactor = -1.00;
  
  while(WarpFactor<0) {
    print("WARP FACTOR (0-",MaxWarp,")? ");
    getInput()
    WarpFactor = Double(input) ?? 0.00;
    
    if (WarpFactor == 0) {
      //0 warp will cancel the NAV command
    }
    if (DamageLevel[1]<0 && WarpFactor>0.2) {
      print("WARP ENGINES ARE DAMAGED. MAXIMUM SPEED = WARP 0.2");
      WarpFactor = -1;
    }
    else if(WarpFactor>8) {
      print("   CHIEF ENGINEER SCOTT REPORTS 'THE ENGINES WON'T TAKE WARP",WarpFactor,"!");
      WarpFactor = -1;
    }
  }
  if debug {print("Calculating NoOfSteps")}
  NoOfSteps = Int(WarpFactor*8+0.5);  // Energy consumed by warp (formerly N) Number of steps of movement
  if (EnergyLevel < NoOfSteps) {
    print("ENGINEERING REPORTS   'INSUFFICIENT ENERGY AVAILABLE");
    print("                       FOR MANOEUVRING AT WARP",WarpFactor,"!'");
    
    // it's possible to deviate energy from shields to warp
    if (ShieldLevel >= (NoOfSteps - EnergyLevel) && DamageLevel[7]>=0) {
      print("DEFLECTOR CONTROL ROOM ACKNOWLEDGES",ShieldLevel,"UNITS OF ENERGY");
      print("                         PRESENTLY DEPLOYED TO SHIELDS.");
    }
  }
  if debug {print("Energy enough")}
  // If Energy is enough, go ahead
  
//  2) Klingons move (before Enterprise moves)
  if debug {print("Move any Klingons")}
  for I in 0...K3 {
    if debug {print("Moving Klingons")}
    if (K[I][3]>0) {
      if debug {print("Moving Klingon",I)}
      AddElementInQuadrantString(elem:"...",y:K[I][1],x:K[I][2]);  // delete ship in current position
      let coordinates = FindEmptyPlaceinQuadrant();        // returns a new position in R1,R2
      K[I][1] = coordinates.y;
      K[I][2] = coordinates.x;
      AddElementInQuadrantString(elem:"+K+",y:K[I][1],x:K[I][2]);  // put ship in the new position
    }
  }
  
// 3) Klingons fire (before Enterprise moves)
  if debug {print("Klingons attack")}
  if (KlingonsAttack()) {
    
    // if KlingonsAttack returns true, the Enterprise has been destroyed
    // GameOver is set to true, so when CourseControl function returns, the game will end
  }
  
//  4) Now check if the movement will repair some Ship systems
//  since this happens after Klingon attack, some device just broken by the klingon can get repaired, nonsense
  if debug {print("Checking for repairs")}
  var RepairFactor = WarpFactor;
  if (WarpFactor >= 1) {
    RepairFactor = 1.00;
  }
  
  var devIndex = 0;
  for I in 1...8 {
    if (DamageLevel[I] < 0) {
      DamageLevel[I] = DamageLevel[I]+RepairFactor;  //  -- moving by 1 quadrant repair by 1
      if (DamageLevel[I] > -0.1 && DamageLevel[I] < 0) {  //  -- if it's almost 0, goes back to -0.1
        DamageLevel[I] = -0.1;
      }
      else if (DamageLevel[I]>=0) {
        print("DAMAGE CONTROL REPORT: '",deviceName[I]," REPAIR COMPLETED.'");
      }
    }
  }
  
//  5) Now check if a random system is broken or repaired
//  In 20% of the cases, select a random system and either repair it or break it
//  wouldn't it be better to do it in the previous loop?
  if debug {print("Checking for damage")}
  if (Double.random(in:0.00...0.99)<=0.2) {
    devIndex=Int.random(in:1...8);
    if (Double.random(in:0.00...0.99)>=0.6) {
      // it does not make sense that a system can have damage > 0
      // also what's the point of repairing something if it was not broken?
      DamageLevel[devIndex]=DamageLevel[devIndex]+Double.random(in:0.00...0.99)*3+1;
      print("DAMAGE CONTROL REPORT: '",deviceName[devIndex]," STATE OF REPAIR IMPROVED.'");
    }
    else {
      // it's possible that something that just got repaired, it's broken here, nonsense
      DamageLevel[devIndex]=DamageLevel[devIndex]-(Double.random(in:0.00...0.99)*5+1);
      print("DAMAGE CONTROL REPORT: '",deviceName[devIndex]," DAMAGED.'");
    }
  }
  
//  6) Finally the Enterprise can move
  //3070 A$="   ":Z1=INT(S1):Z2=INT(S2):GOSUB8670
  //3110 X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1)):X=S1:Y=S2
  //3140 X2=C(C1,2)+(C(C1+1,2)-C(C1,2))*(C1-INT(C1)):Q4=Q1:Q5=Q2
  //3170 FORI=1TON:S1=S1+X1:S2=S2+X2:IFS1<1ORS1>=9ORS2<1ORS2>=9THEN3500
  //3240 S8=INT(S1)*24+INT(S2)*3-26:IFMID$(Q$,S8,2)="  "THEN3360
  //3320 S1=INT(S1-X1):S2=INT(S2-X2):PRINT"WARP ENGINES SHUT DOWN AT ";
  //3350 PRINT"SECTOR";S1;",";S2;"DUE TO BAD NAVAGATION":GOTO3370
  //3360 NEXTI:S1=INT(S1):S2=INT(S2)
  //3370 A$="<*>":Z1=INT(S1):Z2=INT(S2):GOSUB8670:GOSUB3910:T8=1
  //3430 IFW1<1THENT8=.1*INT(10*W1)
  //3450 T=T+T8:IFT>T0+T9THEN6220
  
  if debug {print("Move Enterprise")}
  AddElementInQuadrantString(elem:"...",y:Int(S1),x:Int(S2));  // delete ship
  
  let cindex = Int(Course);
  if debug {print("cindex",cindex)}
  //3110 X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1)):X=S1:Y=S2
  //$StepX1=$C[$cindex][1]+($C[$cindex+1][1]-$C[$cindex][1])*($Course-$cindex);
  StepX1 = Double(C[cindex+1][1]-C[cindex][1])*(Course-Double(cindex));
  if debug {print("StepX1",StepX1)}
  StepX1 = StepX1 + Double(C[cindex][1]);
  if debug {print("StepX1",StepX1)}
  //$StepX2=$C[$cindex][2]+($C[$cindex+1][2]-$C[$cindex][2])*($Course-$cindex);
  StepX2 = Double(C[cindex+1][2]-C[cindex][2])*(Course-Double(cindex));
  if debug {print("StepX2",StepX2)}
  StepX2 = StepX2 + Double(C[cindex][2]);
  if debug {print("StepX2",StepX2)}
  
  X = S1;    // save previous Enterprise position
  Y = S2;
  
  Q4 = Q1;  // save previous Enterprise quadrant  
  Q5 = Q2;
  
  for _ in 1...NoOfSteps {
    if debug {print("S1 and S2 before stepped",S1,S2)}
    S1 = S1+Int(StepX1);
    S2 = S2+Int(StepX2);
    if debug {print("S1 and S2 after stepped",S1,S2)}
    //-- While inside the quadrant, the Enterprise will move step by step, checking if
    //-- it encounters an obstacle, or tries to cross the border of the quadrant
    //-- once the border is crossed, all the rest of the movement will be performed by ExceededQuadrantLimits
    //-- at that point, obstacles dont matter any more, all the movement will be done in one big step
    //-- This makes sense if we consider inside quadrant Impulse Speed and once crossed, Warp speed
    
    if (S1<1 || S1>8 || S2<1 || S2>8) {
      //-- This will check if Enterprise has moved to another quadrant, and will make the rest of the movements
      //-- It's possible that the ship tried to cross border of quadrant and it stopped
      //-- so quadrant has not changed, in this case the function will return false and loop will break
      if (ExceededQuadrantLimits()) {
        // movement has finished
        return true;
      }
      else {
        // exit the "for" loop and then do EndOfMovementInQuadrant
        break;
      }
    }
    
    // still in the same quadrant, so it will continue moving
    
    if (SearchStringinQuadrant(elem:"...",y:S1,x:S2)) {
      // ok then
    }
    else {
      // if space is NOT empty
      // Go back to previous position and exit loop
      S1 = Int(Double(S1)-StepX1);
      S2 = Int(Double(S2)-StepX2);
      print("WARP ENGINES SHUT DOWN AT");
      print("SECTOR",S1,S2,"DUE TO BAD NAVIGATION.");
      break;
    }
  }
  // not sure why INT is necessary
  S1 = Int(S1);
  S2 = Int(S2);
  
  EndOfMovementInQuadrant();
  
  return false;   // still in the same quadrant
}
// *************************************************************
func CumulativeGalacticRecord() -> Bool {
  print("       COMPUTER RECORD OF GALAXY FOR QUADRANT",Q1,Q2);
  PrintComputerRecord(GalaxyMapOn:0);
  return true;
}
// *************************************************************
func DamageControl() {
  print("Damage Control function")
  //5680 REM DAMAGE CONTROL - 5690
  if (DamageLevel[6]>=0) {
    print("\nDEVICE             STATE OF REPAIR");
    for index in 1...8 {
      print(deviceName[index],DamageLevel[index]);
    }
  }
  else {
    print("DAMAGE CONTROL REPORT NOT AVAILABLE");
  }
  print("");
  
  // By checking the status, you can also ask to repair, if docked
  if (ShipDocked) {
    // 5720
    var TimeToRepair = 0.00;
    for I in 1...8 {
      if (DamageLevel[I]<0) {
        TimeToRepair = TimeToRepair+0.1;  //Time increases for each damaged system
      }
    }
    if (TimeToRepair==0) {
      return;          //nothing to repair
    }
    print("");
    
    TimeToRepair = TimeToRepair+Double.random(in:0...0.5);
    
    if (TimeToRepair>0.9) {
      TimeToRepair = 0.9;}  // never more than 1 day
    
    print("TECHNICIANS STANDING BY TO EFFECT REPAIRS TO YOUR SHIP;");
    print("ESTIMATED TIME TO REPAIR:",TimeToRepair,"STARDATES");
    print("WILL YOU AUTHORIZE THE REPAIR ORDER (Y/N) ? ");
    getInput();
    command$ = input.uppercased()
    if command$ == "Y" {
      for I in 1...8 {
        if (DamageLevel[I]<0) {
          DamageLevel[I]=0;
        }
      }
      Stardate = Stardate+Int(TimeToRepair+0.1);    // never trust engineers!
      print("REPAIR COMPLETED.");
    }
  }
  return;  
}
// *************************************************************
func DistanceCalculator() -> Bool{
  print("DIRECTION/DISTANCE CALCULATOR:");
  print("YOU ARE AT QUADRANT",Q1,Q2,"SECTOR",S1,S2);
  print("PLEASE ENTER INITIAL COORDINATES (X,Y): ");
  getInput()
  let y1 = Int(input) ?? 0
  getInput()
  let x1 = Int(input) ?? 0//chomp(my $Coord = <>);
  //my ($y1,$x1) = split(/,/,$Coord,2);
  
  print("  FINAL COORDINATES (X,Y): ");
  //chomp($Coord = <>);
  //my ($y2,$x2) = split(/,/,$Coord,2);
  let y2 = Int(input) ?? 0
  getInput()
  let x2 = Int(input) ?? 0
  if (validCoord(n:x1) && validCoord(n:y1) && validCoord(n:x2) && validCoord(n:2)) {
    PrintDistanceAndDirection(W1:y2,X:x2,C1:y1,A:x1);
    return true;
  }
  else {
    print("WRONG COORDINATES");
    return false;
  }
}
// *************************************************************
func DistanceOfShip(Index:Int) -> Double {
  // Distance between enterprise and Klingon ship
  //my Index =shift;

  let DX = Double(K[Index][1]-S1);
  let DY = Double(K[Index][2]-S2);
  
  return ((DX*DX)+(DY*DY)).squareRoot();   // IN PERL DONT DO THIS: N^2 !!!
}
// *************************************************************
func EndOfMovementInQuadrant() -> Bool{
  //  this is line-3370
  //  These are the last operations done before end of the turn, if the Enterprise has not changed quadrant
  AddElementInQuadrantString(elem:"<*>",y:S1,x:S2);
  ConsumeEnergy();
  var DayIncrement = 1.00;    // time advances by 1, even if you traveled at warp speed 9
  
  if (WarpFactor<1) {
    DayIncrement = WarpFactor;
  }
  Stardate = Stardate+Int(DayIncrement);
  if (Stardate > T0+MaxNumOfDays) {
    GameOver = true;
    return true;
  }
  
  checkIfDocked();
  ShortRangeSensorScan();
  
  return false;
}
// *************************************************************
func EnterpriseDestroyed() {
  print("THE ENTERPRISE HAS BEEN DESTROYED.  THEN FEDERATION WILL BE CONQUERED.");
  return;
}
// *************************************************************
func ExceededQuadrantLimits() ->Bool {
  // checking if quadrant has been exceeded. If it's still in the same quadrant, returns 0
  var CrossingPerimeter:Bool = false
  X = 8*Q1+X+NoOfSteps*Int(StepX1);
  Y = 8*Q2+Y+NoOfSteps*Int(StepX2);
  Q1 = Int(X/8);
  Q2 = Int(Y/8);
  S1 = Int(X-Q1*8);
  S2 = Int(Y-Q2*8);
  
  if (S1 == 0) {
    Q1 = Q1-1;
    S1 = 8;
  }
  if (S2==0) {
    Q2 = Q2-1;
    S2=8;
  }
  CrossingPerimeter = false;
  if(Q1<1) {
    CrossingPerimeter = true;
    Q1 = 1;
    S1 = 1;
  }
  if (Q1>8) {
    CrossingPerimeter = true;
    Q1 = 8;
    S1 = 8;
  }
  if(Q2<1) {
    CrossingPerimeter = true;
    Q2 = 1;
    S2 = 1;
  }
  if(Q2>8) {
    CrossingPerimeter = true;
    Q2 = 8;
    S2 = 8;
  }
  if(CrossingPerimeter == true) {
    print("LT. UHURA REPORTS MESSAGE FROM STARFLEET COMMAND:");
    print("  'PERMISSION TO ATTEMPT CROSSING OF GALACTIC PERIMETER");
    print("  IS HEREBY *DENIED*.  SHUT DOWN YOUR ENGINES.'");
    print("CHIEF ENGINEER SCOTT REPORTS  'WARP ENGINES SHUT DOWN");
    print("  AT SECTOR",S1,S2,"OF QUADRANT",Q1,Q2);
  }
  // this is 3860
  
  if(Q1*8+Q2 == Q4*8+Q5) {
    //-- Quadrant not changed - this could have been (Q1 == Q4 and Q2 == Q5)
    //-- this happens only when CrossingPerimeter is true, but not vice versa
    //-- I could have Crossed the perimeter after changing 1 or more quadrant
    return false;
  }
  
  // If arrived here, it means we reached a new quadrant, so time advances by 1
  // unlike EndOfMovementInQuadrant, this is true also when the warp speed is <1, if this has moved the Enterprise
  // to another quadrant. I think it makes sense
  Stardate = Stardate+1;
  
  if (Stardate > T0+MaxNumOfDays) {
    GameOver = true;
    return true;
  }
  
  ConsumeEnergy();
  // No more in the same quadrant, this will end the inner main loop
  return true;
}
// *************************************************************
func FindEmptyPlaceinQuadrant() -> (y:Int,x:Int) {
  // FIND EMPTY PLACE IN QUADRANT (FOR THINGS)
  // generate 2 random coordinates, and check if quadrant cell is empty.
  // If empty space is found, returns the coordinates
  var found:Bool = false;
  var b = 0
  var a = 0
  while (!found) {
    b = Int.random(in:1...8);
    a = Int.random(in:1...8);
    if debug {print("Random coordinates",b,a)}
    found = SearchStringinQuadrant(elem:"...",y:b,x:a);
  }
  if debug {print("Empty coordinates",b,a)}
  return (b,a);
}
// *************************************************************
func FirePhasers() {
  // formerly line 4260 REM PHASER CONTROL CODE BEGINS HERE
  if debug {print("Energy Level",EnergyLevel)}
  if (DamageLevel[4]<0) {
    print("PHASERS INOPERATIVE");
    //return false;
  }
  if (K3<1) {
    print("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS");
    print("                                IN THIS QUADRANT'");
    //return false;
  }
  if(DamageLevel[8]<0) {
    print("COMPUTER FAILURE HAMPERS ACCURACY");
  }
  print("PHASERS LOCKED ON TARGET:  ");
  //my $Units;
  if debug {print("Energy Level",EnergyLevel)}
  var Units = 0
  var H1 = 0.00
  var KlingonEnergy = 0.00
  var distance = 0.00
  var distanceRatio = 0.00
  var HitPoints = 0.00
  repeat{
    print("ENERGY AVAILABLE = ",EnergyLevel,"UNITS");
    print("NUMBER OF UNITS TO FIRE? ");
    getInput()
    Units = Int(input) ?? 0
    //return if (Units == 0) {false};
  } while (Double(Units)>Double(EnergyLevel));
  if debug {print("Energy Level",EnergyLevel)}
  EnergyLevel = EnergyLevel-Units;
  if debug {print("Energy Level",EnergyLevel)}
  if(DamageLevel[8]<0) {      // when computer is broken, the risk is to waste energy
    Units = Units/Int.random(in:0...9);  // the original code has a bug, it checks shield damage not computer damage
  }
  if debug {print("Divide Phaser fire across enemy ships")}
  if debug {print("Units",Units,"K3",K3)}
  H1 = Double(Units)/Double(K3);   // all the phasers energy is split amongst the enemy ships
  if debug {print("Phaser energy per ship",H1)}
  if debug {print("Energy Level",EnergyLevel)}
  for I in 1...3 {
    if debug {print("Energy Level",EnergyLevel)}
    KlingonEnergy = Double(K[I][3]);
    if debug {print("Klingon",I,"energy",K[I][3])}
    if (KlingonEnergy>0) {
      if debug {print("Energy Level",EnergyLevel)}
      distance = DistanceOfShip(Index:I);
      distanceRatio = H1/distance;    // damage is inversely proportional to distance
      let randNumb = Double.random(in:0.00...0.99)+2;        // but a random factor can increse damage up to x2
      HitPoints = (distanceRatio*randNumb);
      if debug {print("Energy Level",EnergyLevel)}
      if (HitPoints <= (0.15*KlingonEnergy)) {
        print("SENSORS SHOW NO DAMAGE TO ENEMY",I,"AT ",K[I][1],",",K[I][2]);
        HitPoints = 0;
      }
      else {
        K[I][3] = K[I][3]-Int(HitPoints);
        print(Int(HitPoints),"UNIT HIT ON KLINGON",I,"AT SECTOR ",K[I][1],",",K[I][2]);
        if debug {print("Energy Level",EnergyLevel)}
      }
      
      if (K[I][3] > 0) {
        print("   (SENSORS SHOW ",Int(K[I][3])," UNITS REMAINING)");
        if debug {print("Energy Level",EnergyLevel)}
      }
      else {
        print("*** KLINGON DESTROYED ***");
        K3 = K3-1;
        ShipCondition = CheckShipStatus();
        TotalKlingonShips = TotalKlingonShips-1;
        if debug {print("Energy Level",EnergyLevel)}
        
        if(TotalKlingonShips <= 0) {
          KlingonsDefeated();
          GameOver = true;
          //return true;
        }
        
        AddElementInQuadrantString(elem:"...",y:K[I][1],x:K[I][2]);  // Delete klingon ship from screen
        K[I][3] = 0;   // isnt it already 0 ?
        Galaxy[Q1][Q2] = Galaxy[Q1][Q2]-100;      // Delete klingon ship from galaxy array
        ExploredSpace[Q1][Q2] = Galaxy[Q1][Q2];      // clear also explored galaxy
      }
      
    }
  }
  KlingonsAttack();
  //return false;
}
// *************************************************************
func FirePhotonTorpedoes() -> Bool{//4690 REM PHOTON TORPEDO CODE BEGINS HERE
  if (PhotonTorpedoes<=0) {
    print("ALL PHOTON TORPEDOES EXPENDED.");
    return false;
  }
  if (DamageLevel[5]<0) {
    print("PHOTON TUBES ARE NOT OPERATIONAL.");
    return false;
  }
  ShowDirections();  // the original BASIC code does not show this, comment if you want
  print("PHOTON TORPEDO COURSE (1-9)? ");
  //my $Course = <>;
  //chomp($Course);
  //return 0 if (Course !~ /^\d$/ && Course !~ /^\d\.\d+$/); //check that the course is correct
  var Course = 0.00
  getInput()
  Course = Double(input) ?? 0.00
  if Course == 9 {
    Course = 1;
  }
  if (Course<0.1 || Course>9) {
    print("ENSIGN CHEKOV REPORTS,  'INCORRECT COURSE DATA, SIR!'");
    return false;
  }
  
  EnergyLevel = EnergyLevel-2;
  PhotonTorpedoes = PhotonTorpedoes-1;
  
  let cindex = Int(Course);  // this is not present in BASIC. Also in Perl is not necessary
  
  StepX1 = Double(C[cindex+1][1]-C[cindex][1])*(Course-Double(cindex));
  if debug {print("StepX1",StepX1)}
  StepX1 = StepX1 + Double(C[cindex][1]);
  if debug {print("StepX1",StepX1)}
  StepX2 = Double(C[cindex+1][2]-C[cindex][2])*(Course-Double(cindex));
  if debug {print("StepX2",StepX2)}
  StepX2 = StepX2 + Double(C[cindex][2]);
  if debug {print("StepX2",StepX2)}
  
  X=S1;  // torpedoes starting coordinates = Enterprise coordinates
  Y=S2;
  print("TORPEDO TRACK:");
  
  // this is line 4920
  
  var KlingonDestroyed = 0;
  var X3 = 0
  var Y3 = 0
  
  while (true) {
    X = X+Int(StepX1);
    Y = Y+Int(StepX2);
    X3 = Int(Double(X)+0.5);
    Y3 = Int(Double(Y)+0.5);
    
    if (X3<1 || X3>8 || Y3<1 || Y3>8) {
      // torpedo is out of borders
      print("TORPEDO MISSED!");
      break;
    }
    
    print("------------->",X3,",",Y3);
    if (SearchStringinQuadrant(elem:"...",y:X,x:Y)) {
      // found white space, continue and go to next iteration of loop
    }
    else if (SearchStringinQuadrant(elem:"+K+",y:X,x:Y)) {
      // found a klingon at coordinates X, Y
      print("*** KLINGON DESTROYED ***");
      K3 = K3-1;
      ShipCondition = CheckShipStatus();    // could become GREEN if there are no more klingons
      
      TotalKlingonShips = TotalKlingonShips-1;      
      if (TotalKlingonShips<=0) {
        KlingonsDefeated();
        GameOver = true;
        return true;
      }
      // Check which Klingon has been destroyed
      for I in 1...3 {
        if (X3 == K[I][1] && Y3 == K[I][2]) {
          K[I][3]=0;
          KlingonDestroyed = I;
        }
      }
      AddElementInQuadrantString(elem:"...",y:X,x:Y);        // remove klingon
      Galaxy[Q1][Q2]=K3*100+B3*10+S3;        // update galaxy 
      ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2];      // update explored galaxy
      break;
    }
    else if (SearchStringinQuadrant(elem:" * ",y:X,x:Y)) {
      // It was not a Klingon, checking if I hit a star
      print("STAR AT",X3,",",Y3," ABSORBED TORPEDO ENERGY.");
      break;
    }
    // Check if I hit a starbase
    else if (SearchStringinQuadrant(elem:">!<",y:X,x:Y)) {
      // found a starbase
      print("*** STARBASE DESTROYED ***");
      B3=B3-1;
      TotalStarbases = TotalStarbases-1;
      if (TotalStarbases>0 || TotalKlingonShips>Stardate-T0-MaxNumOfDays)  {
        print("STARFLEET COMMAND REVIEWING YOUR RECORD TO CONSIDER");
        print("COURT MARTIAL!");
        ShipDocked = false;  // if docked, no more docked - but what if I was docked to another base?
        
        AddElementInQuadrantString(elem:"...",y:X,x:Y);    // remove base
        Galaxy[Q1][Q2]=K3*100+B3*10+S3;  // update galaxy 
        ExploredSpace[Q1][Q2]=Galaxy[Q1][Q2];
        break;
      }
      else {
        print("THAT DOES IT, CAPTAIN!!  YOU ARE HEREBY RELIEVED OF COMMAND");
        print("AND SENTENCED TO 99 STARDATES AT HARD LABOR ON CYGNUS 12!!");
        GameOver = true;
        return true;
      }
    }
    else {
      // If the space was not empty, and I didnt hit a star, nor a base, or a klingon
      // what else could have happened?
      // in the original code, it asks again to enter the course
      // here I just print a message to see if this can really happen
      print("An unknown object has been hit");
      break;
    }
  }
  KlingonsAttack();
  return true;
}
// *************************************************************
func GalaxyMap() -> Bool {
  //7390 REM SETUP TO CHANGE CUM GAL RECORD TO GALAXY MAP
  print("                        THE GALAXY"); // GOTO7550
  PrintComputerRecord(GalaxyMapOn:1);
  return true;
}
// *************************************************************
func getInput() {
  // get keyboard input, and trim the new line
  input = String(bytes: FileHandle.standardInput.availableData, encoding: .utf8)!
  input = input.trimmingCharacters(in: .whitespacesAndNewlines)
}
// *************************************************************
func GetQuadrantName(_ Z4:Int, _ Z5:Int, RegionNameOnly: Int=0) -> String {
  
  //die if (!$Z4 || !$Z5);
  
  // QUADRANT NAME IN G2$ FROM Z4,Z5 (=Q1,Q2)
  // CALL WITH G5=1 (RegionNameOnly) TO GET REGION NAME ONLY
  var starnames: [String];
  if (Z5 <= 4) {
    starnames = ["ANTARES","RIGEL","PROCYON","VEGA","CANOPUS","ALTAIR","SAGITTARIUS","POLLUX"];
  }
  else {
    starnames = ["SIRIUS","DENEB","CAPELLA","BETELGEUSE","ALDEBARAN","REGULUS","ARCTURUS","SPICA"];
    
  }
  QuadrantName = starnames[Z4-1];
  if (RegionNameOnly == 0) {
    if (Z5 == 1 || Z5 == 5) {
      QuadrantName = QuadrantName+" I";
    }
    else if(Z5 == 2 || Z5 == 6) {
      QuadrantName = QuadrantName+" II";
    }
    else if(Z5 == 3 || Z5 == 7) {
      QuadrantName = QuadrantName+" III";
    }
    else if(Z5 == 4 || Z5 == 8) {
      QuadrantName = QuadrantName+" IV";
    }
  }
  return QuadrantName;
}
// *************************************************************
func KlingonsAttack() -> Bool {
  // this was line-6000
  if (K3<=0) {
    return false;
  }
  print("KLINGON SHIPS ATTACK THE ENTERPRISE");   // This message is not in the original game
  var KlingonEnergy = 0.00
  var Hits = 0.00
  if (ShipDocked) {
    print("STARBASE SHIELDS PROTECT THE ENTERPRISE.");
    return false;
  }
  
  for I in 1...3 {
    KlingonEnergy = Double(K[I][3]);
    if (KlingonEnergy>0) {
      Hits = (KlingonEnergy/DistanceOfShip(Index:I))*(2+Double.random(in:0.00...0.99))+1;
        
      ShieldLevel = ShieldLevel-Int(Hits);
      
      // The choice below is strange. Energy of the klingon decrease when they fire
      // but it does not depend on the power used by the phasers
      // also it decreases a lot, because it can become 1/3 or 1/4 of the previous energy
      // would be better to use an algorithm similar to the one used for the Enterprise
      // Basically they are committing suicide
      
      K[I][3] = Int(KlingonEnergy/(3+Double.random(in:0.00...0.99)));
      
      print(Int(Hits),"UNIT HIT ON ENTERPRISE FROM SECTOR ",K[I][1],",",K[I][2]);
      if(ShieldLevel<0) {
        EnterpriseDestroyed();
        GameOver = true;
        return true;
      }
      print("      <SHIELDS DOWN TO",ShieldLevel,"UNITS");
      
      if (Hits>19 && (ShieldLevel==0 || (Int.random(in:1...10)<6 && (Hits/Double(ShieldLevel)) > 0.02)) ) {
        //my $SysDamaged=FNR(1);
        let SysDamaged = Int.random(in:1...8)
        DamageLevel[SysDamaged] = DamageLevel[SysDamaged] - (Hits/Double(ShieldLevel)) - (0.5 * Double.random(in:0.00...0.99));
        print("DAMAGE CONTROL REPORTS '",deviceName[SysDamaged]," DAMAGED BY THE HIT'");  
      }
    }
  }
  return false;
}
// *************************************************************
func KlingonsDefeated() {
  print("CONGRATULATIONS, CAPTAIN!  THEN LAST KLINGON BATTLE CRUISER");
  print("MENACING THE FEDERATION HAS BEEN DESTROYED.");
  print("YOUR EFFICIENCY RATING IS ",Int(1000*(InitialKlingonShips/(Stardate-T0))^2));
  //return;
}
// *************************************************************
func LibraryComputer(){
  //7280 REM LIBRARY COMPUTER CODE - 7290
  if(DamageLevel[8]<0) {
    print("COMPUTER DISABLED");
    //return false;
  }
  var ComputerDone = false;//need to decide how to implement this 
  var command = 0
  while(!ComputerDone) {
    print("COMPUTER ACTIVE AND AWAITING COMMAND? ");
    getInput()
    command = Int(input) ?? 0
    print("");
    
    if(command == 0) {
      ComputerDone = CumulativeGalacticRecord(); //7540
    }
    else if(command == 1) {
      ComputerDone = StatusReport();  //7900
    }
    else if(command == 2) {
      ComputerDone = PhotonTorpedoData(); //8070
    }
    else if(command == 3) {
      ComputerDone = StarbaseNavData(); //8500
    }
    else if(command == 4) {
      ComputerDone = DistanceCalculator(); //8150
    }
    else if(command == 5) {
      ComputerDone = GalaxyMap(); //7400
    }
    else {
      print("FUNCTIONS AVAILABLE FROM LIBRARY-COMPUTER:");
      print("   0 = CUMULATIVE GALACTIC RECORD");
      print("   1 = STATUS REPORT");
      print("   2 = PHOTON TORPEDO DATA");
      print("   3 = STARBASE NAV DATA");
      print("   4 = DIRECTION/DISTANCE CALCULATOR");
      print("   5 = GALAXY 'REGION NAME' MAP");
    }
  }
  //return false;
}
// *************************************************************
func LongRangeSensorScan() {
  print("Long Range Sensor Scan function")
    //LONG RANGE SENSOR SCAN CODE
    // it was line 4000
    var N:[Int] = Array(repeating: 0, count: 4);
    if (DamageLevel[3]<0) {
      print("LONG RANGE SENSORS ARE INOPERABLE.");
      //return false;
    }
    print("LONG RANGE SCAN FOR QUADRANT",Q1,",",Q2);
    let Header = "-------------------";
    print(Header);
    for I in Q1-1...Q1+1 {
      N[1] = -1;  // if it's not a positive number later, it means the quadrant does not exist
      N[2] = -2;
      N[3] = -3;
      for J in Q2-1...Q2+1 {
        if (I>0 && I<9 && J>0 && J<9) {
          N[J-Q2+2] = Galaxy[I][J];
          ExploredSpace[I][J] = Galaxy[I][J];    // Scan a new quadrant
        }
      }
      for idx in 1...3 {
        print(": ",terminator:"");
        if (N[idx]<0) {
          print("*** ",terminator:"");
        }
        else {
          var strdollar = String(N[idx]+1000);
          strdollar.remove(at:strdollar.startIndex)
          print(strdollar,"",terminator:"");
        }
      }
      print(":");
      print(Header);
    }
    //return false; // goto 1990

}
// *************************************************************
func PhotonTorpedoData() -> Bool{
  //8060 REM TORPEDO, BASE NAV, D/D CALCULATOR
  if(K3<=0) {
    print("SCIENCE OFFICER SPOCK REPORTS  'SENSORS SHOW NO ENEMY SHIPS");
    print("                                IN THIS QUADRANT'");
    return true;
  }
  Ss="";
  if (K3>1) {
    Ss="S";
  }
  print("FROM ENTERPRISE TO KLINGON BATTLE CRUISER",Ss,":");
  
  for I in 1...3 {
    if (K[I][3]>0) {
      print("Klingon at",K[I][1],",",K[I][2])
      PrintDistanceAndDirection(W1:K[I][1],X:K[I][2],C1:S1,A:S2)
    }
  }
  return true;
}
// *************************************************************
func PrintComputerRecord(GalaxyMapOn:Int) -> Bool{
  //my $GalaxyMapOn = shift;
  var tempString = ""
  print("       1     2     3     4     5     6     7     8");
  print("     ----- ----- ----- ----- ----- ----- ----- -----")
  for I in 1...8 {
    print(I,"  ",terminator:"");
    if (GalaxyMapOn==1) {
      QuadrantName = GetQuadrantName(I,1,RegionNameOnly:0);
      print("  ",QuadrantName,terminator:"");
      QuadrantName = GetQuadrantName(I,5,RegionNameOnly:0);
      print("  ",QuadrantName,terminator:"");
    }
    else {
      for J in 1...8 {
        print("  ",terminator:"");
        if (ExploredSpace[I][J]==0) { 
          print("*** ",terminator:"");
        }
        else {
          tempString = String(ExploredSpace[I][J]+1000);
          tempString.remove(at:tempString.startIndex)
          print(tempString+" ",terminator:"");
          
        }
      }
    }
    print("");
    print("     ----- ----- ----- ----- ----- ----- ----- -----");
  }
  print("");
  return false;
}
// *************************************************************
func PrintDistanceAndDirection(W1:Int,X:Int,C1:Int,A:Int) -> Bool{
  //my $W1 = shift;
  //my $X = shift;
  //my $C1 = shift;
  //my $A = shift;
  var Distance:Double
  let X = X-A;
  let A = C1-W1;
  if (X<0) {
    if(A>0) {
      CalcAndPrintDirection(m:A,n:X,StartingCourse:3);  // A>0 and X < 0
    }
    else if(X != 0) {             // else would be enough here (X<0 and A <=0)
      CalcAndPrintDirection(m:X,n:A,StartingCourse:5);
    }
  }
  else {
    if (A<0) {              // case X>= 0 and A < 0
      CalcAndPrintDirection(m:A,n:X,StartingCourse:7);
    }
    else if(X>0) {            // the only case where this is not true is X = 0
      CalcAndPrintDirection(m:X,n:A,StartingCourse:1);
    }
    else if (A==0) {            // so X = 0 and A = 0
      CalcAndPrintDirection(m:X,n:A,StartingCourse:5);
    }
    else if (A > 0) {          // so X = 0 and A > 0
      CalcAndPrintDirection(m:X,n:A,StartingCourse:1);
    }
  }
  Distance = Double((X*X)+(A*A)).squareRoot();
  print(" DISTANCE =",Distance);
  
  return true;
}
// *************************************************************
func PrintInstructions() {
  print("          *************************************")
  print("          *                                   *")
  print("          *                                   *")
  print("          *      * * SUPER STAR TREK * *      *")
  print("          *                                   *")
  print("          *                                   *")
  print("          *************************************")
  print("")
  print("          INSTRUCTIONS FOR 'SUPER STAR TREK'")
  print("1. WHEN YOU SEE 'COMMAND ?' PRINTED, ENTER ONE OF THE LEGAL")
  print("   COMMANDS (NAV,SRS,LRS,PHA,TOR,SHE,DAM,COM, OR XXX).")
  print("2. IF YOU SHOULD TYPE IN AN ILLEGAL COMMAND, YOU'LL GET A SHORT")
  print("   LIST OF THE LEGAL COMMANDS PRINTED OUT.")
  print("3. SOME COMMANDS REQUIRE YOU TO ENTER DATA (FOR EXAMPLE, THE")
  print("   'NAV' COMMAND COMES BACK WITH 'COURSE (1-9) ?'.)  IF YOU")
  print("   TYPE IN ILLEGAL DATA (LIKE NEGATIVE NUMBERS), THEN THE")
  print("   COMMAND WILL BE ABORTED")
  print("")
  print("   THE GALAXY IS DIVIDED INTO AN 8 X 8 QUADRANT GRID,")
  print("AND EACH QUADRANT IS FURTHER DIVIDED INTO AN 8 X 8 SECTOR GRID.")
  print("")
  print("   YOU WILL BE ASSIGNED A STARTING POINT SOMEWHERE IN THE")
  print("GALAXY TO BEGIN A TOUR OF DUTY AS COMMANDER OF THE STARSHIP")
  print("'ENTERPRISE'. YOUR MISSION: TO SEEK AND DESTROY THE FLEET OF")
  print("KLINGON WARSHIPS WHICH ARE MENACING THE UNITED FEDERATION OF")
  print("PLANETS.")
  print("")
  print("   YOU HAVE THE FOLLOWING COMMANDS AVAILABLE TO YOU AS CAPTAIN")
  print("OF THE STARSHIP ENTERPRISE:")
  print("")
  print("'NAV' COMMAND = WARP ENGINE CONTROL")
  print("   COURSE IS IN A CIRCULAR NUMERICAL      4  3  2")
  print("   VECTOR ARRANGEMENT AS SHOWN             . . .")
  print("   INTEGER AND REAL VALUES MAY BE           ...")
  print("   USED.  (THUS COURSE 1.5 IS HALF-     5 ---*--- 1")
  print("   WAY BETWEEN 1 AND 2                      ...")
  print("                                           . . .")
  print("   VALUES MAY APPROACH 9.0, WHICH         6  7  8")
  print("   ITSELF IS EQUIVALENT TO 1.0")
  print("                                          COURSE")
  print("   ONE WARP FACTOR IS THE SIZE OF")
  print("   ONE QUADRANT.  THEREFORE, TO GET")
  print("   FROM QUADRANT 6,5 TO 5,5, YOU WOULD")
  print("   USE COURSE 3, WARP FACTOR 1.")
  print("")
  print("'SRS' COMMAND = SHORT RANGE SENSOR SCAN")
  print("   SHOWS YOU A SCAN OF YOUR PRESENT QUADRANT.")
  print("")
  print("   SYMBOLOGY ON YOUR SENSOR SCREEN IS AS FOLLOWS:")
  print("      <*> = YOUR STARSHIP'S POSITION")
  print("      +K+ = KLINGON BATTLE CRUISER")
  print("      >!< = FEDERATION STARBASE (REFUEL/REPAIR/RE-ARM HERE!)")
  print("       *  = STAR")
  print("   A CONDENSED 'STATUS REPORT' WILL ALSO BE PRESENTED.")
  print("")
  print("'LRS' COMMAND = LONG RANGE SENSOR SCAN")
  print("   SHOWS CONDITIONS IN SPACE FOR ONE QUADRANT ON EACH SIDE")
  print("   OF THE ENTERPRISE (WHICH IS IN THE MIDDLE OF THE SCAN)")
  print("   THE SCAN IS CODED IN THE FORM '###', WHERE THE UNITS DIGIT")
  print("   IS THE NUMBER OF STARS, THE TENS DIGIT IS THE NUMBER OF")
  print("   STARBASES, AND THE HUNDREDS DIGIT IS THE NUMBER OF")
  print("   KLINGONS.")
  print("")
  print("   EXAMPLE - 207 = 2 KLINGONS, NO STARBASES, & 7 STARS.")
  print("")
  print("'PHA' COMMAND = PHASER CONTROL")
  print("   ALLOWS YOU TO DESTROY THE KLINGON BATTLE CRUISERS BY")
  print("   ZAPPING THEM WITH SUITABLY LARGE UNITS OF ENERGY TO")
  print("   DEPLETE THEIR SHIELD POWER.  (REMEMBER, KLINGONS HAVE")
  print("   PHASERS TOO!)")
  print("")
  print("'TOR' COMMAND = PHOTON TORPEDO CONTROL")
  print("")
  print("   TORPEDO COURSE IS THE SAME AS USED IN WARP ENGINE CONTROL")
  print("   IF YOU HIT THE KLINGON VESSEL, HE IS DESTROYED AND")
  print("   CANNOT FIRE BACK AT YOU.  IF YOU MISS, YOU ARE SUBJECT TO")
  print("   HIS PHASER FIRE.  IN EITHER CASE, YOU ARE ALSO SUBJECT TO")
  print("   THE PHASER FIRE OF ALL OTHER KLINGONS IN THE QUADRANT.")
  print("   THE LIBRARY-COMPUTER ('COM' COMMAND) HAS AN OPTION TO")
  print("   COMPUTE TORPEDO TRAJECTORY FOR YOU (OPTION 2)")
  print("")
  print("'SHE' COMMAND = SHIELD CONTROL")
  print("")
  print("   DEFINES THE NUMBER OF ENERGY UNITS TO BE ASSIGNED TO THE")
  print("   SHIELDS.  ENERGY IS TAKEN FROM TOTAL SHIP'S ENERGY.  NOTE")
  print("   THAN THE STATUS DISPLAY TOTAL ENERGY INCLUDES SHIELD ENERGY")
  print("")
  print("'DAM' COMMAND = DAMAGE CONTROL REPORT")
  print("")
  print("   GIVES THE STATE OF REPAIR OF ALL DEVICES.  WHERE A NEGATIVE")
  print("   'STATE OF REPAIR' SHOWS THAT THE DEVICE IS TEMPORARILY")
  print("   DAMAGED.")
  print("")
  print("'COM' COMMAND = LIBRARY-COMPUTER")
  print("")
  print("   THE LIBRARY-COMPUTER CONTAINS SIX OPTIONS:")
  print("")
  print("   OPTION 0 = CUMULATIVE GALACTIC RECORD")
  print("     THIS OPTION SHOWES COMPUTER MEMORY OF THE RESULTS OF ALL")
  print("     PREVIOUS SHORT AND LONG RANGE SENSOR SCANS")
  print("   OPTION 1 = STATUS REPORT")
  print("     THIS OPTION SHOWS THE NUMBER OF KLINGONS, STARDATES,")
  print("     AND STARBASES REMAINING IN THE GAME.")
  print("   OPTION 2 = PHOTON TORPEDO DATA")
  print("     WHICH GIVES DIRECTIONS AND DISTANCE FROM THE ENTERPRISE")
  print("     TO ALL KLINGONS IN YOUR QUADRANT")
  print("   OPTION 3 = STARBASE NAV DATA")  
  print("     THIS OPTION GIVES DIRECTION AND DISTANCE TO ANY")
  print("     STARBASE WITHIN YOUR QUADRANT")  
  print("   OPTION 4 = DIRECTION/DISTANCE CALCULATOR")
  print("     THIS OPTION ALLOWS YOU TO ENTER COORDINATES FOR")  
  print("     DIRECTION/DISTANCE CALCULATIONS")
  print("   OPTION 5 = GALACTIC /REGION NAME/ MAP")  
  print("     THIS OPTION PRINTS THE NAMES OF THE SIXTEEN MAJOR")
  print("     GALACTIC REGIONS REFERRED TO IN THE GAME.")
  print("")
  print("-- HIT RETURN TO CONTINUE ");
  getInput()
}
// *************************************************************
func SearchStringinQuadrant(elem: String,y:Int,x:Int) -> Bool {
  // STRING COMPARISON IN QUADRANT ARRAY - line 8830
  var position = 0  
  position =  (x-1)*3+(y-1)*24+1;
  
  let index = QuadString.index(QuadString.startIndex,offsetBy: position)
  let end = QuadString.index(QuadString.startIndex,offsetBy: position+2)
  if debug {print(position,position+2)}
  if debug {print(position,QuadString[index...end])}
  if QuadString[index...end] == elem {
    return true;
  }
  return false;
}
// *************************************************************
func ShieldControl() {
  if debug {print("Shield Control function")}
  //5520 REM SHIELD CONTROL - 5530
    if (DamageLevel[7]<0) {
      print("SHIELD CONTROL INOPERABLE");
      //return 0;
    }
    print("ENERGY AVAILABLE = ",(EnergyLevel+ShieldLevel));
    print("NUMBER OF UNITS TO SHIELDS? ");
    var Units = 0
    getInput()
    Units = Int(input) ?? 0
    
    if Units <= 0 {
      print("INCORRECT VALUE");
    }
    else if (ShieldLevel == Units) {
      print("<SHIELDS UNCHANGED>");
    }
    else if (Units > EnergyLevel+ShieldLevel) {
      print("SHIELD CONTROL REPORTS  'THIS IS NOT THE FEDERATION TREASURY.'");
      print("<SHIELDS UNCHANGED>");
    }
    else {
      EnergyLevel = EnergyLevel+ShieldLevel-Units;
      ShieldLevel = Units;
      print("DEFLECTOR CONTROL ROOM REPORT:");
      print("  'SHIELDS NOW AT ",ShieldLevel," UNITS PER YOUR COMMAND.'");
      if debug {print("Energy Level",EnergyLevel)}
    }
    //return Units;
  
}
// *************************************************************
func ShortRangeSensorScan() -> Bool{
  // SHORT RANGE SENSOR SCAN & STARTUP SUBROUTINE
  
  // it was line 6720
  if (DamageLevel[2]<0) {
    print("\n*** SHORT RANGE SENSORS ARE OUT ***\n");
    return false;
  }
  
  let Header = "---------------------------------";
  print(Header);
  for I in 1...8 {
    for J in stride(from:(I-1)*24+1,to:(I-1)*24+23,by:3) {
      let index = QuadString.index(QuadString.startIndex,offsetBy: J)
      let end = QuadString.index(QuadString.startIndex,offsetBy: J+2)
      let tempString = QuadString[index...end]
      print("",tempString,terminator:"");
    }
        switch I {
          case 1:
          print("        STARDATE           ",Stardate*10);
          case 2:
          print("        CONDITION          ",ShipCondition);
          case 3:
          print("        QUADRANT           ",Q1,",",Q2);
          case 4:
          print("        SECTOR             ",S1,",",S2);
          case 5:
          print("        PHOTON TORPEDOES   ",Int(PhotonTorpedoes));
          case 6:
          print("        TOTAL ENERGY       ",Int(EnergyLevel+ShieldLevel));
          case 7:
          print("        SHIELDS            ",Int(ShieldLevel));
          case 8:
          print("        KLINGONS REMAINING ",Int(TotalKlingonShips));
          default:
          print("ERROR")
        }
  }
  print(Header);
  return true;
}
// *************************************************************
func ShowDirections() {
  print("");
  print("      4  3  2   ")
  print("       . . .    ");
  print("        ...     ");
  print("    5 ---*--- 1 ");
  print("        ...     ")
  print("       . . .    ");
  print("      6  7  8   ");
  print("");
}
// *************************************************************
func StarbaseNavData() -> Bool{
  if (B3 > 0) {
    print("FROM ENTERPRISE TO STARBASE:");
    PrintDistanceAndDirection(W1:B4,X:B5,C1:S1,A:S2);   // dest, origin
  }
  else {
    print("MR. SPOCK REPORTS,  'SENSORS SHOW NO STARBASES IN THIS");
    print(" QUADRANT.'");
  }
  return true;
}
// *************************************************************
func StatusReport() -> Bool{
  //7890 REM STATUS REPORT - 7900
  print("   STATUS REPORT:");
  Ss="";
  if (TotalKlingonShips>1) {Ss="S";}
  print("KLINGON",Ss," LEFT: ",TotalKlingonShips);
  print("MISSION MUST BE COMPLETED IN ",T0+MaxNumOfDays-Stardate," STARDATES");
  Ss="S";
  if(TotalStarbases<2) {Ss="";}
  
  if(TotalStarbases<1) {
    print("YOUR STUPIDITY HAS LEFT YOU ON YOUR ON IN");
    print("  THE GALAXY -- YOU HAVE NO STARBASES LEFT!");
  }
  else {
    print("THE FEDERATION IS MAINTAINING ",TotalStarbases," STARBASE"+Ss+" IN THE GALAXY");
  }
  DamageControl();
  return true;
}
// *************************************************************
func validCoord(n:Int) -> Bool {
  //my n = shift;
  if (n>=1 && n<=8) {
    return true;
  }
  return false;
}
// *************************************************************
