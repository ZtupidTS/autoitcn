;zip functions using x-zip.dll

;Get the dll here
;http://xstandard.com/printer-friendly.asp?id=C9891D8A-5390-44ED-BC60-2267ED6763A7
;quick and dirty example of zip functionality in  autoit.

dim $oMyError
; Initialize SvenP 's  error handler
$oMyError = ObjEvent("AutoIt.Error","MyErrFunc")

;Show version as proof object created.
$objZip = ObjCreate("XStandard.Zip")
MsgBox(0,"Version","Version "&$objZip.Version)
$objZip = ""

;Add/Create archive
$objZip = objCreate("XStandard.Zip")
;               .Pack(Source file, Dest archive) 
$objZip.Pack ("c:\reportcard1.jpg","C:\Temp\Report.zip")
$objZip.Pack ("c:\reportcard.bmp","C:\Temp\Report.zip")
$objZip = ""

; get archive contents
$message =""
$objZip = ObjCreate("XStandard.Zip")
;                              .Contents(Zip.file.to.get.contents.of)
For $objItem In $objZip.Contents("C:\Temp\archive.zip")
      $message &= $objItem.Path & $objItem.Name & @CRLF
Next

MsgBox(0,"Contents",$message)
$objZip = ""
$objItem = ""

;Extract archive to folder
$objZip = ObjCreate("XStandard.Zip")
;            .UnPack(  Zip file , Destination)
$objZip.UnPack ("C:\Temp\archive.zip", "C:\Temp\archive")
$objZip = ""

;Extract archive using wildcards
$objZip = ObjCreate("XStandard.Zip")
;        .UnPack (Zip Archive, Dest "*.Whatever")
$objZip.UnPack ("C:\Temp\archive.zip", "C:\Temp\wild", "*.jpg")
$objZip = ""

Exit
; these functs not tested but should work as written

;Archive with different compression levels
$objZip = ObjCreate("XStandard.Zip")
;        .Pack (Source file, Dest Archive, Keep path (0=false), compression level)
$objZip.Pack ("C:\x-zip.doc", "C:\Temp\archive.zip",0 , 9)
$objZip.Pack ("C:\sky.jpg", "C:\Temp\archive.zip", 0, 1)
$objZip = ""

;Create with default path
$objZip = ObjCreate("XStandard.Zip")
$objZip.Pack ("C:\x-zip.doc", "C:\Temp\archive.zip", 1)
$objZip.Pack ("C:\sky.jpg", "C:\Temp\archive.zip", 1)
$objZip = ""

;Create with custom paths (tested and working)
$objZip = ObjCreate("XStandard.Zip")
;        .Pack (Source file, Dest Archive, Keep path (1=TRUE), Path or default if left blank)
$objZip.Pack ("C:\x-zip.doc", "C:\Temp\archive.zip", 1, "files/word")
$objZip.Pack ("C:\sky.jpg", "C:\Temp\archive.zip", 1, "files/images")
$objZip = ""

;Create archive using wildcards
$objZip = ObjCreate("XStandard.Zip")
$objZip.Pack ("C:\*.jpg", "C:\Temp\images.zip")
$objZip = ""

;Remove file from archive
$objZip = ObjCreate("XStandard.Zip")
$objZip.Delete ("sky.jpg", "C:\Temp\images.zip")
$objZip = ""

;Move file within archive
$objZip = ObjCreate("XStandard.Zip")
$objZip.Move ("files/images/sky.jpg", "images/sky.jpg", "C:\Temp\images.zip")
$objZip = ""

;Rename file in archive
$objZip = ObjCreate("XStandard.Zip")
$objZip.Move ("files/images/sky.jpg", "files/images/sky1.jpg", "C:\Temp\images.zip")
$objZip = ""

Func MyErrFunc()
  $HexNumber=hex($oMyError.number,8)
  Msgbox(0,"AutoItCOM Test","We intercepted a COM Error !"       & @CRLF  & @CRLF & _
             "err.description is: "    & @TAB & $oMyError.description    & @CRLF & _
             "err.windescription:"     & @TAB & $oMyError.windescription & @CRLF & _
             "err.number is: "         & @TAB & $HexNumber              & @CRLF & _
             "err.lastdllerror is: "   & @TAB & $oMyError.lastdllerror   & @CRLF & _
             "err.scriptline is: "     & @TAB & $oMyError.scriptline     & @CRLF & _
             "err.source is: "         & @TAB & $oMyError.source         & @CRLF & _
             "err.helpfile is: "       & @TAB & $oMyError.helpfile       & @CRLF & _
             "err.helpcontext is: "    & @TAB & $oMyError.helpcontext _
            )
  SetError(1); to check for after this function returns
Endfunc