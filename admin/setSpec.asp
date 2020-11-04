<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
Connect conn
For i=1 To Request.Form("sel").Count
	id=Request.Form("sel")(i)
	specControlName="spec"&id
	specName=Trim(Request.Form(specControlName))
	sql="SELECT * FROM TutorInfo WHERE ID="&id
	GetRecordSet conn,rs,sql,result
	specId=getItemIdByName(specName,"SPECIALITY_ID","SPECIALTY_NAME","ViewSpecialityInfo")
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