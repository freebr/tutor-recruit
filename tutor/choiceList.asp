<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include File="common.asp"-->
<%If IsEmpty(Session("Tuser")) Then Response.Redirect("../error.asp?timeout")
Dim object,Speciality_Name,PubTerm,page_no,page_size

object=Request.Form("In_TEACHTYPE_ID")
Speciality_Name=Request.Form("In_SPECIALITY_NAME")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter")

FormGetToSafeRequest(object)
FormGetToSafeRequest(Speciality_Name)
FormGetToSafeRequest(period_id)

If object="" or Speciality_Name="" or period_id="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

Dim tut_startdate,tut_enddate,bOpen
bOpen=tutclient.isOpenFor(Int(object),SYS_OPR_CONFIRM)
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
sql="SELECT * FROM ViewRecruitInfo WHERE TEACHER_ID="&Session("tid")&" AND SPECIALITY_NAME="&toSqlString(Speciality_Name)&" AND TEACHTYPE_ID="&object&" AND PERIOD_ID="&period_id
Set rs=conn.Execute(sql)
If rs.EOF Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
Else
	recruitID=rs("RECRUIT_ID")
	recruitQuota=rs("RECRUIT_QUOTA")
	confirmedNum=rs("CONFIRMED_NUM")
End If
CloseRs rs

If Len(finalFilter) Then finalFilter=" AND ("&finalFilter&")"
PubTerm="AND TUTOR_RECRUIT_ID="&recruitID&" AND TEACHTYPE_ID="&object&finalFilter
sql="SELECT * FROM VIEW_STUDENT_CHOOSE_TUTOR_INFO WHERE TUTOR_RECRUIT_STATUS IN (2,3,4) "&PubTerm&" ORDER BY TURN_NUM DESC,TUTOR_RECRUIT_STATUS DESC,APPLY_TIME,CLASS_NAME,STU_NAME"
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
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript(Array("query","utils")) %>
<script type="text/javascript" src="../scripts/tutor.js"></script>
<style type="text/css">
	p.accepted {color:#0c0}
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
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_SPECIALITY_NAME" value="<%=Speciality_Name%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
<select id="field" name="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="n_TURN_NUM">批次</option>
<option value="d_APPLY_TIME">提交时间</option>
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
<option value="120" <%If rs.PageSize=120 Then%>selected<%End If%>>120</option>
<option value="240" <%If rs.PageSize=240 Then%>selected<%End If%>>240</option>
<option value="360" <%If rs.PageSize=360 Then%>selected<%End If%>>360</option>
<option value="480" <%If rs.PageSize=480 Then%>selected<%End If%>>480</option>
</select>
条&nbsp;转到
<select name="pageNo" onchange="this.form.submit()">
<%
For i=1 to rs.PageCount
    Response.write "<option value="&i
    If rs.AbsolutePage=i Then Response.write " selected"
    Response.write ">"&i&"</option>"
Next
%></select>
页&nbsp;共<%=rs.recordCount%>条
</td></tr></form></table>
<form id="fmConfirm" method="post" action="doConfirm.asp?type=0">
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_SPECIALITY_NAME" value="<%=Speciality_Name%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>">
<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>">
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray" ID="Table2">
  <!--报名学生信息-->
  <tr bgcolor="gainsboro" align="center" height="25">
  	<td align=center>序号</td>
    <td width="100" align=center>学号</td>
    <td width="150" align=center>学生姓名</td>
    <td width="50" align=center>性别</td>
		<td align=center>班级</td>
    <td align=center>批次</td>
    <td align=center>提交时间</td>
		<td align=center>状态</td>
    <td width="30" align=center>选择</td>
  </tr>
  <%
  Dim arrCssClass:arrCssClass=Array("","unaccepted","unaccepted","accepted","withdrawn")
  For i=1 to rs.PageSize
      If rs.EOF Then Exit For
    	stat=rs("TUTOR_RECRUIT_STATUS")
  %>
  <tr bgcolor="ghostwhite" height="25">
  	<td align=center><%=i%></td>
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo('<%=rs("STU_ID")%>')"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
		<td align=center><%=HtmlEncode(rs("SEX"))%></td>
		<td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
		<td align=center>第&nbsp;<%=rs("TURN_NUM")%>&nbsp;批</td>
		<td align=center><%=rs("APPLY_TIME")%></td>
		<td align=center><%
		cssClass=arrCssClass(stat)
		stat_text=rs("STATUS_TEXT")
		If stat=4 Then
			reason=rs("REASON")
			If IsNull(reason) Then reason="未说明"
			stat_text=stat_text&"("&reason&")"
		End If
%><p class="<%=cssClass%>"><%=stat_text%></p></td>
    <td align=center><input type="checkbox" name="sel" value="<%=rs("STU_ID")%>" /></td>
    <input type="hidden" name="s<%=rs("STU_ID")%>" value="<%=Abs(CInt(rs("TUTOR_RECRUIT_STATUS")=3))%>" />
  </tr><%
  	rs.MoveNext()
  Next
  %>
</table>
<table width="900" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite">
<td width="250">
本方向名额数:&nbsp;<strong><%=recruitQuota%></strong><br />已确认人数:&nbsp;<strong><%=confirmedNum%></strong>&nbsp;剩余名额:&nbsp;<strong><%=recruitQuota-confirmedNum%></strong></td>
<td align="right">全选<input type="checkbox" onclick="checkAll()" id="chk" name="chk">
<input type="button" value="确认选择名单" onclick="doChoice(0)" <%If Not bOpen Then %>disabled <% End If %>/><br />
<input type="text" name="reasontext" id="reasontext" size="25" style="display:none" onmouseup="setTimeout('document.execCommand(\'selectAll\')',10)" />
<select id="withdrawreason" onpropertychange="switchReason(this.options[this.selectedIndex].value)" onchange="switchReason(this.options[this.selectedIndex].value)">
<option value="名额限制">名额限制</option>
<option value="专业不符">专业不符</option>
<option value="">其他</option>
</select>
<input type="button" value="退回填报" onclick="doChoice(1)" <%If Not bOpen Then %>disabled <% End If %>/>
<!--<input type="button" value="取消确认选择名单" onclick="this.form.action='cancelConfirm.asp';this.form.submit()" />--><%
If Not bOpen And Len(tut_startdate) Then
%>
<table width="99%" cellpadding="2" cellspacing="1" bgcolor="#FFFF33">
<tr>
<td style="color:blue">提示：导师确认填报时间为&nbsp;<%=tut_startdate%>&nbsp;至&nbsp;<%=tut_enddate%>，当前还不是确认时间或系统设置为本专业不允许对填报进行确认。</td></tr></table>
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