<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<%
object=Request.Querystring("object")
%>
<html>
<head>
<meta name="theme-color" content="#2D79B2" />
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<frameset rows="65,*" frameborder="no" border="0" cols="*">
	<frame name="top1Frame" frameborder="no" scrolling="no" src="menu.asp?object=<%=object%>" noresize>
	<frame name="detail1Frame" frameborder="no" src="blank.htm" noresize>
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>