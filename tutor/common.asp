<!--#include file="../inc/global.inc"-->
<%
Function checkIfSystemOpen()
	Dim conn,rs,sql,result,bOpen
	Connect conn
	sql="SELECT TUT_STARTDATE,TUT_ENDDATE FROM SystemSettings WHERE USE_YEAR="&cur_year&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
	GetRecordSetNoLock conn,rs,sql,result
	bOpen=True
	If rs.EOF Then
		bOpen=False
	Else
		tut_startdate=rs(0)
		tut_enddate=rs(1)
		If DateDiff("d",tut_startdate,Now)<0 Or DateDiff("d",tut_enddate,Now)>0 Then
			bOpen=False
		End If
	End If
	CloseRs rs
	CloseConn conn
	checkIfSystemOpen=bOpen
End Function

Function getClientInfo(cli)
	Dim conn,rs,sql,result,i
	Connect conn
	sql="SELECT TUT_CLIENT_STATUS,TUT_STARTDATE,TUT_ENDDATE FROM SystemSettings WHERE USE_YEAR="&cur_year&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
	GetRecordSetNoLock conn,rs,sql,result
	If rs.EOF Then
		tutclient.SystemStatus=SYS_STATUS_CLOSED
	Else
		tutclient.SystemStatus=SYS_STATUS_OPEN
		cli.setClientStatus rs(0)
		For i=SYS_OPR_CONFIRM To SYS_OPR_CONFIRM
			cli.setOpentime i,SYS_OPENTIME_START,rs(2*i-1)
			cli.setOpentime i,SYS_OPENTIME_END,rs(2*i)
		Next
	End If
	CloseRs rs
	CloseConn conn
	getClientInfo=1
End Function

Function semesterList(ctlname,sel)	' 显示学期选择框
	Dim conn,sql,rs,result
	Connect conn
	sql="SELECT DISTINCT PERIOD_ID,PERIOD_NAME FROM ViewAvailableSemesterInfo"
	GetRecordSet conn,rs,sql,result
	%><select id="<%=ctlname%>" name="<%=ctlname%>"><option value="0">请选择</option><%
	Do While Not rs.EOF %>
	<option value="<%=rs("PERIOD_ID")%>"<% If sel=rs("PERIOD_ID") Then %> selected<% End If %>><%=rs("PERIOD_NAME")%></option><%
		rs.MoveNext()
	Loop
	CloseRs rs
	CloseConn conn
	%></select><%
End Function

Dim sem_info:sem_info=getCurrentSemester()
Dim cur_year:cur_year=sem_info(0)
Dim cur_semester:cur_semester=sem_info(1)
Dim cur_semester_name:cur_semester_name=sem_info(2)
Dim cur_period_id:cur_period_id=sem_info(3)

Dim tutclient:Set tutclient=New ClientInfo
tutclient.setOprTypeCount(SYS_TUT_OPRTYPE_COUNT)
getClientInfo(tutclient)
If tutclient.SystemStatus=SYS_STATUS_CLOSED And Session("Debug")=False Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">选导师系统未启用！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim startdate:startdate=tutclient.getOpentime(SYS_OPR_CONFIRM,SYS_OPENTIME_START)
Dim enddate:enddate=tutclient.getOpentime(SYS_OPR_CONFIRM,SYS_OPENTIME_END)
%>