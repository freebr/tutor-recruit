<%
'=========================================
' 硕士选导师系统全局成员定义文件
' 2018-04-20
'=========================================

' 选导师系统客户端开放信息访问器类
Class ClientInfo
	Private opentime_start(),opentime_end()
	Private m_client_status()
	Private m_systemstatus
	Private m_opr_type_count

	Private m_show_tutor_quota_student
	Private m_show_tutor_quota_tutor
	Private m_send_accept_email
	Private m_send_withdraw_email

	Function setOprTypeCount(count)
		m_opr_type_count=count
		ReDim opentime_start(count)
		ReDim opentime_end(count)
		ReDim m_client_status(SYS_STUTYPE_COUNT,count)
	End Function
	Function getOpentime(Opr,TimeType)
		If TimeType=SYS_OPENTIME_START Then
			getOpentime=opentime_start(Opr)
		ElseIf TimeType=SYS_OPENTIME_END Then
			getOpentime=opentime_end(Opr)
		End If
	End Function
	Function setOpentime(Opr,TimeType,ByVal Value)
		If IsNull(Value) Then Value=0
		If TimeType=SYS_OPENTIME_START Then
			opentime_start(Opr)=Value
		ElseIf TimeType=SYS_OPENTIME_END Then
			opentime_end(Opr)=Value
		End If
		setOpentime=1
	End Function
	Function getClientStatus(StuType,Opr)
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
	Function setClientStatus(val)
		Dim arr,i,j
		arr=Split(val,",")
		For i=1 To SYS_STUTYPE_COUNT
			For j=1 To m_opr_type_count
				m_client_status(i,j)=arr(m_opr_type_count*(i-1)+j)
			Next
		Next
	End Function
	Function isOpenFor(StuType,Opr)
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
		isOpenFor=m_client_status(i,Opr)="1" And DateDiff("s",opentime_start(Opr),Now)>=0 And DateDiff("s",opentime_end(Opr),Now)<=0
	End Function
	Property Get SystemStatus()
		SystemStatus=m_systemstatus
	End Property
	Property Let SystemStatus(val)
		m_systemstatus=val
	End Property
End Class

Function hasPrivilege(pArr,privilege)
	If IsEmpty(pArr) Then 
		hasPrivilege=False
		Exit Function
	End If
	pArr=split(pArr,",")
	For i=0 To Ubound(pArr)-1
		If pArr(i)=privilege Then
      hasPrivilege=True
      Exit Function
	  End If
	Next
	hasPrivilege=False
End Function

Function baseUrl()
	baseUrl = "/TutorRecruit/"
End Function

Function getCurrentSemester()
	' 返回当前学期信息
	Dim start_year,cur_semester,semester_name,period_id
	Dim arr(3)
	If Month(Now)>=9 Or Month(Now)=1 Then
		If Month(Now)>=9 Then
			start_year=Year(Now)
		Else
			start_year=Year(Now)-1
		End If
		cur_semester=1
		semester_name="上"
	Else
		start_year=Year(Now)-1
		cur_semester=2
		semester_name="下"
	End If
	period_id=start_year&cur_semester
	arr(0)=start_year
	arr(1)=cur_semester
	arr(2)=semester_name
	arr(3)=period_id
	getCurrentSemester=arr
End Function

// 注册系统选项
Dim dictSystemOptions:Set dictSystemOptions = Server.CreateObject("Scripting.Dictionary")
dictSystemOptions.Add "show_tutor_quota_student",	Array("学生端显示导师名额信息（指导名额、报名人数、已确认人数、剩余名额）", 0)
dictSystemOptions.Add "show_tutor_quota_tutor",		Array("导师端显示导师名额信息（指导名额、剩余名额）", 0)
dictSystemOptions.Add "send_accept_email",			Array("导师确认填报时，向学生发送通知邮件", 0)
dictSystemOptions.Add "send_withdraw_email",		Array("导师退回填报时，向学生发送通知邮件", 0)

// 获取系统选项值（没有则使用默认值）
Function getSystemOption(name,stu_type_id)
	If Not dictSystemOptions.Exists(name) Then Exit Function
	Dim conn,rs,sql,result
	Connect conn
	sql="EXEC spGetSystemOption ?,?,?"
	Set rs=ExecQuery(conn,sql,Array(CmdParam("Name",adVarChar,adParamInput,50,name),_
		CmdParam("StuTypeId",adInteger,adParamInput,4,stu_type_id),_
		CmdParam("DefaultValue",adInteger,adParamInput,4,dictSystemOptions.Item(name)(1))),result)
	getSystemOption=rs(0).Value
	CloseRs rs
	CloseConn conn
End Function

// 注册脚本别名
Dim dictScripts:Set dictScripts = Server.CreateObject("Scripting.Dictionary")
dictScripts.Add "admin",	"admin"
dictScripts.Add "common",	Array("utils", "query")
dictScripts.Add "jeasyui",	Array("jeasyui/jquery.easyui.min", "jeasyui/easyloader")
dictScripts.Add "jquery",	"jquery-1.12.4.min"
dictScripts.Add "student",	"student"
dictScripts.Add "tutor",	"tutor"

// 注册样式表别名
Dim dictStylesheets:Set dictStylesheets = Server.CreateObject("Scripting.Dictionary")
dictStylesheets.Add "global",	"global"
dictStylesheets.Add "jeasyui",	Array("jeasyui/themes/icon", "jeasyui/themes/bootstrap/easyui")

Function useScript(arr)
	If Not IsArray(arr) Then arr=Array(arr)
	Dim i
	For i=0 To UBound(arr)
		Dim alias:alias=arr(i)
		If Not dictScripts.Exists(alias) Then
%><script type="text/javascript">console.warn("useScript(): 脚本别名'<%=alias%>'未注册。");</script><%
		Else
			Dim items:items=dictScripts.Item(alias)
			If Not IsArray(items) Then
%><script type="text/javascript" src="<%=baseUrl()%>scripts/<%=items%>.js"></script><%
			Else
				Dim j
				For j=0 To UBound(items)
%><script type="text/javascript" src="<%=baseUrl()%>scripts/<%=items(j)%>.js"></script><%
				Next
			End If
		End If
	Next
End Function

Function useStylesheet(arr)
	If Not IsArray(arr) Then arr=Array(arr)
	Dim i
	For i=0 To UBound(arr)
		Dim alias:alias=arr(i)
		If Not dictStylesheets.Exists(alias) Then
%><script type="text/javascript">console.warn("useStylesheet(): 样式表别名'<%=alias%>'未注册。");</script><%
		Else
			Dim items:items=dictStylesheets.Item(alias)
			If Not IsArray(items) Then
%><link href="<%=baseUrl()%>css/<%=items%>.css" rel="stylesheet" type="text/css" /><%
			Else
				Dim j
				For j=0 To UBound(items)
%><link href="<%=baseUrl()%>css/<%=items(j)%>.css" rel="stylesheet" type="text/css" /><%
				Next
			End If
		End If
	Next
End Function

' 当前系统支持的学生类型数目
Const SYS_STUTYPE_COUNT=4
' 学生端可执行的操作数目（选择导师）
Const SYS_STU_OPRTYPE_COUNT=1
' 导师端可执行的操作数目（确认填报）
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

' 禁止缓存，仅在需要客户端重新请求 JS/CSS/HTML 等静态文件时使用
Response.CacheControl="no-cache"
Response.Charset="utf-8"
%>