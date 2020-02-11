<%

' 选导师系统客户端开放信息访问器类
Class ClientInfo
	Private opentime_start(),opentime_end()
	Private m_client_status()
	Private m_systemstatus
	Public Function setOprTypeCount(count)
		ReDim opentime_start(count)
		ReDim opentime_end(count)
		ReDim m_client_status(SYS_STUTYPE_COUNT,count)
	End Function
	Public Function getOpentime(Opr,TimeType)
		If TimeType=SYS_OPENTIME_START Then
			getOpentime=opentime_start(Opr)
		ElseIf TimeType=SYS_OPENTIME_END Then
			getOpentime=opentime_end(Opr)
		End If
	End Function
	Public Function setOpentime(Opr,TimeType,ByVal Value)
		If IsNull(Value) Then Value=0
		If TimeType=SYS_OPENTIME_START Then
			opentime_start(Opr)=Value
		ElseIf TimeType=SYS_OPENTIME_END Then
			opentime_end(Opr)=Value
		End If
		setOpentime=1
	End Function
	Public Function getClientStatus(StuType,Opr)
		Dim i
		Select Case StuType
		Case SYS_STUTYPE_ME:i=1
		Case SYS_STUTYPE_MBA:i=2
		Case SYS_STUTYPE_EMBA:i=3
		Case SYS_STUTYPE_MPACC:i=4
		Case Else
			getClientStatus=0
			Exit Function
		End Select
		getClientStatus=m_client_status(i,Opr)
	End Function
	Public Function setClientStatus(val)
		Dim arr,i,j
		arr=Split(val,",")
		For i=1 To SYS_STUTYPE_COUNT
			For j=1 To SYS_OPRTYPE_COUNT
				m_client_status(i,j)=arr(SYS_OPRTYPE_COUNT*i+j-SYS_OPRTYPE_COUNT)
			Next
		Next
	End Function
	Public Function isOpenFor(StuType,Opr)
		Dim i
		Select Case StuType
		Case SYS_STUTYPE_ME:i=1
		Case SYS_STUTYPE_MBA:i=2
		Case SYS_STUTYPE_EMBA:i=3
		Case SYS_STUTYPE_MPACC:i=4
		Case Else
			isOpenFor=False
			Exit Function
		End Select
		isOpenFor=m_client_status(i,Opr)="1" And DateDiff("d",opentime_start(Opr),Now)>=0 And DateDiff("d",opentime_end(Opr),Now)<=0
	End Function
	Public Property Get SystemStatus()
		SystemStatus=m_systemstatus
	End Property
	Public Property Let SystemStatus(val)
		m_systemstatus=val
	End Property
End Class

Const SYS_STUTYPE_COUNT=4
Const SYS_STU_OPRTYPE_COUNT=1
Const SYS_TUT_OPRTYPE_COUNT=1

' 学生端
Const SYS_OPR_CHOOSETUTOR = 1
' 导师端
Const SYS_OPR_CONFIRM = 1
Const SYS_OPENTIME_START = 1
Const SYS_OPENTIME_END = 2
Const SYS_STUTYPE_ME = 5
Const SYS_STUTYPE_MBA = 6
Const SYS_STUTYPE_EMBA = 7
Const SYS_STUTYPE_MPACC = 9
Const SYS_STATUS_CLOSED = 0
Const SYS_STATUS_OPEN = 1
Const SYS_STATUS_DEBUG = 2
%>