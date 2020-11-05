<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

Dim recruitID,PubTerm,page_no,page_size

recruitID=Request.QueryString("recruit-id")
page_no=""
page_size=""
If Request.Form("In_PAGE_NO").Count=0 Then
	page_no=Request.Form("pageNo")
	page_size=Request.Form("pageSize")
Else
	page_no=Request.Form("In_PAGE_NO")
	page_size=Request.Form("In_PAGE_SIZE")
End If

ConnectDb conn
sql="SELECT TEACHER_ID,TEACHER_NAME FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruitID
GetRecordSetNoLock conn,rs,sql,result
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数无效。</font><br /><input type="button" value="关 闭" onclick="tabmgr.close(window);" /></center></body><%
	CloseRs rs
  CloseConn conn
	Response.End()
End If
tutorId=rs(0).Value
tutorName=rs(1).Value
CloseRs rs

sql="SELECT * FROM ViewApplyInfoByTurn WHERE RECRUIT_ID="&recruitID&" AND APPLY_STATUS=3 ORDER BY TUTOR_REPLY_TIME DESC"
GetRecordSetNoLock conn,rs,sql,result
specName=rs("SPECIALITY_NAME")
If page_size<>"" Then
	rs.PageSize=CInt(page_size)
Else
	rs.PageSize=10
	page_size=10
End If
If page_no<>"" Then
	If CInt(page_no)<=rs.PageCount Then
	  rs.AbsolutePage=CInt(page_no)
	Else
	  If rs.PageCount<>0 Then rs.AbsolutePage=1
	End If
Else
	If rs.PageCount<>0 Then rs.AbsolutePage=1
	page_no=1
End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% useStyleSheet "global" %>
<title>导师[<%=tutorName%>]已确认学员名单</title>
<% useScript "common", "admin" %>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>导师[<a href="#" onclick="return showTeacherProfile(<%=tutorId%>);"><%=tutorName%></a>]专业[<%=specName%>]已确认学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>每页
<select name="pageSize" id="pageSize" onchange="this.form.submit()">
<option value="5" <%If rs.PageSize=5 Then%>selected<%End If%>>5</option>
<option value="10" <%If rs.PageSize=10 Then%>selected<%End If%>>10</option>
<option value="15" <%If rs.PageSize=15 Then%>selected<%End If%>>15</option>
</select>
条&nbsp;转到
<select name="pageNo" id="pageNo" onchange="this.form.submit()"><%
For i=1 to rs.PageCount
	Response.write "<option value="&i
	If rs.AbsolutePage=i Then Response.write " selected"
	Response.write ">"&i&"</option>"
Next
%></select>
页&nbsp;共<%=rs.recordCount%>条
</td></tr></form></table>
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" align="center" height="25">
    <td width="50">序号</td>
    <td width="100">学号</td>
    <td width="60">学生姓名</td>
    <td width="120">班级</td>
    <td>学期</td>
		<td width="120">志愿次序</td>
    <td width="150">学生提交时间</td>
		<td width="150">导师确认时间</td>
  </tr><%
Dim id:id=(rs.AbsolutePage-1)*rs.PageSize
For i=1 to rs.PageSize
  If rs.EOF Then Exit For
  id=id+1
	If IsNull(rs("TUTOR_REPLY_TIME")) Then
		tutor_reply_time=""
	Else
		tutor_reply_time=FormatDateTime(rs("TUTOR_REPLY_TIME"),2)&"&nbsp;"&FormatDateTime(rs("TUTOR_REPLY_TIME"),3)
	End If
%><tr bgcolor="ghostwhite" align="center">
    <td><%=id%></td>
    <td><%=rs("STU_NO")%></td>
    <td><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td><%=HtmlEncode(rs("CLASS_NAME"))%></td>
    <td><%=rs("PERIOD_NAME")%></td>
    <td><%=arrTurnName(rs("TURN_NUM"))%></td>
		<td><%=FormatDateTime(rs("APPLY_TIME"),2)%>&nbsp;<%=FormatDateTime(rs("APPLY_TIME"),3)%></td>
		<td><%=tutor_reply_time%></td>
  </tr><%
  	rs.MoveNext()
  Next
%></table>
</form>
<p><input type="button" value="关 闭" onclick="closeWindow()" /></p>
</center>
</body>
</html><%
  CloseRs rs
  CloseConn conn
%>