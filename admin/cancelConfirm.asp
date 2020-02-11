<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<!--#include file="../inc/db.asp"-->
<%
'接收参数
listID=Request.QueryString("lid")

finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("pageNo")
page_size=Request.Form("pageSize")

If listID="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

If Month(Now)>=7 Then
	curyear=Year(Now)
	cur_semester=1
Else
	curyear=Year(Now)-1
	cur_semester=2
End If
period_id=CStr(curyear)&CStr(cur_semester)

Connect conn

sql="SELECT RECRUIT_ID FROM ViewRecruitInfo WHERE LIST_ID="&listID&" AND PERIOD_ID="&period_id
Set rs=conn.Execute(sql)
Do While Not rs.EOF
	If Len(recruitID) Then recruitID=recruitID&","
	recruitID=recruitID&rs(0)
	rs.MoveNext()
Loop
CloseRs rs
sql="UPDATE STUDENT_INFO SET TUTOR_RECRUIT_STATUS=2 WHERE TUTOR_RECRUIT_ID IN ("&recruitID&")"
conn.Execute sql
sql="UPDATE TUTOR_RECRUIT_INFO SET IsConfirmed=0 WHERE LIST_ID="&listID
conn.Execute sql
CloseRs rs
CloseConn conn
%><form method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>">
	<input type="hidden" name="pageNo" value="<%=page_no%>">
	<input type="hidden" name="pageSize" value="<%=page_size%>">
</form>
<script type="text/javascript">
	alert('操作完成');
	document.forms[0].submit();
</script>