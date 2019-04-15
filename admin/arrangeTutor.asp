<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

stuType=Request.form("In_TEACHTYPE_ID2")
cur_period_id=Request.form("In_PERIOD_ID2")
tutor_id=Request.form("In_TEACHER_ID")
spec_id=Request.form("In_SPECIALITY_ID")

FormGetToSafeRequest(stuType)
FormGetToSafeRequest(spec_id)
FormGetToSafeRequest(cur_period_id)
FormGetToSafeRequest(tutor_id)

If cur_period_id="" Or stuType="" Or tutor_id="" Or spec_id="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整，请确认是否已选择导师和专业！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

PageNo=Request.Form("In_PageNo2")
PageSize=Request.Form("In_PageSize2")

Connect conn
sql="SELECT RECRUIT_ID,RECRUIT_QUOTA,CONFIRMED_NUM FROM ViewRecruitInfo WHERE TEACHER_ID="&tutor_id&" AND SPECIALITY_ID="&spec_id&" AND PERIOD_ID="&cur_period_id&" AND TEACHTYPE_ID="&stuType
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If
recruit_id=rs(0)
recruitQuota=rs(1)
confirmedNum=rs(2)
CloseRs rs

selcount=Request.Form("sel").Count
If recruitQuota-confirmedNum-selcount<0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">所设置的学生数超过导师设置的名额数(<%=recruitQuota%>)！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

' 按第一志愿导师设置
sql=""
turn_num=1
For i=1 To selcount
	stu_id=Request.Form("sel")(i)
	sql=sql&"EXEC spSetApplyInfo "&stu_id&","&cur_period_id&","&turn_num&","&tutor_id&","&recruit_id&",3;"
Next
If Len(sql) Then conn.Execute sql

CloseConn conn
CloseRs rs
%>
<form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=cur_period_id%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>