SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

NeededVersion = 1.1.24.00

If A_AhkVersion < %NeededVersion%
	MsgBox, Your AHK Version is %A_AHKVersion% - This is too outdated. You need at least version 1.1.24.00 to run the LSPD calculator. Please update to the latest version.
Else
	MsgBox, Your AHK Version is good enough to run the LSPD Calculator.

