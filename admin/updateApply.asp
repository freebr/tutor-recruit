<%Response.Expires=-1%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

stu_type=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")
finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("In_PAGE_NO2")
page_size=Request.Form("In_PAGE_SIZE2")
tutor_id=Request.Form("In_TEACHER_ID")
spec_hash=Request.Form("In_SPECIALITY_HASH")
new_apply_status=Request.Form("new_apply_status")

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(period_id)
FormGetToSafeRequest(tutor_id)
FormGetToSafeRequest(spec_hash)

If period_id="" Or stu_type="" Or tutor_id="" Or spec_hash="" Then
	showErrorPage "信息不完整，请确认是否已选择导师和专业！", "提示"
End If

Connect conn
sql="SELECT RECRUIT_ID FROM ViewRecruitInfo WHERE TEACHER_ID="&tutor_id&" AND SPECIALITY_HASH="&toSqlString(spec_hash)&" AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&stu_type&" AND VALID=1"
Set rs=conn.Execute(sql)
If rs.EOF Then
	showErrorPage "找不到所选导师的招生信息！", "提示"
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
	sql=sql&"spSetApplyInfo "&stu_id&","&period_id&","&turn_num&","&tutor_id&","&recruit_id&","&new_apply_status&";"
Next
If bError Then
	showErrorPage errdesc, "提示"
ElseIf Len(sql) Then
	conn.Execute sql
End If

CloseConn conn
CloseRs rs
%><form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>" />
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>" />
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>" />
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>" />
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>