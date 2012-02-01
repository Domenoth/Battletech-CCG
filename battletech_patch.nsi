; battletech_fix.nsi
;
; This script will correct errors and add functionality to the
; LackeyCCG Battletech plugin.
;
; Original Author:
; Domenoth

;--------------------------------

Name "BattleTech CCG Patch"

OutFile "battletech_patch.exe"

InstallDir $PROGRAMFILES\LackeyCCG\plugins\battletech

; InstallDirRegKey HKLM "Software\BattleTechPatch" "Install_Dir"

RequestExecutionLevel admin

;--------------------------------

; Pages

Page directory
Page instfiles

; UninstPage uninstConfirm
; UninstPage instfiles

;--------------------------------

Var images_path
Var current_image
Var faux_checksum
Var correct_file
Var correct_destination
Var card_name

!macro GetFileSize FileName FileHandleRegister SizeRegister
  ClearErrors
  FileOpen ${FileHandleRegister} ${FileName} r
  IfErrors done
  FileSeek ${FileHandleRegister} 0 END ${SizeRegister}
  FileClose ${FileHandleRegister}
!macroend

!macro GetLastUniqueByte FileName FileHandleRegister ByteRegister
  ClearErrors
  FileOpen ${FileHandleRegister} ${FileName} r
  IfErrors done
  FileSeek ${FileHandleRegister} -4 END
  FileReadByte ${FileHandleRegister} ${ByteRegister}
  FileClose ${FileHandleRegister}
!macroend

!macro CheckFile FileName
  StrCpy $current_image ${FileName}
  Call SetFileData
  StrCmp $1$2 $faux_checksum success 0
!macroend

Function SetFileData
  ClearErrors
  FileOpen $0 $images_path$current_image r
  IfErrors failed
  FileSeek $0 0 END $1
  FileSeek $0 -4 END
  FileReadByte $0 $2
  FileClose $0
  Goto exit

  failed:
  DetailPrint "Error opening $images_path$current_image"
  
  exit:
FunctionEnd

Function FindRightFile
  !insertmacro CheckFile "LT277.jpg"

  !insertmacro CheckFile "LT278.jpg"

  !insertmacro CheckFile "LT279.jpg"

  !insertmacro CheckFile "LT288.jpg"

  !insertmacro CheckFile "LT289.jpg"

  !insertmacro CheckFile "LT290.jpg"

  StrCpy $correct_file "Not Found"
  Goto exit

  success:
  StrCpy $correct_file $current_image

  exit:
FunctionEnd

Function ShuffleImages
  StrCmp $correct_file "Not Found" 0 begin
  DetailPrint "$card_name was not found"
  Goto exit

  begin:
  StrCmp $correct_destination $correct_file 0 move
  DetailPrint "$card_name looks correct"
  Goto exit

  move:
  Rename $images_path$correct_destination "$images_pathmoving.jpg"
  Rename $images_path$correct_file $images_path$correct_destination
  Rename "$images_pathmoving.jpg" $images_path$correct_file

  exit:
FunctionEnd

Function MoveVictor9B
  StrCpy $faux_checksum "6537036"
  StrCpy $correct_destination "LT277.jpg"
  StrCpy $card_name "Victor VTR-9B"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveVictor9K
  StrCpy $faux_checksum "65045114"
  StrCpy $correct_destination "LT278.jpg"
  StrCpy $card_name "Victor VTR-9K"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveVictorSteinerDavion
  StrCpy $faux_checksum "68687228"
  StrCpy $correct_destination "LT279.jpg"
  StrCpy $card_name "Victor Steiner-Davion"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveWolfTrap
  StrCpy $faux_checksum "65810158"
  StrCpy $correct_destination "LT288.jpg"
  StrCpy $card_name "Wolf Trap WFT-1"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveWolfhound
  StrCpy $faux_checksum "6396228"
  StrCpy $correct_destination "LT289.jpg"
  StrCpy $card_name "Wolfhound WLF-2"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveWolfDragoon
  StrCpy $faux_checksum "67174147"
  StrCpy $correct_destination "LT290.jpg"
  StrCpy $card_name "Wolf Dragoons Pilot"

  Call FindRightFile
  Call ShuffleImages
FunctionEnd

Function MoveImages
  Call MoveVictor9B
  Call MoveVictor9K
  Call MoveVictorSteinerDavion
  Call MoveWolfTrap
  Call MoveWolfhound
  Call MoveWolfDragoon


  ; !insertmacro GetFileSize $INSTDIR\sets\setimages\Unlimited\LT288.jpg $0 $1
  ; !insertmacro GetLastUniqueByte $INSTDIR\sets\setimages\Unlimited\LT288.jpg $0 $2
  ; DetailPrint "288: $1 $2"
  ; !insertmacro GetFileSize $INSTDIR\sets\setimages\Unlimited\LT289.jpg $0 $1
  ; !insertmacro GetLastUniqueByte $INSTDIR\sets\setimages\Unlimited\LT289.jpg $0 $2
  ; DetailPrint "289: $1 $2"
  ; !insertmacro GetFileSize $INSTDIR\sets\setimages\Unlimited\LT290.jpg $0 $1
  ; !insertmacro GetLastUniqueByte $INSTDIR\sets\setimages\Unlimited\LT290.jpg $0 $2
  ; DetailPrint "290: $1 $2"
  done:
FunctionEnd

Function DeletePackDefinitions
  StrCpy $5 "$INSTDIR\packs\packdefinitions.txt"
  IfFileExists $5 delete_pack_definitions
  DetailPrint "Did not find packdefinitions.txt so it was not deleted."
  Goto exit

  delete_pack_definitions:
  Delete $5

  exit:
FunctionEnd

Section "Apply Patch"

  SectionIn RO

  IfFileExists $INSTDIR\plugininfo.txt PathGood

  DetailPrint "Could not find plugininfo.txt"
  MessageBox MB_OK "Directory does not appear to be a Lackey Plugin. No plugininfo.txt was found. Installer will not continue."
  Abort ; if $INSTDIR is not a plugin directory, don't let us install there

  PathGood:

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  StrCpy $images_path "$INSTDIR\sets\setimages\Unlimited\"

  Call MoveImages

  Call DeletePackDefinitions
  
  File /r include\*.*
  
  ; Write the installation path into the registry
  ; WriteRegStr HKLM Software\BattleTechPatch "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  ; WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2" "DisplayName" "NSIS Example2"
  ; WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2" "UninstallString" '"$INSTDIR\uninstall.exe"'
  ; WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2" "NoModify" 1
  ; WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2" "NoRepair" 1
  ; WriteUninstaller "uninstall.exe"
  
SectionEnd

;--------------------------------

; Uninstaller

;Section "Uninstall"
  
  ; Remove registry keys
  ; DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Example2"
  ; DeleteRegKey HKLM SOFTWARE\NSIS_Example2

  ; Remove files and uninstaller
  ; Delete $INSTDIR\example2.nsi
  ; Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  ; Delete "$SMPROGRAMS\Example2\*.*"

  ; Remove directories used
  ; RMDir "$SMPROGRAMS\Example2"
  ; RMDir "$INSTDIR"

;SectionEnd
