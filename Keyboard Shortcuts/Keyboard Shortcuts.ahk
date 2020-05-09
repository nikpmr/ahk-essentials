#NoTrayIcon
SetWorkingDir %A_ScriptDir%
#Include DockWin.ahk

;Remap Caps Lock to Ctrl (Use Win+C for Caps Lock)
;You can comment this out in favor of changing the key thru registry editor
;Capslock::Control
#C::SetCapsLockState, % (State:=!State) ? "On" : "Off"

;Use Ctrl+IJKL as arrow keys
<^I::Send {Up}
<^+I::Send ^{Up}
<^K::Send {Down}
<^+K::Send ^{Down}
<^J::Send {Left}
<^+J::Send ^{Left}
<^L::Send {Right}
<^+L::Send ^{Right}

;Use Win+F to launch web browser
#F::Run, "firefox.exe"

;Use Win+E to launch file manager
#E::Run, "dopus.exe"

;Use Ctrl+Win+E to restart explorer.exe
^#E::
	Process,close,explorer.exe
	Sleep, 1000 
	run, explorer.exe
	WinWait, ahk_class CabinetWClass
	WinClose ;Close the new explorer window
Return

;Use Win+Q to close windows (Ctrl+Q also works)
#Q::WinClose A
<^Q::WinClose A

;Use Win+Z to minimize windows
#Z::WinMinimize A

;Use Win+Esc to sleep PC 
#ESC::
	;GoSub #+0
	;Sleep, 100
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

;Use Ctrl+Win+/ to restore windows after sleeping PC
^#/::
	GoSub #0
Return

;Use Win+/ to center current window
#/::
	if(A_ScreenWidth <= 2560){ ;Laptop screen
		w := 2160
		h := 1360
		voffset := -30
	}
	else{ ;External monitor
		w := 2160
		h := 1880
		voffset := -30
	}
	WinExist("A")
	WinMove,A,,,,w,h
	WinGetPos,,, sizeX, sizeY
	WinMove, (A_ScreenWidth/2)-(sizeX/2), (A_ScreenHeight/2)-(sizeY/2) + voffset
Return

;Use Win+Space to dismiss notifications (Ctrl+Space also works, use Win+Ctrl+Space for Ctrl+Space)
#SPACE::
^SPACE::
	CoordMode, Mouse, Screen
	MouseGetPos, xpos, ypos 
	WinGet, winid ,, A
	MouseMove, (A_ScreenWidth - 100), (A_ScreenHeight - 120), 0
	Click
	MouseMove, xpos, ypos, 0
	WinActivate ahk_id %winid%
Return
#^SPACE::Send #{Space}

;Use PgUp and PgDn to scroll partway up and down a page 
;(Use Win+PgUp and Win+PgDn for PgUp and PgDn)
PgUp:: 
	Loop, 3{
		KeyWait Control
		Send {WheelUp 1}
		Sleep, 25
	}
Return
PgDn:: 
	Loop, 3{
		KeyWait Control
		Send {WheelDown 1}
		Sleep, 25
	}
Return
#PgUp::PgUp
#PgDn::PgDn

;Use Ctrl+Win+V to paste without formatting
;(Use Win+V to bring up clipboard history)
^#V::                            
   Clipboard := Clipboard
   	Send ^v
Return

;Use Win+T to keep window on top
#T::  
	Winset, Alwaysontop, , A
	SoundPlay, *-1
Return

;Use Ctrl+Win+K to relaunch script
^#K:: 
	SoundPlay *-1
	Reload
Return