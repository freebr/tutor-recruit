<%Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/admin.js"></script>
<script type="text/javascript">
	window.tabmgr=parent.tabmgr;
</script>
<style type="text/css">
	span.accepted {color:#090}
	span.unaccepted {color:#00f}
	span.withdrawn {color:#c00}
	span.hidden {color:#666}
</style>
</head>
<body bgcolor="ghostwhite" onload="On_Load();">
<center>
<%
	Dim object,PubTerm,PageNo,PageSize

	object=Request.Form("In_TEACHTYPE_ID")
	period_id=Request.Form("In_PERIOD_ID")
	query_apply_status=Request.Form("In_APPLY_STATUS")
	finalFilter=Request.Form("finalFilter")
	FormGetToSafeRequest(object)
	FormGetToSafeRequest(period_id)

	If period_id="" or object="" Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">请选择条件！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.end
	End If
	If Len(finalFilter) Then finalFilter=" AND ("&finalFilter&")"
	PubTerm="AND PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&object&finalFilter

	If Len(query_apply_status)=0 Then query_apply_status="-1"
	If query_apply_status<>"-1" Then
		PubTerm=PubTerm&" AND APPLY_STATUS="&toSqlString(query_apply_status)
	End If
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
	sql="SELECT * FROM VIEW_TUTOR_STUDENT_APPLY_INFO WHERE 1=1 "&PubTerm&" ORDER BY APPLY_TIME DESC"
	GetRecordSetNoLock conn,rs,sql,result
	If PageSize<>"" Then
		rs.PageSize=CInt(PageSize)
	Else
		rs.PageSize=120
		PageSize=120
	End If
	If PageNo<>"" Then
		If CInt(PageNo)<=rs.PageCount Then
		  rs.AbsolutePage=CInt(PageNo)
		Else
		  If rs.PageCount<>0 Then rs.AbsolutePage=1
		End If
	Else
		If rs.PageCount<>0 Then rs.AbsolutePage=1
		PageNo=1
	End If
%><font size=4><b>已选导师学员名单</b></font>
<table cellspacing=4 cellpadding=0>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<!--查找-->
填报状态：<select name="In_APPLY_STATUS"><option value="-1">所有</option><%
GetMenuListPubTerm "CODE_TUTOR_RECRUIT_STATUS","ID","STATUS_NAME",query_apply_status,"AND ID>0"
%></select>
<select name="field" id="field" onchange="ReloadOperator()">
<option value="s_STU_NAME">学生姓名</option>
<option value="s_STU_NO">学号</option>
<option value="s_CLASS_NAME">班级</option>
<option value="d_APPLY_TIME">学生提交时间</option>
<option value="ms_TUTOR_NAME1|TUTOR_NAME2|TUTOR_NAME3">所选导师</option>
<option value="ms_SPECIALITY_NAME1|SPECIALITY_NAME2|SPECIALITY_NAME3">所选专业</option>
<option value="s_TUTOR_NAME">最终确认导师</option>
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
<form id="fmView" method="post" action="setApplyStatus.asp">
<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
<input type="hidden" name="In_APPLY_STATUS" value="<%=query_apply_status%>">
<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
<input type="hidden" name="finalFilter2" value="<%=Request.Form("finalFilter")%>">
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
<tr bgcolor="ghostwhite">
<td width="110"><input type="button" value="导出到Excel文件" onclick="this.form.action='exportChoiceList.asp';this.form.submit();" /></td>
<td align="right">
全选<input type="checkbox" onclick="checkAll()" id="chk">&nbsp;
<input type="button" value="导出学生个人信息" onclick="this.form.action='batchExportProfile.asp';this.form.submit();" />
<input type="button" value="设为学生未提交状态" onclick="if(confirm('是否将所选填报记录设为学生未提交状态？')){this.form.action='setApplyStatus.asp?stat=1';this.form.submit();}" />
<input type="button" value="设为导师未确认状态" onclick="if(confirm('是否将所选填报记录设为导师未确认状态？')){this.form.action='setApplyStatus.asp?stat=2';this.form.submit();}" />
<input type="button" value="设为导师已确认状态" onclick="if(confirm('是否将所选填报记录设为导师已确认状态？')){this.form.action='setApplyStatus.asp?stat=3';this.form.submit();}" />
<input type="button" value="设为导师已退回状态" onclick="if(confirm('是否将所选填报记录设为导师已退回状态？')){this.form.action='setApplyStatus.asp?stat=4';this.form.submit();}" />
<input type="button" value="显示" onclick="if(confirm('是否将所选填报记录设为对导师可见？')){this.form.action='setApplyStatus.asp?show';this.form.submit();}" />
<input type="button" value="隐藏" onclick="if(confirm('是否将所选填报记录设为对导师隐藏？')){this.form.action='setApplyStatus.asp?hide';this.form.submit();}" />
<input type="button" value="删除填报记录" onclick="if(confirm('是否删除所选填报记录？这将恢复到未填报状态！'))this.form.submit();" />
</td></tr>
<tr bgcolor="ghostwhite"><td colspan="2"><table width=600" cellpadding="2" cellspacing="1"><%
	Dim ArrayList(1,5),k
	Table="VIEW_TUTOR_RECRUIT_INFO"
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
	FormName="fmView"
	Get_ListJavaMenu ArrayList,k,FormName,""
%><td>填报状态：<select name="apply_status"><%
	For i=0 To UBound(arrApplyStatus)
%><option value="<%=arrApplyStatus(i)(0)%>"><%=arrApplyStatus(i)(1)%></option><%
	Next
%></select></td>
<td><input type="button" value="修改填报信息" onclick="if(Chk_Select())if(confirm('是否修改所选的填报信息？')){this.form.action='updateApply.asp';this.form.submit();}"></td>
</tr></table></td></tr></table>
<table width="1000" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" align="center" height=25>
    <td width="100" align=center>学号</td>
    <td width="60" align=center>学生姓名</td>
    <td width="120" align=center>班级</td>
    <td width="80" align=center>学生提交时间</td>
		<td width="120" align=center>第一志愿</td>
		<td width="120" align=center>第二志愿</td>
		<td width="120" align=center>第三志愿</td>
		<td width="60" align=center>确认导师</td>
		<td align=center>填报状态</td>
    <td width="30" align=center>选择</td>
  </tr>
  <%
  Dim arrCssClass:arrCssClass=Array("","unaccepted","unaccepted","accepted","withdrawn")
  For i=1 to rs.PageSize
    If rs.EOF Then Exit For
  	If IsNull(rs("TUTOR_REPLY_TIME")) Then
  		tutor_reply_time=""
  	Else
  		tutor_reply_time="<br/>@ "&FormatDateTime(rs("TUTOR_REPLY_TIME"),2)&"<br/>"&FormatDateTime(rs("TUTOR_REPLY_TIME"),3)
		End If
  %>
  <tr bgcolor="ghostwhite">
    <td align=center><%=HtmlEncode(rs("STU_NO"))%></td>
    <td align=center><a href="#" onclick="return showStudentInfo(<%=rs("STU_ID")%>);"><%=HtmlEncode(rs("STU_NAME"))%></a></td>
    <td align=center><%=HtmlEncode(rs("CLASS_NAME"))%></td>
		<td align=center><%=FormatDateTime(rs("APPLY_TIME"),2)%><br/><%=FormatDateTime(rs("APPLY_TIME"),4)%></td><%
		For j=1 To 3
			stat=rs("APPLY_STATUS"&j) %>
    <td align=center>
    <input type="checkbox" name="sel_turn" value="<%=rs("STU_ID")%>|<%=j%>"><%
    	If Not IsNull(rs("RECRUIT_ID"&j)) Then %>
   	<a href="#" onclick="return showTeacherResume('<%=rs("TUTOR_ID"&j)%>')"><%=HtmlEncode(rs("TUTOR_NAME"&j))%></a><br/><%=HtmlEncode(rs("SPECIALITY_NAME"&j))%><br/><%
				stat_text=rs("APPLY_STATUS_NAME"&j)
				If stat=4 Then
					reason=rs("TUTOR_REPLY"&j)
					If IsNull(reason) Then reason="未说明"
					stat_text=stat_text&"("&reason&")"
				End If
				If rs("VALID"&j) Then
					cssClass=arrCssClass(stat)
				Else
					cssClass="hidden"
					stat_text=stat_text&"[隐藏]"
				End If
%><span class="<%=cssClass%>"><%=stat_text%></span></p><%
			End If %></td><%
		Next %>
    <td align=center><%
   	If rs("TUTOR_ID")<>0 Then
%><a href="#" onclick="return showTeacherResume(<%=rs("TUTOR_ID")%>);"><p><%=HtmlEncode(rs("TUTOR_NAME"))%></p></a><%
		End If
%></td>
		<td align=center><%=rs("APPLY_STATUS_NAME")%><%=tutor_reply_time%></td>
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
  CloseRs rs
  CloseConn conn
%>