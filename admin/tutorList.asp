<!--#include file="../inc/db.asp"-->
<%Response.Expires=-1
If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
Connect conn
finalFilter=Request.Form("finalFilter")
If Len(Request.Form("finalFilter")) Then finalFilter="AND "&finalFilter
sql="SELECT * FROM ViewTutorInfo WHERE 1=1 "&finalFilter&" ORDER BY TEACHER_NAME"
GetRecordSetNoLock conn,rs,sql,result
pageSize=Request.Form("pageSize")
If IsEmpty(pageSize) Or Not IsNumeric(pageSize) Then
  pageSize=-1
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
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/utils.js"></script>
<script type="text/javascript" src="../scripts/query.js"></script>
<script type="text/javascript" src="../scripts/admin.js"></script>
<style type="text/css">
	tr.valid {background-color:#ffffaa}
	tr.invalid {background-color:ghostwhite}
	input.editable {width:100%;background-color:#ffffff;border:1px solid #000000;text-align:center}
	input.disabled {width:100%;padding:3px 0;background:none;border:0;text-align:center}
</style>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>硕士生导师（含专业学位）名单</b><br>
<table cellspacing=4 cellpadding=0 width="95%">
<tr><td>
<form id="query" method="post" onsubmit="return chkField()">
<tr><td>
<!--查找-->
<select name="field" onchange="ReloadOperator()">
<option value="s_RECRUIT_TYPE_NAME">专业学位类型</option>
<option value="s_TEACHER_NAME">姓名</option>
<option value="n_DEFAULT_QUOTA">指导名额</option>
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
<br>
</td></tr>
</form>
</table>
<form id="delRs" method="post">
<table width="95%" cellpadding="2" cellspacing="1" bgcolor="dimgray" style="color:black">
<tr bgcolor="ghostwhite"><td>全选<input type="checkbox" onclick="checkAll()" id="chk" />
<input type="button" value="开 放" onclick="submitForm(this.form,'setValid.asp?valid=1')" />
<input type="button" value="不开放" onclick="submitForm(this.form,'setValid.asp?valid=0')" />
<input type="button" value="修 改" onclick="submitForm(this.form,'setSpec.asp')" />
<input type="button" value="从Excel文件导入" onclick="location.href='importTutorInfo.asp'" />
<input type="button" value="删 除" onclick="deleteTutor(this.form,countClk())" />
<input type="hidden" name="finalFilter2" value="<%=Request.Form("finalFilter")%>" />
<input type="hidden" name="pageSize2" value="<%=Request.Form("pageSize")%>" />
<input type="hidden" name="pageNo2" value="<%=Request.Form("pageNo")%>" />
</td></tr>
</table>
<table width="95%" cellpadding="2" cellspacing="1" bgcolor="dimgray">
  <tr bgcolor="gainsboro" height="25">
    <td width="100" align=center>姓名</td>
    <td width="80" align=center>出生年月</td>
    <td width="60" align=center>职称</td>
    <td width="160" align=center>学术型招生专业名称</td>
    <td width="200" align=center>专业学位类型</td>
    <td width="180" align=center>工程领域名称</td>
    <td width="50" align=center>主岗</td>
    <td width="50" align=center>兼岗</td>
    <td width="48" align=center>指导名额</td>
    <td align=center>备注</td>
  </tr><%
  For i=1 To rs.PageSize
  	If rs.EOF Then Exit For
  %>
  <tr class=<% If rs("VALID") THEN %>"valid"<% ELSE %>"invalid"<% END IF %>>
    <td>
    <input type="checkbox" id="sel" name="sel" value="<%=rs("ID")%>"><a href="/index/teacher_resume.asp?id=<%=rs("TEACHER_ID")%>" target="_blank"><%=HtmlEncode(rs("TEACHER_NAME"))%></a></td>
    <td align=center><%=HtmlEncode(rs("BIRTHDAY"))%></td>
    <td align=center><%=HtmlEncode(rs("PRO_DUTYNAME"))%></td>
    <td align=center><input type="text" id="spec" name="spec<%=rs("ID")%>" class="disabled" value="<%=HtmlEncode(rs("SPECIALITY_NAME"))%>" readonly /></td>
    <td align=center><%=HtmlEncode(rs("RECRUIT_TYPE_NAME"))%></td>
    <td align=center><%=HtmlEncode(rs("RESEARCH_WAYNAME"))%></td>
    <td align=center><%=HtmlEncode(rs("PRIMARY_TYPE"))%></td>
    <td align=center><%=HtmlEncode(rs("SECOND_TYPE"))%></td>
    <td align=center><%=rs("DEFAULT_QUOTA")%></td>
    <td align=center><%=HtmlEncode(rs("MEMO"))%></td>
  </tr><%
  	rs.MoveNext()
  Next
  %>
</table>
</form></center><script type="text/javascript">
	num=<%=rs.RecordCount%>;
	for(var i=0;i<num;i++) {
		var sel=document.getElementsByName("sel").item(i);
		sel.onchange=sel.onclick=function() {
			var spec=this.parentElement.parentElement.children[3].children[0];
			var className;
			if(this.checked) {
				className="editable";
			} else {
				className="disabled";
			}
			spec.className=className;
			spec.readOnly=!this.checked;
		}
	}
</script>
<%
  CloseRs rs
  CloseConn conn
%>