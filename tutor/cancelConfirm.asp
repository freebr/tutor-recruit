<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("TId")) Then Response.Redirect("../error.asp?timeout")

stu_type=Request.Form("In_TEACHTYPE_ID")
spec_id=Request.Form("In_SPECIALITY_ID")
period_id=Request.Form("In_PERIOD_ID")
page_no=Request.Form("In_PAGE_NO")
page_size=Request.Form("In_PAGE_SIZE")
ids=Replace(Request.Form("sel")," ","")

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(spec_id)
FormGetToSafeRequest(period_id)

If period_id="" or stu_type="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
ElseIf ids="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Connect conn

sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("TId")&" AND TEACHTYPE_ID="&stu_type&" AND PERIOD_ID="&period_id
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
Else
	recruitID=rs("RECRUIT_ID")
End If

sql="EXEC spCancelConfirm "&ids&","&recruitID
conn.Execute sql
CloseRs rs
CloseConn conn
%><form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>">
	<input type="hidden" name="In_Speciality_Id" value="<%=spec_id%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>">
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>