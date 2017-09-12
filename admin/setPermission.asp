<!--#include file="../inc/db.asp"-->
<%
pmtype=Request.QueryString("type")
If IsNull(pmtype) Then
	pmtype=0
End If
finalFilter=Request.Form("finalFilter2")
object=Request.form("In_TEACHTYPE_ID2")
period_id=Request.form("In_PERIOD_ID2")

FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

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
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=dbo.addPrivilege(WRITEPRIVILEGETAGSTRING,'SA6','SA7'),"&_
				"READPRIVILEGETAGSTRING=dbo.addPrivilege(READPRIVILEGETAGSTRING,'SA6','SA7') WHERE STU_ID IN ("&sql&")"
	Case 1
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=dbo.addPrivilege(WRITEPRIVILEGETAGSTRING,'SA7','SA6'),"&_
				"READPRIVILEGETAGSTRING=dbo.addPrivilege(READPRIVILEGETAGSTRING,'SA7','SA6') WHERE STU_ID IN ("&sql&")"
	Case 2
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA6'),'SA7'),"&_
				"READPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA6'),'SA7') WHERE STU_ID IN ("&sql&")"
	End Select
	conn.Execute sql
End If
CloseConn conn
CloseRs rs
%><form id="ret" method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作成功。");
	document.all.ret.submit();
</script>