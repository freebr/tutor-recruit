<%Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
	
	Dim recruitID,PubTerm,PageNo,PageSize
	
	recruitID=Request.QueryString("recruit_id")
	'----------------------PAGE-------------------------
	PageNo=""
	PageSize=""
	If Request.Form("In_PageNo").Count=0 Then
		PageNo=Request.Form("PageNo")
		PageSize=Request.Form("pageSize")
	Else
		PageNo=Request.Form("In_PageNo")
		PageSize=Request.Form("In_pageSize")
	End If
	
	'------------------------------------------------------
	Connect conn
	sql="SELECT TEACHER_ID,TEACHER_NAME FROM VIEW_TUTOR_RECRUIT_INFO WHERE RECRUIT_ID="&recruitID
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
	
	sql="SELECT * FROM VIEW_TUTOR_STUDENT_APPLY_INFO_BY_TURN WHERE RECRUIT_ID="&recruitID&" AND APPLY_STATUS=3 ORDER BY TUTOR_REPLY_TIME DESC"
	GetRecordSetNoLock conn,rs,sql,result
	If PageSize<>"" Then
		rs.PageSize=CInt(PageSize)
	Else
		rs.PageSize=10
		PageSize=10
	End If
	If PageNo<>"" Then
		If CInt(PageNo)<=rs.PageCount Then
		  rs.AbsolutePage=CInt(PageNo)
		Else
		  If rs.PageCount<>0 Then rs.AbsolutePage=1
		End If
	Else
		If rs.PageCount<>0 Then rs.AbsolutePage=1
		PageNo=1
	End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<title>导师[<%=tutorName%>]已确认学员名单</title>
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/admin.js"></script>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>导师[<a href="#" onclick="return showTeacherResume(<%=tutorId%>);"><%=tutorName%></a>]已确认学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>每页
<select name="pageSize" id="pageSize" onchange="this.form.submit()">
<option value="5" <%If rs.PageSize=5 Then%>selected<%End If%>>5</option>
<option value="10" <%If rs.PageSize=10 Then%>selected<%End If%>>10</option>
<option value="15" <%If rs.PageSize=15 Then%>selected<%End If%>>15</option>
</select>
条&nbsp;转到
<select name="pageNo" id="pageNo" onchange="this.form.submit()">
<%
	For i=1 to rs.PageCount
	    Response.write "<option value="&i
	    If rs.AbsolutePage=i Then Response.write " selected"
	    Response.write ">"&i&"</option>"
	Next
%></select>
页&nbsp;共<%=rs.recordCount%>条
</td></tr></form></table>
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" align="center" height=25>
    <td width="50" align=center>序号</td>
    <td width="100" align=center>学号</td>
    <td width="60" align=center>学生姓名</td>
    <td width="120" align=center>班级</td>
		<td width="120" align=center>志愿次序</td>
    <td width="80" align=center>学生提交时间</td>
		<td width="120" align=center>导师确认时间</td>
  </tr>
  <%
  Dim arrTurnName:arrTurnName=Array("","第一志愿","第二志愿","第三志愿")
  Dim id:id=(rs.AbsolutePage-1)*rs.PageSize
  For i=1 to rs.PageSize
    If rs.EOF Then Exit For
    id=id+1
  	If IsNull(rs("TUTOR_REPLY_TIME")) Then
  		tutor_reply_time=""
  	Else
  		tutor_reply_time=FormatDateTime(rs("TUTOR_REPLY_TIME"),2)&"<br/>"&FormatDateTime(rs("TUTOR_REPLY_TIME"),3)
		End If
  %>
  <tr bgcolor="ghostwhite">
    <td align=center><%=id%></td>
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
    <td align=center><%=arrTurnName(rs("TURN_NUM"))%></td>
		<td align=center><%=FormatDateTime(rs("APPLY_TIME"),2)%><br/><%=FormatDateTime(rs("APPLY_TIME"),4)%></td>

		<td align=center><%=tutor_reply_time%></td>
  </tr><%
  	rs.MoveNext()
  Next
  %>
</table>
</form>
<p><input type="button" value="关 闭" onclick="tabmgr.close(window);" /></p>
</center>
</body>
</html>
<%
  CloseRs rs
  CloseConn conn
%>