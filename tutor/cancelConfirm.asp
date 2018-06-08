<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("TId")) Then Response.Redirect("../error.asp?timeout")

stuType=Request.form("In_TEACHTYPE_ID")
Speciality_Id=Request.form("In_Speciality_Id")
cur_period_id=Request.form("In_PERIOD_ID")
ids=Request.Form("sel")

FormGetToSafeRequest(stuType)
FormGetToSafeRequest(Speciality_Id)
FormGetToSafeRequest(cur_period_id)
PageNo=Request.Form("In_PageNo")
PageSize=Request.Form("In_pageSize")

If cur_period_id="" or stuType="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
ElseIf ids="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Connect conn

sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("TId")&" AND TEACHTYPE_ID="&stuType&" AND cur_period_id="&cur_period_id
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
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_Speciality_Id" value="<%=Speciality_Id%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=cur_period_id%>">
	<input type="hidden" name="In_PageNo" value="<%=PageNo%>">
	<input type="hidden" name="In_PageSize" value="<%=PageSize%>">
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>