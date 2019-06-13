<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("StuId")) Then Response.Redirect("../error.asp?timeout")%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<link href="../css/global.css" rel="stylesheet" type="text/css">
<% useScript "jquery", "common", "student" %>
</head>
<body bgcolor="ghostwhite">
<center>
<%
Connect conn
stuType=Session("StuType")
pageSize=Request.Form("pageSize")
pageCur=Request.Form("pageNo")
finalFilter=Request.Form("finalFilter")
If IsEmpty(finalFilter) Then finalFilter=vbNullString

If Len(pageSize)=0 Or Not IsNumeric(pageSize) Then pageSize=20 Else pageSize=Int(pageSize)
If Len(pageCur)=0 Or Not IsNumeric(pageCur) Then pageCur=1 Else pageCur=Int(pageCur)

If Not bSystemOpen Then disabled_flag=" disabled"
sql="SELECT TURN_NUM FROM SystemSettings WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
GetRecordSetNoLock conn,rs,sql,result
If rs.EOF Then
	nTurn=0
Else
	nTurn=rs("TURN_NUM").Value
End If
bRefill=False

sql="SELECT * FROM ViewApplyInfo WHERE STU_ID="&Session("Stuid")
GetRecordSetNoLock conn,rs,sql,result
If Not rs.EOF Then
	For i=1 To 3
		If IsNull(rs("RECRUIT_ID"&i)) Then Exit For
		choiceSavedCount=choiceSavedCount+1
		If rs("APPLY_STATUS"&i)=3 Or apply_status<=rs("APPLY_STATUS"&i) And apply_status<>3 Then
			apply_status=rs("APPLY_STATUS"&i)
			handled_turn_num=i
			If apply_status>=3 Then
				tutor_name=rs("TUTOR_NAME"&i)
				If apply_status=4 Then
					reason=rs("TUTOR_REPLY"&i)
					If IsNull(reason) Then reason="未说明"
				End If
			End If
		ElseIf apply_status>=3 And rs("APPLY_STATUS"&i)=1 Then	' 学生有重新提交志愿的情形
			apply_status=1
			bRefill=True
		End If
	Next
End If
%><p><font size=4><b><%=cur_year%>-<%=cur_year+1%>年度<%=cur_semester_name%>学期工商管理学院硕士研究生在线选导师系统</b></font><br />
(开放时间:<%=FormatDateTime(startdate,1)%>～<%=FormatDateTime(enddate,1)%>)</p>
<%
If Not bSystemOpen Then
%>
<p align="center"><span class="tip">注意：本专业上传通道已关闭或当前不在开放时间内，只能查看信息，不能提交！</span></p><%
End If
If Not checkIfProfileFilledIn() Then
%>
<p align="center"><span class="tip">温馨提示：您尚未完善个人资料，请在右上方点击&quot;个人资料修改&quot;完成相关必填项再提交填报。</span></p><%
End If

%>
<ul class="recruitprogress"><%
	Dim arrStepImg:arrStepImg=Array("","step1","step2","step3","step4")
	step_latest=apply_status+1
	If step_latest>4 Then step_latest=4
	For i=1 To UBound(arrStepImg)
		imgfile=arrStepImg(i)
		If i>step_latest Then imgfile=imgfile&"_d"
		imgfile=imgfile&".png"
%><li><span id="step<%=i%>" style="background-image:url(../images/<%=imgfile%>)"></span></li><%
	Next
%></ul><%
If choiceSavedCount>0 Then ' 显示已填报信息 %>
<table width="1000" cellpadding="0" cellspacing="1" bgcolor="dimgray" style="margin:10px 0;text-align: center">
<thead><tr bgcolor="gainsboro" height="25"><td colspan="5"><p style="text-align: left;font-weight:bold">&emsp;您已填报的信息如下：<%
	Select Case apply_status
	Case 1
		If bSystemOpen Then
%>&nbsp;<%
			If Not bRefill Then
%><button id="btnCancelChoice">取消填报</button><%
			End If %>
<button id="btnConfirmChoice" style="font-weight:bold">确认填报</button>&nbsp;
<span class="tip">请点击左边的“确认填报”按钮，确认后填报信息将不能再更改！</span><%
		End If
	Case 2
%>&nbsp;<span style="color:blue">(当前状态：您已确认填报，请等候导师确认)</span><%
	Case 3
%>&nbsp;<span style="color:blue">(当前状态：导师[<%=tutor_name%>]已确认您的<%=arrTurnName(handled_turn_num)%>填报)</span><%
	Case 4
%>&nbsp;<span style="color:blue">(导师[<%=tutor_name%>]已退回您的<%=arrTurnName(handled_turn_num)%>填报，退回原因为：<%=reason%>)</span><%
	End Select
%></p></td></tr></thead>
<tbody><tr bgcolor="gainsboro" height="25">
  <td width="100">志愿名称</td>
	<td width="100">条目代码</td>
	<td width="300">专业</td>
	<td width="300">选择导师</td>
	<td>导师意见</td></tr><%
	For i=1 To choiceSavedCount
		apply_status=rs("APPLY_STATUS"&i)
		recruit_id=rs("RECRUIT_ID"&i)
		css_class="choicesaved"
		If apply_status="3" Then
			css_class=css_class&" choiceaccepted"
		ElseIf apply_status="4" Then
			css_class=css_class&" choicewithdrawn"
		End If
%>
	<tr class="<%=css_class%>" bgcolor="ghostwhite" height="40">
	<td valign="middle"><%=arrTurnName(i)%></td><%
  	If recruit_id<>0 Then %>
  <td valign="middle"><% Response.Write(recruit_id)%></td>
	<td valign="middle"><% If rs("TUTOR_ID"&i)<>0 Then Response.Write(HtmlEncode(rs("SPECIALITY_NAME"&i)))%></td><%
		Else %>
	<td valign="middle" colspan="2"></td><%
		End If %>
  <td valign="middle"><a href="#" onclick="return showTeacherResume(<%=rs("TUTOR_ID"&i)%>)"><%=HtmlEncode(rs("TUTOR_NAME"&i))%></a></td>
	<td valign="middle"><%
		Select Case apply_status
    Case 1
%><p class="unaccepted">未提交</p><%
    Case 2
%><p class="unaccepted">未确认</p><%
    Case 3
%><p class="accepted">已确认</p><%
		Case 4
%><p class="withdrawn">已退回</p><%
		End Select %></td></tr><%
	Next %>
</tbody></table><%
End If

If apply_status<=1 Then	' 显示填报新信息
%>
<table width="1000" cellpadding="0" cellspacing="1" bgcolor="dimgray" style="margin:10px 0;text-align: center">
<thead>
<tr bgcolor="gainsboro" height="25"><td colspan="5"><p style="font-weight:bold">&emsp;填报新的选导师信息（第一、二志愿必填）</p></td></tr>
<tr bgcolor="gainsboro" height="25">
<td width="100">志愿名称</td>
<td width="100">条目代码</td>
<td width="300">专业</td>
<td width="300">选择导师</td>
<td>操作</td></tr></thead>
<tbody><%
	Dim bWithdrawn,cssClass,recruitID
	For i=1 To 3
		cssClass="choicenew"
		If rs.EOF Then
			bWithdrawn=False
		Else
			bWithdrawn=(rs("APPLY_STATUS"&i)=4)
		End If
		If bWithdrawn Then	' 隐藏被退回的志愿
			cssClass=cssClass&" hidden"
			recruitID=rs("RECRUIT_ID"&i)
		Else
			recruitID=""
		End If
	%>
	<tr class="<%=cssClass%>" bgcolor="ghostwhite" height="25">
	<td valign="middle"><%=arrTurnName(i)%></td>
  <td width="40" valign="middle"><%=recruitID%></td>
	<td valign="middle"></td>
  <td valign="middle"></td>
	<td valign="middle">
	<p><a href="#" onclick="return selectTutor(this)">选择导师</a><%
	If i<=choiceSavedCount Then %>&emsp;<a href="#" onclick="return copyChoiceFromSaved(this)">从上表提取</a><%
	End If %></p>
	<div class="choicecontrol"><a href="#" onclick="recruitMoveUp(this);return false" title="上移"><span class="moveup">&emsp;</span></a>
	<a href="#" onclick="recruitMoveDown(this);return false" title="下移"><span class="movedown">&emsp;</span></a>
	<a href="#" onclick="return clearSelection(this)" title="删除选择"><span class="delete">&emsp;</span></a></div>
	</td></tr><%
	Next %>
</tbody></table>
<p><button id="btnSubmitChoice" style="font-weight:bold"<%=disabled_flag%>>提交填报信息</button></p><%
End If %>
</center>
<%
  CloseConn Conn
  CloseRs rs
%>
<script type="text/javascript">
	function callback(args) {
		var $col=$('tr.choicenew').eq(args[0]-1).children();
		$col.eq(1).text(args[2]);
		$col.eq(2).text(args[1]);
		$col.eq(3).text(args[4]);
		$col.find('div.choicecontrol').show();
		return;
	}
	$(document).ready(function(){
		$('div.choicecontrol').hide();
		$('button#btnSubmitChoice').click(submitChoice);
		$('button#btnCancelChoice').click(cancelChoice);
		$('button#btnConfirmChoice').click(confirmChoice);
	});
</script>