Option Explicit

Const ForWriting = 2
Const TristateFalse = 0
Const ATTR_HIDDEN = 2
Const ATTR_SYSTEM = 4
Const DRIVE_REMOVABLE = 1
Const EVENT_DEVICE_ARRIVAL = 2

Dim shell, fso, scriptDir, iconPath, startupDir, shortcutPath
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
iconPath = fso.BuildPath(scriptDir, "ico.ico")
startupDir = shell.SpecialFolders("Startup")
shortcutPath = fso.BuildPath(startupDir, "UsbIconSet.lnk")

If Not fso.FileExists(iconPath) Then
    MsgBox "Icon file not found:" & vbCrLf & iconPath, vbExclamation, "USB Icon Set"
    WScript.Quit 1
End If

InstallStartupShortcut
ProcessExistingRemovableDrives
MonitorDriveArrival

Sub InstallStartupShortcut
    Dim shortcut
    Set shortcut = shell.CreateShortcut(shortcutPath)
    shortcut.TargetPath = WScript.FullName
    shortcut.Arguments = Chr(34) & WScript.ScriptFullName & Chr(34)
    shortcut.WorkingDirectory = scriptDir
    shortcut.Description = "Automatically set USB drive icon"
    shortcut.WindowStyle = 7
    shortcut.Save
End Sub

Sub ProcessExistingRemovableDrives
    Dim drive
    For Each drive In fso.Drives
        If drive.DriveType = DRIVE_REMOVABLE Then
            If drive.IsReady Then
                SetDriveIcon drive.DriveLetter & ":\"
            End If
        End If
    Next
End Sub

Sub MonitorDriveArrival
    Dim locator, service, events, volumeEvent, driveName
    Set locator = CreateObject("WbemScripting.SWbemLocator")
    Set service = locator.ConnectServer(".", "root\cimv2")
    Set events = service.ExecNotificationQuery( _
        "SELECT * FROM Win32_VolumeChangeEvent WHERE EventType = " & EVENT_DEVICE_ARRIVAL)

    Do
        Set volumeEvent = events.NextEvent
        driveName = volumeEvent.DriveName
        If Not IsNull(driveName) Then
            If Len(driveName) > 0 Then
                WScript.Sleep 1500
                SetDriveIcon driveName
            End If
        End If
    Loop
End Sub

Sub SetDriveIcon(ByVal driveRoot)
    Dim destinationIcon, autorunPath, file, content
    If Not fso.FolderExists(driveRoot) Then Exit Sub

    destinationIcon = fso.BuildPath(driveRoot, "ico.ico")
    autorunPath = fso.BuildPath(driveRoot, "autorun.inf")

    On Error Resume Next
    Err.Clear
    fso.CopyFile iconPath, destinationIcon, True
    If Err.Number <> 0 Then
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If

    content = "[autorun]" & vbCrLf & _
              "icon=ico.ico" & vbCrLf
    Set file = fso.OpenTextFile(autorunPath, ForWriting, True, TristateFalse)
    file.Write content
    file.Close

    shell.Run "cmd.exe /c attrib +h +s " & Quote(destinationIcon), 0, True
    shell.Run "cmd.exe /c attrib +h +s " & Quote(autorunPath), 0, True
    On Error GoTo 0
End Sub

Function Quote(ByVal value)
    Quote = Chr(34) & value & Chr(34)
End Function
