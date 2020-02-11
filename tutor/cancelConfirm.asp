<%If IsEmpty(Session("Tuser")) Then Response.Redirect("../error.asp?timeout")%>
<!--#include file="../inc/db.asp"-->
<%
'接收参数
object=Request.Form("In_TEACHTYPE_ID")
Speciality_Id=Request.Form("In_Speciality_Id")
period_id=Request.Form("In_PERIOD_ID")

FormGetToSafeRequest(object)
FormGetToSafeRequest(Speciality_Id)
FormGetToSafeRequest(period_id)
page_no=Request.Form("In_PAGE_NO")
page_size=Request.Form("In_PAGE_SIZE")

If period_id="" or object="" Then
	Response.write "<CENTER><FONT color=red SIZE=""4"">条件丢失</FONT>"
	Response.write "</CENTER>"
	Response.end
End If

Connect conn

sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND TEACHTYPE_ID="&object&" AND PERIOD_ID="&period_id
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
Else
	recruitID=rs("RECRUIT_ID")
End If

sql=""
For i=1 To Request.Form("sel").Count
	sql=sql&"UPDATE STUDENT_INFO SET TUTOR_RECRUIT_STATUS=2,WRITEPRIVILEGETAGSTRING=REPLACE(WRITEPRIVILEGETAGSTRING,'SA8,',''),READPRIVILEGETAGSTRING=REPLACE(READPRIVILEGETAGSTRING,'SA8,','') WHERE STU_ID="&Request.Form("sel")(i)&vbNewLine
Next
If Len(sql) Then conn.Execute sql
sql="UPDATE TUTOR_RECRUIT_INFO SET IsConfirmed=0 WHERE ID="&recruitID
conn.Execute sql
CloseRs rs
CloseConn conn
%><form method="post" action="chooseList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_Speciality_Id" value="<%=Speciality_Id%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>">
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
</form>
<script type="text/javascript">
	alert("操作完成");
	document.forms[0].submit();
</script>