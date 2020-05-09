/*

"Mouse Tweaks.ahk" is a script which contains various functions that make pointer navigation easier. 
It enables the following features:

• Taskbar Volume: Allows the user to control the volume by scrolling the mouse over the taskbar. 
• Mouse Gestures: Holding the middle/right mouse button and dragging up, down, left, or right activates different keyboard shortcuts.
• Application Specific Scrolling Behavior: Assigns different mouse wheel speeds to different applications. It also optionally enables Smooth Scrolling functionality, removing the need for external browser extensions, etc. 
• Enhance Pointer Precision: Keeps the "Enhance Pointer Precision" option in the Control Panel Mouse settings permanently on. This prevents 3rd party applications from turning it off.

*/

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MaxHotkeysPerInterval 999
#NoTrayIcon
;Menu, Tray, Icon, icon.ico 


;WEBSOCKET CONFIGURATION:

Gui +LastFound
Gui WebSocket:Add, ActiveX, vWB
    , about:<meta http-equiv='X-UA-Compatible' content='IE=edge'>
while WB.ReadyState != 4
	Sleep 100
if WB.Document.documentMode < 10 {
	MsgBox IE10+ required.
}
js=
(
	({
		socketOpen: function(host, handlers) {
			try{
				socket = new WebSocket(host);
				(["open", "close", "error", "message"]).forEach(function(e) {
					var h = handlers[e];
					if (h)
						socket["on"+e] = function(p) { h(handlers, socket, p); };
				})
			}
			catch(e){}
		}
	})
)
global webSocketHost := "ws://127.0.0.1:59243"
global WebSocket := WB.Document.parentWindow.eval(js)
class WebSocketClassEnable { 
     open(socket) {
		data := "{""hiRes"":true,""reason"":""content looks good for scrolling""}"
        socket.send(data)
        socket.close()
    }
}
class WebSocketClassDisable { 
     open(socket) {
		data := "{""hiRes"":false,""reason"":""content does not look good for scrolling""}"
        socket.send(data)
        socket.close()
    }
}


;SCRIPT:

global ChangingVolume := False

global GestureActive := False

ApplicationSpecificScrollingBehavior()

SetTimerF("EnhancePointerPrecision",100)

global IsSmoothScroll := False


;HOTKEYS:

~WheelUp::TaskbarVolume("up")
~WheelDown::TaskbarVolume("down")

MButton::
	MouseGetPos,x1,y1
	SetTimerF("MouseGestures",150,1)
	GestureActive := False
	ToggleMute()
Return
MButton UP::
	SetTimerF("MouseGestures",0,1)
	if(GestureActive = False){
		Send {MButton}
	}
	GestureActive := False
Return 

RButton::
	MouseGetPos,x1,y1
	SetTimerF("MouseGestures",150,2)
	GestureActive := False
Return
RButton UP::
	SetTimerF("MouseGestures",0,2)
	if(GestureActive = False){
		Send {RButton}
	}
	GestureActive := False
Return 

#M:: 
	Edit
Return
^#M:: 
	SoundPlay *-1
	Reload
Return


;FUNCTIONS:

TaskbarVolume(command){
	if(MouseIsOver("ahk_class Shell_TrayWnd")){
		if(!WinActive("ahk_class Shell_TrayWnd")){
			if(!WinActive("ahk_exe firefox.exe")){
				WinActivate, ahk_class Shell_TrayWnd
			}
			else{
				if(ChangingVolume = False){
					SmoothScrolling("disable")
				}
			}
			ChangingVolume := True
		}

		if(command = "up"){
			Send {Volume_Up}
		}
		if(command = "down"){
			Send {Volume_Down}
		}
		
	}
	if(!MouseIsOver("ahk_class Shell_TrayWnd")){
		if(ChangingVolume){
			if(!WinActive("ahk_exe firefox.exe")){
				MouseGetPos,,, WinUMID
				WinActivate, ahk_id %WinUMID%
			}
			else{
				SmoothScrolling("enable")
			}
			ChangingVolume := False
		}
	}
}
ToggleMute(){
	if(MouseIsOver("ahk_class Shell_TrayWnd")){
		Send {Volume_Mute}
		ChangingVolume := True
	}
}
MouseIsOver(WinTitle) {
	MouseGetPos,,,Win
	return WinExist(WinTitle . " ahk_id " . Win)
}

MouseGestures(Level := 1){
	if(GestureActive = False){
		global x1
		global y1
		Distance := 50
		MouseGetPos,x2,y2
		if(y2 < y1 - Distance) or (y2 > y1 + Distance) or (x2 < x1 - Distance) or (x2 > x1 + Distance)
			GestureActive := True

		if(x2 < x1 - Distance){ ;gesture left
			if(Level = 1) ;m button
				Send !{Tab}
			else if(Level = 2) ;r button
				DoNothing := true
		}
		else if(x2 > x1 + Distance){ ;gesture right
			if(Level = 1) ;m button
				Send !{Tab}
			else if(Level = 2) ;r button
				DoNothing := true
		}
		else if(y2 < y1 - Distance){ ;gesture up
			if(Level = 1) ;m button
				Send ^!{Tab}
			else if(Level = 2) ;r button
				Send {WheelUp 500}
		}
		else if(y2 > y1 + Distance){ ;gesture down
			if(Level = 1) ;m button
				WinMinimize, A
			else if(Level = 2) ;r button
				Send {WheelDown 500}	
		}
	}
}

ApplicationSpecificScrollingBehavior(){
	hWnd := WinExist()
	DllCall( "RegisterShellHookWindow", UInt,Hwnd )
	MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
	OnMessage( MsgNum, "CheckForScrollBehaviorSet" )	
}
CheckForScrollBehaviorSet( wParam,lParam ){
	IsSmoothScroll := False

	;Applications that do not support or are hindered by smooth scrolling (blacklist)
	SmoothScrollingBlacklist := Array("explorer.exe","dopus.exe","Photoshop.exe","Illustrator.exe","Notepad2.exe","ConEmu64.exe")
	
	If (wParam=32772) or (wParam=4){ ;HSHELL_WINDOWACTIVATED

		;Applications with custom scroll speeds
		if(WinActive("ahk_exe Taskmgr.exe")){
			SetScrollSpeed(12)
		}
		else if(WinActive("ahk_exe sublime_text.exe") OR WinActive("ahk_exe WINWORD.EXE")){
			SetScrollSpeed(6)
			SmoothScrolling("enable")
		}

		else{ ;Default
			SetScrollSpeed(3)
			Blacklisted := false
			for index, value in SmoothScrollingBlacklist{
				if(WinActive("ahk_exe "value)){
					Blacklisted := true
				}
			}
			if(Blacklisted = false){
				SmoothScrolling("enable")
			}
		}
	}
}

SetScrollSpeed(speed){
	DllCall("SystemParametersInfo", UInt, 0x69, UInt, speed, UInt, 0, UInt, 0)
}
SmoothScrolling(command){
	if(command = "enable"){
		IsSmoothScroll := True
		Sleep, 100
		WebSocket.socketOpen(webSocketHost, WebSocketClassEnable)
	}
	else if(command = "disable"){
		IsSmoothScroll := False
		Sleep, 100
		WebSocket.socketOpen(webSocketHost, WebSocketClassDisable)
	}
}

EnhancePointerPrecision(){
	SPI_SETMOUSE = 0x0004
	VarSetCapacity(MySet, 12, 0)
	InsertInteger(6, MySet, 0)	; MouseThreshold1
	InsertInteger(10, MySet, 4)	; MouseThreshold2
	InsertInteger(1, MySet, 8)	; MouseSpeed
	DllCall("SystemParametersInfo", UInt, SPI_SETMOUSE, UInt, 0, Str, MySet, UInt, 1)
}
InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4){ ;Required for Enhanced Pointer Precision function.
	Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
		DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}

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
