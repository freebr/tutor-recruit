﻿<%Response.Charset="utf-8"%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript(Array("query","utils")) %>
<style type="text/css">
	p.permitted {color:#0c0}
	p.unpermitted {color:#aaa}
</style>
</head>
<body bgcolor="ghostwhite">
<center>
<%
Dim object,PubTerm,page_no,page_size

object=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter")
FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

If object="" Or period_id="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If
' 对查询条件作等效转换
Dim regExp,matches,op:Set regExp=New RegExp
regExp.Pattern="ISPERMITTED (=|<>) '(.*)'$"
regExp.IgnoreCase=True
Set matches=regExp.Execute(finalFilter)
If matches.Count>0 Then
	op=matches(0).SubMatches(0)
	Select Case matches(0).SubMatches(1)
	Case "开放"
		finalFilter=Replace(finalFilter,matches(0),"dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6')"&op&"1")
	Case "不开放"
		finalFilter=Replace(finalFilter,matches(0),"dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6')"&op&"0")
	Case Else
		finalFilter=Replace(finalFilter,matches(0),"1=0")
	End Select
End If
If Len(finalFilter) Then finalFilter=" AND ("&finalFilter&")"
'----------------------PAGE-------------------------
page_no=""
page_size=""
If Request.Form("In_PAGE_NO").Count=0 Then
	page_no=Request.Form("page_no")
	page_size=Request.Form("pageSize")
Else
	page_no=Request.Form("In_PAGE_NO")
	page_size=Request.Form("In_PAGE_SIZE")
End If
'------------------------------------------------------
Connect conn
sql="SELECT STU_ID,STU_NO,STU_NAME,SEX,CLASS_NAME,dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6') AS ISPERMITTED FROM VIEW_STUDENT_INFO_NEW WHERE VALID=0 "&_
		"AND TEACHTYPE_ID="&object&" AND (dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6')=1 OR dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA7')=1 "&_
		"OR dbo.hasPrivilege(READPRIVILEGETAGSTRING,'SA6')=1 OR dbo.hasPrivilege(READPRIVILEGETAGSTRING,'SA7')=1) AND TUTOR_RECRUIT_ID=0"&finalFilter&" ORDER BY CLASS_NAME,Stu_Name"
GetRecordSetNoLock conn,rs,sql,result
If page_size<>"" Then
  rs.PageSize=CInt(page_size)
Else
  rs.PageSize=120
	page_size=120
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
%>
<font size=4><b>未选导师学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
<select name="field" id="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_CLASS_NAME">班级</option>
<option value="f_ISPERMITTED">系统权限</option>
</select>
<select name="operator" id="operator">
<script>ReloadOperator()</script>
</select>
<input type="text" name="filter" id="filter" size="10" onkeypress="checkKey()">
<input type="hidden" name="finalFilter" id="finalFilter" value="<%=Request.Form("finalFilter")%>">
<input type="submit" value="查找" onclick="genFilter()">
<input type="submit" value="在结果中查找" onclick="genFinalFilter()">
&nbsp;每页
<select name="pageSize" id="pageSize" onchange="this.form.submit()">
<option value="120" <%If rs.PageSize=120 Then%>selected<%End If%>>120</option>
<option value="240" <%If rs.PageSize=240 Then%>selected<%End If%>>240</option>
<option value="360" <%If rs.PageSize=360 Then%>selected<%End If%>>360</option>
<option value="480" <%If rs.PageSize=480 Then%>selected<%End If%>>480</option>
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
<form id="fmStuList" method="post" action="addstudent.asp">
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID2" value="<%=period_id%>">
<input type="hidden" name="In_PAGE_NO2" value=<%=page_no%>>
<input type="hidden" name="In_PAGE_SIZE2" value=<%=page_size%>>
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<%
Dim ArrayList(1,5),k
Table="ViewRecruitInfo"
WhereStr="AND VALID=1 AND TEACHTYPE_ID="&object&" AND PERIOD_ID="&period_id
k=0

ArrayList(k,0)="导师"
ArrayList(k,1)=Table
ArrayList(k,2)="TEACHER_ID"
ArrayList(k,3)="TEACHER_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=WhereStr

k=1
ArrayList(k,0)="专业"
ArrayList(k,1)=Table
ArrayList(k,2)="SPECIALITY_NAME"
ArrayList(k,3)="SPECIALITY_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=WhereStr
FormName="fmStuList"
Get_ListJavaMenu ArrayList,k,FormName,""
%><td><input type="button" value="安排导师" onclick="if(Chk_Select())if(confirm('是否为所选的'+countClk()+'个学生安排导师？'))this.form.submit();"></td>
<td align=right>全选<input type="checkbox" onclick="checkAll()" id="chk" name="chk">&nbsp;<input type="button" value="开放系统权限" onclick="setPermission(0)">&nbsp;<input type="button" value="关闭系统权限" onclick="setPermission(1)">
&nbsp;<input type="button" value="删除权限记录" onclick="setPermission(2)">
</td></tr></table>
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <!--报名学生信息-->
  <tr bgcolor="gainsboro" align="center" height="25">
    <td align=center width="100">学号</td>
    <td width="150" align=center>姓名</td>
    <td width="50" align=center>性别</td>
		<td align=center>班级</td>
		<td align=center>系统权限</td>
    <td width="30" align=center>选择</td>
  </tr>
  <%
  For i=1 to rs.PageSize
      If rs.EOF Then Exit For
  %>
  <tr bgcolor="ghostwhite">
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td align=center><%=HtmlEncode(rs("SEX"))%></td>
    <td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
    <td align=center><%
			If rs("ISPERMITTED") Then
%><p class="permitted">开放</p><%
			Else
%><p class="unpermitted">不开放</p><%
			End If %></td>
    <td align=center><input type="checkbox" name="sel" value="<%=rs("STU_ID")%>">
	</td>
  </tr>
  <%
  rs.MoveNext
  Next
  %>
</table>
</form>
</center>
<script type="text/javascript">On_Load();</script>
</body>
</html>
<%
  CloseConn conn
  CloseRs rs
%>