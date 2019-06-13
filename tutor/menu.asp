<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Tid")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% useStyleSheet "global" %>
<meta name="theme-color" content="#2D79B2" />
<title></title>
</head>
<body bgcolor="ghostwhite" onload="return On_Load()">
<center>
<table cellspacing="1" cellpadding="2" bgcolor="#999999">
<form id="topForm" method="post" target="detailFrame">
<%
dim ArrayList(2,5),k,objectTerm

k=0
ArrayList(k,0)="学生类型"
ArrayList(k,1)="ViewStudentTypeInfo"
ArrayList(k,2)="TEACHTYPE_ID"
ArrayList(k,3)="TEACHTYPE_NAME"
ArrayList(k,4)=""
ArrayList(k,5)="AND TEACHTYPE_ID IN (5,6,7,9)"

k=1
ArrayList(k,0)="学期"
ArrayList(k,1)="ViewAvailableSemesterInfo"
ArrayList(k,2)="PERIOD_ID"
ArrayList(k,3)="PERIOD_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=""

k=2
ArrayList(k,0)="专业"
ArrayList(k,1)="ViewRecruitInfo"
ArrayList(k,2)="SPECIALITY_HASH"
ArrayList(k,3)="SPECIALITY_NAME"
ArrayList(k,4)=""
ArrayList(k,5)="AND TEACHER_ID="&Session("tid")

FormName="topForm"
Get_ListJavaMenu ArrayList,k,FormName,""
%>
</tr>
<tr><td bgcolor="ghostwhite" colspan=8 align="center">
	<input type="button" value="查   询" onclick="if(Chk_Select()){document.all.topForm.action='applyList.asp';this.form.submit();}">
</td></tr>
</form>
</table>
</center>
</BODY>
</HTML>
