		WinActivate("�½���� - Lotus Notes", "�½����")
		WinMenuSelectItem("�½���� - Lotus Notes", "�½����", "�ļ�(&F)", "����(&A)...")
		WinWait("��������", "���ҷ�Χ(&I):", 60)
		ControlSend("��������", "���ҷ�Χ(&I):", "[Class:Edit; Instance:1; ID:1152]", "E:\1.rar")
		Sleep(200)
		ControlSend("��������","���ҷ�Χ(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
		WinWaitClose("��������", "���ҷ�Χ(&I):", 60)
		MsgBox(0, "debug", "done")
		