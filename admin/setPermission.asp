<!--#include file="../inc/global.inc"-->
<%
stu_type=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")
finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("In_PAGE_NO2")
page_size=Request.Form("In_PAGE_SIZE2")

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(period_id)

pm_type=Request.QueryString("type")
If IsNull(pm_type) Then
	pm_type=0
End If

ConnectDb conn
For i=1 To Request.Form("sel").Count
	If i>1 Then sql=sql&","
	sql=sql&Request.Form("sel")(i)
Next
If Len(sql) Then
	Select Case pm_type
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
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>" />
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>" />
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>" />
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>" />
</form>
<script type="text/javascript">
	alert("操作成功。");
	document.all.ret.submit();
</script>