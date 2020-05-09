### Lenovo Yoga 2 Pro Pointing Device Notes

**Devices:** 
Synaptics Touchpad
Logitech SetPoint compatible mouse (with throttled hyperscroll wheel)

1. From the Device Manager, install Synaptics Touchpad Driver.
	(19.0.19.1 generally works, found in the Extras folder)
	Upon restart, Windows might update the driver, in which case it needs to be rolled back.
	
2. Use Synaptics Touchpad Button Assignment.reg to assign correct gestures to 2-finger and 3-finger touches/presses.

3. Download Logitech SetPoint (v6.67, found in the Extras folder) and configure accordingly.

4. Move "Mouse Tweaks.ahk" to the Startup folder.

5. In Firefox's about:config menu, change the following:

> general.smoothScroll.mouseWheel: false
	> mousewheel.default.delta_multiplier_y: 160

6. If 3 finger back/forward aren't accessible:
    Press Win and type Regedit and Navigate

  > HKEY_LOCAL_MACHINE\SOFTWARE\Synatics\SynTP\Win10\3FingerGestures

  For the 3 Finger Swipes back/foward to work correctly edit the following ActionIDs to the following:  

  > ActionID3 = 1c 
  > ActionID7 = 1c 

  Exit the Registry Editor and reset (reboot or signout and signin)