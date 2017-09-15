<%Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
'接收参数
object=Request.form("In_TEACHTYPE_ID2")
spec_name=Request.form("In_SPECIALITY_NAME")
period_id=Request.form("In_PERIOD_ID2")
tutor_id=Request.form("In_TEACHER_ID")

FormGetToSafeRequest(object)
FormGetToSafeRequest(spec_name)
FormGetToSafeRequest(period_id)
FormGetToSafeRequest(tutor_id)

PageNo=Request.Form("In_PageNo2")
PageSize=Request.Form("In_PageSize2")

If period_id="" or object="" or tutor_id="" or spec_name="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整，请确认是否已选择导师和专业！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

Connect conn
sql="SELECT RECRUIT_ID,RECRUIT_QUOTA,CONFIRMED_NUM FROM VIEW_TUTOR_RECRUIT_INFO WHERE TEACHER_ID="&tutor_id&" AND SPECIALITY_NAME="&toSqlString(spec_name)&" AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&object&" AND VALID=1"
'Response.Write sql
'Response.End
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If
recruit_id=rs(0)
recruitQuota=rs(1)
confirmedNum=rs(2)
CloseRs rs

selcount=Request.Form("sel").Count
If recruitQuota-confirmedNum-selcount<0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">所设置的学生数超过导师设置的名额数(<%=recruitQuota%>)！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

sql=""
turn_num=1
For i=1 To selcount
	stu_id=Request.Form("sel")(i)
	sql=sql&"UPDATE STUDENT_INFO SET TUTOR_ID="&tutor_id&",TUTOR_RECRUIT_ID="&recruit_id&_
	",TUTOR_RECRUIT_STATUS=3,WRITEPRIVILEGETAGSTRING=dbo.addPrivilege(WRITEPRIVILEGETAGSTRING,'SA8',''),READPRIVILEGETAGSTRING=dbo.addPrivilege(READPRIVILEGETAGSTRING,'SA8','') WHERE STU_ID="&stu_id&";"
	sql=sql&"IF EXISTS(SELECT STU_ID FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&")"&_
			"UPDATE TUTOR_STUDENT_APPLY_INFO SET TUTOR_ID="&tutor_id&",RECRUIT_ID="&recruit_id&",TURN_NUM="&turn_num&",APPLY_TIME='"&Now&"',APPLY_STATUS=3,TUTOR_REPLY_TIME='"&Now&"' WHERE STU_ID="&stu_id&_
			" ELSE INSERT INTO TUTOR_STUDENT_APPLY_INFO (STU_ID,TUTOR_ID,RECRUIT_ID,PERIOD_ID,TURN_NUM,APPLY_TIME,APPLY_STATUS,TUTOR_REPLY_TIME) VALUES("&stu_id&","&tutor_id&","&recruit_id&","&period_id&","&turn_num&",'"&Now&"',3,'"&Now&"');"
Next
If Len(sql) Then conn.Execute sql

CloseConn conn
CloseRs rs
%>
<form method="post" action="chosenList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>