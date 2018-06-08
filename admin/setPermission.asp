<!--#include file="../inc/db.asp"-->
<%
pmtype=Request.QueryString("type")
If IsNull(pmtype) Then
	pmtype=0
End If
finalFilter=Request.Form("finalFilter2")
stuType=Request.Form("In_TEACHTYPE_ID2")
cur_period_id=Request.Form("In_PERIOD_ID2")

FormGetToSafeRequest(stuType)
FormGetToSafeRequest(cur_period_id)

PageNo=Request.Form("In_PageNo2")
PageSize=Request.Form("In_pageSize2")

Connect conn
For i=1 To Request.Form("sel").Count
	If i>1 Then sql=sql&","
	sql=sql&Request.Form("sel")(i)
Next
If Len(sql) Then
	Select Case pmtype
	Case 0
		sql="EXEC spSwitchStudentPrivilege "&toSqlString(sql)&",1,0;"
	Case 1
		sql="EXEC spSwitchStudentPrivilege "&toSqlString(sql)&",0,0;"
	Case 2
		sql="EXEC spSwitchStudentPrivilege "&toSqlString(sql)&",0,1;"
	End Select
	conn.Execute sql
End If
CloseConn conn
CloseRs rs
%><form id="ret" method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=cur_period_id%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作成功。");
	document.all.ret.submit();
</script>