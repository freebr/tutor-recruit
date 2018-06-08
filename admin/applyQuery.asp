<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
stuType=Request.QueryString("stuType")
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<link href="../css/global.css" rel="stylesheet" type="text/css">
<title>学员选导师情况</title>
</head>
<frameset rows="65,*" frameborder="no" border="0" cols="*">
	<frame name="topFrame" src="menu.asp?stuType=<%=stuType%>" frameborder="no" scrolling="no" noresize>
	<frame name="detailFrame" src="blank.html" frameborder="no" noresize>
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>