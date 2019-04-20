<%Response.Expires=-1
Server.ScriptTimeout=5000
%><!--#include file="../inc/db.asp"-->
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

Dim ids,arr_ids,arr_apply_info,selcount

selcount=0
ReDim arr_ids(Request.Form("sel").Count)
For i=1 To Request.Form("sel").Count
	arr_apply_info=Split(Request.Form("sel")(i),"|")
	If arr_apply_info(2)="0" Then	' 导师未确认该学生填报
		selcount=selcount+1
		arr_ids(selcount)=arr_apply_info(0)&"|"&arr_apply_info(1)
		If Len(ids) Then ids=ids&","
		ids=ids&arr_ids(selcount)
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
sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND TEACHTYPE_ID="&stu_type&" AND PERIOD_ID="&period_id&" AND SPECIALITY_HASH='"&spec_hash&"'"
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	CloseRs rs
	CloseConn conn
	Response.End()
End If
recruit_id=rs("RECRUIT_ID").Value
CloseRs rs

Dim mail_id:mail_id=getTutorSystemMailIdByType(Now)
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
	
	sql="EXEC spTutorClientAuditApply "&toSqlString(ids)&","&recruit_id&",1,NULL"
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行确认填报操作。"
	send_email = getSystemOption("send_accept_email", stu_type)
Case 1	' 退回操作
	withdraw_reason=Request.Form("reasontext")
	sql="EXEC spTutorClientAuditApply "&toSqlString(ids)&","&recruit_id&",0,"&toSqlString(withdraw_reason)
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行退回填报操作。"
	send_email = getSystemOption("send_withdraw_email", stu_type)
End Select

If send_email Then
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