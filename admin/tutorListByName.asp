<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript(Array("query","utils")) %>
<style type="text/css">
	p.confirmed {color:#0c0}
	p.unconfirmed {color:#aaa}
</style>
</head>
<body bgcolor="ghostwhite">
<center><%
Connect conn

sem_info=getCurrentSemester()
curyear=sem_info(0)
cur_semester=sem_info(1)
period_id=CStr(curyear)&CStr(cur_semester)
object=Request.QueryString("object")
If object="" Or Not IsNumeric(object) Then object="5"

If Len(Request.Form("finalfilter")) Then
	finalFilter=" AND "&Request.Form("finalfilter")
End If
sql="SELECT Teacher_Id,Teacher_Name,Count(*) AS [Count] FROM ViewRecruitInfo WHERE 1=1"&_
		finalFilter&" GROUP BY Teacher_Id,Teacher_Name,PERIOD_ID,TEACHTYPE_ID HAVING Count(*)>=1 AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&object&" ORDER BY TEACHER_NAME"
GetRecordSetNoLock conn,rs,sql,result
If Request.Form("pageSize")<>"" Then
  rs.PageSize=CInt(Request.Form("pageSize"))
Else
  rs.PageSize=40
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

arrObjName=Array("工程硕士","MBA","EMBA","MPAcc")
arrObjId=Array("5","6","7","9")
%><form id="search" method="post">
<font size=4><b><select onchange="location.href='?object='+this.options[selectedIndex].value">
<%
For i=0 To UBound(arrObjName)
	If arrObjId(i)=object Then
		selprop=" selected"
	Else
		selprop=""
	End If
%><option value="<%=arrObjId(i)%>"<%=selprop%>><%=arrObjName(i)%></option><%
Next %></select>
学员导师名单(按姓名排序)</b></font>
<table cellspacing="1" cellpadding="1">
<tr align=center><td>
	<!--查找-->
	<select name="field" onchange="ReloadOperator()">
		<option value="s_Teacher_Name">教师姓名</option>
		<option value="s_Speciality_Name">专业</option>
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
共<%=rs.recordCount%>条&nbsp;
全选<input type="checkbox" onclick="checkAll()" id="chk">&nbsp;
</td></tr>
<tr><td>
<input type="button" value="修改名额" onclick="batchSetQuota()" />&emsp;
<input type="button" value="删除招生信息" onclick="batchRemoveRecruitInfo(countClk())" /></td></tr></table></form>
<form id="query" id="query" method="post">
<table width="800" cellpadding="0" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="gainsboro" align="center" height="25">
  <td width="13%" align=center>教师姓名</td>
  <td width="20%" align=center>专业</td>
  <td width="25%" align=center>工程领域名称</td>
  <td width="10%" align=center>报名学员数</td>
  <td width="10%" align=center>确认学员数</td>
  <td width="10%" align=center>总名额数</td>
</tr>
<%
		i=0:k=0:l=1
		For i=1 To rs.PageSize
			If rs.EOF Then Exit For
			countRecruitInfo=rs("Count")
			tid=rs("Teacher_Id")
			sql="SELECT RECRUIT_ID,LIST_ID,Speciality_Name,Research_WayName,RECRUIT_QUOTA,APPLIED_NUM,CONFIRMED_NUM,ISCONFIRMED FROM ViewRecruitInfo WHERE TEACHER_ID="&_
					tid&" AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&object&finalFilter
			GetRecordSetNoLock conn,rs2,sql,result
			j=0
			Do While Not rs2.EOF
				recruitID=rs2(0)
				listID=rs2(1)
				recruitQuota=rs2(4)
				appliedNum=rs2(5)
				confirmedNum=rs2(6)
				If appliedNum=0 Then appliedNum=""
				If confirmedNum=0 Then confirmedNum=""
%><tr bgcolor="gainsboro" height="25"><%
				If k Mod 2=0 Then
					tdbgcolor="#eeeeee"
				Else
					tdbgcolor="#ffffff"
				End If
				If j=0 Then
%><td valign="middle" align=center rowspan="<%=countRecruitInfo%>"><a href="/index/teacher_resume.asp?id=<%=rs("TEACHER_ID")%>" target="_blank"><%=HtmlEncode(rs("Teacher_Name"))%></a></td><%
				End If
%><td bgcolor="<%=tdbgcolor%>" align=center><%=HtmlEncode(rs2("Speciality_Name"))%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=HtmlEncode(rs2("Research_WayName"))%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=appliedNum%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><%=confirmedNum%></td>
<td bgcolor="<%=tdbgcolor%>" align=center><input type="checkbox" name="sel" value="<%=recruitID%>,<%=l%>" />&nbsp;
<input type="text" name="recruitQuota" size="5" value="<%=recruitQuota%>" style="text-align:center" /></td><%
				l=l+1
				j=j+1
				k=k+1
%></tr><%
				rs2.MoveNext()
			Loop
			Set rs2=Nothing
  		rs.MoveNext()
   	Next
  %>
</table>
<input type="hidden" name="teachtypeid" value="<%=object%>" />
<input type="hidden" name="finalFilter2" value="<%=Request.Form("finalFilter")%>">
<input type="hidden" name="pageNo" value="<%=Request.Form("pageNo")%>" />
<input type="hidden" name="pageSize" value="<%=Request.Form("pageSize")%>" />
</form>
</center>
<%
  Closeconn Conn
  Closers rs
%>