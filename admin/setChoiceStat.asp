<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
stat=Request.QueryString("stat")
If stat="" Then stat=0
object=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter2")
FormGetToSafeRequest(stat)
FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

page_no=Request.Form("In_PAGE_NO")
page_size=Request.Form("In_PAGE_SIZE")
If period_id="" or object="" Then
	Response.write "<CENTER><FONT color=red SIZE=""4"">条件丢失</FONT>"
	Response.write "</CENTER>"
	Response.end
End If

mail_id=getTutorSystemMailIdByType(Now)
Connect conn
Dim arr
ReDim arr(Request.Form("sel").Count,4)
For i=1 To Request.Form("sel").Count
	stu_id=Request.Form("sel")(i)
	sql2="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL FROM VIEW_STUDENT_INFO_NEW A "&_
	 		 "LEFT JOIN TEACHER_INFO B ON B.TEACHERID=A.TUTOR_ID WHERE STU_ID="&stu_id
	Set rs=conn.Execute(sql2)
	If Not rs.EOF Then
		stu_name=rs(0)
		Select Case stat
		Case 0
			stat_text="未填报状态"
		Case 1
			stat_text="未确认填报状态"
		Case 2
			stat_text="导师未确认状态"
		End Select
		class_name=rs(1)
		spec_name=rs(2)
		stu_email=rs(3)
		tutor_name=rs(4)
		tutor_email=rs(5)
	End If
	
	sql=sql&"UPDATE STUDENT_INFO SET TUTOR_RECRUIT_STATUS="&stat
	If stat=0 Then
		sql=sql&",TUTOR_ID=0,TUTOR_RECRUIT_ID=0"
	End If
	sql=sql&",WRITEPRIVILEGETAGSTRING=REPLACE(WRITEPRIVILEGETAGSTRING,'SA8,',''),READPRIVILEGETAGSTRING=REPLACE(READPRIVILEGETAGSTRING,'SA8,','') WHERE STU_ID="&stu_id&";"
	sql=sql&"DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&";"
	
	fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,stat_text)
	bSuccess=sendAnnouncementEmail(mail_id(4),stu_email,fieldval)
	logtxt="行政人员["&Session("name")&"]在选导师系统执行学生填报状态变更操作["&stat_text&"]，通知邮件发至["&stu_name&":"&stu_email&"]"
	If bSuccess Then
		logtxt=logtxt&"成功。"
	Else
		logtxt=logtxt&"失败。"
	End If
	WriteLogForTutorSystem logtxt
	CloseRs rs
Next
If Len(sql) Then conn.Execute sql

CloseRs rs
CloseConn conn
%>
<form method="post" action="chosenList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>">
	<input type="hidden" name="In_PAGE_NO" value=<%=page_no%>>
	<input type="hidden" name="In_PAGE_SIZE" value=<%=page_size%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>