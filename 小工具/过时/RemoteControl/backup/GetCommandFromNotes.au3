		WinActivate("新建便笺 - Lotus Notes", "新建便笺")
		WinMenuSelectItem("新建便笺 - Lotus Notes", "新建便笺", "文件(&F)", "附加(&A)...")
		WinWait("创建附件", "查找范围(&I):", 60)
		ControlSend("创建附件", "查找范围(&I):", "[Class:Edit; Instance:1; ID:1152]", "E:\1.rar")
		Sleep(200)
		ControlSend("创建附件","查找范围(&I):", "[Class:Button: Instance:2; ID:1]", "{ENTER}")
		WinWaitClose("创建附件", "查找范围(&I):", 60)
		MsgBox(0, "debug", "done")
		