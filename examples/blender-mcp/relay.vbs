' Launch the Blender MCP relay from this folder without showing a console window.
' Copy this file into the Startup folder to start the relay at logon.
Dim fso, shell, here
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
here = fso.GetParentFolderName(WScript.ScriptFullName)
shell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & here & "\relay.ps1""", 0, False
