<%Response.Expires=-1
Server.ScriptTimeout=5000
%><!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("TId")) Then Response.Redirect("../error.asp?timeout")

opr=Request.QueryString("type")
If IsNull(opr) Then opr=0
If Not IsNumeric(opr) Then opr=0

stuType=Request.Form("In_TEACHTYPE_ID")
spec_id=Request.Form("In_SPECIALITY_ID")
period_id=Request.Form("In_PERIOD_ID")

FormGetToSafeRequest(stuType)
FormGetToSafeRequest(spec_id)
FormGetToSafeRequest(period_id)
PageNo=Request.Form("In_PageNo")
PageSize=Request.Form("In_PageSize")

Dim bOpen:bOpen=tutclient.isOpenFor(Int(stuType),SYS_OPR_CONFIRM) Or Session("Debug")
If Not bOpen Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">导师确认时间为&nbsp;<%=startdate%>&nbsp;至&nbsp;<%=enddate%>，当前还不是确认时间或系统设置为本专业禁止确认填报。</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

If period_id="" or stuType="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整或格式不正确！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim ids,arrIds,selcount

selcount=0
ReDim arrIds(Request.Form("sel").Count)
For i=1 To Request.Form("sel").Count
	If Request.Form("s"&Request.Form("sel")(i))="0" Then
		selcount=selcount+1
		arrIds(selcount)=Request.Form("sel")(i)
		If Len(ids) Then ids=ids&","
		ids=ids&arrIds(selcount)
	End If
Next
If Request.Form("sel").Count=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您未选择任何学生！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If
If selcount=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您无法对已确认的学生进行操作！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Connect conn
sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND TEACHTYPE_ID="&stuType&" AND PERIOD_ID="&period_id&" AND SPECIALITY_ID="&spec_id
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If
tutor_id=Session("Tid")
recruit_id=rs("RECRUIT_ID").Value
CloseRs rs

Dim mail_id:mail_id=getTutorSystemMailIdByType(Now)
sql="SELECT TURN_NUM FROM SystemSettings WHERE USE_YEAR="&cur_year&" AND USE_SEMESTER="&cur_semester
GetRecordSetNoLock conn,rs,sql,result
turn_num=rs("TURN_NUM").Value
Select Case opr
Case 0	' 确认操作
	sql="SELECT RECRUIT_QUOTA,CONFIRMED_NUM FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruit_id
	Set rs=conn.Execute(sql)
	recruit_quota=rs(0).Value
	confirmed_count=rs(1).Value
	CloseRs rs
	
	If recruit_quota-confirmed_count-selcount<0 Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">所确认的学生数已超出设定的名额数！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End()
	End If
	confirmed_count=confirmed_count+selcount
	
	sql="EXEC spTutorClientAuditApply "&toSqlString(Request.Form("sel"))&","&recruit_id&","&
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行确认填报操作。"
Case 1	' 退回操作
	withdraw_reason=Request.Form("reasontext")
	sql=""
	For i=1 To selcount
		sql=sql&"EXEC spSetApplyInfo "&arrIds(i)&","&period_id&","&turn_num&","&tutor_id&","&recruit_id&",4,"&toSqlString(withdraw_reason)&";"
	Next
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行退回填报操作。"
End Select

If tutclient.IfSendMail Then
	sql="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL,TUTOR_RECRUIT_STATUS FROM ViewStudentInfo A "&_
	 		"LEFT JOIN ViewTeacherInfo B ON B.TEACHERID=A.TUTOR_ID WHERE STU_ID IN ("&ids&")"
	Set rs=conn.Execute(sql)
	Do While Not rs.EOF
		stu_name=rs(0).Value
		class_name=rs(1).Value
		spec_name=rs(2).Value
		stu_email=rs(3).Value
		tutor_name=rs(4).Value
		tutor_email=rs(5).Value
		fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,"",withdraw_reason)
		bSuccess=sendAnnouncementEmail(mail_id(opr+2),stu_email,fieldval)
		logtxt=logtxt0&"通知邮件发至["&stu_name&":"&stu_email&"]"
		If bSuccess Then
			logtxt=logtxt&"成功。"
		Else
			logtxt=logtxt&"失败。"
		End If
		WriteLog logtxt
		rs.MoveNext()
	Loop
	CloseRs rs
Else
	WriteLog logtxt0
End If
CloseConn conn

%><form method="post" action="choiceList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_SPECIALITY_ID" value="<%=spec_id%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PageNo" value="<%=PageNo%>">
	<input type="hidden" name="In_PageSize" value="<%=PageSize%>">
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>