<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
stu_type=Request.QueryString("stu_type")
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<% useStyleSheet "global" %>
<title>学员选导师情况</title>
</head>
<frameset rows="65,*" frameborder="no" border="0" cols="*">
	<frame name="topFrame" src="menu.asp?stu_type=<%=stu_type%>" frameborder="no" scrolling="no" noresize>
	<frame name="detailFrame" src="blank.html" frameborder="no" noresize>
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>