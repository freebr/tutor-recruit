<%
Sub CatchErr()
	If Err.number<>0 Then 
	    Response.write "<form id='err' ACTION='../err/err.asp' METHOD='post'>"
	    Response.write "<INPUT TYPE='hidden' NAME='number' VALUE='"&Err.Number&"'>"
	    Response.write "<INPUT TYPE='hidden' NAME='desc' VALUE='"&Err.Description&"'>"
	    Response.write "<INPUT TYPE='hidden' NAME='source' VALUE='"&Err.Source&"'>"
	    Response.write "</FORM>"
	    Response.write "<SCRIPT>document.forms('err').submit()</SCRIPT>"
	    Response.End
	End If
	
End Sub 
%>