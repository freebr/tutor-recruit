<!--#include file="../inc/db.asp"-->
<%
pmtype=Request.QueryString("type")
If IsNull(pmtype) Then
	pmtype=0
End If
finalFilter=Request.Form("finalFilter2")
object=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")

FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

page_no=Request.Form("In_PAGE_NO2")
page_size=Request.Form("In_PAGE_SIZE2")

Connect conn
For i=1 To Request.Form("sel").Count
	If i>1 Then sql=sql&","
	sql=sql&Request.Form("sel")(i)
Next
If Len(sql) Then
	Select Case pmtype
	Case 0
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=REPLACE(WRITEPRIVILEGETAGSTRING,'SA7,','SA6,'),"&_
				"READPRIVILEGETAGSTRING=REPLACE(READPRIVILEGETAGSTRING,'SA7,','SA6,') WHERE STU_ID IN ("&sql&")"
	Case 1
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=REPLACE(WRITEPRIVILEGETAGSTRING,'SA6,','SA7,'),"&_
				"READPRIVILEGETAGSTRING=REPLACE(READPRIVILEGETAGSTRING,'SA6,','SA7,') WHERE STU_ID IN ("&sql&")"
	Case 2
		sql="UPDATE STUDENT_INFO SET WRITEPRIVILEGETAGSTRING=REPLACE(REPLACE(WRITEPRIVILEGETAGSTRING,'SA6,',''),'SA7,',''),"&_
				"READPRIVILEGETAGSTRING=REPLACE(REPLACE(READPRIVILEGETAGSTRING,'SA6,',''),'SA7,','') WHERE STU_ID IN ("&sql&")"
	End Select
	conn.Execute sql
End If
CloseConn conn
CloseRs rs
%><form id="ret" method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="In_PAGE_NO" value=<%=page_no%>>
	<input type="hidden" name="In_PAGE_SIZE" value=<%=page_size%>>
</form>
<script type="text/javascript">
	alert("操作成功。");
	document.all.ret.submit();
</script>