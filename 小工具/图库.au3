$srcBase = 'http://image5.av-girl.info/beauty/asian_beauty/Yumi_Sugimoto'
$folderBase = 'E:\Downloads\Images\'
$folderName = 'ɼ������(Yumi_Sugimoto)'
_downloadGirl($srcBase, $folderBase, $folderName)

Func _downloadGirl($srcBase, $folderBase, $folderName)
	DirCreate($folderBase & $folderName)
	$i = 18
	$j = 0
	While True
		While True
			$j += 1
			If $i > 1 Then
				If _download($srcBase & '_' & $i & '/' & _getFileName($j) & '.jpg', _
						$folderBase & $folderName & '\' & _getFileName($i) & '_' & _getFileName($j) & '.jpg') Then ContinueLoop
			Else
				If _download($srcBase & '/' & _getFileName($j) & '.jpg', _
						$folderBase & $folderName & '\' & _getFileName($i) & '_' & _getFileName($j) & '.jpg') Then ContinueLoop
			EndIf
			If  $j == 1 Then
				MsgBox(266304, 'ͼ������', $folderName & ' ������ɣ���')
				Return
			Else
				ExitLoop
			EndIf
		WEnd
		$i += 1
		$j = 0
	WEnd
EndFunc   ;==>_downloadGirl

Func _download($url, $save, $retry = 3)
	For $i = 1 To $retry
		InetGet($url, $save, 0, 1)
		$j = 1
		While @InetGetActive
			Sleep(50)
			If $j >= 1000 Then
				ExitLoop
			EndIf
			$j += 1
		WEnd
		If @InetGetBytesRead > 0 And $j < 1000 Then
			ConsoleWrite($url & '		' & @InetGetBytesRead & @CRLF)
			Return True
		EndIf
	Next
	FileDelete($save)
	Return False
EndFunc   ;==>_download

Func _getFileName($num)
	If $num < 10 Then Return '00' & $num
	If $num < 100 Then Return '0' & $num
	Return $num
EndFunc   ;==>_getFileName



;~ http://image4.topidol.com/beauty/asian_beauty/Sayuki_Matsumoto			�ɱ����椭 Sayuki_Matsumoto		d
;~ http://image4.topidol.com/beauty/asian_beauty/Kaori_Ishii				ʯ����֯(Kaori_Ishii)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Toda_Erika					���������(Toda_Erika)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Miho_Yoshioka				��������(Miho_Yoshioka)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Momoko_komachi				С�����(Momoko_komachi)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Nonami_Takizawa			���g����(Nonami_Takizawa)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Ayaka_Komatsu				С�ɲ���(Ayaka_Komatsu)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Yumi_Sugimoto				ɼ������(Yumi_Sugimoto)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Rina_Akiyama				��ɽ����(Rina_Akiyama)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Natsuko_Tatsumi			�����ζ���(Natsuko_Tatsumi)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Nao_Nagasawa				��������(Nao_Nagasawa)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Mizuki_Horii				ܥ������(Mizuki_Horii)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Yuika_Hotta				ܥ��椤��(Yuika_Hotta)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Tani_Momoko				������(Tani_Momoko)				d
;~ http://image4.topidol.com/beauty/asian_beauty/Aya_Kiguchi				ľ�ځ�ʸ(Aya_Kiguchi)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Yamasaki_Mami				ɽ����g(Yamasaki_Mami)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Miu_Nakamura				�ٴ�ߤ�(Miu_Nakamura)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Mami_Matsuyama				��ɽ�ޤ�(Mami_Matsuyama)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Mikie_Hara					ԭ�ɻ�(Mikie_hara)				d
;~ http://image4.topidol.com/beauty/asian_beauty/Yuzuki_Aikawa				�۴��椺��(Yuzuki_Aikawa)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Anna_Kawamura				���夢���(Anna_Kawamura)
;~ http://image4.topidol.com/beauty/asian_beauty/Yukie_Kawamura				����椭��(Yukie_Kawamura)
;~ http://image4.topidol.com/beauty/asian_beauty/Hiroko_Sato				���ٿ���(Hiroko_Sato)
;~ http://image4.topidol.com/beauty/asian_beauty/Saaya_Irie					�뽭ɴ�(Saaya_Irie)
;~ http://image4.topidol.com/beauty/asian_beauty/Hitomi_Aizawa				��������(Hitomi_Aizawa)
;~ http://image4.topidol.com/beauty/asian_beauty/Sayaka_Ando				����ɳҮ��(Sayaka_Ando)
;~ http://image4.topidol.com/beauty/asian_beauty/Aki_Hoshino				��Ұ��ϣ(Aki_Hoshino)
;~ http://image4.topidol.com/beauty/asian_beauty/Akane_Suzuki				��ľ��(Akane_Suzuki)
;~ http://image4.topidol.com/beauty/asian_beauty/Azusa_Yamamoto				ɽ����(Azusa_Yamamoto)


