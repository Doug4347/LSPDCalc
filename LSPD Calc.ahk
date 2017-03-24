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
AppVersion:=1.2

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
	Gui, Add, Checkbox, gUpdateTimes x28 y120 vSpeedPos, Possession of Amphetamine
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
	Gui, Add, Checkbox, gUpdateTimes x28 y260 vTrafikingLowCalWeapons, Trafiking Low Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vTrafikingHighCalWeapons, Trafiking High Caliber Weapons
	Gui, Add, Checkbox, gUpdateTimes x28 y280 vSolicitingArmour, Soliciting Illegal Body Armour
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
	If BrandishingFirearm
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Brandishing a Firearm{Enter}
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
	}
	If UnregisteredVehicle
	{
		Mins+=15
		If LicenseStrikes < 2
			LicenseStrikes:=2
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving an unregistered vehicle{Enter}
	}
	If LicenseFailure
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure to Provide License{Enter}
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
	}
	If AttemptedGTA
	{
		Mins+=25
		If LicenseStrikes < 3
			LicenseStrikes:=3
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% (Attempted) Grand Theft Auto{Enter}
	}
	If DUI
	{
		Mins+=20
		If LicenseStrikes < 2
			LicenseStrikes:=2
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving Under the Influence{Enter}
	}
	If HnR
	{
		Mins+=30
		If LicenseStrikes < 3
			LicenseStrikes:=3
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Hit and Run{Enter}
	}
	If DwS
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Driving While Suspended{Enter}
	}
	If Racing
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Street Racing{Enter}
	}
	If GTA
	{
		Mins+=35
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Grand Theft Auto{Enter}
	}
	If VehAssualt
	{
		Mins+=50
		If LicenseStrikes < 3
			LicenseStrikes:=3
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Vehicular Assault{Enter}
	}
	If Loitering
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Loitering{Enter}
	}
	If Trespassing
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trespassing{Enter}
	}
	If IndecentExposure
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Indecent Exposure{Enter}
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
	}
	If Affray
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Affray{Enter}
	}
	If ResistingPhysical
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Resisting Arrest{Enter}
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
	}
	If DisorderlyConduct
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Disorderly Conduct{Enter}
	}
	If AidingAbettingInfractions
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Infractions){Enter}
	}
	If MeleeWeaponPossession
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Melee Weapon{Enter}
	}
	If MeleeWeaponSoliciting
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of a Melee Weapon{Enter}
	}
	If LowCalWeaponSemiAutomatic
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Low Caliber Weapon (Semi-Automatic){Enter}
	}
	If LowCalWeaponFullyAutomatic
	{
		Mins+=45
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Low Caliber Weapon (Fully-Automatic){Enter}
	}
	If ValidIDFailure
	{
		Mins+=15
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Failure to Provide ID{Enter}
	}
	If CounterfeitDocs
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Counterfeit Documentation{Enter}
	}
	If SolicitingLowCal
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Low Caliber Weapons{Enter}
	}
	If SilencedPossession
	{
		Mins+=35
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Silenced Low Caliber Weapon{Enter}
	}
	If SolicitingSilenced
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Low Caliber Silenced Weapons{Enter}
	}
	If Impersonating
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Impersonating an LEO{Enter}
	}
	If Obstruction
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Obstruction of Justice{Enter}
	}
	If MurderConspiracy
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Conspiracy to Commit Murder{Enter}
	}
	If Harassment
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Harassment{Enter}
	}
	If FirearmDischargeSingle
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Discharge of Firearm (Single Shot){Enter}
	}
	If FirearmDischargeMulti
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Discharge of Firearm (Multiple shots){Enter}
	}
	If PEndangerment
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Public Endangerment{Enter}
	}
	If Fraud
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Fraud{Enter}
	}
	If LyingToLEO
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Lying to an LEO in function{Enter}
	}
	If AidingAbettingMisdemeanors
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Misdemeanors){Enter}
	}
	If CounterfeitProduction
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafficking/Production of Counterfeit Documentation{Enter}
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
	}
	If HighCalWeaponPossession
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a High Caliber Firearm{Enter}
	}
	If DeaglePossession
	{
		Mins+=45
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Unlawful Possession of a Desert Eagle{Enter}
	}
	If HighCalWeaponSoliciting
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting High Caliber Weapons{Enter}
	}
	If DeagleSoliciting
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Desert Eagle{Enter}
	}
	If Manslaughter
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Manslaughter{Enter}
	}
	If MurderAccessory
	{
		Mins+=50
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Accessory to Murder{Enter}
	}
	If AttemptedMurder
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Murder{Enter}
	}
	If AttemptedMurderLEO
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Murder of an LEO{Enter}
	}
	If MurderAccomplice
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Accomplice to Murder{Enter}
	}
	If InstigatingAnarchy
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Instigating Public Anarchy{Enter}
	}
	If Racketeering
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Racketeering{Enter}
	}
	If Kidnapping
	{
		Mins+=100
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Kidnapping{Enter}
	}
	If KidnappingLEO
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Kidnapping an LEO{Enter}
	}
	If AttemptedRobbery
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Attempted Robbery{Enter}
	}
	If Robbery
	{
		Mins+=45
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Robbery{Enter}
	}
	If ArmedRobbery
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Armed Robbery{Enter}
	}
	If Burglary
	{
		Mins+=25
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Burglary{Enter}
	}
	If Gambling
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Illegal Gambling{Enter}
	}
	If Bribery
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Bribery{Enter}
	}
	If Assault
	{
		Mins+=20
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Assault{Enter}
	}
	If AssaultLEO
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Assault of an LEO{Enter}
	}
	If Battery
	{
		Mins+=50
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery{Enter}
	}
	If BatteryLEO
	{
		Mins+=70
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery of an LEO{Enter}
	}
	If BatteryWeap
	{
		Mins+=70
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery with a deadly weapon{Enter}
	}
	If BatteryWeapLEO
	{
		Mins+=80
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Battery with a deadly weapon of an LEO{Enter}
	}
	If Extortion
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Extortion{Enter}
	}
	If Scamming
	{
		Mins+=40
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Scamming{Enter}
	}
	If Arson
	{
		Mins+=30
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Arson{Enter}
	}
	If AidingAbettingCapital
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Aiding and Abetting (Felonies){Enter}
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
	}
	If ExplosivesPossession
	{
		Mins+=90
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Explosives{Enter}
	}
	If TerrorismConspiracy
	{
		Mins+=100
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Conspiracy to Commit Terrorism{Enter}
	}
	If DomesticTerrorism
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Domestic Terrorism{Enter}
	}
	If Murder
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Murder{Enter}
	}
	If MurderLEO
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Murder of an LEO{Enter}
	}
	If MassMurder
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Mass Murder{Enter}
	}
	If Corruption
	{
		Mins+=120
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Corruption{Enter}
	}
	If Piracy
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Piracy{Enter}
	}
	If SolicitingMaterials
	{
		Mins+=30
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Materials{Enter}
	}
	If TrafikingStreetArmour
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Street Armour{Enter}
	}
	If TrafikingStandardArmour
	{
		Mins+=50
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Standard Armour{Enter}
	}
	If TrafikingMilitaryArmour
	{
		Mins+=60
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Military Armour{Enter}
	}
	If TrafikingMeleeWeapons
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Melee Weapons{Enter}
	}
	If TrafikingLowCalWeapons
	{
		Mins+=40
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Low Caliber Weapons{Enter}
	}
	If TrafikingHighCalWeapons
	{
		Mins+=80
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking High Caliber Weapons{Enter}
	}
	If SolicitingArmour
	{
		Mins+=25
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting Illegal Body Armour{Enter}
	}
	If SolicitingCocaine
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Cocaine{Enter}
	}
	If SolicitingAmphetamine
	{
		Mins+=20
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Amphetamine{Enter}
	}
	If SolicitingMarijuana
	{
		Mins+=10
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Soliciting of Marijuana{Enter}
	}
	If SmugglingContraband
	{
		Mins+=50
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Smuggling Contraband{Enter}
	}
;===============================================
	If PotPos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Marijuana (%Pot%g){Enter}
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
	If CokePos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Cocaine (%Coke%g){Enter}
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
	If SpeedPos
	{
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Amphetamine (%Speed% Tablets){Enter}
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
		If Notes
			Notes = %Notes%`nAssume Traffiking (Narcotics)
		Else
			Notes = Assume Traffiking (Narcotics)
		Mins+=40
		If RecordingCrimes
		{
			If PotTrafiking
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Marijuana){Enter}
			If CokeTrafiking
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Cocaine){Enter}
			If SpeedTrafiking
				Send, t^a/recordcrime %CrimScum% Trafiking of Contraband (Amphetamine){Enter}
		}
	}

;===============================================
	If StreetPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Street Materials (%StreetMats% Mats){Enter}
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
	If StandardPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Standard Materials (%StandardMats% Mats){Enter}
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
	If MilitaryPos
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Possession of Military Materials (%MilitaryMats% Mats){Enter}
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
		Mins+=30If Notes
		If Notes
			Notes = %Notes%`nAssume Traffiking (Standard Mats)
		Else
			Notes = Assume Traffiking (Standard Mats)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Street Materials{Enter}
	}
	If StreetMatsTrafiking
	{
		Mins+=50If Notes
		If Notes
			Notes = %Notes%`nAssume Traffiking (Street Mats)
		Else
			Notes = Assume Traffiking (Street Mats)
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Standard Materials{Enter}
	}
	If MilitaryMatsTrafiking
	{
		Mins+=60If Notes
		If Notes
			Notes = %Notes%`nAssume Traffiking (Millitary Mats)
		Else
			Notes = Assume Traffiking (Millitary Mats)
		Bail = No
		If RecordingCrimes
			Send, t^a/recordcrime %CrimScum% Trafiking Military Materials{Enter}
	}
	
	If Mins > 120
		Mins:=120
	If not Notes
		Notes = None
	GuiControl, Text, EditableText, Ticket Total: $%TicketCash%`nTime Total: %Mins% Mins`nFine Total: $%FineCash%`nLicense Strikes: %LicenseStrikes% Strikes`nBail: %Bail%
	GuiControl, Text, EditableTextNotes, Notes:`n%Notes%
Return
