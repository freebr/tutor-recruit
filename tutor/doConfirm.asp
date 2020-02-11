<%Response.Expires=-1
Server.ScriptTimeout=5000
%>
<!--#include file="../inc/db.asp"-->
<!--#include File="common.asp"-->
<%If IsEmpty(Session("Tuser")) Then Response.Redirect("../error.asp?timeout")

'接收参数
opr=Request.QueryString("type")
If IsNull(opr) Then opr=0
If Not IsNumeric(opr) Then opr=0

object=Request.Form("In_TEACHTYPE_ID")
Speciality_Name=Request.Form("In_SPECIALITY_NAME")
period_id=Request.Form("In_PERIOD_ID")

FormGetToSafeRequest(object)
FormGetToSafeRequest(Speciality_Name)
FormGetToSafeRequest(period_id)
page_no=Request.Form("In_PAGE_NO")
page_size=Request.Form("In_PAGE_SIZE")

Dim tut_startdate,tut_enddate,bOpen
bOpen=tutclient.isOpenFor(Int(object),SYS_OPR_CONFIRM)
If Not checkIfSystemOpen() Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">导师确认时间为&nbsp;<%=tut_startdate%>&nbsp;至&nbsp;<%=tut_enddate%>，当前还不是确认时间或系统设置为本专业不允许对填报进行确认。</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

If period_id="" or object="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整或格式不正确！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

Dim ids,arr

selcount=0
ReDim arr(Request.Form("sel").Count)
For i=1 To Request.Form("sel").Count
	If Request.Form("s"&Request.Form("sel")(i))="0" Then
		selcount=selcount+1
		arr(selcount)=Request.Form("sel")(i)
		If Len(ids) Then ids=ids&","
		ids=ids&arr(selcount)
	End If
Next
If Request.Form("sel").Count=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您未选择任何学生！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If
If selcount=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您无法对已确认的学生进行操作！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

Connect conn
sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND TEACHTYPE_ID="&object&" AND PERIOD_ID="&period_id&" AND SPECIALITY_NAME="&toSqlString(Speciality_Name)
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If
recruitID=rs("RECRUIT_ID")
CloseRs rs

mail_id=getTutorSystemMailIdByType(Now)
Select Case opr
Case 0	' 确认操作
	sql="SELECT RECRUIT_QUOTA,CONFIRMED_NUM FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruitID
	Set rs=conn.Execute(sql)
	recruitQuota=rs(0)
	confirmedNum=rs(1)
	
	If recruitQuota-confirmedNum-selcount<0 Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">所确认的学生数已超出设定的名额数！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	End If
	CloseRs rs
	sql="UPDATE STUDENT_INFO SET TUTOR_RECRUIT_STATUS=3,WRITEPRIVILEGETAGSTRING=WRITEPRIVILEGETAGSTRING+'SA8,',READPRIVILEGETAGSTRING=READPRIVILEGETAGSTRING+'SA8,' WHERE STU_ID IN ("&ids&");"
	sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=3 WHERE STU_ID IN ("&ids&")"
	conn.Execute sql
	sql="UPDATE TUTOR_RECRUIT_INFO SET IsConfirmed=1 WHERE ID="&recruitID
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行确认填报操作"
Case 1	' 退回操作
	withdraw_reason=Request.Form("reasontext")
	sql="UPDATE STUDENT_INFO SET TUTOR_RECRUIT_STATUS=4 WHERE TUTOR_RECRUIT_STATUS=2 AND STU_ID IN ("&ids&");"
	sql=sql&"UPDATE TUTOR_WITHDRAW_INFO SET VALID=0 WHERE STU_ID IN ("&ids&");"
	sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=4,TUTOR_REPLY="&toSqlString(withdraw_reason)&" WHERE STU_ID IN ("&ids&");"
	For i=1 To selcount
		sql=sql&"INSERT INTO TUTOR_WITHDRAW_INFO VALUES("&arr(i)&","&toSqlString(withdraw_reason)&",1);"
	Next
	conn.Execute sql
	logtxt0="教师["&Session("Tname")&"]在选导师系统执行退回填报操作"
End Select

If opr=0 Or opr=1 Then
	sql="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL,TUTOR_RECRUIT_STATUS FROM VIEW_STUDENT_INFO_NEW A "&_
	 		"LEFT JOIN TEACHER_INFO B ON B.TEACHERID=A.TUTOR_ID WHERE STU_ID IN ("&ids&")"
	Set rs=conn.Execute(sql)
	Do While Not rs.EOF
		stu_name=rs(0)
		class_name=rs(1)
		spec_name=rs(2)
		stu_email=rs(3)
		tutor_name=rs(4)
		tutor_email=rs(5)
		fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,withdraw_reason)
		bSuccess=sendAnnouncementEmail(mail_id(opr+2),stu_email,fieldval)
		logtxt=logtxt0&"，通知邮件发至["&stu_name&":"&stu_email&"]"
		If bSuccess Then
			logtxt=logtxt&"成功。"
		Else
			logtxt=logtxt&"失败。"
		End If
		WriteLogForTutorSystem logtxt
		rs.MoveNext()
	Loop
	CloseRs rs
End If
CloseConn conn

%><form method="post" action="choiceList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_SPECIALITY_NAME" value="<%=Speciality_Name%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>">
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
</form>
<script type="text/javascript">
	alert("操作完成");
	document.forms[0].submit();
</script>