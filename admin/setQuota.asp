<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")

bRemove=Request.QueryString()="remove"
teachtype_id=Request.Form("teachtypeid")
finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("pageNo")
page_size=Request.Form("pageSize")

sem_info=getCurrentSemester()
curyear=sem_info(0)
cur_semester=sem_info(1)
If teachtype_id<>"" Then
	wherestr2=" AND TEACHTYPE_ID="&teachtype_id
End If

Connect conn
Dim arr,recruitID,teacherName,recruitQuota,confirmed_num
Dim errdesc,bError
If bRemove Then
For i=1 To Request.Form("sel").Count
		arr=Split(Request.Form("sel")(i),",")
		recruitID=arr(0)
		sql="DELETE FROM TUTOR_RECRUIT_INFO WHERE ID="&recruitID
		conn.Execute sql
	Next
Else
	For i=1 To Request.Form("sel").Count
		arr=Split(Request.Form("sel")(i),",")
		recruitID=arr(0)
		recruitQuota=Request.Form("recruitQuota")(arr(1))
		If Not IsNumeric(recruitQuota) Then
			errdesc="输入的第 "&i&" 个名额值无效！"
			bError=True
		ElseIf recruitQuota<0 Then
			errdesc="输入的第 "&i&" 个名额值无效！"
			bError=True
		End If
		If bError Then
		%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
			CloseConn conn
			Response.End
		End If
		recruitQuota=Int(recruitQuota)
		
		sql="SELECT TEACHER_NAME,CONFIRMED_NUM FROM ViewRecruitInfo WHERE ID="&recruitID&wherestr2
		Set rs=conn.Execute(sql)
		teacherName=rs(0)
		confirmed_num=rs(1)
		CloseRs rs
		If recruitQuota<confirmed_num Then
		%><body bgcolor="ghostwhite"><center><font color=red size="4">为[<%=teacherName%>]老师设定的名额数少于已确认的学生数(<%=confirmed_num%>)！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
			CloseConn conn
			Response.End
		End If
		
		wherestr=" WHERE ID="&recruitID&" AND RECRUIT_YEAR="&curyear&" AND RECRUIT_SEMESTER="&cur_semester&wherestr2
		sql="UPDATE TUTOR_RECRUIT_INFO SET RECRUIT_QUOTA="&recruitQuota&wherestr
		conn.Execute sql
	Next
End If
CloseConn conn
%><form method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>">
	<input type="hidden" name="pageNo" value="<%=page_no%>">
	<input type="hidden" name="pageSize" value="<%=page_size%>">
</form>
<script type="text/javascript">
	setTimeout("document.forms[0].submit();",0);
</script>