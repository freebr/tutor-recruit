﻿<!--#include file="../inc/global.inc"-->
<%Response.Expires=-1
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
open=Request.QueryString("open")
If Len(open)=0 Or Not IsNumeric(open) Then open="0"
sem_info=getCurrentSemester()

ConnectDb conn
wherestr=" WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
If open="0" Then
	sql="SELECT * FROM SystemSettings"&wherestr
	GetRecordSetNoLock conn,rs,sql,result
	CloseRs rs
	If result=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">未设置系统开放时间！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	End If
	
	sql="SELECT VALID FROM SystemSettings"&wherestr
	GetRecordSet conn,rs,sql,result
	If rs("VALID") Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">系统已经开放！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	Else
		' 开放系统
		rs("VALID")=True
		rs.Update()
		CloseRs rs
	End If
ElseIf open="1" Then
	' 关闭系统
	sql="UPDATE SystemSettings SET VALID=0"&wherestr
	conn.Execute sql
ElseIf open="101" Then
	sql="SELECT VALID FROM SystemSettings"&wherestr
	GetRecordSet conn,rs,sql,result
	If rs("VALID") Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">系统正在运行，不能删除数据！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	End If
	sql="DELETE FROM RecruitInfo"
	conn.Execute sql
End If
CloseConn conn
%><form id="ret" method="post" action="systemSettings.asp?step=1"><input type="hidden" name="ok" value="1" /></form>
<script type="text/javascript">document.all.ret.submit();</script>