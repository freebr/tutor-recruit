<%
Response.Expires=-1
If IsEmpty(Session("Tuser")) Then 
	'Response.Redirect("../teacher/err/timeout.asp")
	Response.Write "<center><font color='red' size=3><b>登录超时，请重新登录!</b></font></center>"
	Response.end
End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css/global.css" rel="stylesheet" type="text/css">
</head>
<frameset rows="65,*" frameborder="yes" border="0" cols="*"> 
	<frame name="topFrame" frameborder="no" src="menu.asp" scrolling="no" noresize>
	<frame name="detailFrame" frameborder="no" src="blank.html" noresize>
</frameset>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>


