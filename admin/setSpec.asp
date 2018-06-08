<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
Connect conn
For i=1 To Request.Form("sel").Count
	specControlName="spec"&Request.Form("sel")(i)
	specName=Trim(Request.Form(specControlName))
	sql="SELECT * FROM ViewTutorInfo WHERE ID="&Request.Form("sel")(i)
	GetRecordSet conn,rs,sql,result
	specId=getItemIdByName(specName,"SPECIALITY_ID","SPECIALTY_NAME","CODE_SPECIALITY")
	If specId<>0 Then
		specName=Null
	End If
	rs("SPECIALITY_ID")=specId
	rs("APPLY_SPECIALITY")=specName
	rs.Update()
	rs.MoveNext()
	CloseRs rs
Next
CloseConn conn
%><form id="ret" method="post" action="tutorList.asp">
<input type="hidden" name="finalFilter" value="<%=Request.Form("finalFilter2")%>" />
<input type="hidden" name="pageSize" value="<%=Request.Form("pageSize2")%>" />
<input type="hidden" name="pageNo" value="<%=Request.Form("pageNo2")%>" />
</form><script type="text/javascript">
	alert("操作完成。");
	document.all.ret.submit();
</script>