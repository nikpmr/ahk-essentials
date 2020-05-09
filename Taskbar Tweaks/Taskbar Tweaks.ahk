/*

"Taskbar Tweaks.ahk" is a script which contains various functions that tidy up the taskbar. 
It fires immediately upon loading the taskbar and enables the following features:

• Remove highlighted taskbar icons: The taskbar will sometimes turn permanently orange when cursor blink rate is set to 0. This script fixes this issue.
• Remove unnecessary tray icons: Removes extra icons that appear in the taskbar when taskbar first loads.
• Prevent unwanted popups: Will prevent specified popup windows from opening.

*/


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon
#Persistent
#Include TrayIcon.ahk

DetectHiddenWindows, on  ; Might allow detection of popups sooner.

global FixHighlightedTaskbarButtonsIsRunning := False
global FirstRun := True

SetTimerF("FixHighlightedTaskbarButtons",100)
;SetTimer, PreventUnwantedPopups, 250

FixHighlightedTaskbarButtons(){ 
	if(!WinExist("ahk_exe explorer.exe")) and (FixHighlightedTaskbarButtonsIsRunning = False) or (FirstRun = True){
		FirstRun := False
		
		; Fix highlighted taskbar buttons
		FixHighlightedTaskbarButtonsIsRunning := True
		Sleep, 5000
		DllCall("SetCaretBlinkTime", UInt, 500)
		Process, Close, explorer.exe
		Run, explorer.exe
		WinWait, ahk_class CabinetWClass
		WinClose ;close the new explorer window
		Sleep, 3000
		DllCall("SetCaretBlinkTime", UInt, -1)
		FixHighlightedTaskbarButtonsIsRunning := False
		
		; Remove unnecessary tray icons
		Icons := TrayIcon_GetInfo()
		Loop, % Icons.MaxIndex()
		{
		    if (Icons[A_Index].process = "davmail.exe"){
		    	TrayIcon_Remove(Icons[A_Index].hwnd, Icons[A_Index].uid)
		    }
		}
	}
}
PreventUnwantedPopups:
	WinClose, 1 reminder ahk_exe MailClient.exe
Return

SetTimerF( p1, p2="", p3=0, p4=0 ) { ;Allows timers to be set for functions.
	;Timer function. 1st param: function, 2nd param: delay in ms (0 to stop timer, positive to start, negative to run once)
	Static tmrs, CBA
	if !CBA
	   CBA := RegisterCallback( A_ThisFunc, "", 4 )
	If IsFunc( p1 ) {
		if RegExMatch(tmrs, "(?i)^(?<pre>.*)(?<=^|;)(?<tmr>\d+)," p1 ",[^;]*;(?<post>.*)$", _)
       		ret := DllCall( "KillTimer", UInt,0, UInt, _tmr ), tmrs := _pre _post
    	if (p2 = 0)
    		return ret
    	return !!tmr := DllCall( "SetTimer", UInt,0, UInt,0, UInt,p2 ? Abs(p2) : (p2 := 250), UInt,CBA )
			, tmrs .= tmr "," p1 "," p2 "," (p3+=0) "," (p4+=0) ";"
	}
	RegExMatch(tmrs, "^(?<pre>.*)(?<=^|;)" p3 ",(?<func>[\da-zA-Z@#$_]+),(?<delay>-?\d+),(?<ptr>\d*),(?<len>\d*);(?<post>.*)$", _)
	if (_delay < 0)
		DllCall( "KillTimer", UInt,0, UInt, p3 ), tmrs := _pre _post
	ErrorLevel := p4, %_func%( _ptr, _len )
}