<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"--><%
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

opr=Request.QueryString()
teachtype_id=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")
finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("pageNo")
page_size=Request.Form("pageSize")
If Len(teachtype_id) And teachtype_id<>"0" Then
	teachtype_id=Int(teachtype_id)
Else
	errdesc="无效学生类型！"
	bError=True
End If
filterstr=filterstr&" AND TEACHTYPE_ID="&toSqlString(teachtype_id)
If Len(period_id) And period_id<>"0" Then
	period_id=Int(period_id)
	period_year=Left(period_id,4)
	period_sem=Right(period_id,1)
Else
	errdesc="无效学期！"
	bError=True
End If
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br/><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If
filterstr=filterstr&" AND PERIOD_ID="&toSqlString(period_id)

Connect conn
Dim selcount,arr,recruitID,teacherName,recruitQuota,confirmed_num
Dim errdesc,bError
selcount=Request.Form("sel").Count
Select Case opr
Case "remove"
	For i=1 To selcount
		arr=Split(Request.Form("sel")(i),",")
		recruitID=arr(0)
		sql="DELETE FROM RecruitInfo WHERE ID="&recruitID
		conn.Execute sql
	Next
Case "removeZero"
	filterstr="RECRUIT_QUOTA=0 AND RECRUIT_YEAR="&period_year&" AND RECRUIT_SEMESTER="&period_sem&" AND TEACHTYPE_ID="&toSqlString(teachtype_id)
	sql="SELECT COUNT(*) FROM RecruitInfo WHERE "&filterstr
	Set rs=conn.Execute(sql)
	selcount=rs(0)
	CloseRs rs
	sql="DELETE FROM RecruitInfo WHERE "&filterstr
	conn.Execute sql
Case Else
	For i=1 To selcount
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

		sql="SELECT TEACHER_NAME,CONFIRMED_NUM FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruitID&filterstr
		Set rs=conn.Execute(sql)
		teacherName=rs(0)
		confirmed_num=rs(1)
		CloseRs rs
		If recruitQuota<confirmed_num Then
		%><body bgcolor="ghostwhite"><center><font color=red size="4">为[<%=teacherName%>]老师设定的名额数少于已确认的学生数(<%=confirmed_num%>)！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
			CloseConn conn
			Response.End
		End If
		
		sql="UPDATE RecruitInfo SET RECRUIT_QUOTA="&recruitQuota&" WHERE ID="&recruitID&" AND RECRUIT_YEAR="&period_year&" AND RECRUIT_SEMESTER="&period_sem&" AND TEACHTYPE_ID="&toSqlString(teachtype_id)
		conn.Execute sql
	Next
End Select
CloseConn conn
%><form method="post" action="<%=Request.ServerVariables("HTTP_REFERER")%>">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=teachtype_id%>" />
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>" />
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="pageNo" value="<%=page_no%>" />
	<input type="hidden" name="pageSize" value="<%=page_size%>" />
</form>
<script type="text/javascript">
	alert("操作完成，更新了 <%=selcount%> 条招生信息名额。");
	setTimeout("document.forms[0].submit();",0);
</script>