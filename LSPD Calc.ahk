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
AppVersion:=1.1

SplashImage, LSPD.png,, Downloading Update Info..., Checking for Updates...
FileDelete, LSPDUpdateInfo.ini
UrlDownloadToFile, https://www.dropbox.com/s/8rvndpkvb78rhnc/LSPDCalc.ini?dl=1, LSPDUpdateInfo.ini
SplashImage, Off
IniRead, LatestAHK, LSPDUpdateInfo.ini, AHK, Latest, 0
If not LatestAHK
	MsgBox, 16,, Upatater Error: Could not find the update info file. Please make sure you have an internet connection, then restart the app to check for updates.
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




If A_AHKVersion < 1.1.23.00
{
	MsgBox, 16,, Due to a mechanic used in this app, you need to update to version 1.1.23.00 of AHK or higher before using this app.`nPlease restart the app and use the built-in auto updater.
	ExitApp
}

/*
THE REST OF THIS IS THE ACTUAL SCRIPT ITSELF
*/

#If not (A_AHKVersion < 1.1.23.00)


StringTrimRight, SettingsFile, A_ScriptName, 4
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
	Gui, Add, Tab3, vMainTabs w1000, Vehicular Infractions|Vehicular Misdemeanors|Vehicular Felonies|INFRACTIONS|MISDEMEANORS|FELONIES|Narcotics|Materials
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
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vHighCalWeaponPossession, Unlawful Possession of a High Caliber Firearm(M4, AK, Combat, Sniper)
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
	Gui, Add, Checkbox, gUpdateTimes x28 y80 vPotPos, Possession of Pot
	Gui, Add, Checkbox, gUpdateTimes x28 y100 vCokePos, Possession of Coke
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vSpeedPos, Possession of Speed
	Gui, Add, Edit, gUpdateTimes x400 y80 w200 vPot, 0
	Gui, Add, Edit, gUpdateTimes x400 y100 w200 vCoke, 0
	Gui, Add, Edit, gUpdateTimes x400 y120 w200 vSpeed, 0
	Gui, Add, Checkbox, gUpdateTimes x28 y160 vSolicitingCocaine, Soliciting of Cocaine
	Gui, Add, Checkbox, gUpdateTimes x28 y180 vSolicitingAmphetamine, Soliciting of Amphetamine
	Gui, Add, Checkbox, gUpdateTimes x28 y200 vSolicitingMarijuana, Soliciting of Marijuana
	Gui, Add, Checkbox, gUpdateTimes x28 y220 vSmugglingContraband, Smuggling Contraband (Any Type)
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
	Gui, Add, Checkbox, gUpdateTimes x28 y260 vTrafikingLowWeapons, Trafiking Low Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vTrafikingHighCalWeapons, Trafiking High Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vSolicitingArmour, Soliciting Illegal Body Armour
	Gui, Tab,
	Gui, Add, Checkbox, x28 gUpdateTimes vFineArrest, Include Fine on /arrest
	Gui, Add, Checkbox, x28 gUpdateTimes vStrikeArrest, Include Strikes on /arrest
	Gui, Add, Text, x28, Custom Fine:
	Gui, Add, Edit, x28 w250 vCustomFine gUpdateTimes, 0
	Gui, Add, Text, x28, Custom Time:
	Gui, Add, Edit, x28 w250 vCustomTime gUpdateTimes, 0
	Gui, Add, Text, x28 w365 r15 vEditableText, Ticket Total: $%TicketCash%`nTime Total: %Mins% Mins`nFine Total: $%FineCash%`nLicense Strikes: %LicenseStrikes% Strikes`nNotes:`nBail: %Bail%`n%Notes%
	Gui, Add, Pic, x389 y480, LSPD.png
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
	MsgBox, Crimes
Return

UpdateTimes:
	Gui, Submit, NoHide
	TicketCash:=0
	Mins:=0
	FineCash:=0
	LicenseStrikes:=0
	Notes = 
	PotTrafiking:=False
	CokeTrafiking:=False
	SpeedTrafiking:=False
	StandardMatsTrafiking:=False
	StreetMatsTrafiking:=False
	MilitaryMatsTrafiking:=False
	Bail = Yes
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
	}
	If UnregisteredVehicle
	{
		Mins+=15
		If LicenseStrikes < 2
			LicenseStrikes:=2
	}
	If LicenseFailure
	{
		Mins+=20
	}
	If VehicleEvading
	{
		Mins+=30
		If LicenseStrikes < 2
			LicenseStrikes:=2
	}
	If TicketPayTime
	{
		TicketCash+=5000
		FineCash:=CustomFine
	}
	If AttemptedGTA
	{
		Mins+=25
		If LicenseStrikes < 3
			LicenseStrikes:=3
	}
	If DUI
	{
		Mins+=20
		If LicenseStrikes < 2
			LicenseStrikes:=2
	}
	If HnR
	{
		Mins+=30
		If LicenseStrikes < 3
			LicenseStrikes:=3
	}
	If DwS
	{
		Mins+=40
	}
	If Racing
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
	}
	If GTA
	{
		Mins+=35
		If LicenseStrikes < 3
			LicenseStrikes:=3
	}
	If VehAssualt
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
	}
	If Loitering
	{
		Mins+=10
	}
	If Trespassing
	{
		Mins+=15
	}
	If IndecentExposure
	{
		Mins+=10
	}
	If Vandalism
	{
		Mins+=25
		FineCash:=CustomFine
	}
	If Affray
	{
		Mins+=20
	}
	If ResistingPhysical
	{
		Mins+=25
	}
	If EvadingFoot
	{
		Mins+=20
		If VehicleEvading
			Mins-=20
	}
	If DisorderlyConduct
	{
		Mins+=10
	}
	If AidingAbettingInfractions
	{
		Mins+=20
	}
	If MeleeWeaponPossession
	{
		Mins+=15
	}
	If MeleeWeaponSoliciting
	{
		Mins+=10
	}
	If LowCalWeaponSemiAutomatic
	{
		Mins+=30
	}
	If LowCalWeaponFullyAutomatic
	{
		Mins+=45
	}
	If ValidIDFailure
	{
		Mins+=15
	}
	If CounterfeitDocs
	{
		Mins+=20
	}
	If SolicitingLowCal
	{
		Mins+=20
	}
	If SilencedPossession
	{
		Mins+=35
	}
	If SolicitingSilenced
	{
		Mins+=25
	}
	If Impersonating
	{
		Mins+=30
	}
	If Obstruction
	{
		Mins+=40
	}
	If MurderConspiracy
	{
		Mins+=40
	}
	If Harassment
	{
		Mins+=25
	}
	If FirearmDischargeSingle
	{
		Mins+=30
	}
	If FirearmDischargeMulti
	{
		Mins+=40
	}
	If PEndangerment
	{
		Mins+=30
	}
	If Fraud
	{
		Mins+=25
	}
	If LyingToLEO
	{
		Mins+=25
	}
	If AidingAbettingMisdemeanors
	{
		Mins+=30
	}
	If CounterfeitProduction
	{
		Mins+=30
	}
	If 911Misuse
	{
		Mins+=CustomTime
	}
	If HighCalWeaponPossession
	{
		Mins+=60
		Bail = No
	}
	If DeaglePossession
	{
		Mins+=45
		Bail = No
	}
	If HighCalWeaponSoliciting
	{
		Mins+=40
		Bail = No
	}
	If DeagleSoliciting
	{
		Mins+=30
		Bail = No
	}
	If Manslaughter
	{
		Mins+=30
		Bail = No
	}
	If MurderAccessory
	{
		Mins+=50
		Bail = No
	}
	If AttemptedMurder
	{
		Mins+=60
		Bail = No
	}
	If AttemptedMurderLEO
	{
		Mins+=90
		Bail = No
	}
	If MurderAccomplice
	{
		Mins+=90
		Bail = No
	}
	If InstigatingAnarchy
	{
		Mins+=30
		Bail = No
	}
	If Racketeering
	{
		Mins+=120
		Bail = No
	}
	If Kidnapping
	{
		Mins+=100
		Bail = No
	}
	If KidnappingLEO
	{
		Mins+=120
		Bail = No
	}
	If AttemptedRobbery
	{
		Mins+=30
		Bail = No
	}
	If Robbery
	{
		Mins+=45
		Bail = No
	}
	If ArmedRobbery
	{
		Mins+=60
		Bail = No
	}
	If Burglary
	{
		Mins+=25
		Bail = No
	}
	If Gambling
	{
		Mins+=40
		Bail = No
	}
	If Bribery
	{
		Mins+=60
		Bail = No
	}
	If Assault
	{
		Mins+=20
		Bail = No
	}
	If AssaultLEO
	{
		Mins+=30
		Bail = No
	}
	If Battery
	{
		Mins+=50
		Bail = No
	}
	If BatteryLEO
	{
		Mins+=70
		Bail = No
	}
	If BatteryWeap
	{
		Mins+=70
		Bail = No
	}
	If BatteryWeapLEO
	{
		Mins+=80
		Bail = No
	}
	If Extortion
	{
		Mins+=30
		Bail = No
	}
	If Scamming
	{
		Mins+=40
		Bail = No
	}
	If Arson
	{
		Mins+=30
		Bail = No
	}
	If AidingAbettingCapital
	{
		Mins+=60
		Bail = No
	}
	If FugitiveHarboring
	{
		Mins+=60
		Bail = No
	}
	If ExplosivesPossession
	{
		Mins+=90
		Bail = No
	}
	If TerrorismConspiracy
	{
		Mins+=100
		Bail = No
	}
	If DomesticTerrorism
	{
		Mins+=120
		Bail = No
	}
	If Murder
	{
		Mins+=120
		Bail = No
	}
	If MurderLEO
	{
		Mins+=120
		Bail = No
	}
	If MassMurder
	{
		Mins+=120
		Bail = No
	}
	If Corruption
	{
		Mins+=120
		Bail = No
	}
	If Piracy
	{
		Mins+=60
		Bail = No
	}
	If SolicitingMaterials
	{
		Mins+=30
	}
	If TrafikingStreetArmour
	{
		Mins+=40
	}
	If TrafikingStandardArmour
	{
		Mins+=50
	}
	If TrafikingMilitaryArmour
	{
		Mins+=60
		Bail = No
	}
	If TrafikingMeleeWeapons
	{
		Mins+=25
	}
	If TrafikingLowWeapons
	{
		Mins+=40
	}
	If TrafikingHighCalWeapons
	{
		Mins+=80
		Bail = No
	}
	If SolicitingArmour
	{
		Mins+=25
	}
	If SolicitingCocaine
	{
		Mins+=20
	}
	If SolicitingAmphetamine
	{
		Mins+=20
	}
	If SolicitingMarijuana
	{
		Mins+=10
	}
	If SmugglingContraband
	{
		Mins+=50
	}
;===============================================	
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
	If (Pot > 100) and (PotPos)
	{
		PotTrafiking:=True
	}
	If (Pot > 200) and (PotPos)
	{
		Mins+=30
	}
;===============================================
;===============================================	
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
	If (Coke > 60) and (CokePos)
	{
		CokeTrafiking:=True
	}
	If (Coke > 140) and (CokePos)
	{
		Mins+=120
	}
;===============================================
;===============================================	
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
	If (Speed > 60) and (SpeedPos)
	{
		SpeedTrafiking:=True
	}
	If (Speed > 201) and (SpeedPos)
	{
		Mins+=100
	}
;===============================================
	If PotTrafiking or CokeTrafiking or SpeedTrafiking
	{
		Mins+=40
	}

;===============================================	
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
	If (StreetMats > 90) and (StreetPos)
	{
		StreetMatsTrafiking:=True
	}
	If (StreetMats > 300) and (StreetPos)
	{
		Mins+=60
	}
;===============================================
;===============================================	
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
	If (StandardMats > 90) and (StandardPos)
	{
		StandardMatsTrafiking:=True
	}
	If (StandardMats > 300) and (StandardPos)
	{
		Mins+=65
	}
;===============================================
;===============================================	
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
	If (MilitaryMats > 90) and (MilitaryPos)
	{
		MilitaryMatsTrafiking:=True
	}
	If (MilitaryMats > 300) and (MilitaryPos)
	{
		Mins+=75
	}
;===============================================
	If StandardMatsTrafiking
	{
		Mins+=30
	}
	If StreetMatsTrafiking
	{
		Mins+=50
	}
	If MilitaryMatsTrafiking
	{
		Mins+=60
		Bail = No
	}
	
	If Mins > 120
		Mins:=120
	If not Notes
		Notes = None
	GuiControl, Text, EditableText, Ticket Total: $%TicketCash%`nTime Total: %Mins% Mins`nFine Total: $%FineCash%`nLicense Strikes: %LicenseStrikes% Strikes`nNotes:`nBail: %Bail%`n%Notes%
Return
