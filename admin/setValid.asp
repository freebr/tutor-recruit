<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
valid=Request.QueryString("valid")
If IsEmpty(valid) Or Not IsNumeric(valid) Then
	valid=0
Else
	valid=Int(valid)
	If valid<0 Or valid>1 Then valid=0
End If
Connect conn
For i=1 To Request.Form("sel").Count
	sql=sql&"UPDATE TutorInfo SET VALID="&valid&" WHERE ID="&Request.Form("sel")(i)&";"
Next
If Len(sql) Then conn.Execute sql
CloseConn conn
%><form id="ret" method="post" action="tutorList.asp">
<input type="hidden" name="finalFilter" value="<%=Request.Form("finalFilter2")%>" />
<input type="hidden" name="pageSize" value="<%=Request.Form("pageSize2")%>" />
<input type="hidden" name="pageNo" value="<%=Request.Form("pageNo2")%>" />
</form><script type="text/javascript">
	alert("操作完成。");
	document.all.ret.submit();
</script>