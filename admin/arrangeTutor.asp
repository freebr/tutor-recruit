<%Response.Expires=-1%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

stu_type=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")
page_no=Request.Form("In_PAGE_NO2")
page_size=Request.Form("In_PAGE_SIZE2")
tutor_id=Request.Form("In_TEACHER_ID")
spec_hash=Request.Form("In_SPECIALITY_HASH")

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(period_id)
FormGetToSafeRequest(tutor_id)
FormGetToSafeRequest(spec_hash)

If period_id="" Or stu_type="" Or tutor_id="" Or spec_hash="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整，请确认是否已选择导师和专业！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Connect conn
sql="SELECT RECRUIT_ID,RECRUIT_QUOTA,CONFIRMED_NUM FROM ViewRecruitInfo WHERE TEACHER_ID="&tutor_id&" AND SPECIALITY_HASH="&toSqlString(spec_hash)&" AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&stu_type
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
	sql=sql&"EXEC spSetApplyInfo "&stu_id&","&period_id&","&turn_num&","&tutor_id&","&recruit_id&",3;"
Next
If Len(sql) Then conn.Execute sql

CloseConn conn
CloseRs rs
%>
<form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>" />
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>" />
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>" />
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>" />
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>