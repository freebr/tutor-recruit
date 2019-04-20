<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Tid")) Then Response.Redirect("../error.asp?timeout")
Dim stu_type,spec_hash,PubTerm,page_cur,page_size

stu_type=Request.Form("In_TEACHTYPE_ID")
spec_hash=Request.Form("In_SPECIALITY_HASH")
period_id=Request.Form("In_PERIOD_ID")
page_size=Request.Form("pageSize")
page_cur=Request.Form("pageNo")
finalFilter=Request.Form("finalFilter")
If IsEmpty(finalFilter) Then finalFilter=vbNullString

If Len(page_size)=0 Or Not IsNumeric(page_size) Then page_size=30 Else page_size=Int(page_size)
If Len(page_cur)=0 Or Not IsNumeric(page_cur) Then page_cur=1 Else page_cur=Int(page_cur)

FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(spec_hash)
FormGetToSafeRequest(period_id)

If IsEmpty(stu_type) Or IsEmpty(spec_hash) Or IsEmpty(period_id) Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim bOpen
sem_info=getCurrentSemester()
bOpen=tutclient.isOpenFor(Int(stu_type),SYS_OPR_CONFIRM)

Connect conn
sql="SELECT TURN_NUM FROM SystemSettings WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
GetRecordSetNoLock conn,rs,sql,result
show_turn_num=rs("TURN_NUM")

sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND SPECIALITY_HASH="&toSqlString(spec_hash)&" AND TEACHTYPE_ID="&stu_type&" AND PERIOD_ID="&period_id
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
Else
	recruit_id=rs("RECRUIT_ID")
	recruit_quota=rs("RECRUIT_QUOTA")
	count_confirmed=rs("CONFIRMED_NUM")
End If
CloseRs rs

sql="EXEC dbo.spQueryApplyInfo "&period_id&","&stu_type&","&recruit_id&","&show_turn_num&","&toSqlString(finalFilter)&","&page_size&","&page_cur
Set rs = conn.Execute(sql)
Set rs = rs.NextRecordSet()
count_rec = rs(0).Value
If page_size = -1 Then page_size = count_rec
count_page = count_rec/page_size
If Int(count_page)<>count_page Then count_page=Int(count_page)+1
Set rs = rs.NextRecordSet()

show_tutor_quota_tutor = getSystemOption("show_tutor_quota_tutor", stu_type)
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% useStylesheet("global") %>
<% useScript("common") %>
<script type="text/javascript" src="../scripts/tutor.js"></script>
<script type="text/javascript">
	window.tabmgr=parent.tabmgr;
</script>
<style type="text/css">
	p.accepted {color:#090}
	p.unaccepted {color:#00f;font-weight:bold}
	p.withdrawn {color:#c00}
</style>
</head>
<body bgcolor="ghostwhite">
<center>
<font size=4><b>已选导师学生名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>">
<input type="hidden" name="In_SPECIALITY_HASH" value="<%=spec_hash%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
<select id="field" name="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="d_APPLY_TIME">学生提交时间</option>
<option value="d_TUTOR_REPLY_TIME">导师确认/退回时间</option>
</select>
<select id="operator" name="operator">
<script>ReloadOperator()</script>
</select>
<input type="text" id="filter" name="filter" size="10" onkeypress="checkKey()">
<input type="hidden" id="finalFilter" name="finalFilter" value="<%=finalFilter%>">
<input type="submit" value="查找" onclick="genFilter()">
<input type="submit" value="在结果中查找" onclick="genFinalFilter()">
&nbsp;每页
<select name="pageSize" onchange="this.form.submit()">
<option value="-1" <%If page_size=-1 Then%>selected<%End If%>>全部</option>
<option value="30" <%If page_size=30 Then%>selected<%End If%>>30</option>
<option value="60" <%If page_size=60 Then%>selected<%End If%>>60</option>
<option value="90" <%If page_size=90 Then%>selected<%End If%>>90</option>
<option value="120" <%If page_size=120 Then%>selected<%End If%>>120</option>
</select>
条&nbsp;转到
<select name="pageNo" onchange="this.form.submit()">
<%
For i=1 to count_page
    Response.write "<option value="&i
    If page_cur=i Then Response.write " selected"
    Response.write ">"&i&"</option>"
Next
%></select>
页&nbsp;共<%=count_rec%>条
</td></tr></form></table>
<form id="fmConfirm" method="post" action="doChoice.asp?type=0">
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>">
<input type="hidden" name="In_SPECIALITY_HASH" value="<%=spec_hash%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<input type="hidden" name="In_PAGE_NO" value="<%=page_cur%>">
<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray" ID="Table2">
  <!--报名学生信息-->
  <tr bgcolor="gainsboro" align="center" height="25">
  	<td align=center>序号</td>
    <td width="100" align=center>学号</td>
    <td width="150" align=center>学生姓名</td>
    <td width="50" align=center>性别</td>
		<td align=center>班级</td>
    <td align=center>学生提交时间</td>
    <td align=center>导师确认/退回时间</td>
		<td align=center>状态</td>
    <td width="30" align=center>选择</td>
  </tr>
  <%
  Dim arrCssClass:arrCssClass=Array("","unaccepted","unaccepted","accepted","withdrawn")
  For i=1 to page_size
      If rs.EOF Then Exit For
    	stat=rs("APPLY_STATUS")
    	is_confirmed=Abs(CInt(stat=3))
      apply_info=rs("STU_ID")&"|"&rs("TURN_NUM")&"|"&is_confirmed
  %>
  <tr bgcolor="ghostwhite" height="25">
  	<td align=center><%=i%></td>
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
		<td align=center><%=HtmlEncode(rs("SEX"))%></td>
		<td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
		<td align=center><%=rs("APPLY_TIME")%></td>
		<td align=center><%=rs("TUTOR_REPLY_TIME")%></td>
		<td align=center><%
		cssClass=arrCssClass(stat)
		stat_text=rs("STATUS_TEXT")
		If stat=4 Then
			reason=rs("TUTOR_REPLY")
			If IsNull(reason) Then reason="未说明"
			stat_text=stat_text&"("&reason&")"
		End If
%><p class="<%=cssClass%>"><%=stat_text%></p></td>
    <td align=center><input type="checkbox" name="sel" value="<%=apply_info%>" /></td>
  </tr><%
  	rs.MoveNext()
  Next
  %>
</table>
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite">
<td width="250"><%
	If show_tutor_quota_tutor Then %>
本方向名额数:&nbsp;<strong><%=recruit_quota%></strong><br/><%
	End If %>
已确认人数:&nbsp;<strong><%=count_confirmed%></strong><%
	If show_tutor_quota_tutor Then %>
<br/>剩余名额:&nbsp;<strong><%=recruit_quota-count_confirmed%></strong><%
	End If %></td>
<td align="right">全选<input type="checkbox" onclick="checkAll()" id="chk" name="chk">
<input type="button" value="确认选择名单" onclick="doChoice(0)" <%If Not bOpen Then %>disabled <% End If %>/><br />
<input type="text" name="reasontext" id="reasontext" size="60" style="display:none" value="名额限制" onfocus="setTimeout('document.execCommand(\'selectAll\')',10)" />
<select id="withdrawreason" onpropertychange="switchReason(this.options[this.selectedIndex].value)" onchange="switchReason(this.options[this.selectedIndex].value)">
<option value="名额限制">名额限制</option>
<option value="专业不符">专业不符</option>
<option value="">其他</option>
</select>
<input type="button" value="退回填报" onclick="doChoice(1)" <%If Not bOpen Then %>disabled <% End If %>/>
<!--<input type="button" value="取消确认选择名单" onclick="this.form.action='cancelConfirm.asp';this.form.submit()" />--><%
If Not bOpen And Len(startdate) Then
%>
<table width="99%" cellpadding="2" cellspacing="1" bgcolor="#FFFF33">
<tr>
<td style="color:blue">提示：导师确认填报时间为&nbsp;<%=startdate%>&nbsp;至&nbsp;<%=enddate%>，当前还不是确认时间或系统设置为本专业禁止确认填报。</td></tr></table>
<%
End If %>
</td></tr></table>
</form>
</center>
</body>
</html>
<%
  CloseConn conn
  CloseRs rs
%>