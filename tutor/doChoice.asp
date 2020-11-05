<%Response.Expires=-1
Server.ScriptTimeout=5000
%><!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("TId")) Then Response.Redirect("../error.asp?timeout")

opr=Request.QueryString("type")
If IsNull(opr) Then opr=0
If Not IsNumeric(opr) Then opr=0

stu_type=Request.Form("In_TEACHTYPE_ID")
spec_hash=Request.Form("In_SPECIALITY_HASH")
period_id=Request.Form("In_PERIOD_ID")

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(spec_hash)
FormGetToSafeRequest(period_id)
page_no=Request.Form("In_PAGE_NO")
page_size=Request.Form("In_PAGE_SIZE")

Dim bOpen:bOpen=tutclient.isOpenFor(Int(stu_type),SYS_OPR_CONFIRM) Or Session("Debug")
If Not bOpen Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">导师确认时间为&nbsp;<%=startdate%>&nbsp;至&nbsp;<%=enddate%>，当前还不是确认时间或系统设置为本专业禁止确认填报。</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

If IsEmpty(period_id) Or IsEmpty(stu_type) Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整或格式不正确！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim arr_id_turns,arr_apply_info
Dim id_turns,ids,selcount

selcount=0
ReDim arr_id_turns(Request.Form("sel").Count)
For i=1 To Request.Form("sel").Count
	arr_apply_info=Split(Request.Form("sel")(i),"|")
	If arr_apply_info(2)="0" Then	' 导师未确认该学生填报
		selcount=selcount+1
		arr_id_turns(selcount)=arr_apply_info(0)&"|"&arr_apply_info(1)
		If Len(id_turns) Then
			id_turns=id_turns&","
			ids=ids&","
		End If
		id_turns=id_turns&arr_id_turns(selcount)
		ids=ids&arr_apply_info(0)
	End If
Next
If Request.Form("sel").Count=0 Then
	showErrorPage "您未选择任何学生！", "提示"
End If
If selcount=0 Then
	showErrorPage "您无法对已确认的学生进行操作！", "提示"
End If

ConnectDb conn
sql=Format("SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID={0} AND TEACHTYPE_ID={1} AND PERIOD_ID={2} AND SPECIALITY_HASH={3}",_
	Session("tid"),stu_type,period_id,toSqlString(spec_hash))
Set rs=conn.Execute(sql)
If rs.EOF Then
	showErrorPage "您在所查询的学期没有招生名额！", "提示"
End If
recruit_id=rs("RECRUIT_ID")
CloseRs rs

Dim mail_id:mail_id=getTutorSystemMailIdByType(Now)
Select Case opr
Case 0	' 确认操作
	sql="SELECT RECRUIT_QUOTA,CONFIRMED_NUM FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruit_id
	Set rs=conn.Execute(sql)
	recruit_quota=rs(0)
	confirmed_count=rs(1)
	CloseRs rs
	
	If recruit_quota-confirmed_count-selcount<0 Then
		showErrorPage "所确认的学生数已超出设定的名额数！", "提示"
	End If
	confirmed_count=confirmed_count+selcount
	
	sql="EXEC spTutorClientAuditApply "&toSqlString(id_turns)&","&recruit_id&",1,NULL"
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行确认填报操作。"
	send_email = getSystemOption("send_accept_email", stu_type)
Case 1	' 退回操作
	withdraw_reason=Request.Form("reasontext")
	sql="EXEC spTutorClientAuditApply "&toSqlString(id_turns)&","&recruit_id&",0,"&toSqlString(withdraw_reason)
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行退回填报操作。"
	send_email = getSystemOption("send_withdraw_email", stu_type)
End Select

If send_email Then
	sql="SELECT TEACHERNAME,EMAIL FROM ViewTeacherInfo WHERE TEACHERID="&Session("Tid")
	Set rs=conn.Execute(sql)
	tutor_name=rs(0)
	tutor_email=rs(1)
	CloseRs rs
	sql="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,EMAIL,TUTOR_RECRUIT_STATUS FROM ViewStudentInfo WHERE STU_ID IN ("&ids&")"
	Set rs=conn.Execute(sql)
	Do While Not rs.EOF
		stu_name=rs(0)
		class_name=rs(1)
		spec_name=rs(2)
		stu_email=rs(3)
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

%><form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>">
	<input type="hidden" name="In_SPECIALITY_HASH" value="<%=spec_hash%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>">
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>