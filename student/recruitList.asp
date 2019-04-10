<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("StuId")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/jquery-1.6.3.min.js"></script>
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/student.js"></script>
<style type="text/css">
	a:visited, a:link { text-decoration:underline }
	span.no-quota { color:#aaa;cursor:not-allowed }
</style>
</head>
<body bgcolor="ghostwhite">
<center><%
Function showTable(data)
	Dim i
	For i=1 To UBound(data,1)
		If Len(data(i,1))=0 Then Exit For
%><tr class="recruit" height="25"><%
		If i Mod 2=0 Then
			tdbgcolor="#eeeeee"
		Else
			tdbgcolor="#ffffff"
		End If
		tutor_name=HtmlEncode(data(i,5))
		If data(i,0)<>0 Then
			speciality_name=HtmlEncode(data(i,1))
%><td bgcolor="#ddddff" valign="middle" align="center" rowspan="<%=data(i,0)%>"><%=speciality_name%></td><%
		End If %>
<td width="40" bgcolor="<%=tdbgcolor%>" align="center"><%=data(i,2)%></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><a href="#" onclick="return showTeacherResume(<%=data(i,4)%>)"><%=tutor_name%></a></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%
		If data(i,6)=0 Then
%><span class="no-quota">0</span><%
		Else
%><%=data(i,6)%><%
		End If %></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%=data(i,7)%></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%=data(i,8)%></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%=data(i,9)%></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%=HtmlEncode(data(i,3))%></td>
<td bgcolor="<%=tdbgcolor%>" align="center"><%
		If data(i,6)=0 Then
%><span class="no-quota">选择</span><%
		Else
%><a href="#" onclick="return chooseTutor(<%=turnNum%>,'<%=speciality_name%>',<%=data(i,2)%>,<%=data(i,4)%>,'<%=tutor_name%>')">选择</a><%
		End If %></a></td></tr><%
	Next
	showTable=1
End Function

Connect conn
stuType=Session("StuType")
turnNum=Request.QueryString("turn")
page_size=Request.Form("pageSize")
page_cur=Request.Form("pageNo")
finalFilter=Request.Form("finalFilter")
If IsEmpty(finalFilter) Then finalFilter=vbNullString

If Len(page_size)=0 Or Not IsNumeric(page_size) Then page_size=-1 Else page_size=Int(page_size)
If Len(page_cur)=0 Or Not IsNumeric(page_cur) Then page_cur=1 Else page_cur=Int(page_cur)

sem_info=getCurrentSemester()
cur_year=sem_info(0)
cur_semester=sem_info(1)
cur_semester_name=sem_info(2)
cur_period_id=sem_info(3)

Set comm = Server.CreateObject("ADODB.Command")
comm.ActiveConnection=conn
comm.CommandText="spQueryRecruitInfo"
comm.CommandType=adCmdStoredProc
Set pmPeriod=comm.CreateParameter("cur_period_id",adInteger,adParamInput,5,cur_period_id)
Set pmObject=comm.CreateParameter("teachtype_id",adInteger,adParamInput,5,stuType)
Set pmWhere=comm.CreateParameter("where",adVarChar,adParamInput,2000,finalFilter)
Set pmPageSize=comm.CreateParameter("page_size",adInteger,adParamInput,5,page_size)
Set pmPageCur=comm.CreateParameter("page_cur",adInteger,adParamInput,5,page_cur)
comm.Parameters.Append pmPeriod
comm.Parameters.Append pmObject
comm.Parameters.Append pmWhere
comm.Parameters.Append pmPageSize
comm.Parameters.Append pmPageCur
Set rs = comm.Execute()
Set rs = rs.NextRecordSet().NextRecordSet()
count_rec = rs(0).Value
If page_size = -1 Then
	page_size = count_rec
	count_page = 1
Else
	count_page = count_rec/page_size
End If
If Int(count_page)<>count_page Then count_page=Int(count_page)+1
Set rs = rs.NextRecordSet()
%><p><font size=4><b>选择<%=arrTurnName(turnNum)%>导师</b></font><br />
<table cellspacing=4 cellpadding=0>
<form id="search" method="post">
<tr align="center"><td colspan=4>
	<!--查找-->
	<select id="field" name="field" onchange="ReloadOperator()">
		<option value="s_SPECIALITY_NAME">专业名称</option>
		<option value="n_RECRUIT_ID">选项号</option>
		<option value="s_TEACHER_NAME">导师姓名</option>
		<option value="n_APPLIED_NUM">报名人数</option>
		<option value="n_REMAINING_NUM">剩余名额</option>
	</select>
	<select id="operator" name="operator">
		<script>ReloadOperator()</script>
	</select>
		<input type="text" id="filter" name="filter" size="10" onkeypress="checkKey()">
		<input type="hidden" id="finalFilter" name="finalFilter" value="<%=finalFilter%>">
		<input type="submit" value="查找" onclick="genFilter()">
		<input type="submit" value="在结果中查找" onclick="genFinalFilter()">
		<input type="button" value="浏览全部" onclick="location.href='recruitList.asp'" />
	&nbsp;
	每页
	<select id="pageSize" name="pageSize" onchange="this.form.submit()">
		<option value="20" <%If page_size=20 Then%>selected<%End If%>>20</option>
		<option value="40" <%If page_size=40 Then%>selected<%End If%>>40</option>
		<option value="60" <%If page_size=60 Then%>selected<%End If%>>60</option>
		<option value="-1" <%If page_size=-1 Then%>selected<%End If%>>全部</option>
	</select>
	条
	&nbsp;
	转到
	<select id="pageNo" name="pageNo" onchange="this.form.submit()">
	<%
	For i=1 to count_page
	    Response.write "<option value="&i
	    If page_cur=i Then Response.write " selected"
	    Response.write ">"&i&"</option>"
	Next
	%>
	</select>
	页
	&nbsp;
	共<%=count_rec%>条&nbsp;<input type="button" name="btnrefresh" value="刷新页面" onclick="location.reload()" />
</td></tr></form></table>
<table width="1000" cellpadding="0" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="gainsboro" align="center" height="25">
  <td width="150" align="center">专业名称</td>
  <td align="center" width="120" colspan="2">导师姓名</td>
  <td width="90" align="center">指导名额</td>
  <td width="90" align="center">报名人数</td>
  <td width="90" align="center">已确认人数</td>
  <td width="90" align="center">剩余名额</td>
  <td align="center">工程领域</td>
  <td width="50" align="center">选择</td>
</tr><%
	Dim appliedNum,arrData
	j=1
	k=0
	ReDim arrData(page_size,9)
	For i=1 to page_size
		If rs.EOF Then Exit For
		remainingQuota=rs("REMAINING_NUM")
		appliedNum=rs("APPLIED_NUM")
		If appliedNum=0 Then appliedNum=""
		arrData(i,0)=0
		arrData(i,1)=rs("Speciality_Name")
		arrData(i,2)=rs("RECRUIT_ID")
		arrData(i,3)=rs("Research_WayName")
		arrData(i,4)=rs("TEACHER_ID")
		arrData(i,5)=rs("Teacher_Name")
		arrData(i,6)=rs("RECRUIT_QUOTA")
		arrData(i,7)=appliedNum
		arrData(i,8)=rs("CONFIRMED_NUM")
		arrData(i,9)=remainingQuota
		If arrData(i,1)=arrData(j,1) Then
			arrData(j,0)=arrData(j,0)+1
		Else
			j=i
			arrData(j,0)=1
		End If
		rs.MoveNext()
  Next
  CloseRs rs
  CloseConn Conn
	showTable arrData
%></table></center>