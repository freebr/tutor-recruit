<!--#include file="../inc/global.inc"-->
<%
arr=getCurrentSemester()
curyear=arr(0)
cur_semester=arr(1)

Function checkIfSystemOpen()
	Dim conn,rs,sql,result,bOpen
	Connect conn
	sql="SELECT TUT_STARTDATE,TUT_ENDDATE FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&curyear&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
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
	Dim sem_info,curyear,cur_semester
	sem_info=getCurrentSemester()
	curyear=sem_info(0)
	cur_semester=sem_info(1)
	Connect conn
	sql="SELECT TUT_CLIENT_STATUS,TUT_STARTDATE,TUT_ENDDATE,IF_SEND_MAIL FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&curyear&" AND USE_SEMESTER="&cur_semester&" AND VALID=1"
	GetRecordSetNoLock conn,rs,sql,result
	If rs.EOF Then
		tutclient.SystemStatus=SYS_STATUS_CLOSED
		tutclient.IfSendMail=False
	Else
		tutclient.SystemStatus=SYS_STATUS_OPEN
		tutclient.IfSendMail=rs("IF_SEND_MAIL")
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

Dim tutclient:Set tutclient=New ClientInfo
tutclient.setOprTypeCount(SYS_TUT_OPRTYPE_COUNT)
getClientInfo(tutclient)
If tutclient.SystemStatus=SYS_STATUS_CLOSED And Session("Debug")=False Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">选导师系统未启用！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If

Dim startdate,enddate
startdate=tutclient.getOpentime(SYS_OPR_CONFIRM,SYS_OPENTIME_START)
enddate=tutclient.getOpentime(SYS_OPR_CONFIRM,SYS_OPENTIME_END)
%>