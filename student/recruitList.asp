<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Suser")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/jquery-1.6.3.min.js"></script>
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/student.js"></script>
<style type="text/css">
	a:visited, a:link {text-decoration:underline}
	span.noquota {color:#aaa;cursor:not-allowed}
</style>
</head>
<body bgcolor="ghostwhite">
<center>
<%
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
%><td bgcolor="#ddddff" valign="middle" align=center rowspan="<%=data(i,0)%>"><%=speciality_name%></td><%
		End If %>
<td width="40" bgcolor="<%=tdbgcolor%>" align=center><%=data(i,2)%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><a href="#" onclick="return showTeacherResume(<%=data(i,4)%>)"><%=tutor_name%></a></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%
		If data(i,6)=0 Then
%><span class="noquota">0</span><%
		Else
%><%=data(i,6)%><%
		End If %></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=data(i,7)%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=data(i,8)%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=data(i,9)%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=HtmlEncode(data(i,3))%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%
		If data(i,6)=0 Then
%><span class="noquota">选择</span><%
		Else
%><a href="#" onclick="return chooseTutor(<%=turnNum%>,'<%=speciality_name%>',<%=data(i,2)%>,<%=data(i,4)%>,'<%=tutor_name%>')">选择</a><%
		End If %></a></td></tr><%
	Next
	showTable=1
End Function

Connect conn
'================接收的类型==========================
object=Session("StuObject")
turnNum=Request.QueryString("turn")
pagesize=Request.Form("pageSize")
pagecur=Request.Form("pageNo")
finalFilter=Request.Form("finalFilter")
If IsEmpty(finalFilter) Then finalFilter=vbNullString

If Len(pagesize)=0 Or Not IsNumeric(pagesize) Then pagesize=-1 Else pagesize=Int(pagesize)
If Len(pagecur)=0 Or Not IsNumeric(pagecur) Then pagecur=1 Else pagecur=Int(pagecur)

If InStr("5,6,7,9",object)=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您没有权限！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

'==========================================
sem_info=getCurrentSemester()
curyear=sem_info(0)
cur_semester=sem_info(1)
semester_name=sem_info(2)
period_id=sem_info(3)
If object=6 Then
	sql="SELECT CLASS_NAME FROM CODE_CLASS WHERE CLASS_ID="&Session("StuClass")
	GetRecordSetNoLock conn,rs,sql,result
	If result=0 Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">您的班级信息异常，请联系系统管理员。</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	End If
	If InStr(LCase(rs(0)),"mpacc") Then object=9
End If

Set comm = Server.CreateObject("ADODB.Command")
comm.ActiveConnection=conn
comm.CommandText="getTutorRecruitInfoOrderBySpec"
comm.CommandType=adCmdStoredProc
Set pmPeriod=comm.CreateParameter("period_id",adInteger,adParamInput,5,period_id)
Set pmObject=comm.CreateParameter("teachtype_id",adInteger,adParamInput,5,object)
Set pmWhere=comm.CreateParameter("where",adVarChar,adParamInput,2000,finalFilter)
Set pmPageSize=comm.CreateParameter("pagesize",adInteger,adParamInput,5,pagesize)
Set pmPageCur=comm.CreateParameter("pagecur",adInteger,adParamInput,5,pagecur)
comm.Parameters.Append pmPeriod
comm.Parameters.Append pmObject
comm.Parameters.Append pmWhere
comm.Parameters.Append pmPageSize
comm.Parameters.Append pmPageCur
Set rs=comm.Execute()
Set rs=rs.NextRecordSet().NextRecordSet().NextRecordSet()
recNum=rs(0)
pageNum=recNum/pagesize
If Int(pageNum)<>pageNum Then pageNum=Int(pageNum)+1
Set rs=rs.NextRecordSet()
%><p><font size=4><b>选择<%=arrTurnName(turnNum)%>导师</b></font><br />
<table cellspacing=4 cellpadding=0>
<form id="search" method="post">
<tr align=center><td colspan=4>
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
		<option value="20" <%If pageSize=20 Then%>selected<%End If%>>20</option>
		<option value="40" <%If pageSize=40 Then%>selected<%End If%>>40</option>
		<option value="60" <%If pageSize=60 Then%>selected<%End If%>>60</option>
		<option value="-1" <%If pageSize=-1 Then%>selected<%End If%>>全部</option>
	</select>
	条
	&nbsp;
	转到
	<select id="pageNo" name="pageNo" onchange="this.form.submit()">
	<%
	For i=1 to pageNum
	    Response.write "<option value="&i
	    If pagecur=i Then Response.write " selected"
	    Response.write ">"&i&"</option>"
	Next
	%>
	</select>
	页
	&nbsp;
	共<%=recNum%>条&nbsp;<input type="button" name="btnrefresh" value="刷新页面" onclick="location.reload()" />
</td></tr></form></table>
<table width="1000" cellpadding="0" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="gainsboro" align="center" height="25">
  <td width="150" align=center>专业名称</td>
  <td align=center width="120" colspan="2">导师姓名</td>
  <td width="90" align=center>指导名额</td>
  <td width="90" align=center>报名人数</td>
  <td width="90" align=center>已确认人数</td>
  <td width="90" align=center>剩余名额</td>
  <td align=center>工程领域</td>
  <td width="50" align=center>选择</td>
</tr>
<%
	If pageSize=-1 Then
		pageSize=recNum
	End If
	Dim appliedNum,arrData
	j=1
	k=0
	ReDim arrData(pageSize,9)
	For i=1 to pageSize
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
	showTable arrData
%></table></center><%
  CloseConn Conn
%>