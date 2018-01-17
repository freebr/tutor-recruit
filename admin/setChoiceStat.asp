<%Response.Charset="utf-8"%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
stat=Request.QueryString("stat")
If stat="" Then stat=0
If Not IsNumeric(stat) Then
	errdesc="参数无效。":bError=True
ElseIf stat<0 Or stat>4 Then
	errdesc="参数无效。":bError=True
End If
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If
object=Request.form("In_TEACHTYPE_ID")
period_id=Request.form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter2")
FormGetToSafeRequest(stat)
FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

PageNo=Request.Form("In_PageNo")
PageSize=Request.Form("In_pageSize")
If period_id="" or object="" Then
	Response.Write "<center><font color=red size=""4"">条件丢失</font>"
	Response.Write "</center>"
	Response.End
End If

mail_id=getTutorSystemMailIdByType(Now)
Connect conn
Dim arrSelStu:arrSelStu=Split(Request.Form("sel"),",")
Dim arrSelTurn:arrSelTurn=Split(Request.Form("sel_turn"),",")
Dim dictStu:Set dictStu=Server.CreateObject("Scripting.Dictionary")
Dim bSendEmail:bSendEmail=False

Select Case stat
Case Empty
	Dim oper:oper=Request.QueryString()
	If Len(oper) Then
		Dim valid
		Select Case oper
		Case "show":valid="1"
		Case "hide":valid="0"
		End Select
		For i=0 To UBound(arrSelTurn)
			arr=Split(arrSelTurn(i),"|")
			stu_id=arr(0)
			turn_num=arr(1)
			' 更新填报信息
			sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET VALID="&valid&" WHERE STU_ID="&stu_id&" AND TURN_NUM="&turn_num&";"
		Next
		If Len(sql) Then conn.Execute sql
	Else	' 删除记录
		For i=0 To UBound(arrSelStu)
			stu_id=arrSelStu(i)
			' 更新填报信息
			'sql=sql&"DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&";"
			' 更新学生表信息
			sql=sql&"UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS=0,WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA8'),READPRIVILEGETAGSTRING=dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA8')"&_
							" WHERE STU_ID="&stu_id&";"
		Next
		For i=0 To UBound(arrSelTurn)
			arr=Split(arrSelTurn(i),"|")
			stu_id=arr(0)
			turn_num=arr(1)
			' 更新填报信息
			sql=sql&"DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&" AND TURN_NUM="&turn_num&";"
			' 更新学生表信息
			sql=sql&"IF NOT EXISTS(SELECT STU_ID FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&" AND APPLY_STATUS=3) UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS=0,WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA8'),READPRIVILEGETAGSTRING=dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA8')"&_
							" WHERE STU_ID="&stu_id&";"
		Next
		If Len(sql) Then conn.Execute sql
	End If
Case 1,2	' 未提交/未确认
	For i=0 To UBound(arrSelStu)
		stu_id=arrSelStu(i)
		' 更新填报信息
		sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS="&stat&",VALID=1,TUTOR_REPLY_TIME=NULL WHERE STU_ID="&stu_id&";"
		' 更新学生表信息
		sql=sql&"UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS="&stat&",WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA8'),READPRIVILEGETAGSTRING=dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA8')"&_
						" WHERE STU_ID="&stu_id&";"
	Next
	For i=0 To UBound(arrSelTurn)
		arr=Split(arrSelTurn(i),"|")
		stu_id=arr(0)
		turn_num=arr(1)
		' 更新填报信息
		sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS="&stat&",VALID=1,TUTOR_REPLY_TIME=NULL WHERE STU_ID="&stu_id&" AND TURN_NUM="&turn_num&";"
		' 更新学生表信息
		sql=sql&"UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS="&stat&",WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA8'),READPRIVILEGETAGSTRING=dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA8')"&_
						" WHERE STU_ID="&stu_id&";"
	Next
	If Len(sql) Then conn.Execute sql
Case 3	' 确认填报记录
	sql="DECLARE @tutor_id int,@rec_id int;"
	For i=0 To UBound(arrSelTurn)
		arr=Split(arrSelTurn(i),"|")
		stu_id=arr(0)
		turn_num=arr(1)
		' 获取填报信息
		sql=sql&"SELECT @tutor_id=TUTOR_ID"&turn_num&",@rec_id=RECRUIT_ID"&turn_num&" FROM VIEW_TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&";"
		' 更新填报信息
		sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=3,VALID=1,TUTOR_REPLY_TIME="&toSqlString(Now)&" WHERE STU_ID="&stu_id&" AND TURN_NUM="&turn_num&";"&_
						"UPDATE TUTOR_STUDENT_APPLY_INFO SET VALID=0,APPLY_STATUS=CASE WHEN APPLY_STATUS=3 THEN 2 ELSE APPLY_STATUS END,TUTOR_REPLY_TIME=CASE WHEN APPLY_STATUS=3 THEN NULL ELSE TUTOR_REPLY_TIME END WHERE STU_ID="&stu_id&" AND TURN_NUM<>"&turn_num&";"
		' 更新学生表信息
		sql=sql&"UPDATE STUDENT_INFO SET TUTOR_ID=@tutor_id,TUTOR_RECRUIT_ID=@rec_id,TUTOR_RECRUIT_STATUS=3,WRITEPRIVILEGETAGSTRING=dbo.addPrivilege(WRITEPRIVILEGETAGSTRING,'SA8',''),READPRIVILEGETAGSTRING=dbo.addPrivilege(READPRIVILEGETAGSTRING,'SA8','')"&_
						" WHERE STU_ID="&stu_id&";"
	Next
	If Len(sql) Then conn.Execute sql
Case 4	' 已退回
	For i=0 To UBound(arrSelTurn)
		arr=Split(arrSelTurn(i),"|")
		stu_id=arr(0)
		turn_num=arr(1)
		' 更新填报信息
		sql=sql&"UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=4,VALID=1,TUTOR_REPLY_TIME="&toSqlString(Now)&",TUTOR_REPLY='名额限制' WHERE STU_ID="&stu_id&" AND TURN_NUM="&turn_num&";"
		' 更新学生表信息
		sql=sql&"IF NOT EXISTS(SELECT 1 FROM TUTOR_STUDENT_APPLY_INFO WHERE APPLY_STATUS=3 AND STU_ID="&stu_id&") "&_
						"UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS=4,WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'SA8'),READPRIVILEGETAGSTRING=dbo.removePrivilege(READPRIVILEGETAGSTRING,'SA8') WHERE STU_ID="&stu_id&";"
	Next
	If Len(sql) Then conn.Execute sql
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
	If bSendEmail Then
		Dim arrStatText:arrStatText=Array("未填报状态","未确认填报状态","导师未确认状态","导师已确认状态","导师已退回状态")
		For Each item In dictStu.Items
			stu_id=item
			sql="SELECT STU_NAME,CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL FROM VIEW_STUDENT_INFO_NEW A,TEACHER_INFO B"&_
			 	  " WHERE STU_ID="&stu_id&" AND B.TEACHERID=A.TUTOR_ID"
			Set rs=conn.Execute(sql)
			If Not rs.EOF Then
				stu_name=rs(0)
				class_name=rs(1)
				spec_name=rs(2)
				stu_email=rs(3)
				tutor_name=rs(4)
				tutor_email=rs(5)
				stat_text=arrStatText(stat)
				fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,stat_text)
				bSuccess=sendAnnouncementEmail(mail_id(4),stu_email,fieldval)
				logtxt="行政人员["&Session("name")&"]在选导师系统执行学生填报状态变更操作["&stat_text&"]，通知邮件发至["&stu_name&":"&stu_email&"]"
				If bSuccess Then
					logtxt=logtxt&"成功。"
				Else
					logtxt=logtxt&"失败。"
				End If
				WriteLogForTutorSystem logtxt
			End If
			CloseRs rs
		Next
	End If
End If
Set dictStu=Nothing
CloseConn conn
%>
<form method="post" action="chosenList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=object%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>