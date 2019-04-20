<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Tid")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% useStylesheet("global") %>
</head>
<frameset rows="65,*" frameborder="yes" border="0" cols="*">
	<frame name="topFrame" frameborder="no" src="menu.asp" scrolling="no" noresize>
	<frame name="detailFrame" frameborder="no" src="blank.html" noresize>
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>


