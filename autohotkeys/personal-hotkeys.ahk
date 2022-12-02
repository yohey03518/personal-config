#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


!r::
click
return

F4::
click
return

!F2::
SendRaw 1234qwer
return

!F3::
SendRaw zxcv1234
return

!1::
WinActivate PowerShell
return