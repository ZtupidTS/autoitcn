$srcBase = 'http://image5.av-girl.info/beauty/asian_beauty/Yumi_Sugimoto'
$folderBase = 'E:\Downloads\Images\'
$folderName = '杉本有美(Yumi_Sugimoto)'
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
				MsgBox(266304, '图库助手', $folderName & ' 下载完成！！')
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



;~ http://image4.topidol.com/beauty/asian_beauty/Sayuki_Matsumoto			松本さゆき Sayuki_Matsumoto		d
;~ http://image4.topidol.com/beauty/asian_beauty/Kaori_Ishii				石井香织(Kaori_Ishii)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Toda_Erika					户田惠梨香(Toda_Erika)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Miho_Yoshioka				吉冈美穗(Miho_Yoshioka)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Momoko_komachi				小町桃子(Momoko_komachi)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Nonami_Takizawa			滝沢乃南(Nonami_Takizawa)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Ayaka_Komatsu				小松彩夏(Ayaka_Komatsu)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Yumi_Sugimoto				杉本有美(Yumi_Sugimoto)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Rina_Akiyama				秋山莉奈(Rina_Akiyama)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Natsuko_Tatsumi			辰巳奈都子(Natsuko_Tatsumi)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Nao_Nagasawa				长泽奈央(Nao_Nagasawa)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Mizuki_Horii				堀井美月(Mizuki_Horii)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Yuika_Hotta				堀田ゆい夏(Yuika_Hotta)			***
;~ http://image4.topidol.com/beauty/asian_beauty/Tani_Momoko				谷桃子(Tani_Momoko)				d
;~ http://image4.topidol.com/beauty/asian_beauty/Aya_Kiguchi				木口亜矢(Aya_Kiguchi)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Yamasaki_Mami				山崎真実(Yamasaki_Mami)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Miu_Nakamura				仲村みう(Miu_Nakamura)			d
;~ http://image4.topidol.com/beauty/asian_beauty/Mami_Matsuyama				松山まみ(Mami_Matsuyama)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Mikie_Hara					原干惠(Mikie_hara)				d
;~ http://image4.topidol.com/beauty/asian_beauty/Yuzuki_Aikawa				愛川ゆず季(Yuzuki_Aikawa)		d
;~ http://image4.topidol.com/beauty/asian_beauty/Anna_Kawamura				川村あんな(Anna_Kawamura)
;~ http://image4.topidol.com/beauty/asian_beauty/Yukie_Kawamura				川村ゆきえ(Yukie_Kawamura)
;~ http://image4.topidol.com/beauty/asian_beauty/Hiroko_Sato				佐藤宽子(Hiroko_Sato)
;~ http://image4.topidol.com/beauty/asian_beauty/Saaya_Irie					入江纱绫(Saaya_Irie)
;~ http://image4.topidol.com/beauty/asian_beauty/Hitomi_Aizawa				相泽仁美(Hitomi_Aizawa)
;~ http://image4.topidol.com/beauty/asian_beauty/Sayaka_Ando				安藤沙耶香(Sayaka_Ando)
;~ http://image4.topidol.com/beauty/asian_beauty/Aki_Hoshino				星野亚希(Aki_Hoshino)
;~ http://image4.topidol.com/beauty/asian_beauty/Akane_Suzuki				铃木茜(Akane_Suzuki)
;~ http://image4.topidol.com/beauty/asian_beauty/Azusa_Yamamoto				山本梓(Azusa_Yamamoto)


