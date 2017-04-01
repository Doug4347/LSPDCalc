SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
/*
DEV NOTES
ARREST:			/arrest [playerid] [time (1 minute - 120 minutes)] [allow bail? 'yes' or 'no'] (strikes) (fine)
TICKET: 		/ticket [ID] [Price]
RECORD CRIME:	/recordcrime [fullname] [offence]
*/
IfNotExist, LSPD.png
UrlDownloadToFile, http://i.imgur.com/KGYrdR4.png, LSPD.png

/*
UPDATERS: This next part checks for updates of this app or AHK.
UPDATE INFO: https://www.dropbox.com/s/8rvndpkvb78rhnc/LSPDCalc.ini?dl=1
*/
AppVersion:=1.6

SplashImage, LSPD.png,, Downloading Update Info..., Checking for Updates...
FileDelete, LSPDUpdateInfo.ini
UrlDownloadToFile, https://www.dropbox.com/s/8rvndpkvb78rhnc/LSPDCalc.ini?dl=1, LSPDUpdateInfo.ini
SplashImage, Off
IniRead, LatestAHK, LSPDUpdateInfo.ini, AHK, Latest, 0
If not LatestAHK
{
	MsgBox, 16,, Upatater Error: Could not find the update info file. Please make sure you have an internet connection, then restart the app to check for updates.
	UpdaterError:=True
}
Else
{
	If A_AHKVersion != %LatestAHK%
	{
		MsgBox, 68,, Your AutoHotkey is out of date. Would you like to automatically download the latest version?
		IfMsgBox Yes
		{
			IniRead, LatestAHKDL, LSPDUpdateInfo.ini, AHK, Download, 0
			If not LatestAHKDL
			{
				MsgBox, 16,, Error: Cannot read the Update Info file, and cannot access the download link. Please restart the app and try again.
			}
			Else
			{
				SplashImage, LSPD.png,, Checking Update Link..., Downloading AHK Update...
				IniRead, LatestAHKDownload, LSPDUpdateInfo.ini, AHK, Download
				SplashImage, LSPD.png,, Creating Downloads Folder..., Downloading AHK Update...
				FileCreateDir, Downloads
				SplashImage, LSPD.png,, Downloading AHK..., Downloading AHK Update...
				UrlDownloadToFile, %LatestAHKDownload%, Downloads\AHKIntall-%LatestAHK%.exe
				SplashImage, Off
				MsgBox, 64,, Done downloading the update! Please check the Downloads folder for the version you need to install.
				ExitApp
			}
		}
	}
}
If not UpdaterError
{
	IniRead, LatestApp, LSPDUpdateInfo.ini, App, Latest, 0
	If Not LatestApp
	{
		MsgBox, 16,, Upatater Error: Could not find the update info file. Please make sure you have an internet connection, then restart the app to check for updates.
	}
	Else
	{
		If AppVersion != %LatestApp%
		{
			MsgBox, 68,, This LSPD Calculator is out of date! You would like to automatically download a new one?`n`nYour Version: %AppVersion%`nLatest Version: %LatestApp%
			IfMsgBox Yes
			{
				SplashImage, LSPD.png,, Checking Update Link..., Downloading App Update...
				IniRead, LatestAppDownload, LSPDUpdateInfo.ini, App, Download
				SplashImage, LSPD.png,, Creating Downloads Folder..., Downloading App Update...
				FileCreateDir, Downloads
				SplashImage, LSPD.png,, Downloading App..., Downloading App Update...
				UrlDownloadToFile, %LatestAppDownload%, Downloads\LSPDCalc-%LatestApp%.ahk
				SplashImage, Off
				MsgBox, 64,, Done downloading the update! Please check the Downloads folder for the version you need to install.
				ExitApp
			}
		}
	}
}
/*
THE REST OF THIS IS THE ACTUAL SCRIPT ITSELF
*/

StringTrimRight, SettingsFile, A_ScriptName, 4
AppendingFile = Report.txt
SettingsFile = %SettingsFile%.ini
TicketCash:=0
Mins:=0
FineCash:=0
LicenseStrikes:=0
Notes = None
Bail = Yes
IniRead, ArrestHotkeyIni, %SettingsFile%, Hotkeys, Arrest, !1
IniRead, CrimeHotkeyIni, %SettingsFile%, Hotkeys, Crime, !2
Hotkey, %ArrestHotkeyIni%, Arrest, On
Hotkey, %CrimeHotkeyIni%, RecordCrimes, On

Menu, Tray, NoStandard
Menu, Standards, Standard
Menu, Script, Add, Settings, SettingsGUI
Menu, Script, Add, LSPD Calculator, LSPDCalc
Menu, Tray, Add, Script Stuff, :Script
Menu, Tray, Add, Standards, :Standards
Goto, LSPDCalc
Return

SettingsGUI:
	Gui, Destroy
	IniRead, ArrestHotkeyIni, %SettingsFile%, Hotkeys, Arrest, !1
	IniRead, CrimeHotkeyIni, %SettingsFile%, Hotkeys, Crime, !2
	Gui, Add, Text,, Hotkey for /arrest:
	Gui, Add, Hotkey, vArrestHotkey w500, %ArrestHotkeyIni%
	Gui, Add, Text,, Hotkey for /recordcrime:
	Gui, Add, Hotkey, vCrimeHotkey w500, %CrimeHotkeyIni%
	Gui, Add, Button, gSubmitHotkeys, Submit Hotkeys
	Gui, Show
Return

SubmitHotkeys:
	Gui, Submit, NoHide
	IniWrite, %ArrestHotkey%, %SettingsFile%, Hotkeys, Arrest
	IniWrite, %CrimeHotkey%, %SettingsFile%, Hotkeys, Crime
	Hotkey, %ArrestHotkeyIni%, Arrest, Off
	Hotkey, %CrimeHotkeyIni%, RecordCrimes, Off
	Hotkey, %ArrestHotkey%, Arrest, On
	Hotkey, %CrimeHotkey%, RecordCrimes, On
	MsgBox, Your hotkeys have been saved and activated!
Return

LSPDCalc:
	Gui, Destroy
	Gui, Add, Edit, gUpdateTimes x10 w500 vCrimScum, John_Doe
	Gui, Add, Button, gLSPDCalc x522 y5, Reset Values
	Gui, Add, Button, gGenerateReport x600 y5, Generate Report
	Gui, Add, Tab3, vMainTabs w1000 x10, Vehicular Infractions|Vehicular Misdemeanors|Vehicular Felonies|INFRACTIONS|MISDEMEANORS|FELONIES|Narcotics|Materials|Ammo|Report Info
	Gui, Tab, Vehicular Infractions
	Gui, Add, Checkbox, gUpdateTimes vIllegalParking, Illegal Parking
	Gui, Add, Checkbox, gUpdateTimes vIllegalShortcut, Illegal Shortcut
	Gui, Add, Checkbox, gUpdateTimes vUnlawfulHyds, Unlawful Hydraulics
	Gui, Add, Checkbox, gUpdateTimes vUnlawfulNos, Unlawful Nos
	Gui, Add, Checkbox, gUpdateTimes vRecklessDriving, Reckless Driving (The driver obeys you)
	Gui, Add, Checkbox, gUpdateTimes vDrivingWODCAA, Driving without due care and attention
	Gui, Add, Checkbox, gUpdateTimes vYieldFailure, Failure to Yield
	Gui, Add, Checkbox, gUpdateTimes vAcceptTicketFailure, Failure to accept a ticket
	Gui, Add, Checkbox, gUpdateTimes vUnregisteredVehicle, Failure to Provide Valid Registration (Driving an unregistered vehicle)
	Gui, Add, Checkbox, gUpdateTimes vLicenseFailure, Failure to Provide License
	Gui, Add, Checkbox, gUpdateTimes vVehicleEvading, Evading a police officer in a vehicle
	Gui, Add, Checkbox, gUpdateTimes vTicketPayTime, Failure to pay a ticket on time (2 weeks | Uses Custom Fine)
	Gui, Tab, Vehicular Misdemeanors
	Gui, Add, Checkbox, gUpdateTimes vAttemptedGTA, (Attempted) Grand Theft Auto
	Gui, Add, Checkbox, gUpdateTimes vDUI, Driving Under the Influence (DUI)
	Gui, Add, Checkbox, gUpdateTimes vHnR, Hit and Run
	Gui, Add, Checkbox, gUpdateTimes vDwS, Driving While Suspended
	Gui, Tab, Vehicular Felonies
	Gui, Add, Checkbox, gUpdateTimes vRacing, Street Racing
	Gui, Add, Checkbox, gUpdateTimes vGTA, Grand Theft Auto
	Gui, Add, Checkbox, gUpdateTimes vVehAssualt, Vehicular Assault
	Gui, Tab, INFRACTIONS
	Gui, Add, Checkbox, gUpdateTimes vLoitering, Loitering on Private/Government Property (After 3 warnings)
	Gui, Add, Checkbox, gUpdateTimes vTrespassing, Trespassing
	Gui, Add, Checkbox, gUpdateTimes vIndecentExposure, Indecent Exposure
	Gui, Add, Checkbox, gUpdateTimes vVandalism, Vandalism (Uses Custom Fine)
	Gui, Add, Checkbox, gUpdateTimes vAffray, Affray
	Gui, Add, Checkbox, gUpdateTimes vResistingPhysical, Resisting Arrest (Attempting to flee from a LEO through physical force)
	Gui, Add, Checkbox, gUpdateTimes vEvadingFoot, Evading a police officer on foot
	Gui, Add, Checkbox, gUpdateTimes vDisorderlyConduct, Disorderly Conduct
	Gui, Add, Checkbox, gUpdateTimes vAidingAbettingInfractions, Aiding and Abetting - Infractions
	Gui, Tab, MISDEMEANORS
	Gui, Add, Checkbox, gUpdateTimes vMeleeWeaponPossession, Unlawful Possession of a Melee Weapon (knives, swords, brass knuckles)
	Gui, Add, Checkbox, gUpdateTimes vMeleeWeaponSoliciting, Soliciting of a Melee Weapon
	Gui, Add, Checkbox, gUpdateTimes vLowCalWeaponSemiAutomatic, Unlawful Possession of a Low Caliber Weapon (Semi-Automatic)
	Gui, Add, Checkbox, gUpdateTimes vLowCalWeaponFullyAutomatic, Unlawful Possession of a Low Caliber Weapon (Fully-Automatic)
	Gui, Add, Checkbox, gUpdateTimes vBrandishingFirearm, Brandishing a Firearm
	Gui, Add, Checkbox, gUpdateTimes vValidIDFailure, Failure to Provide Valid Identification
	Gui, Add, Checkbox, gUpdateTimes vCounterfeitDocs, Possession of Counterfeit Documentation
	Gui, Add, Checkbox, gUpdateTimes vSolicitingLowCal, Soliciting Low Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes vSilencedPossession, Unlawful Possession of a Silenced Low Caliber Weapon
	Gui, Add, Checkbox, gUpdateTimes vSolicitingSilenced, Soliciting Low Caliber Silenced Weapons
	Gui, Add, Checkbox, gUpdateTimes vImpersonating, Impersonating an LEO
	Gui, Add, Checkbox, gUpdateTimes vObstruction, Obstruction of Justice
	Gui, Add, Checkbox, gUpdateTimes vMurderConspiracy, Conspiracy to Commit Murder
	Gui, Add, Checkbox, gUpdateTimes vHarassment, Harassment
	Gui, Add, Checkbox, gUpdateTimes vFirearmDischargeSingle, Unlawful Discharge of Firearm (Single Shot)
	Gui, Add, Checkbox, gUpdateTimes vFirearmDischargeMulti, Unlawful Discharge of Firearm (Multiple shots/Rapid Fire)
	Gui, Add, Checkbox, gUpdateTimes vPEndangerment, Public Endangerment
	Gui, Add, Checkbox, gUpdateTimes vFraud, Fraud
	Gui, Add, Checkbox, gUpdateTimes vLyingToLEO, Lying to an LEO in function
	Gui, Add, Checkbox, gUpdateTimes vAidingAbettingMisdemeanors, Aiding and Abetting - Misdemeanors
	Gui, Add, Checkbox, gUpdateTimes vCounterfeitProduction, Trafficking/Production of Counterfeit Documentation
	Gui, Add, Checkbox, gUpdateTimes v911Misuse, Wasting Police Time (misuse of 911 | Uses Custom Time)
	Gui, Tab, FELONIES
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vHighCalWeaponPossession, Unlawful Possession of a High Caliber Firearm (M4, AK, Combat, Sniper)
	Gui, Add, Checkbox, gUpdateTimes x28 y100 vDeaglePossession, Unlawful Possession of a Desert Eagle
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vHighCalWeaponSoliciting, Soliciting High Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y140 vDeagleSoliciting, Soliciting Desert Eagle
	Gui, Add, Checkbox, gUpdateTimes x28 y160 vManslaughter, Manslaughter
	Gui, Add, Checkbox, gUpdateTimes x28 y180 vMurderAccessory, Accessory to Murder
	Gui, Add, Checkbox, gUpdateTimes x28 y200 vAttemptedMurder, Attempted Murder
	Gui, Add, Checkbox, gUpdateTimes x28 y220 vAttemptedMurderLEO, Attempted Murder of an LEO
	Gui, Add, Checkbox, gUpdateTimes x28 y240 vMurderAccomplice, Accomplice to Murder
	Gui, Add, Checkbox, gUpdateTimes x28 y260 vInstigatingAnarchy, Instigating Public Anarchy
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vRacketeering, Racketeering
	Gui, Add, Checkbox, gUpdateTimes x28 y300 vKidnapping, Kidnapping
	Gui, Add, Checkbox, gUpdateTimes x28 y320 vKidnappingLEO, Kidnapping an LEO
	Gui, Add, Checkbox, gUpdateTimes x28 y340 vAttemptedRobbery, Attempted Robbery
	Gui, Add, Checkbox, gUpdateTimes x28 y360 vRobbery, Robbery
	Gui, Add, Checkbox, gUpdateTimes x28 y380 vArmedRobbery, Armed Robbery
	Gui, Add, Checkbox, gUpdateTimes x28 y400 vBurglary, Breaking and entering (Burglary)
	Gui, Add, Checkbox, gUpdateTimes x28 y420 vGambling, Illegal Gambling
	Gui, Add, Checkbox, gUpdateTimes x28 y440 vBribery, Bribery
	
	Gui, Add, Checkbox, gUpdateTimes x400 y80 vAssault, Assault (Spitting, physical threats etc.)
	Gui, Add, Checkbox, gUpdateTimes x400 y100 vAssaultLEO, Assault (Spitting, physical threats etc.) of an LEO
	Gui, Add, Checkbox, gUpdateTimes x400 y120 vBattery, Battery (Physical attacks, punching, kicking etc.)
	Gui, Add, Checkbox, gUpdateTimes x400 y140 vBatteryLEO, Battery (Physical attacks, punching, kicking etc.) of an LEO
	Gui, Add, Checkbox, gUpdateTimes x400 y160 vBatteryWeap, Battery with a deadly weapon
	Gui, Add, Checkbox, gUpdateTimes x400 y180 vBatteryWeapLEO, Battery with a deadly weapon of an LEO
	Gui, Add, Checkbox, gUpdateTimes x400 y200 vExtortion, Extortion (Threatening someone to obtain money, property, or services)
	Gui, Add, Checkbox, gUpdateTimes x400 y220 vScamming, Scamming
	Gui, Add, Checkbox, gUpdateTimes x400 y240 vArson, Arson
	Gui, Add, Checkbox, gUpdateTimes x400 y260 vAidingAbettingCapital, Aiding and Abetting - Felonies/Capital Offenses
	Gui, Add, Checkbox, gUpdateTimes x400 y280 vFugitiveHarboring, Harboring a Fugitive
	Gui, Add, Checkbox, gUpdateTimes x400 y300 vExplosivesPossession, Possession of Explosives
	Gui, Add, Checkbox, gUpdateTimes x400 y320 vTerrorismConspiracy, Conspiracy to Commit Terrorism
	Gui, Add, Checkbox, gUpdateTimes x400 y340 vDomesticTerrorism, Domestic Terrorism
	Gui, Add, Checkbox, gUpdateTimes x400 y360 vMurder, Successful Murder
	Gui, Add, Checkbox, gUpdateTimes x400 y380 vMurderLEO, Successful Murder of an LEO
	Gui, Add, Checkbox, gUpdateTimes x400 y400 vMassMurder, Mass Murder
	Gui, Add, Checkbox, gUpdateTimes x400 y420 vCorruption, Corruption
	Gui, Add, Checkbox, gUpdateTimes x400 y440 vPiracy, Piracy (Of boats, not media.)
	Gui, Tab, Narcotics
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vPotPos, Possession of Marijuana
	Gui, Add, Checkbox, gUpdateTimes x28 y100 vCokePos, Possession of Cocaine
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vSpeedPos, Possession of Amphetamine (Speed)
	Gui, Add, Checkbox, gUpdateTimes x28 y140 vMethPos, Possession of Amphetamine (Meth)
	Gui, Add, Edit, gUpdateTimes x400 y80 w200 vPot, 0
	Gui, Add, Edit, gUpdateTimes x400 y100 w200 vCoke, 0
	Gui, Add, Edit, gUpdateTimes x400 y120 w200 vSpeed, 0
	Gui, Add, Edit, gUpdateTimes x400 y140 w200 vMeth, 0
	Gui, Add, Checkbox, gUpdateTimes x28 y180 vSolicitingCocaine, Soliciting of Cocaine
	Gui, Add, Checkbox, gUpdateTimes x28 y200 vSolicitingMarijuana, Soliciting of Marijuana
	Gui, Add, Checkbox, gUpdateTimes x28 y220 vSolicitingAmphetamine, Soliciting of Amphetamine (Speed)
	Gui, Add, Checkbox, gUpdateTimes x28 y240 vSolicitingMeth, Soliciting of Amphetamine (Meth)
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vCokeTrafiking, Trafiking of Cocaine
	Gui, Add, Checkbox, gUpdateTimes x28 y300 vPotTrafiking, Trafiking of Marijuana
	Gui, Add, Checkbox, gUpdateTimes x28 y320 vSpeedTrafiking, Trafiking of Amphetamine (Speed)
	Gui, Add, Checkbox, gUpdateTimes x28 y340 vMethTrafiking, Trafiking of Amphetamine (Meth)
	Gui, Add, Checkbox, gUpdateTimes x28 y380 vSmugglingContraband, Smuggling Contraband (Any Type)
	Gui, Tab, Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vStreetPos, Possession of Street Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y100 vStandardPos, Possession of Standard Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vMilitaryPos, Possession of Military Materials
	Gui, Add, Edit, gUpdateTimes x400 y80 w200 vStreetMats, 0
	Gui, Add, Edit, gUpdateTimes x400 y100 w200 vStandardMats, 0
	Gui, Add, Edit, gUpdateTimes x400 y120 w200 vMilitaryMats, 0
	Gui, Add, Checkbox, gUpdateTimes x28 y160 vSolicitingMaterials, Soliciting of Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y180 vTrafikingStreetArmour, Trafiking Street Armour
	Gui, Add, Checkbox, gUpdateTimes x28 y200 vTrafikingStandardArmour, Trafiking Standard Armour
	Gui, Add, Checkbox, gUpdateTimes x28 y220 vTrafikingMilitaryArmour, Trafiking Military Armour
	Gui, Add, Checkbox, gUpdateTimes x28 y240 vTrafikingMeleeWeapons, Trafiking Melee Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y260 vTrafikingLowCalWeapons, Trafiking Low Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vTrafikingHighCalWeapons, Trafiking High Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y300 vSolicitingArmour, Soliciting Illegal Body Armour
	Gui, Add, Checkbox, gUpdateTimes x28 y340 vStreetMatsTrafiking, Trafiking Street Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y360 vStandardMatsTrafiking, Trafiking Standard Materials
	Gui, Add, Checkbox, gUpdateTimes x28 y380 vMilitaryMatsTrafiking, Trafiking Military Materials
	Gui, Tab, Ammo
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vAmmoPos, Possession of Illegal Bullets
	Gui, Add, Edit, gUpdateTimes x400 y80 w200 vAmmo, 0
	Gui, Add, Checkbox, gUpdateTimes x28 y100 vSolicitingAmmo, Soliciting Bullets
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vAmmoTrafiking, Trafiking Bullets
	; Gui, Add, Checkbox, gUpdateTimes x28 y380 , Smuggling Bullets
	Gui, Tab, Report Info
	Gui, Add, Text, x28 y80, Offender's Phone number(s)
	Gui, Add, Edit, gUpdateTimes x400 y80 w200 vPhones
	Gui, Add, Text, x28 y100, Offender's House
	Gui, Add, Edit, gUpdateTimes x400 y100 w200 vHouse
	Gui, Add, Text, x28 y120, Offender's Business
	Gui, Add, Edit, gUpdateTimes x400 y120 w200 vBusiness
	Gui, Add, Text, x28 y140, Offender's Last Known Vehicle
	Gui, Add, Edit, gUpdateTimes x400 y140 w200 vVehicle
	Gui, Add, Text, x28 y160, Arresting Officer
	Gui, Add, Edit, gUpdateTimes x400 y160 w200 vOfficer
	Gui, Add, Text, x28 y180, Cruiser Number
	Gui, Add, Edit, gUpdateTimes x400 y180 w200 vCruiser
	Gui, Add, Text, x28 y220, Confiscated Items
	Gui, Add, Edit, gUpdateTimes x400 y220 w200 r5 vConfiscate
	Gui, Add, Text, x28 y300, Vehicle(s) Impounded
	Gui, Add, Edit, gUpdateTimes x400 y300 w200 r5 vImpounded
	Gui, Add, Text, x28 y380, Summarize what happened
	Gui, Add, Edit, gUpdateTimes x400 y380 w200 r5 vSummary
	Gui, Add, Checkbox, gUpdateTimes x620 y80 vDaylightSavings, Daylight Savings Time (DST)
	Gui, Tab,
	Gui, Add, Checkbox, x28 gUpdateTimes vFineArrest, Include Fine on /arrest
	Gui, Add, Checkbox, x28 gUpdateTimes vStrikeArrest, Include Strikes on /arrest
	Gui, Add, Text, x28, Custom Fine:
	Gui, Add, Edit, x28 w250 vCustomFine gUpdateTimes, 0
	Gui, Add, Text, x28, Custom Time:
	Gui, Add, Edit, x28 w250 vCustomTime gUpdateTimes, 0
	Gui, Add, Text, x28 w250 r15 vEditableText, Ticket Total: $%TicketCash%`nTime Total: %Mins% Mins`nFine Total: $%FineCash%`nLicense Strikes: %LicenseStrikes% Strikes`nBail: %Bail%
	Gui, Add, Pic, x300 y500, LSPD.png
	Gui, Add, Text, x600 w400 y500 r20 vEditableTextNotes, Notes:`n%Notes%
	GoSub, UpdateTimes
	Gui, Show
Return

Arrest:
	If not FineArrest
		FineCash = 0
	If not StrikeArrest
		LicenseStrikes = 0
	SendInput, t^a/arrest %CrimScum% %Mins% %Bail% %LicenseStrikes% %FineCash%
Return

RecordCrimes:
	RecordingCrimes:=True
	Gosub, UpdateTimes
	RecordingCrimes:=False
Return
GenerateReport:
	ReportAppending:=True
	Gosub, UpdateTimes
	ReportAppending:=False
	MsgBox, Report made! Open %AppendingFile% to view it.
Return
UpdateTimes:
	If ReportAppending
	{
		FileDelete, %AppendingFile%
		FileAppend,
		(
[CENTER][FONT=Arial][IMG]http://i.imgur.com/jUIyIJs.png[/IMG][/FONT]
[B][FONT=Arial]Criminal Resources Department[/FONT][/B][/CENTER]
[LEFT][FONT=Arial][SIZE=3]
[B]Mugshot[/B]:[/SIZE][/FONT][/LEFT]

[LEFT][SIZE=3][FONT=Arial][B]Offender's Full Name[/B]: %CrimScum%

[B]Offender's Contact information[/B]:
Phone number: %Phones%
House: %House%
Business: %Business%
Last known vehicle: %Vehicle%[/FONT][/SIZE]
[B][FONT=Arial][SIZE=3]
Arresting Officer[/SIZE][/FONT][/B][SIZE=3][FONT=Arial]: %Officer%[/FONT][/SIZE]
[B][FONT=Arial][SIZE=3]
Cruiser Number[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %Cruiser%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Crimes Committed[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]:

		), %AppendingFile%
	}
	Gui, Submit, NoHide
	TicketCash:=0
	Mins:=0
	FineCash:=0
	LicenseStrikes:=0
	Notes = 
	/*
	PotTrafiking:=False
	CokeTrafiking:=False
	SpeedTrafiking:=False
	MethTrafiking:=False
	StandardMatsTrafiking:=False
	StreetMatsTrafiking:=False
	MilitaryMatsTrafiking:=False
	AmmoTrafiking:=False
	*/
	Bail = Yes
	If BrandishingFirearm
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Brandishing a Firearm{Enter}
		If ReportAppending
			FileAppend, Brandishing a Firearm`n, %AppendingFile%
	}
	If IllegalParking
	{
		TicketCash+=3000
	}
	If IllegalShortcut
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If UnlawfulHyds
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If UnlawfulNos
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If RecklessDriving
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If DrivingWODCAA
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If YieldFailure
	{
		TicketCash+=5000
		If LicenseStrikes < 1
			LicenseStrikes:=1
	}
	If AcceptTicketFailure
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure To Accept a Ticket{Enter}
		If ReportAppending
			FileAppend, Failure To Accept a Ticket`n, %AppendingFile%
	}
	If UnregisteredVehicle
	{
		Mins+=15
		If LicenseStrikes < 2
			LicenseStrikes:=2
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving an unregistered vehicle{Enter}
		If ReportAppending
			FileAppend,  Driving an unregistered vehicle`n, %AppendingFile%
	}
	If LicenseFailure
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure to Provide License{Enter}
		If ReportAppending
			FileAppend,  Failure to Provide License`n, %AppendingFile%
	}
	If VehicleEvading
	{
		Mins+=30
		If LicenseStrikes < 2
			LicenseStrikes:=2
		If Notes
			Notes = %Notes%`nNot to be stacked with "Evading a police officer on foot" (Evading in a vehicle)
		Else
			Notes = Not to be stacked with "Evading a police officer on foot" (Evading in a vehicle)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Evading an LEO (Vehicle){Enter}
		If ReportAppending
			FileAppend,  Evading an LEO (Vehicle)`n, %AppendingFile%
	}
	If TicketPayTime
	{
		Mins+=20
		FineCash:=CustomFine
		If Notes
			Notes = %Notes%`nCustom Fine = 3 times the ticket price (Failure to pay a ticket on time)
		Else
			Notes = Custom Fine = 3 times the ticket price (Failure to pay a ticket on time)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure to pay a ticket on time{Enter}
		If ReportAppending
			FileAppend,  Failure to pay a ticket on time`n, %AppendingFile%
	}
	If AttemptedGTA
	{
		Mins+=25
		If LicenseStrikes < 3
			LicenseStrikes:=3
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% (Attempted) Grand Theft Auto{Enter}
		If ReportAppending
			FileAppend,  (Attempted) Grand Theft Auto`n, %AppendingFile%
	}
	If DUI
	{
		Mins+=20
		If LicenseStrikes < 2
			LicenseStrikes:=2
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving Under the Influence{Enter}
		If ReportAppending
			FileAppend,  Driving Under the Influence`n, %AppendingFile%
	}
	If HnR
	{
		Mins+=30
		If LicenseStrikes < 3
			LicenseStrikes:=3
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Hit and Run{Enter}
		If ReportAppending
			FileAppend,  Hit and Run`n, %AppendingFile%
	}
	If DwS
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving While Suspended{Enter}
		If ReportAppending
			FileAppend,  Driving While Suspended`n, %AppendingFile%
	}
	If Racing
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Street Racing{Enter}
		If ReportAppending
			FileAppend,  Street Racing`n, %AppendingFile%
	}
	If GTA
	{
		Mins+=35
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Grand Theft Auto{Enter}
		If ReportAppending
			FileAppend,  Grand Theft Auto`n, %AppendingFile%
	}
	If VehAssualt
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Vehicular Assault{Enter}
		If ReportAppending
			FileAppend,  Vehicular Assault`n, %AppendingFile%
	}
	If Loitering
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Loitering{Enter}
		If ReportAppending
			FileAppend,  Loitering`n, %AppendingFile%
	}
	If Trespassing
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trespassing{Enter}
		If ReportAppending
			FileAppend,  Trespassing`n, %AppendingFile%
	}
	If IndecentExposure
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Indecent Exposure{Enter}
		If ReportAppending
			FileAppend,  Indecent Exposure`n, %AppendingFile%
	}
	If Vandalism
	{
		Mins+=25
		FineCash:=CustomFine
		If Notes
			Notes = %Notes%`nCustom Fine = Damages caused (Vandalism)
		Else
			Notes = Custom Fine = Damages caused (Vandalism)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Vandalism{Enter}
		If ReportAppending
			FileAppend,  Vandalism`n, %AppendingFile%
	}
	If Affray
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Affray{Enter}
		If ReportAppending
			FileAppend,  Affray`n, %AppendingFile%
	}
	If ResistingPhysical
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Resisting Arrest{Enter}
		If ReportAppending
			FileAppend,  Resisting Arrest`n, %AppendingFile%
	}
	If EvadingFoot
	{
		Mins+=20
		If VehicleEvading
			Mins-=20
		If Notes
			Notes = %Notes%`nNot to be stacked with "Evading a police officer in a vehicle" (Evading on Foot)
		Else
			Notes = Not to be stacked with "Evading a police officer in a vehicle" (Evading on Foot)
		If RecordingCrimes
			If not VehicleEvading
				Send, t^a/recordcrime %CrimScum% Evading an LEO (Foot){Enter}
		If ReportAppending
			FileAppend,  Evading an LEO (Foot)`n, %AppendingFile%
	}
	If DisorderlyConduct
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Disorderly Conduct{Enter}
		If ReportAppending
			FileAppend,  Disorderly Conduct`n, %AppendingFile%
	}
	If AidingAbettingInfractions
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Infractions){Enter}
		If ReportAppending
			FileAppend,  Aiding and Abetting (Infractions)`n, %AppendingFile%
	}
	If MeleeWeaponPossession
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Melee Weapon{Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a Melee Weapon`n, %AppendingFile%
	}
	If MeleeWeaponSoliciting
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of a Melee Weapon{Enter}
		If ReportAppending
			FileAppend,  Soliciting of a Melee Weapon`n, %AppendingFile%
	}
	If LowCalWeaponSemiAutomatic
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Low Caliber Weapon (Semi-Automatic){Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a Low Caliber Weapon (Semi-Automatic)`n, %AppendingFile%
	}
	If LowCalWeaponFullyAutomatic
	{
		Mins+=45
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Low Caliber Weapon (Fully-Automatic){Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a Low Caliber Weapon (Fully-Automatic)`n, %AppendingFile%
	}
	If ValidIDFailure
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure to Provide ID{Enter}
		If ReportAppending
			FileAppend,  Failure to Provide ID`n, %AppendingFile%
	}
	If CounterfeitDocs
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Counterfeit Documentation{Enter}
		If ReportAppending
			FileAppend,  Possession of Counterfeit Documentation`n, %AppendingFile%
	}
	If SolicitingLowCal
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Low Caliber Weapons{Enter}
		If ReportAppending
			FileAppend,  Soliciting Low Caliber Weapons`n, %AppendingFile%
	}
	If SilencedPossession
	{
		Mins+=35
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Silenced Low Caliber Weapon{Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a Silenced Low Caliber Weapon`n, %AppendingFile%
	}
	If SolicitingSilenced
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Low Caliber Silenced Weapons{Enter}
		If ReportAppending
			FileAppend,  Soliciting Low Caliber Silenced Weapons`n, %AppendingFile%
	}
	If Impersonating
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Impersonating an LEO{Enter}
		If ReportAppending
			FileAppend,  Impersonating an LEO`n, %AppendingFile%
	}
	If Obstruction
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Obstruction of Justice{Enter}
		If ReportAppending
			FileAppend,  Obstruction of Justice`n, %AppendingFile%
	}
	If MurderConspiracy
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Conspiracy to Commit Murder{Enter}
		If ReportAppending
			FileAppend,  Conspiracy to Commit Murder`n, %AppendingFile%
	}
	If Harassment
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Harassment{Enter}
		If ReportAppending
			FileAppend,  Harassment`n, %AppendingFile%
	}
	If FirearmDischargeSingle
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Discharge of Firearm (Single Shot){Enter}
		If ReportAppending
			FileAppend,  Unlawful Discharge of Firearm (Single Shot)`n, %AppendingFile%
	}
	If FirearmDischargeMulti
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Discharge of Firearm (Multiple shots){Enter}
		If ReportAppending
			FileAppend,  Unlawful Discharge of Firearm (Multiple shots)`n, %AppendingFile%
	}
	If PEndangerment
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Public Endangerment{Enter}
		If ReportAppending
			FileAppend,  Public Endangerment`n, %AppendingFile%
	}
	If Fraud
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Fraud{Enter}
		If ReportAppending
			FileAppend,  Fraud`n, %AppendingFile%
	}
	If LyingToLEO
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Lying to an LEO in function{Enter}
		If ReportAppending
			FileAppend,  Lying to an LEO in function`n, %AppendingFile%
	}
	If AidingAbettingMisdemeanors
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Misdemeanors){Enter}
		If ReportAppending
			FileAppend,  Aiding and Abetting (Misdemeanors)`n, %AppendingFile%
	}
	If CounterfeitProduction
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafficking/Production of Counterfeit Documentation{Enter}
		If ReportAppending
			FileAppend,  Trafficking/Production of Counterfeit Documentation`n, %AppendingFile%
	}
	If 911Misuse
	{
		Mins+=CustomTime
		If Notes
			Notes = %Notes%`nCustom Time = 10-30 mins (Misuse of 911)
		Else
			Notes = Custom Time = 10-30 mins (Misuse of 911)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Misuse of 911{Enter}
		If ReportAppending
			FileAppend,  Misuse of 911`n, %AppendingFile%
	}
	If HighCalWeaponPossession
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a High Caliber Firearm{Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a High Caliber Firearm`n, %AppendingFile%
	}
	If DeaglePossession
	{
		Mins+=45
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Desert Eagle{Enter}
		If ReportAppending
			FileAppend,  Unlawful Possession of a Desert Eagle`n, %AppendingFile%
	}
	If HighCalWeaponSoliciting
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting High Caliber Weapons{Enter}
		If ReportAppending
			FileAppend,  Soliciting High Caliber Weapons`n, %AppendingFile%
	}
	If DeagleSoliciting
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Desert Eagle{Enter}
		If ReportAppending
			FileAppend,  Soliciting Desert Eagle`n, %AppendingFile%
	}
	If Manslaughter
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Manslaughter{Enter}
		If ReportAppending
			FileAppend,  Manslaughter`n, %AppendingFile%
	}
	If MurderAccessory
	{
		Mins+=50
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Accessory to Murder{Enter}
		If ReportAppending
			FileAppend,  Accessory to Murder`n, %AppendingFile%
	}
	If AttemptedMurder
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Murder{Enter}
		If ReportAppending
			FileAppend,  Attempted Murder`n, %AppendingFile%
	}
	If AttemptedMurderLEO
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Murder of an LEO{Enter}
		If ReportAppending
			FileAppend,  Attempted Murder of an LEO`n, %AppendingFile%
	}
	If MurderAccomplice
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Accomplice to Murder{Enter}
		If ReportAppending
			FileAppend,  Accomplice to Murder`n, %AppendingFile%
	}
	If InstigatingAnarchy
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Instigating Public Anarchy{Enter}
		If ReportAppending
			FileAppend,  Instigating Public Anarchy`n, %AppendingFile%
	}
	If Racketeering
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Racketeering{Enter}
		If ReportAppending
			FileAppend,  Racketeering`n, %AppendingFile%
	}
	If Kidnapping
	{
		Mins+=100
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Kidnapping{Enter}
		If ReportAppending
			FileAppend,  Kidnapping`n, %AppendingFile%
	}
	If KidnappingLEO
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Kidnapping an LEO{Enter}
		If ReportAppending
			FileAppend,  Kidnapping an LEO`n, %AppendingFile%
	}
	If AttemptedRobbery
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Robbery{Enter}
		If ReportAppending
			FileAppend,  Attempted Robbery`n, %AppendingFile%
	}
	If Robbery
	{
		Mins+=45
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Robbery{Enter}
		If ReportAppending
			FileAppend,  Robbery`n, %AppendingFile%
	}
	If ArmedRobbery
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Armed Robbery{Enter}
		If ReportAppending
			FileAppend,  Armed Robbery`n, %AppendingFile%
	}
	If Burglary
	{
		Mins+=25
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Burglary{Enter}
		If ReportAppending
			FileAppend,  Burglary`n, %AppendingFile%
	}
	If Gambling
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Illegal Gambling{Enter}
		If ReportAppending
			FileAppend,  Illegal Gambling`n, %AppendingFile%
	}
	If Bribery
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Bribery{Enter}
		If ReportAppending
			FileAppend,  Bribery`n, %AppendingFile%
	}
	If Assault
	{
		Mins+=20
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Assault{Enter}
		If ReportAppending
			FileAppend,  Assault`n, %AppendingFile%
	}
	If AssaultLEO
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Assault of an LEO{Enter}
		If ReportAppending
			FileAppend,  Assault of an LEO`n, %AppendingFile%
	}
	If Battery
	{
		Mins+=50
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery{Enter}
		If ReportAppending
			FileAppend,  Battery`n, %AppendingFile%
	}
	If BatteryLEO
	{
		Mins+=70
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery of an LEO{Enter}
		If ReportAppending
			FileAppend,  Battery of an LEO`n, %AppendingFile%
	}
	If BatteryWeap
	{
		Mins+=70
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery with a deadly weapon{Enter}
		If ReportAppending
			FileAppend,  Battery with a deadly weapon`n, %AppendingFile%
	}
	If BatteryWeapLEO
	{
		Mins+=80
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery with a deadly weapon of an LEO{Enter}
		If ReportAppending
			FileAppend,  Battery with a deadly weapon of an LEO`n, %AppendingFile%
	}
	If Extortion
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Extortion{Enter}
		If ReportAppending
			FileAppend,  Extortion`n, %AppendingFile%
	}
	If Scamming
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Scamming{Enter}
		If ReportAppending
			FileAppend,  Scamming`n, %AppendingFile%
	}
	If Arson
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Arson{Enter}
		If ReportAppending
			FileAppend,  Arson`n, %AppendingFile%
	}
	If AidingAbettingCapital
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Felonies){Enter}
		If ReportAppending
			FileAppend,  Aiding and Abetting (Felonies)`n, %AppendingFile%
	}
	If FugitiveHarboring
	{
		Mins+=60
		Bail = No
		If Notes
			Notes = %Notes%`nImpound Vehicle (Harboring a Fugitive in a Vehicle)
		Else
			Notes = Impound Vehicle (Harboring a Fugitive in a Vehicle)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Harboring a Fugitive{Enter}
		If ReportAppending
			FileAppend,  Harboring a Fugitive`n, %AppendingFile%
	}
	If ExplosivesPossession
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Explosives{Enter}
		If ReportAppending
			FileAppend,  Possession of Explosives`n, %AppendingFile%
	}
	If TerrorismConspiracy
	{
		Mins+=100
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Conspiracy to Commit Terrorism{Enter}
		If ReportAppending
			FileAppend,  Conspiracy to Commit Terrorism`n, %AppendingFile%
	}
	If DomesticTerrorism
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Domestic Terrorism{Enter}
		If ReportAppending
			FileAppend,  Domestic Terrorism`n, %AppendingFile%
	}
	If Murder
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Murder{Enter}
		If ReportAppending
			FileAppend,  Murder`n, %AppendingFile%
	}
	If MurderLEO
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Murder of an LEO{Enter}
		If ReportAppending
			FileAppend,  Murder of an LEO`n, %AppendingFile%
	}
	If MassMurder
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Mass Murder{Enter}
		If ReportAppending
			FileAppend,  Mass Murder`n, %AppendingFile%
	}
	If Corruption
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Corruption{Enter}
		If ReportAppending
			FileAppend,  Corruption`n, %AppendingFile%
	}
	If Piracy
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Piracy{Enter}
		If ReportAppending
			FileAppend,  Piracy`n, %AppendingFile%
	}
	If SolicitingMaterials
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Materials{Enter}
		If ReportAppending
			FileAppend,  Soliciting of Materials`n, %AppendingFile%
	}
	If TrafikingStreetArmour
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Street Armour{Enter}
		If ReportAppending
			FileAppend,  Trafiking Street Armour`n, %AppendingFile%
	}
	If TrafikingStandardArmour
	{
		Mins+=50
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Standard Armour{Enter}
		If ReportAppending
			FileAppend,  Trafiking Standard Armour`n, %AppendingFile%
	}
	If TrafikingMilitaryArmour
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Military Armour{Enter}
		If ReportAppending
			FileAppend,  Trafiking Military Armour`n, %AppendingFile%
	}
	If TrafikingMeleeWeapons
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Melee Weapons{Enter}
		If ReportAppending
			FileAppend,  Trafiking Melee Weapons`n, %AppendingFile%
	}
	If TrafikingLowCalWeapons
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Low Caliber Weapons{Enter}
		If ReportAppending
			FileAppend,  Trafiking Low Caliber Weapons`n, %AppendingFile%
	}
	If TrafikingHighCalWeapons
	{
		Mins+=80
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking High Caliber Weapons{Enter}
		If ReportAppending
			FileAppend,  Trafiking High Caliber Weapons`n, %AppendingFile%
	}
	If SolicitingArmour
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Illegal Body Armour{Enter}
		If ReportAppending
			FileAppend,  Soliciting Illegal Body Armour`n, %AppendingFile%
	}
	If SolicitingCocaine
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Cocaine{Enter}
		If ReportAppending
			FileAppend,  Soliciting of Cocaine`n, %AppendingFile%
	}
	If SolicitingAmphetamine
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Amphetamine (Speed){Enter}
		If ReportAppending
			FileAppend,  Soliciting of Amphetamine (Speed)`n, %AppendingFile%
	}
	If SolicitingMeth
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Amphetamine (Meth){Enter}
		If ReportAppending
			FileAppend,  Soliciting of Amphetamine (Meth)`n, %AppendingFile%
	}
	If SolicitingMarijuana
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Marijuana{Enter}
		If ReportAppending
			FileAppend,  Soliciting of Marijuana`n, %AppendingFile%
	}
	If SmugglingContraband
	{
		Mins+=50
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Smuggling Contraband{Enter}
		If ReportAppending
			FileAppend,  Smuggling Contraband`n, %AppendingFile%
	}
;===============================================
	If PotPos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Marijuana (%Pot%g){Enter}
		If ReportAppending
			FileAppend,  Possession of Marijuana (%Pot%g)`n, %AppendingFile%
	}
	If (Pot > 20) and (Pot < 101) and (PotPos)
	{
		Mins+=10
	}
	If (Pot > 49) and (PotPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (50+ Grams of Pot)
		Else
			Notes = Impound Vehicle (50+ Grams of Pot)
	}
	If (Pot > 100) and (Pot < 201) and (PotPos)
	{
		Mins+=20
	}
	/*
	If (Pot > 100) and (PotPos)
	{
		PotTrafiking:=True
	}
	*/
	If (Pot > 200) and (PotPos)
	{
		Mins+=30
	}
;===============================================
;===============================================
	If CokePos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Cocaine (%Coke%g){Enter}
		If ReportAppending
			FileAppend,  Possession of Cocaine (%Coke%g)`n, %AppendingFile%
	}	
	If (Coke < 6) and (CokePos)
	{
		TicketCash+=5000
	}
	If (Coke > 5) and (Coke < 21) and (CokePos)
	{
		Mins+=10
	}
	If (Coke > 20) and (Coke < 41) and (CokePos)
	{
		Mins+=20
	}
	If (Coke > 40) and (Coke < 60) and (CokePos)
	{
		Mins+=30
	}
	If (Coke > 49) and (CokePos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (50+ Grams of Coke)
		Else
			Notes = Impound Vehicle (50+ Grams of Coke)
	}
	If (Coke > 60) and (Coke < 81) and (CokePos)
	{
		Mins+=40
	}
	If (Coke > 80) and (Coke < 101) and (CokePos)
	{
		Mins+=60
	}
	If (Coke > 100) and (Coke < 121) and (CokePos)
	{
		Mins+=80
	}
	If (Coke > 120) and (Coke < 141) and (CokePos)
	{
		Mins+=100
	}
	/*
	If (Coke > 60) and (CokePos)
	{
		CokeTrafiking:=True
	}
	*/
	If (Coke > 140) and (CokePos)
	{
		Mins+=120
	}
;===============================================
;===============================================
	If SpeedPos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Amphetamine (Speed - %Speed% Tablets){Enter}
		If ReportAppending
			FileAppend,  Possession of Amphetamine (Speed - %Speed% Tablets)`n, %AppendingFile%
	}	
	If (Speed < 6) and(SpeedPos)
	{
		TicketCash+=5000
	}
	If (Speed > 5) and (Speed < 21) and (SpeedPos)
	{
		Mins+=20
	}
	If (Speed > 20) and (Speed < 51) and (SpeedPos)
	{
		Mins+=40
	}
	If (Speed > 50) and (Speed < 100) and (SpeedPos)
	{
		Mins+=60
	}
	If (Speed > 49) and (SpeedPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (50+ Grams of Speed)
		Else
			Notes = Impound Vehicle (50+ Grams of Speed)
	}
	If (Speed > 100) and (Speed < 201) and (SpeedPos)
	{
		Mins+=80
	}
	/*
	If (Speed > 60) and (SpeedPos)
	{
		SpeedTrafiking:=True
	}
	*/
	If (Speed > 201) and (SpeedPos)
	{
		Mins+=100
	}
;===============================================
	If MethPos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Amphetamine (Meth - %Meth%g){Enter}
		If ReportAppending
			FileAppend,  Possession of Amphetamine (Meth - %Meth%g)`n, %AppendingFile%
	}	
	If (Meth < 6) and(MethPos)
	{
		TicketCash+=7000
	}
	If (Meth > 5) and (Meth < 21) and (MethPos)
	{
		Mins+=15
	}
	If (Meth > 20) and (Meth < 41) and (MethPos)
	{
		Mins+=25
	}
	If (Meth > 40) and (Meth < 60) and (MethPos)
	{
		Mins+=35
	}
	If (Meth > 49) and (MethPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (50+ Grams of Meth)
		Else
			Notes = Impound Vehicle (50+ Grams of Meth)
	}
	If (Meth > 60) and (Meth < 81) and (MethPos)
	{
		Mins+=45
	}
	If (Meth > 80) and (Meth < 101) and (MethPos)
	{
		Mins+=65
	}
	If (Meth > 100) and (Meth < 121) and (MethPos)
	{
		Mins+=85
	}
	If (Meth > 120) and (Meth < 141) and (MethPos)
	{
		Mins+=100
	}
	/*
	If (Meth > 61) and (MethPos)
	{
		MethTrafiking:=True
	}
	*/
	If (Meth > 140) and (MethPos)
	{
		Mins+=100
	}
;===============================================
	If PotTrafiking or CokeTrafiking or SpeedTrafiking or MethTrafiking
	{
		If Notes
			Notes = %Notes%`nAssume Traffiking (Narcotics)
		Else
			Notes = Assume Traffiking (Narcotics)
		Mins+=40
		If RecordingCrimes
		{
			If PotTrafiking
			{
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Marijuana){Enter}
				If ReportAppending
					FileAppend,  Trafiking of Contraband (Marijuana)`n, %AppendingFile%
			}
			If CokeTrafiking
			{
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Cocaine){Enter}
				If ReportAppending
					FileAppend,  Trafiking of Contraband (Cocaine)`n, %AppendingFile%
			}
			If SpeedTrafiking
			{
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Amphetamine - Speed){Enter}
				If ReportAppending
					FileAppend,  Trafiking of Contraband (Amphetamine - Speed)`n, %AppendingFile%
			}
			If MethTrafiking
			{
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Amphetamine - Meth){Enter}
				If ReportAppending
					FileAppend,  Trafiking of Contraband (Amphetamine - Meth)`n, %AppendingFile%
			}
		}
	}

;===============================================
	If StreetPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Street Materials (%StreetMats%){Enter}
		If ReportAppending
			FileAppend,  Possession of Street Materials (%StreetMats%)`n, %AppendingFile%
	If (StreetMats > 30) and (StreetMats < 61) and (StreetPos)
	{
		Mins+=10
	}
	If (StreetMats > 60) and (StreetMats < 91) and (StreetPos)
	{
		Mins+=20
	}
	If (StreetMats > 79) and (StreetPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (80+ Street Mats)
		Else
			Notes = Impound Vehicle (80+ Street Mats)
	}
	If (StreetMats > 90) and (StreetMats < 120) and (StreetPos)
	{
		Mins+=30
	}
	If (StreetMats > 120) and (StreetMats < 151) and (StreetPos)
	{
		Mins+=40
	}
	If (StreetMats > 150) and (StreetMats < 301) and (StreetPos)
	{
		Mins+=50
	}
	/*
	If (StreetMats > 90) and (StreetPos)
	{
		StreetMatsTrafiking:=True
	}
	*/
	If (StreetMats > 300) and (StreetPos)
	{
		Mins+=60
	}
;===============================================
;===============================================
	If StandardPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Standard Materials (%StandardMats%){Enter}
		If ReportAppending
			FileAppend,  Possession of Standard Materials (%StandardMats%)`n, %AppendingFile%
	If (StandardMats < 30) and (StandardPos)
	{
		Mins+=10
	}
	If (StandardMats > 30) and (StandardMats < 61) and (StandardPos)
	{
		Mins+=15
	}
	If (StandardMats > 60) and (StandardMats < 91) and (StandardPos)
	{
		Mins+=25
	}
	If (StandardMats > 59) and (StandardPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (80+ Standard Mats)
		Else
			Notes = Impound Vehicle (80+ Standard Mats)
	}
	If (StandardMats > 90) and (StandardMats < 120) and (StandardPos)
	{
		Mins+=35
	}
	If (StandardMats > 120) and (StandardMats < 151) and (StandardPos)
	{
		Mins+=45
	}
	If (StandardMats > 150) and (StandardMats < 301) and (StandardPos)
	{
		Mins+=55
	}
	/*
	If (StandardMats > 90) and (StandardPos)
	{
		StandardMatsTrafiking:=True
	}
	*/
	If (StandardMats > 300) and (StandardPos)
	{
		Mins+=65
	}
;===============================================
;===============================================
	If MilitaryPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Military Materials (%MilitaryMats%){Enter}
		If ReportAppending
			FileAppend,  Possession of Military Materials (%MilitaryMats%)`n, %AppendingFile%
	If (MilitaryMats < 30) and (MilitaryPos)
	{
		Mins+=20
	}
	If (MilitaryMats > 30) and (MilitaryMats < 61) and (MilitaryPos)
	{
		Mins+=25
	}
	If (MilitaryMats > 60) and (MilitaryMats < 91) and (MilitaryPos)
	{
		Mins+=35
	}
	If (MilitaryMats > 59) and (MilitaryPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (80+ Military Mats)
		Else
			Notes = Impound Vehicle (80+ Military Mats)
	}
	If (MilitaryMats > 90) and (MilitaryMats < 120) and (MilitaryPos)
	{
		Mins+=45
	}
	If (MilitaryMats > 120) and (MilitaryMats < 151) and (MilitaryPos)
	{
		Mins+=55
	}
	If (MilitaryMats > 150) and (MilitaryMats < 301) and (MilitaryPos)
	{
		Mins+=65
	}
	/*
	If (MilitaryMats > 90) and (MilitaryPos)
	{
		MilitaryMatsTrafiking:=True
	}
	*/
	If (MilitaryMats > 300) and (MilitaryPos)
	{
		Mins+=75
	}
;===============================================
	If StandardMatsTrafiking
	{
		Mins+=30
		If Notes
			Notes = %Notes%`nAssume Traffiking (Standard Mats)
		Else
			Notes = Assume Traffiking (Standard Mats)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Street Materials{Enter}
		If ReportAppending
			FileAppend,  Trafiking Street Materials`n, %AppendingFile%
	}
	If StreetMatsTrafiking
	{
		Mins+=50
		If Notes
			Notes = %Notes%`nAssume Traffiking (Street Mats)
		Else
			Notes = Assume Traffiking (Street Mats)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Standard Materials{Enter}
		If ReportAppending
			FileAppend,  Trafiking Standard Materials`n, %AppendingFile%
	}
	If MilitaryMatsTrafiking
	{
		Mins+=60
		If Notes
			Notes = %Notes%`nAssume Traffiking (Millitary Mats)
		Else
			Notes = Assume Traffiking (Millitary Mats)
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Military Materials{Enter}
		If ReportAppending
			FileAppend,  Trafiking Military Materials`n, %AppendingFile%
	}
; ======================================================

	If AmmoPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Illegal Ammunition (%Ammo%){Enter}
		If ReportAppending
			FileAppend,  Possession of Illegal Ammunition (%Ammo%)`n, %AppendingFile%
	If (Ammo < 10) and (AmmoPos)
	{
		FineCash+=5000
	}
	If (Ammo > 10) and (Ammo < 31) and (AmmoPos)
	{
		Mins+=15
	}
	If (Ammo > 30) and (Ammo < 51) and (AmmoPos)
	{
		Mins+=25
	}
	If (Ammo > 50) and (Ammo < 80) and (AmmoPos)
	{
		Mins+=35
	}
	If (Ammo > 79) and (AmmoPos)
	{
		If Notes
			Notes = %Notes%`nImpound Vehicle (80+ Bullets)
		Else
			Notes = Impound Vehicle (80+ Bullets)
	}
	If (Ammo > 80) and (Ammo < 101) and (AmmoPos)
	{
		Mins+=45
	}
	If (Ammo > 100) and (Ammo < 121) and (AmmoPos)
	{
		Mins+=65
	}
	If (Ammo > 120) and (Ammo < 141) and (AmmoPos)
	{
		Mins+=85
	}
	If (Ammo > 140) and (Ammo < 161) and (AmmoPos)
	{
		Mins+=100
	}
	/*
	If (Ammo > 80) and (AmmoPos)
	{
		AmmoTrafiking:=True
	}
	*/
	If (Ammo > 160) and (AmmoPos)
	{
		Mins+=120
	}
; ======================================================
	MaxTimeMessage:=
	If Mins > 120
	{
		MaxTimeMessage = (%Mins% Total)
		Mins:=120
	}
	If not Notes
		Notes = None
	GuiControl, Text, EditableText, Ticket Total: $%TicketCash%`nTime Total: %Mins% Mins %MaxTimeMessage%`nFine Total: $%FineCash%`nLicense Strikes: %LicenseStrikes% Strikes`nBail: %Bail%
	GuiControl, Text, EditableTextNotes, Notes:`n%Notes%
	If ReportAppending
	{
	If DaylightSavings
		MTGTime:=A_NowUTC-10000
	Else
		MTGTime:=A_NowUTC
	;YYYY MM DD HH MM SS
	Year := SubStr(MTGTime, 1, 4)
	Month := SubStr(MTGTime, 5, 2)
	Day := SubStr(MTGTime, 7, 2)
	Hour := SubStr(MTGTime, 9, 2)
	Minute := SubStr(MTGTime, 11, 2)
	Second := SubStr(MTGTime, 13, 2)
	FileAppend, 
	(
[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
License Strikes[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %LicenseStrikes%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Confiscated Items[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %Confiscate%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Vehicle(s) Impounded[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %Impounded%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Summarize what happened[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %Summary%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Time and date of the arrest[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]: %Hour%:%Minute% - %Year%/%Month%/%Day%[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Associated Reports[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]:[/SIZE][/FONT]
[B][FONT=Arial][SIZE=3]
Additional notes (optional)[/SIZE][/FONT][/B][FONT=Arial][SIZE=3]:[/SIZE][/FONT][/LEFT]
[IMG]
	), %AppendingFile%
	}
Return
