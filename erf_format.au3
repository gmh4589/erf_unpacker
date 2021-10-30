#include <array.au3>

$sFileName = FileOpenDialog ('Select file', " ", 'Aurora Engine ERF Files (*.erf)|All files (*.*)', 1+4)
	If @error = 1 then Exit
$sFolderName = FileSelectFolder ('Select folder to save files', '')
	If @error = 1 then Exit

$iFile = FileOpen($sFileName, 16)
FileSetPos ($iFile, 4, 0)
$iVer = FileRead($iFile, 4)
ProgressOn('', 'Wait, files is unpacking...', '', (@DesktopWidth/2)-150, (@DesktopHeight/2)-62, 18)
	If $iVer = '0x56312E30' Then
			FileSetPos ($iFile, 16, 0)
				$iFileCount = FileRead ($iFile, 4)
				$iFileCount = Dec(StringTrimLeft (_Endian($iFileCount), 2))
			FileSetPos ($iFile, 24, 0)
				$iOff2Lst = FileRead ($iFile, 4)
				$iOff2Lst = Dec(StringTrimLeft (_Endian($iOff2Lst), 2))
			FileSetPos ($iFile, 28, 0)
				$iERFLst = FileRead ($iFile, 4)
				$iERFLst = Dec(StringTrimLeft (_Endian($iERFLst), 2))
			FileSetPos ($iFile, $iOff2Lst, 0)
			Local $FileNameArray[0], $FileExtArray[0]
				For $i = 0 to $iFileCount
					$RName = FileRead ($iFile, 16)
					_ArrayAdd($FileNameArray, $RName)
					FileSetPos ($iFile, 4, 1)
					$fEXT = FileRead ($iFile, 4)
					If $fEXT = '0xBF0B0000' Then
						$fEXT = '.dds'
					Else
						$fEXT = '.dat'
					EndIf
					_ArrayAdd($FileExtArray, $fEXT)
				Next
			FileSetPos ($iFile, $iERFLst, 0)
				For $j = 1 to $iFileCount
					$data1 = FileRead ($iFile, 4)
						$data1 = Dec(StringTrimLeft (_Endian($data1), 2))
					$data2 = FileRead ($iFile, 4)
						$data2 = Dec(StringTrimLeft (_Endian($data2), 2))
					$c = FileGetPos($iFile)
					FileSetPos ($iFile, $data1, 0)
					$Data = FileRead ($iFile, $data2)
					$RName = StringReplace($FileNameArray[$j], '00', '')
					$fName = BinaryToString($RName) & $FileExtArray[$j]
					$iNewFile = FileOpen ($sFolderName & '\' & $fName, 26)
					FileWrite ($iNewFile, $Data)
					FileSetPos ($iFile, $c, 0)
					ProgressSet((100/$iFileCount) * $j, 'Saved: ' & @TAB & $fName & @CRLF & $j & "/" & $iFileCount)
				Next
	Else
		FileSetPos($iFile, 8, 0)
		$iVer = FileRead($iFile, 4)
			If $iVer = '0x56003200' Then
					FileSetPos ($iFile, 16, 0)
						$iFileCount = FileRead ($iFile, 4)
						$iFileCount = Dec(StringTrimLeft (_Endian($iFileCount), 2))
					FileSetPos ($iFile, 32, 0)
					For $i = 0 to $iFileCount
						$RName = FileRead ($iFile, 64)
						$iOffs = FileRead ($iFile, 4)
							$iOffs = Dec(StringTrimLeft (_Endian($iOffs), 2))
						$iLong = FileRead ($iFile, 4)
							$iLong = Dec(StringTrimLeft (_Endian($iLong), 2))
						$c = FileGetPos($iFile)
						FileSetPos ($iFile, $iOffs, 0)
						$Data = FileRead ($iFile, $iLong)
						$RName = StringReplace($RName, '00', '')
						$fName = BinaryToString($RName)
						$iNewFile = FileOpen ($sFolderName & '\' & $fName, 26)
						FileWrite ($iNewFile, $Data)
						FileSetPos ($iFile, $c, 0)
						ProgressSet((100/$iFileCount) * $i, 'Saved: ' & @TAB & $fName & @CRLF & $i & "/" & $iFileCount)								
					Next
			ElseIf $iVer = '0x56003300' Then
				MsgBox($MB_SYSTEMMODAL, $tMessage, "Version 3 while not supported!")
			Else
				MsgBox($MB_SYSTEMMODAL, $tMessage, $tNoGame & "Aurora Engine")
				
			EndIf
	EndIf
FileClose ($iFile)
ProgressSet(100, 'Done!')
ProgressOff()	
MsgBox (0, 'Message', 'Done!', 3)

Func _Endian($Binary)
	$Len = StringLen($Binary)
		;MsgBox (0, '', $Binary)
	If $Len < 6 or Mod($Len, 2) = 1 or StringIsXDigit(StringTrimLeft($Binary, 2)) = 0 Then
		MsgBox (0, '', $Binary & " не является 16-ричным числом!")
		Return
	EndIf
	
	$BinaryArray = StringRegExp($Binary, '\N\N', 3)
	$a = UBound($BinaryArray) - 1
	$txt = FileOpen (@TempDir & '\bindata.txt', 10)
	
		For $i = $a to 1 Step -1
			FileWrite ($txt, $BinaryArray[$i])
		Next
	FileClose ($txt)
	Return ('0x' & FileReadLine (@TempDir & '\bindata.txt', 1))
EndFunc
