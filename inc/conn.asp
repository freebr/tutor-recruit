<!--#include file="pub.asp"-->
<%
Response.Expires=-1
Sub Connect(conn)
	Dim connstr
	connstr="Provider=SQLNCLI10;Persist Security Info=True;User ID=sa;Password=cnsba2016.net;Initial Catalog=SCUT_MD;Data Source=(local);Pooling=true;MAX Pool Size=512;Min Pool Size=50;Connection Lifetime=999;"
	Set conn=Server.CreateObject("ADODB.CONNECTION")
  conn.CommandTimeout=300
	conn.Open connstr
End Sub
'========================  
%>