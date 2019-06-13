<%
Function checkIfProfileFilledIn()
	Dim conn,rs,sql,i,ret
	Connect conn
	sql="SELECT BIRTHDAY,Native_City,Self_Tel,Before_Unit,EMAIL,DUTY,THESIS_TOPIC,PERSONAL_RESUME,EXPERIENCES,OCCU_PLAN FROM ViewStudentInfo WHERE STU_ID="&Session("Stuid")
	Set rs=conn.Execute(sql)
	ret=True
	For i=0 To rs.Fields.Count-1
		If Len(rs(i))=0 Or IsNull(rs(i)) Then
			ret=False
			Exit For
		End If
	Next
	CloseRs rs
	CloseConn conn
	checkIfProfileFilledIn=ret
End Function

Function getSystemStatus()
	Dim arr,conn,rs,sql,result
	arr=getCurrentSemester()
	cur_year=arr(0)
	cur_semester=arr(1)
	Connect conn
	sql="SELECT STU_STARTDATE,STU_ENDDATE FROM SystemSettings WHERE USE_YEAR="&cur_year&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
	GetRecordSetNoLock conn,rs,sql,result
	If rs.EOF Then
		getSystemStatus=0
	Else
		startdate=rs(0)
		enddate=rs(1)
		If DateDiff("d",startdate,Now)<0 Or DateDiff("d",enddate,Now)>0 Then
			getSystemStatus=1
		Else
			getSystemStatus=2
		End If
	End If
	CloseRs rs
	CloseConn conn
End Function

Function getClientInfo(cli)
	Dim conn,rs,sql,result,i
	Connect conn
	sql="SELECT STU_CLIENT_STATUS,STU_STARTDATE,STU_ENDDATE FROM SystemSettings WHERE USE_YEAR="&cur_year&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
	GetRecordSetNoLock conn,rs,sql,result
	If rs.EOF Then
		stuclient.SystemStatus=SYS_STATUS_CLOSED
	Else
		stuclient.SystemStatus=SYS_STATUS_OPEN
		cli.setClientStatus rs(0)
		For i=SYS_OPR_CHOOSETUTOR To SYS_OPR_CHOOSETUTOR
			cli.setOpentime i,SYS_OPENTIME_START,rs(2*i-1)
			cli.setOpentime i,SYS_OPENTIME_END,rs(2*i)
		Next
	End If
	CloseRs rs
	CloseConn conn
	getClientInfo=1
End Function

If Not hasPrivilege(Session("writeprivileges"),"SA6") And Not hasPrivilege(Session("readprivileges"),"SA6") _
	 And Not hasPrivilege(Session("writeprivileges"),"SA7") And Not hasPrivilege(Session("readprivileges"),"SA7") Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您没有权限！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim sem_info:sem_info=getCurrentSemester()
Dim cur_year:cur_year=sem_info(0)
Dim cur_semester:cur_semester=sem_info(1)
Dim cur_semester_name:cur_semester_name=sem_info(2)
Dim cur_period_id:cur_period_id=sem_info(3)

Dim stuclient:Set stuclient=New ClientInfo
stuclient.setOprTypeCount(SYS_STU_OPRTYPE_COUNT)
getClientInfo(stuclient)
If stuclient.SystemStatus=SYS_STATUS_CLOSED And Session("Debug")=False Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">选导师系统未启用！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim stu_type:stu_type=Session("StuType")
Dim opr:opr=SYS_OPR_CHOOSETUTOR
Dim bSystemOpen:bSystemOpen=stuclient.isOpenFor(stu_type,opr) Or Session("Debug")
Dim startdate:startdate=stuclient.getOpentime(opr,SYS_OPENTIME_START)
Dim enddate:enddate=stuclient.getOpentime(opr,SYS_OPENTIME_END)
Dim arrTurnName:arrTurnName=Array("","第一志愿","第二志愿","第三志愿")
%>