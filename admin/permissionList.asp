<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/admin.js"></script>
<style type="text/css">
	p.permitted {color:#0c0}
	p.unpermitted {color:#aaa}
</style>
</head>
<body bgcolor="ghostwhite">
<center>
<%
Dim finalFilter,PageNo,PageSize

finalFilter=Request.Form("finalFilter")
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
If Len(finalFilter) Then finalFilter="AND "&finalFilter
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
sql="SELECT STU_ID,STU_NO,STU_NAME,SEX,CLASS_NAME,dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6') AS ISPERMITTED FROM VIEW_STUDENT_INFO_NEW WHERE Valid=0 "&finalFilter&_
		" AND (dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA6')=1 OR dbo.hasPrivilege(WRITEPRIVILEGETAGSTRING,'SA7')=1 "&_
		"OR dbo.hasPrivilege(READPRIVILEGETAGSTRING,'SA6')=1 OR dbo.hasPrivilege(READPRIVILEGETAGSTRING,'SA7')=1) ORDER BY ENTER_YEAR DESC,ISPERMITTED,CLASS_NAME,STU_NAME"
GetRecordSetNoLock conn,rs,sql,result
If IsEmpty(pageSize) Or Not IsNumeric(pageSize) Then
  pageSize=60
Else
	pageSize=CInt(pageSize)
End If
If pageSize=-1 Then
	If rs.RecordCount>0 Then rs.PageSize=rs.RecordCount
Else
  rs.PageSize=pageSize
End If
pageNo=Request.Form("pageNo")
If IsEmpty(pageNo) Or Not IsNumeric(pageNo) Then
	If rs.PageCount<>0 Then pageNo=1
Else
	pageNo=CInt(pageNo)
  If pageNo>rs.PageCount Then
	  If rs.PageCount<>0 Then pageNo=1
	End If
End If
If rs.RecordCount>0 Then rs.AbsolutePage=pageNo
%>
<font size=4><b>开放选导师系统权限学员名单</b></font>
<form id="fmUpload" action="importPermissionList.asp?step=1" method="POST" enctype="multipart/form-data">
<table width="95%" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite"><td style="font-weight:bold">从Excel文件导入开放系统权限学员名单（<a href="template/permissionlist.xls" target="_blank">点击此处下载名单模板</a>）</td></tr>
<tr bgcolor="ghostwhite"><td>
<p>请选择要导入的 Excel 文件：<br />文件名：<input type="file" name="upfile" size="100" />
<input type="hidden" name="filen" id="filen" /></p>
</td></tr></table>
</form>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<!--查找-->
<select name="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_CLASS_NAME">班级</option>
<option value="f_ISPERMITTED">系统权限</option>
</select>
<select name="operator">
<script>ReloadOperator()</script>
</select>
<input type="text" name="filter" size="10" onkeypress="checkKey()">
<input type="hidden" name="finalFilter" value="<%=Request.Form("finalFilter")%>">
<input type="submit" value="查找" onclick="genFilter()">
<input type="submit" value="在结果中查找" onclick="genFinalFilter()">
&nbsp;
每页
<select name="pageSize" onchange="this.form.submit()">
<option value="-1" <%If pageSize=-1 Then%>selected<%End If%>>全部</option>
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
共<%=rs.RecordCount%>条
</td><td>全选<input type="checkbox" onclick="checkAll()" id="chk" />&nbsp;<input type="button" value="开放" onclick="setPermission(0)">&nbsp;<input type="button" value="关闭" onclick="setPermission(1)">
&nbsp;<input type="button" value="删除权限记录" onclick="setPermission(2)"></td></tr></form></table>
<form id="fmStuList" method="post" action="setPermission.asp?open=0">
<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
<table width="95%" cellpadding="2" cellspacing="1" bgcolor="dimgray">
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
</center>
<script type="text/javascript">
	document.all.fmUpload.upfile.onchange=function() {
		var fileName = this.value;
		var fileExt = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
		if (fileExt != ".xls" && fileExt != ".xlsx") {
			alert("所选文件不是 Excel 文件！");
			this.form.reset();
			return false;
		}
		document.all.filen.value=document.all.upfile.value;
		this.form.submit();
	}
</script>
</body>
</html>
<%
  CloseConn conn
  CloseRs rs
%>