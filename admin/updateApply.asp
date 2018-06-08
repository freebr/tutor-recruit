<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

stuType=Request.form("In_TEACHTYPE_ID")
spec_name=Request.form("In_SPECIALITY_NAME")
cur_period_id=Request.form("In_PERIOD_ID")
tutor_id=Request.form("In_TEACHER_ID")
apply_status=Request.form("apply_status")

FormGetToSafeRequest(stuType)
FormGetToSafeRequest(spec_name)
FormGetToSafeRequest(cur_period_id)
FormGetToSafeRequest(tutor_id)

PageNo=Request.Form("In_PageNo2")
PageSize=Request.Form("In_PageSize2")

If cur_period_id="" or stuType="" or tutor_id="" or spec_name="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整，请确认是否已选择导师和专业！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Connect conn
sql="SELECT RECRUIT_ID FROM ViewRecruitInfo WHERE TEACHER_ID="&tutor_id&" AND SPECIALITY_NAME="&toSqlString(spec_name)&" AND cur_period_id="&cur_period_id&" AND TEACHTYPE_ID="&stuType&" AND VALID=1"
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If
recruit_id=rs(0).Value
selcount=Request.Form("sel_turn").Count

sql=""
For i=1 To selcount
	arr=Split(Request.Form("sel_turn")(i),"|")
	stu_id=arr(0)
	turn_num=arr(1)
	sql2="SELECT STU_NAME,dbo.getTurnName(TURN_NUM) AS TURN_NAME,dbo.getTurnName("&turn_num&") AS TURN_NAME_SET FROM ApplyInfo A,ViewStudentInfo B WHERE A.STU_ID="&stu_id&" AND RECRUIT_ID="&recruit_id&" AND A.STU_ID=B.STU_ID"
	Set rs2=conn.Execute(sql2)
	If Not rs2.EOF Then
		errdesc="学生["&rs2(0)&"]的"&rs2(2)&"无法修改，因为"&rs2(1)&"已选择相同的导师和专业！":bError=True
		CloseRs rs2
		Exit For
	End If
	CloseRs rs2
	sql=sql&"spSetApplyInfo "&stu_id&","&cur_period_id&","&turn_num&","&tutor_id&","&recruit_id&","&apply_status&";"
Next
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
ElseIf Len(sql) Then
	conn.Execute sql
End If

CloseConn conn
CloseRs rs
%><form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=cur_period_id%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>