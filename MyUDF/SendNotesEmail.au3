#include <date.au3>
SendNotesMail("chen.xu8@zte.com.cn", "subject", "body", "", False)

Func SendNotesMail($recipient, $Subject, $bodytext, $attachment, $saveit)
       ;Start a $Session to notes
        $Session = ObjCreate("Notes.NotesSession")
       ;Get the sessions $UserName and then calculate the mail file name
        $UserName = $Session.UserName
        $MailDbName = StringLeft($UserName, 1) & StringRight($UserName, (StringLen($UserName) - StringInstr(1, $UserName, " "))) & ".nsf"
       ;Open the mail database in notes
        $Maildb = $Session.GETDATABASE("", $MailDbName)
        If $Maildb.IsOpen = 1 Then
           ;Already open for mail
        Else
            $Maildb.OPENMAIL()
        EndIf
       ;Set up the new mail document
        $MailDoc = $Maildb.CREATEDOCUMENT
        $MailDoc.Form = "Memo"
        $MailDoc.sendto = $recipient
        $MailDoc.Subject = $Subject
        $MailDoc.Body = $bodytext
        $MailDoc.SAVEMESSAGEONSEND = $saveit
       ;Set up the embedded $Object and $attachment and attach it
        If $attachment <> "" Then
            If FileExists(@ScriptDir & "\" & $attachment) Then
                $filename = $attachment
                $fullpath = @ScriptDir & "\" & $attachment
            ElseIf FileExists($attachment) Then
                $pos = StringInStr($attachment,"\",0,-1)
                $filename = StringTrimLeft($attachment,$pos)
                $fullpath = $attachment
            Else
                MsgBox(0,"LoNo Error","attachment not found")
                Exit
            EndIf
            $AttachME = $MailDoc.CREATERICHTEXTITEM($filename)
            $EmbedObj = $AttachME.EMBEDOBJECT(1454, "", $fullpath, $filename)
        ;$MailDoc.CREATERICHTEXTITEM($filename)
        EndIf
       ;Send the document
        $MailDoc.PostedDate = _Now();Gets the mail to appear in the sent items folder
        $MailDoc.SEND(0, $recipient)
        $Maildb = "NULL"
        $MailDoc = "NULL"
        $AttachME = "NULL"
        $Session = "NULL"
        $EmbedObj = "NULL"
EndFunc