<%Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript(Array("utils","query")) %>
<style type="text/css">
	p.accepted {color:#0c0}
	p.unaccepted {color:#00f;font-weight:bold}
	p.withdrawn {color:#c00}
</style>
<script type="text/javascript">
	function showStudentInfo(id) {
		location.href="showStudentInfo.asp?id="+id;
		return false;
	}
	function showTeacherResume(id) {
		window.open("/index/teacher_resume.asp?id="+id);
		return false;
	}
</script>
</head>
<body bgcolor="ghostwhite">
<center>
<%
Dim object,PubTerm,page_no,page_size

object=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
query_recruit_status=Request.Form("In_RECRUIT_STATUS")
finalFilter=Request.Form("finalFilter")
FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

If period_id="" or object="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If
If Len(finalFilter) Then finalFilter=" AND ("&finalFilter&")"
PubTerm="AND TUTOR_PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&object&finalFilter
If Len(query_recruit_status) And query_recruit_status<>"-1" Then
	PubTerm=PubTerm&" AND TUTOR_RECRUIT_STATUS="&toSqlString(query_recruit_status)
End If
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
sql="SELECT * FROM VIEW_STUDENT_CHOOSE_TUTOR_INFO WHERE 1=1 "&PubTerm&" ORDER BY TURN_NUM DESC,TUTOR_RECRUIT_STATUS DESC,APPLY_TIME DESC,CLASS_NAME,STU_NAME"
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
%><font size=4><b>已选导师学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
填报状态：<select name="In_RECRUIT_STATUS"><option value="-1">所有</option><%
GetMenuListPubTerm "ApplyStatusInfo","ID","Name",query_recruit_status,"AND ID>0"
%></select>
<select name="field" id="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_CLASS_NAME">班级</option>
<option value="n_TURN_NUM">批次</option>
<option value="d_APPLY_TIME">提交时间</option>
<option value="s_TEACHERNAME">所选导师</option>
<option value="s_SPECIALITY_NAME">所选专业</option>
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
<form id="fmView" method="post" action="setChoiceStat.asp">
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<input type="hidden" name="In_RECRUIT_STATUS" value="<%=query_recruit_status%>">
<input type="hidden" name="In_PAGE_NO" value=<%=page_no%>>
<input type="hidden" name="In_PAGE_SIZE" value=<%=page_size%>>
<input type="hidden" name="finalFilter2" value="<%=Request.Form("finalFilter")%>">
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite">
<td width="110"><input type="button" value="导出到Excel文件" onclick="this.form.action='exportChoiceList.asp';this.form.submit();" /></td>
<td align="right">
全选<input type="checkbox" onclick="checkAll()" id="chk">&nbsp;
<input type="button" value="设为学生未提交状态" onclick="if(<%=IfChk%>confirm('是否将所选'+countClk()+'个学生的填报记录设为学生未提交状态？')){this.form.action='setChoiceStat.asp?stat=1';this.form.submit();}" />
<input type="button" value="设为导师未确认状态" onclick="if(<%=IfChk%>confirm('是否将所选'+countClk()+'个学生的填报记录设为导师未确认状态？')){this.form.action='setChoiceStat.asp?stat=2';this.form.submit();}" />
<input type="button" value="删除填报记录" onclick="if(<%=IfChk%>confirm('是否删除所选'+countClk()+'个学生的填报记录？这将恢复到未填报状态！'))this.form.submit();" />
</td></tr></table>
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" align="center" height=25>
    <td width="100" align=center>学号</td>
    <td width="150" align=center>学生姓名</td>
    <td width="50" align=center>性别</td>
    <td align=center>班级</td>
    <td align=center>批次</td>
    <td align=center>提交时间</td>
		<td align=center>所选导师</td>
		<td width="120" align=center>所选专业</td>
		<td align=center>状态</td>
    <td width="30" align=center>选择</td>
  </tr>
  <%
  Dim arrCssClass:arrCssClass=Array("","unaccepted","unaccepted","accepted","withdrawn")
  For i=1 to rs.PageSize
    If rs.EOF Then Exit For
    	stat=rs("TUTOR_RECRUIT_STATUS")
  %>
  <tr bgcolor="ghostwhite">
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td align=center><%=HtmlEncode(rs("SEX"))%></td>
    <td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
		<td align=center>第&nbsp;<%=rs("TURN_NUM")%>&nbsp;批</td>
		<td align=center><%=rs("APPLY_TIME")%></td>
    <td align=center><a href="#" onclick="return showTeacherResume('<%=rs("TUTOR_ID")%>')"><%=HtmlEncode(rs("TEACHERNAME"))%></a></td>
		<td align=center><%=HtmlEncode(rs("SPECIALITY_NAME"))%></td>
		<td align=center><%
		cssClass=arrCssClass(stat)
		stat_text=rs("STATUS_TEXT")
		If stat=4 Then
			reason=rs("REASON")
			If IsNull(reason) Then reason="未说明"
			stat_text=stat_text&"("&reason&")"
		End If
%><p class="<%=cssClass%>"><%=stat_text%></p></td>
    <td align=center><input type="checkbox" name="sel" value="<%=rs("STU_ID")%>"></td>
  </tr><%
  	rs.MoveNext()
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