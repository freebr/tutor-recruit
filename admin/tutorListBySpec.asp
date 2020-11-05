<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

sem_info=getCurrentSemester()
teachtype_id=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter")
If Len(finalFilter) Then finalFilter=" AND ("&finalFilter&")"
If Len(teachtype_id) And teachtype_id<>"0" Then
	teachtype_id=Int(teachtype_id)
Else
	teachtype_id=5
End If
teachtype_name=getStudentTypeName(teachtype_id)

PubTerm=PubTerm&" AND TEACHTYPE_ID="&toSqlString(teachtype_id)
If Len(period_id) And period_id<>"0" Then
	period_id=Int(period_id)
Else
	period_id=cur_period_id
End If
PubTerm=PubTerm&" AND PERIOD_ID="&toSqlString(period_id)

ConnectDb conn
sql="SELECT SPECIALITY_NAME,COUNT(*) AS [COUNT] FROM ViewTutorInfo WHERE 1=1 "&Request.Form("finalFilter")&" GROUP BY SPECIALITY_NAME"
GetRecordSetNoLock conn,rs,sql,result
If Request.Form("pageSize")<>"" Then
  rs.PageSize=CInt(Request.Form("pageSize"))
Else
  rs.PageSize=20
End If
If Request.Form("pageNo")<>"" Then
  If CInt(Request.Form("pageNo"))<=rs.PageCount Then
    rs.AbsolutePage=CInt(Request.Form("pageNo"))
  Else
    If rs.PageCount<>0 Then rs.AbsolutePage=1
  End If
Else
  If rs.PageCount<>0 Then rs.AbsolutePage=1
End If
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<% useStyleSheet "global" %>
<% useScript "common", "admin" %>
<style type="text/css">
	p.confirmed {color:#0c0}
	p.unconfirmed {color:#aaa}
</style>
</head>
<body bgcolor="ghostwhite">
<center><form id="search" method="post">
<font size=4><b><%=teachtype_name%> 学员导师名单(按专业排序)</b></font>
<table cellspacing="1" cellpadding="1">
<tr><td><table width="400" cellspacing="1" cellpadding="1">
<tr><td>学生类型&nbsp;<select name="In_TEACHTYPE_ID"><%
GetMenuListPubTerm "ViewStudentTypeInfo","TEACHTYPE_ID","TEACHTYPE_NAME",teachtype_id,"AND TEACHTYPE_ID IN (5,6,7,9)"
%></select></td><td>学期&nbsp;<%=semesterList("In_PERIOD_ID",Int(period_id))%></td></tr></table></td></tr>
<tr align=center><td>
	<!--查找-->
	<select name="field" onchange="ReloadOperator()">
		<option value="s_TEACHER_NAME">教师姓名</option>
		<option value="s_SPECIALITY_NAME">专业</option>
	</select>
	<select name="operator">
		<script>ReloadOperator()</script>
	</select>
	<input type="text" name="filter" size="20" onkeypress="checkKey()">
	<input type="hidden" name="finalFilter" value="<%=Request.Form("finalFilter")%>">
	<input type="submit" value="查找" onclick="genFilter()">
	<input type="submit" value="在结果中查找" onclick="genFinalFilter()">
	&nbsp;每页
	<select name="pageSize" onchange="this.form.submit()">
		<option value="20" <%If rs.PageSize=20 Then%>selected<%End If%>>20</option>
		<option value="40" <%If rs.PageSize=40 Then%>selected<%End If%>>40</option>
		<option value="60" <%If rs.PageSize=60 Then%>selected<%End If%>>60</option>
	</select>
	条
	&nbsp;
	转到
	<select name="pageNo" onchange="this.form.submit()">
	<%
	For i=1 to rs.PageCount
	    Response.write "<option value="&i
	    If rs.AbsolutePage=i Then Response.write " selected"
	    Response.write ">"&i&"</option>"
	Next
	%>
	</select>
	页
	&nbsp;
	共<%=rs.recordCount%>条
</td></tr>
<tr><td>
<input type="button" value="修改名额" onclick="batchSetQuota()" />&emsp;
<input type="button" value="删除招生信息" onclick="batchRemoveRecruitInfo(countClk())" />&emsp;
<input type="button" value="删除无指导名额的招生信息" onclick="removeZeroQuotaRecruitInfo()" /></td></tr></table></form>
<form id="query" id="query" method="post">
<table width="1000" cellpadding="0" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="gainsboro" align="center" height="25">
  <td width="17%" align=center>专业名称</td>
  <td width="13%" align=center>教师姓名</td>
  <td width="30%" align=center>论文指导方向</td>
  <td width="10%" align=center>报名学员数</td>
  <td width="10%" align=center>确认学员数</td>
  <td width="10%" align=center>总名额数</td>
  <td width="10%" align=center>操作</td>
</tr>
  <%
  	k=0:l=1
  	For i=1 to rs.PageSize
			If rs.EOF Then Exit For
			strSub="SELECT * FROM ViewRecruitInfo WHERE SPECIALITY_NAME="&toSqlString(rs("SPECIALITY_NAME"))&PubTerm
			GetRecordSetNoLock conn,rs2,strSub,result
			j=0
			Do While Not rs2.EOF
				listID=rs2("LIST_ID")
				recruitID=rs2("RECRUIT_ID")
				strSub2="SELECT RECRUIT_ID,RECRUIT_QUOTA,APPLIED_NUM,CONFIRMED_NUM,ISCONFIRMED FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruitID
				GetRecordSetNoLock conn,rs22,strSub2,result2
				If Not rs22.EOF Then
					recruitQuota=rs22(1)
					appliedNum=rs22(2)
					confirmedNum=rs22(3)
					If appliedNum=0 Then appliedNum=""
					If confirmedNum=0 Then confirmedNum=""
%><tr bgcolor="gainsboro" height="25"><%
					If k Mod 2=0 Then
						tdbgcolor="#eeeeee"
					Else
						tdbgcolor="#ffffff"
					End If
					If j=0 Then
%><td valign="middle" align=center rowspan="<%=result%>"><%=HtmlEncode(rs("Speciality_Name"))%></td><%
					End If
	%><td bgcolor="<%=tdbgcolor%>" align=center><a href="/index/teacher_resume.asp?id=<%=rs2("TEACHER_ID")%>" target="_blank"><%=HtmlEncode(rs2("Teacher_Name"))%></a></td>
  <td bgcolor="<%=tdbgcolor%>" align=center><%=HtmlEncode(rs2("Research_WayName"))%></td>
	<td bgcolor="<%=tdbgcolor%>" align=center><%=appliedNum%></td>
	<td bgcolor="<%=tdbgcolor%>" align=center><%=confirmedNum%></td>
	<td bgcolor="<%=tdbgcolor%>" align=center><input type="checkbox" name="sel" value="<%=recruitID%>,<%=l%>" />&nbsp;
	<input type="text" name="recruitQuota" size="5" value="<%=recruitQuota%>" style="text-align:center" /></td><%
					l=l+1
					j=j+1
					k=k+1
%><td bgcolor="<%=tdbgcolor%>" align=center><%
				If Len(confirmedNum) Then
%><a href="#" onclick="return showApplyList(<%=rs2("RECRUIT_ID")%>);">查看确认名单</a><%
				End If
%></td></tr><%
				End If
				CloseRs rs22
				rs2.MoveNext()
			Loop
			Set rs2=Nothing
  		rs.MoveNext()
   	Next
  %>
  </tr>
</table>
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=teachtype_id%>" />
<input type="hidden" name="In_PERIOD_ID2" value="<%=period_id%>" />
<input type="hidden" name="finalFilter2" value="<%=Request.Form("finalFilter")%>">
<input type="hidden" name="pageNo" value="<%=Request.Form("pageNo")%>" />
<input type="hidden" name="pageSize" value="<%=Request.Form("pageSize")%>" />
</form>
</center>
<%
  Closeconn Conn
  Closers rs
%>