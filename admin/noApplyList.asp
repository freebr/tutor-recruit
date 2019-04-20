<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

Dim stu_type,PubTerm,page_no,page_size

stu_type=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter")
FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(period_id)

If Not IsNumeric(stu_type) Or Not IsNumeric(period_id) Or period_id="0" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

' 对查询条件作等效转换
Dim regExp,matches,op:Set regExp=New RegExp
regExp.Pattern="(PERMITTED|PROFILE_FILLED) (=|<>) '(.*)'$"
regExp.IgnoreCase=True
Set matches=regExp.Execute(finalFilter)
If matches.Count>0 Then
	op=matches(0).SubMatches(1)
	Select Case matches(0).SubMatches(2)
	Case "开放"
		finalFilter=Replace(finalFilter,matches(0),"PERMITTED"&op&"1")
	Case "不开放"
		finalFilter=Replace(finalFilter,matches(0),"PERMITTED"&op&"0")
	Case "已填写"
		finalFilter=Replace(finalFilter,matches(0),"PROFILE_FILLED"&op&"1")
	Case "未填写"
		finalFilter=Replace(finalFilter,matches(0),"PROFILE_FILLED"&op&"0")
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
sql="SELECT * FROM ViewNoApplyStudentInfo WHERE TEACHTYPE_ID="&stu_type&finalFilter&" ORDER BY CLASS_NAME,STU_NAME"
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
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<% useStylesheet("global") %>
<% useScript("common") %>
<script type="text/javascript" src="../scripts/admin.js"></script>
<style type="text/css">
	p.true_flag { color:#0c0 }
	p.false_flag { color:#aaa }
</style>
</head>
<body bgcolor="ghostwhite" onload="On_Load();">
<center>
<font size=4><b>未选导师学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
<select name="field" id="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_CLASS_NAME">班级</option>
<option value="f_PERMITTED">系统权限</option>
<option value="f_PROFILE_FILLED">个人资料状态</option>
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
<form id="fmStuList" method="post" action="arrangeTutor.asp">
<input type="hidden" name="In_TEACHTYPE_ID2" value="<%=stu_type%>">
<input type="hidden" name="In_PERIOD_ID2" value="<%=period_id%>">
<input type="hidden" name="In_PAGE_NO2" value="<%=page_no%>">
<input type="hidden" name="In_PAGE_SIZE2" value="<%=page_size%>">
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite"><td><b>安排导师</b></td><td>
<table width="600" cellpadding="2" cellspacing="1" style="display: inline-block"><%
Dim ArrayList(1,5),k
Table="ViewRecruitInfo"
WhereStr="AND TEACHTYPE_ID="&stu_type&" AND PERIOD_ID="&period_id
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
ArrayList(k,2)="SPECIALITY_HASH"
ArrayList(k,3)="SPECIALITY_NAME"
ArrayList(k,4)=""
ArrayList(k,5)=WhereStr
FormName="fmStuList"
Get_ListJavaMenu ArrayList,k,FormName,""
%><td><input type="button" value="安排导师" onclick="if(Chk_Select())if(confirm('是否为所选的'+countClk()+'个学生安排导师？'))this.form.submit();" /></td>
<td align="right">全选<input type="checkbox" onclick="checkAll()" id="chk" name="chk" /></td></tr></table>
</td><td align="right"><input type="button" value="开放系统权限" onclick="setPermission(0)" />
<input type="button" value="关闭系统权限" onclick="setPermission(1)" />
<input type="button" value="删除权限记录" onclick="setPermission(2)" />
</td></tr></table>
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <!--报名学生信息-->
  <tr bgcolor="gainsboro" align="center" height="25">
    <td align="center" width="100">学号</td>
    <td width="150" align="center">姓名</td>
    <td width="50" align="center">性别</td>
		<td align="center">班级</td>
		<td align="center">系统权限</td>
		<td align="center">个人资料状态</td>
    <td width="30" align="center">选择</td>
  </tr>
  <%
  For i=1 to rs.PageSize
      If rs.EOF Then Exit For
  %>
  <tr bgcolor="ghostwhite">
    <td align="center"><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align="center"><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td align="center"><%=HtmlEncode(rs("SEX"))%></td>
    <td align="center"><%=HtmlEncode(rs("CLASS_NAME"))%></td>
    <td align="center"><%
			If rs("PERMITTED") Then
%><p class="true_flag">开放</p><%
			Else
%><p class="false_flag">不开放</p><%
			End If %></td>
    <td align="center"><%
			If rs("PROFILE_FILLED") Then
%><p class="true_flag">已填写</p><%
			Else
%><p class="false_flag">未完善</p><%
			End If %></td>
    <td align="center"><input type="checkbox" name="sel" value="<%=rs("STU_ID")%>">
	</td>
  </tr>
  <%
  rs.MoveNext
  Next
  %>
</table>
</form>
</center>
</body>
</html>
<%
  CloseConn conn
  CloseRs rs
%>