﻿<%
	Select Case Request.QueryString()
	Case "timeout"
		title="会话超时"
		notice_html="您登录的会话已超时（20分钟），请从网站首页重新登录。"
	Case Else
		title="未知错误"
		notice_html="未知错误"
	End Select
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="/index/css/error.css" rel="stylesheet" type="text/css">
<meta name="theme-color" content="#2D79B2" />
<title><%=title%></title>
</head>
<body>
<div class="container">
	<div class="errorbox">
	<p align="center"><%=notice_html%></p>
	<p align="center"><button width="200" height="100" onclick="window.top.location.href='/'">返回网站首页</button>&emsp;
	<button width="200" height="100" onclick="location.reload()">刷新页面</button></p>
	</div>
</div>
</body>
</html>