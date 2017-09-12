<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<meta name="theme-color" content="#2D79B2" />
<title></title>
</head>
<body bgcolor="ghostwhite" onload="return On_Load()">
<center>
<table cellspacing="1" cellpadding="2" bgcolor="#999999">
<form id="top1Form" method="post" target="detail1Frame">
<%
Dim ArrayList(1,5),k,objectTerm

k=0
ArrayList(k,0)="学生类型"
ArrayList(k,1)="CODE_TEACHTYPE"
ArrayList(k,2)="TEACHTYPE_ID"
ArrayList(k,3)="TEACHTYPE_NAME"
ArrayList(k,4)="5"
ArrayList(k,5)="AND TEACHTYPE_ID IN (5,6,7,9)"

k=1
ArrayList(k,0)="学期"
ArrayList(k,1)="VIEW_YEAR_SEMESTER"
ArrayList(k,2)="PERIOD_ID"
ArrayList(k,3)="PERIOD_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=""

FormName="top1Form"
Get_ListJavaMenu ArrayList,k,FormName,""
%>
</tr>
<tr><td bgcolor="ghostwhite" colspan=6 align="center">
	<input type="button" value="查看未选择导师的学生" onclick="if(Chk_Select()){document.all.top1Form.action='notChosenList.asp';this.form.submit();}">
	<input type="button" value="查看已选择导师的学生" onclick="if(Chk_Select()){document.all.top1Form.action='chosenList.asp';this.form.submit();}">
</td></tr>
</form>
</table>
</center>
</body>
</html>