<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
stu_type=Request.QueryString("stu_type")
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<% useStylesheet("global") %>
<title></title>
</head>
<body bgcolor="ghostwhite" onload="return On_Load()">
<center>
<table cellspacing="1" cellpadding="2" bgcolor="#999999">
<form id="topForm" method="post" target="detailFrame">
<%
Dim ArrayList(1,5),k,objectTerm

k=0
ArrayList(k,0)="学生类型"
ArrayList(k,1)="ViewStudentTypeInfo"
ArrayList(k,2)="TEACHTYPE_ID"
ArrayList(k,3)="TEACHTYPE_NAME"
ArrayList(k,4)=stu_type
ArrayList(k,5)="AND TEACHTYPE_ID IN (5,6,7,9)"

k=1
ArrayList(k,0)="学期"
ArrayList(k,1)="ViewAvailableSemesterInfo"
ArrayList(k,2)="PERIOD_ID"
ArrayList(k,3)="PERIOD_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=""

FormName="topForm"
Get_ListJavaMenu ArrayList,k,FormName,""
%>
</tr>
<tr><td bgcolor="ghostwhite" colspan=6 align="center">
	<input type="button" value="查看未选择导师的学生" onclick="if(Chk_Select()){document.all.topForm.action='noApplyList.asp';this.form.submit();}" />
	<input type="button" value="查看已选择导师的学生" onclick="if(Chk_Select()){document.all.topForm.action='applyList.asp';this.form.submit();}" />
</td></tr>
</form>
</table>
</center>
</body>
</html>