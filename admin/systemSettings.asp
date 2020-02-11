﻿<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%Response.Charset="utf-8"%>
<!--#include file="../inc/db.asp"-->
<!--#include file="../inc/setEditor.asp"-->
<!--#include file="../inc/ckeditor/ckeditor.asp"-->
<!--#include file="../inc/ckfinder/ckfinder.asp"-->
<!--#include file="../inc/global.inc"-->
<%Response.Expires=-1
If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
curstep=Request.QueryString("step")
If Len(curstep)=0 Or Not IsNumeric(curstep) Then curstep="1"	
sem_info=getCurrentSemester()
Dim arrMailId(4),arrMailSubject
Dim arrStuOprFlag,arrStuOprName
Dim arrTutOprFlag,arrTutOprName
Dim arrStuTypeId,arrStuType
Dim tutor_startdate,tutor_enddate
Dim stu_startdate,stu_enddate
Dim tut_clientstatus,stu_clientstatus
arrTutOprFlag=Array("","CONFIRM")
arrTutOprName=Array("","确认填报")
arrStuOprFlag=Array("","CHOOSE")
arrStuOprName=Array("","选择导师")
arrStuTypeId=Array("",5,6,7,9)
arrStuType=Array("","ME","MBA","EMBA","MPAcc")
arrMailSubject=Array("","学员选导师确认通知","导师确认填报通知","导师退回填报通知","学员选导师填报状态变更通知")
If curstep="1" Then
	ReDim tut_clientstatus(SYS_TUT_OPRTYPE_COUNT*SYS_STUTYPE_COUNT)
	ReDim stu_clientstatus(SYS_STU_OPRTYPE_COUNT*SYS_STUTYPE_COUNT)
	Connect conn
	sql="SELECT * FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
	GetRecordSetNoLock conn,rs,sql,result
	If result=0 Then	' 本学期无系统设置
		stu_startdate=Date
		stu_enddate=Date+7
		tut_startdate=Date+7
		tut_enddate=Date+9
		turn_num=1
		isValid=False
	Else	' 本学期有系统设置
		bSet=True
		stu_startdate=rs("STU_STARTDATE")
		stu_enddate=rs("STU_ENDDATE")
		tut_startdate=rs("TUT_STARTDATE")
		tut_enddate=rs("TUT_ENDDATE")
		stu_clientstatus=Split(rs("STU_CLIENT_STATUS"),",")
		tut_clientstatus=Split(rs("TUT_CLIENT_STATUS"),",")
		turn_num=rs("TURN_NUM")
		For i=1 To 4
			arrMailId(i)=rs("MAIL_"&i)
		Next
		isValid=rs("VALID")
	End If
	CloseRs rs
	sql="SELECT * FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&(sem_info(0)-1)&" AND USE_SEMESTER="&sem_info(1)
	GetRecordSetNoLock conn,rs,sql,result
	If result>0 Then
		bLastSet=True
		last_stu_startdate=rs("STU_STARTDATE")
		last_stu_enddate=rs("STU_ENDDATE")
		last_tut_startdate=rs("TUT_STARTDATE")
		last_tut_enddate=rs("TUT_ENDDATE")
	End If
	If Not bSet Then
		sql="SELECT TOP 1 * FROM TUTOR_SYSTEM_SETTINGS ORDER BY ID DESC"
		GetRecordSetNoLock conn,rs,sql,result
		If result Then ' 显示最新学期的邮件内容
			For i=1 To UBound(arrMailId)
				arrMailId(i)=rs("MAIL_"&i)
			Next
		End If
	End If
	CloseRs rs
	CloseConn conn
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript(Array("query","utils")) %>
<script type="text/javascript" src="../scripts/admin.js"></script>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b><%=sem_info(0)%>-<%=sem_info(0)+1%>年度<%=sem_info(2)%>学期硕士生选导师系统设置</b><br><%
	If Not bSet Then
%><span style="color:red;font-weight:bold">(请先设置开放时间等属性，方可开放系统)</span><%
	End If %></font>
<form id="fmOpentime" id="fmOpentime" method="post" action="?step=2" onsubmit="return chkForm()">
<input type="hidden" name="In_TEACHTYPE_ID" value="0">
<input type="hidden" name="In_PERIOD_ID" value="<%=sem_info(3)%>">
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite">
<td align="left"><%
	Select Case Request("ok")
	Case "0"
%><span style="color:red">更新设置时发生错误，请检查设置参数是否正确</span><br/><%
	Case "1"
%><span style="color:red">设置成功</span><br/><%
	End Select
%></td></tr>
<tr bgcolor="ghostwhite">
<td align="center">当前系统状态：<%
	If isValid Then
%>开放<br/><input type="button" name="btnOpenSystem" value="关闭选导师系统" onclick="this.disabled=true;location.href='setSystemStatus.asp?open=1'" /><%
	Else
%>关闭<br/><input type="button" name="btnOpenSystem" value="开放选导师系统" <% If Not bSet Then %>disabled <% Else %>onclick="this.disabled=true;location.href='setSystemStatus.asp?open=0'" <% End If %>/><%
	End If %><input type="button" value="del" onclick="location.href='setSystemStatus.asp?open=101'" style="display:none" /></td></tr>
</td></tr>
<tr bgcolor="ghostwhite">
<td align="center"><p>当前是第&nbsp;<input type="text" name="turn_num" id="turn_num" value="<%=turn_num%>" size="5" style="text-align:center" />&nbsp;批
&nbsp;<input type="submit" value="增加批次" onclick="document.all.turn_num.value='<%=turn_num+1%>'" /><br />
<input type="submit" value="导出本批次双选名单" onclick="document.all.fmOpentime.action='exportChoiceList.asp?fn=<%=sem_info(3)%>_<%=turn_num%>&turn=<%=turn_num%>&exportall=1'" />
&nbsp;<input type="button" name="viewexportfiles" value="查看以往批次双选名单" onclick="window.open('/admin/tutorAssign/export/spec')" /></p>
<p><table width="680" cellpadding="0" cellspacing="0" border="0">
<tr bgcolor="ghostwhite"><td align="center" colspan="3">导师端上传通道开放时间和开放对象：</td></tr>
<%
	For i=1 To SYS_TUT_OPRTYPE_COUNT
%><tr bgcolor="ghostwhite">
<td align="right"><%=arrTutOprName(i)%>：</td>
<td align="center"><input type="text" name="tut_startdate" id="tut_startdate" value="<%=tut_startdate%>" size="19" style="text-align:center" />
<img style="cursor:pointer" src="../images/calendar.gif" onclick="showCalendar('tut_startdate','<%=tut_startdate%>')" title="打开日历">&nbsp;至&nbsp;
<input type="text" name="tut_enddate" id="tut_enddate" value="<%=tut_enddate%>" size="19" style="text-align:center" />
<img style="cursor:pointer" src="../images/calendar.gif" onclick="showCalendar('tut_enddate','<%=tut_enddate%>')" title="打开日历"></td>
<td align="center"><%
		For j=1 To SYS_STUTYPE_COUNT
			k=SYS_TUT_OPRTYPE_COUNT*(j-1)+i
			If tut_clientstatus(k)="1" Then
				checkflag="checked=""true"" "
			Else
				checkflag=vbNullString
			End If
%>&emsp;<label for="tut_clientstatus<%=k%>"><input type="checkbox" name="tut_clientstatus<%=k%>" id="tut_clientstatus<%=k%>" <%=checkflag%>/><%=arrStuType(j)%></label><%
		Next
%></td></tr><%
	Next %></table></p>
<p><table width="680" cellpadding="0" cellspacing="0" border="0">
<tr bgcolor="ghostwhite"><td align="center" colspan="3">学生端上传通道开放时间和开放对象：</td></tr>
<%
	For i=1 To SYS_STU_OPRTYPE_COUNT
%><tr bgcolor="ghostwhite">
<td align="right"><%=arrStuOprName(i)%>：</td>
<td align="center"><input type="text" name="stu_startdate" id="stu_startdate" value="<%=stu_startdate%>" size="19" style="text-align:center" />
<img style="cursor:pointer" src="../images/calendar.gif" onclick="showCalendar('stu_startdate','<%=stu_startdate%>')" title="打开日历">&nbsp;至&nbsp;
<input type="text" name="stu_enddate" id="stu_enddate" value="<%=stu_enddate%>" size="19" style="text-align:center" />
<img style="cursor:pointer" src="../images/calendar.gif" onclick="showCalendar('stu_enddate','<%=stu_enddate%>')" title="打开日历"></td>
<td align="center"><%
		For j=1 To SYS_STUTYPE_COUNT
			k=SYS_STU_OPRTYPE_COUNT*(j-1)+i
			If stu_clientstatus(k)="1" Then
				checkflag="checked=""true"" "
			Else
				checkflag=vbNullString
			End If
%>&emsp;<label for="stu_clientstatus<%=k%>"><input type="checkbox" name="stu_clientstatus<%=k%>" id="stu_clientstatus<%=k%>" <%=checkflag%>/><%=arrStuType(j)%></label><%
		Next
%></td></tr><%
	Next %></table></p></td></tr>
<tr bgcolor="ghostwhite"><td colspan=4><p align="center"><input type="submit" value="更改设置"><%
	If bLastSet Then
%><br/><span>注：<%=sem_info(0)-1%>-<%=sem_info(0)%>年度<%=sem_info(2)%>学期的选导师系统开放时间：<br/>
学生端：&nbsp;<%=last_stu_startdate%>&nbsp;至&nbsp;<%=last_stu_enddate%><br/>教师端：&nbsp;<%=last_tut_startdate%>&nbsp;至&nbsp;<%=last_tut_enddate%></span><%
End If %></p></td></tr>
<tr bgcolor="ghostwhite"><td align="left"><font style="font-weight:bold">通知邮件内容设置</font></td></tr>
<tr bgcolor="ghostwhite"><td align="left"><%
	For i=1 To 4
%><input name="mail" id="mail<%=i%>" type="radio" onclick="switchMailContent(<%=i%>)" /><label for="mail<%=i%>"><%=arrMailSubject(i)%></label><%
	Next
%><br />
<span id="mailtip">字段符号:<br/>$stuname - 学生姓名,$stuclass - 学生班级,$stuspec - 所选专业,$stumail - 学生邮箱,$reason - 退回原因(仅限导师退回填报通知)<br/>$tutorname - 导师姓名,$tutormail - 导师邮箱,$stat - 更改后的状态(仅限学员选导师填报状态变更通知)</span></td></tr>
<tr bgcolor="ghostwhite">
<td align="left"><%
	For i=1 To 4
%><div id="divmailcontent<%=i%>" style="display:none"><% SetEditorWithName "mailcontent"&i,getEmailTemplateContent(arrMailId(i)),170 %></div><%
	Next %>
</td></tr>
<tr bgcolor="ghostwhite"><td align="center"><input type="submit" value="更改设置"></td></tr>
<tr bgcolor="ghostwhite"><td align="left"><font style="font-weight:bold">导师指导名额刷新</font></td></tr>
<tr bgcolor="ghostwhite"><td align="left">
<p>请选择学生类型<%
	For i=1 To SYS_STUTYPE_COUNT
%>&emsp;<label for="stu_updatequota<%=k%>"><input type="checkbox" name="stu_updatequota" id="stu_updatequota<%=k%>" value="<%=arrStuTypeId(i)%>" /><%=arrStuType(i)%></label><%
	Next
%></p><p>提示：点击下面的按钮，可按导师名单中的信息设定以上学生类型的指导名额。</p></td></tr>
<tr bgcolor="ghostwhite"><td align="center"><input type="button" id="btnUpdateQuota" value="刷新指导名额"></td></tr>
</table></form>
</center><script type="text/javascript">
	document.all.btnUpdateQuota.onclick=function() {
		this.form.action='updateQuota.asp?updatesel=1';
		this.form.submit();
	}
</script>
</body>
</html><%
Else
	Dim mail_content(4),fieldlist
	stu_startdate=Request.Form("stu_startdate")
	stu_enddate=Request.Form("stu_enddate")
	tut_startdate=Request.Form("tut_startdate")
	tut_enddate=Request.Form("tut_enddate")
	stu_clientstatus="0"
	tut_clientstatus="0"
	For i=1 To SYS_STU_OPRTYPE_COUNT*SYS_STUTYPE_COUNT
		stu_clientstatus=stu_clientstatus&","
		If Request.Form("stu_clientstatus"&i)="on" Then
			stu_clientstatus=stu_clientstatus&"1"
		Else
			stu_clientstatus=stu_clientstatus&"0"
		End If
	Next
	For i=1 To SYS_TUT_OPRTYPE_COUNT*SYS_STUTYPE_COUNT
		tut_clientstatus=tut_clientstatus&","
		If Request.Form("tut_clientstatus"&i)="on" Then
			tut_clientstatus=tut_clientstatus&"1"
		Else
			tut_clientstatus=tut_clientstatus&"0"
		End If
	Next
	
	turn_num=Request.Form("turn_num")
	If Not IsNumeric(turn_num) Then
		turn_num=1
	ElseIf turn_num<1 Then
		turn_num=1
	End If
	turn_num=Int(turn_num)
	For i=1 To 4
		arrMailId(i)=0
		mail_content(i)=Request.Form("mailcontent"&i)
	Next	
	fieldlist="$stuname,$stuclass,$stuspec,$stumail,$tutorname,$tutormail,$stat,$reason"
	
	bTurnChanged=False
	Connect conn
	sql="SELECT * FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
	GetRecordSet conn,rs,sql,result
	On Error Resume Next
	If result=0 Then
		rs.AddNew()
		rs("USE_YEAR")=sem_info(0)
		rs("USE_SEMESTER")=sem_info(1)
	Else
		If rs("turn_num")<>turn_num Then
			prev_turn_num=rs("turn_num")
			bTurnChanged=True
		End If
	End If
	rs("STU_STARTDATE")=stu_startdate
	rs("STU_ENDDATE")=stu_enddate
	rs("TUT_STARTDATE")=tut_startdate
	rs("TUT_ENDDATE")=tut_enddate
	rs("STU_CLIENT_STATUS")=stu_clientstatus
	rs("TUT_CLIENT_STATUS")=tut_clientstatus
	rs("TURN_NUM")=turn_num
	For i=1 To UBound(arrMailSubject)
		arrMailId(i)=rs("MAIL_"&i)
		If result=0 Or IsNull(arrMailId(i)) Then arrMailId(i)=0
	Next
	rs.Update()
	
	If Err.Number=0 Then ok=1 Else ok=0
	On Error GoTo 0
	
	sql="UPDATE TUTOR_SYSTEM_SETTINGS SET "
	For i=1 To 4
		template_name=sem_info(0)&"-"&(sem_info(0)+1)&"年度"&sem_info(2)&"学期"&arrMailSubject(i)
		arrMailId(i)=updateEmailTemplate(arrMailId(i),template_name,arrMailSubject(i),mail_content(i),fieldlist)
		sql=sql&"MAIL_"&i&"="&arrMailId(i)
		If i<4 Then sql=sql&","
	Next
	sql=sql&" WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
	conn.Execute sql
	
	CloseRs rs
	CloseConn conn
%><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"></head>
<body><form id="ret" method="post" action="?step=1"><input type="hidden" name="ok" value="<%=ok%>" />
<input type="hidden" name="In_TEACHTYPE_ID" value="0">
<input type="hidden" name="In_PERIOD_ID" value="<%=sem_info(3)%>">
</form>
<script type="text/javascript">
<% If bTurnChanged Then
%>document.all.ret.action="exportChoiceList.asp?fn=<%=sem_info(3)%>_<%=prev_turn_num%>&turn=<%=prev_turn_num%>&exportall=1&ret=systemSettings.asp?ok=1";
<% End If
%>document.all.ret.submit();<%
%></script></body></html><%
End If
%>