<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
stat=Request.QueryString("stat")
If stat="" Then stat=0
stu_type=Request.Form("In_TEACHTYPE_ID2")
period_id=Request.Form("In_PERIOD_ID2")
finalFilter=Request.Form("finalFilter2")
page_no=Request.Form("In_PAGE_NO2")
page_size=Request.Form("In_PAGE_SIZE2")
FormGetToSafeRequest(stat)
FormGetToSafeRequest(stu_type)
FormGetToSafeRequest(period_id)

If Not IsNumeric(stat) Then
	errdesc="参数无效。":bError=True
ElseIf stat<0 Or stat>4 Then
	errdesc="参数无效。":bError=True
ElseIf IsEmpty(period_id) Or IsEmpty(stu_type) Then
	errdesc="参数无效。":bError=True
End If
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim conn,sql
Dim mail_id:mail_id=getTutorSystemMailIdByType(Now)
Dim ids:ids=Replace(Request.Form("sel")," ","")
Dim id_turns:id_turns=Replace(Request.Form("sel_turn")," ","")
Dim arrSelStu:arrSelStu=Split(ids,",")
Dim arrSelTurn:arrSelTurn=Split(id_turns,",")
Dim dictStu:Set dictStu=Server.CreateObject("Scripting.Dictionary")
Dim bSendEmail:bSendEmail=False

ConnectDb conn
Select Case stat
Case Empty
	Dim oper:oper=Request.QueryString()
	If Len(oper) Then
		Dim valid
		If oper="show" Then
			valid="1"
		Else
			valid="0"
		End If
		sql="EXEC spSetApplyDisplayState "&toSqlString(id_turns)&","&valid
		conn.Execute sql
	Else	' 删除记录
		' 删除所选学生的全部填报信息
		sql="EXEC spDeleteApplyInfo 0,"&toSqlString(ids)
		conn.Execute sql
		' 删除所选学生的指定填报信息
		sql="EXEC spDeleteApplyInfo 1,"&toSqlString(id_turns)
		conn.Execute sql
	End If
Case 1,2,3,4	' 未提交/导师未确认/导师已确认/导师已退回
	If stat=1 Or stat=2 Then
		' 设置所选学生的全部填报信息
		sql="EXEC spBatchSetApplyInfo 0,"&toSqlString(ids)&",NULL,NULL,NULL,"&stat&",NULL"
		conn.Execute sql
	End If
	' 设置所选学生的指定填报信息
	Dim withdraw_reason
	If stat=4 Then
		withdraw_reason="名额限制"
	End If
	sql="EXEC spBatchSetApplyInfo 1,"&toSqlString(id_turns)&",NULL,NULL,NULL,"&stat&","&toSqlString(withdraw_reason)
	conn.Execute sql
End Select

For i=0 To UBound(arrSelStu)
	stu_id=arrSelStu(i)
	If Not dictStu.Exists(stu_id) Then
		dictStu.Add stu_id,stu_id
	End If
Next
For i=0 To UBound(arrSelTurn)
	stu_id=Left(arrSelTurn(i),InStr(arrSelTurn(i),"|")-1)
	If Not dictStu.Exists(stu_id) Then
		dictStu.Add stu_id,stu_id
	End If
Next

If Len(stat) Then
	Dim arrStatText:arrStatText=Array("未填报状态","未确认填报状态","导师未确认状态","导师已确认状态","导师已退回状态")
	stat_text=arrStatText(stat)
	For Each item In dictStu.Items
		stu_id=item
		logtxt="教务员["&Session("name")&"]在选导师系统执行学生填报状态变更操作["&stat_text&"]。"
		If bSendEmail Then
			sql="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL FROM ViewStudentInfo A,ViewTeacherInfo B"&_
				" WHERE STU_ID="&stu_id&" AND B.TEACHERID=A.TUTOR_ID"
			Set rs=conn.Execute(sql)
			If Not rs.EOF Then
				stu_name=rs(0)
				class_name=rs(1)
				spec_name=rs(2)
				stu_email=rs(3)
				tutor_name=rs(4)
				tutor_email=rs(5)
				fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,stat_text)
				bSuccess=sendAnnouncementEmail(mail_id(4),stu_email,fieldval)
				logtxt=logtxt&"通知邮件发至["&stu_name&":"&stu_email&"]"
				If bSuccess Then
					logtxt=logtxt&"成功。"
				Else
					logtxt=logtxt&"失败。"
				End If
			End If
			CloseRs rs
		End If
		WriteLog logtxt
	Next
End If
Set dictStu=Nothing
CloseConn conn
%><form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stu_type%>" />
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>" />
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>" />
	<input type="hidden" name="In_PAGE_NO" value="<%=page_no%>" />
	<input type="hidden" name="In_PAGE_SIZE" value="<%=page_size%>" />
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>