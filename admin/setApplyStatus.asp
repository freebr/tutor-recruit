<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
stat=Request.QueryString("stat")
If stat="" Then stat=0
stuType=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
finalFilter=Request.Form("finalFilter2")
FormGetToSafeRequest(stat)
FormGetToSafeRequest(stuType)
FormGetToSafeRequest(period_id)

PageNo=Request.Form("In_PageNo")
PageSize=Request.Form("In_pageSize")

If Not IsNumeric(stat) Then
	errdesc="参数无效。":bError=True
ElseIf stat<0 Or stat>4 Then
	errdesc="参数无效。":bError=True
ElseIf IsEmpty(period_id) Or IsEmpty(stuType) Then
	errdesc="参数无效。":bError=True
End If
If bError Then
%><body bgcolor="ghostwhite"><center><font color=red size="4"><%=errdesc%></font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End()
End If

Dim conn,sql
Dim mail_id:mail_id=getTutorSystemMailIdByType(Now)
Dim arrSelStu:arrSelStu=Split(Request.Form("sel"),",")
Dim arrSelTurn:arrSelTurn=Split(Request.Form("sel_turn"),",")
Dim dictStu:Set dictStu=Server.CreateObject("Scripting.Dictionary")
Dim bSendEmail:bSendEmail=False

Connect conn
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
		sql="EXEC spSetApplyDisplayState "&toSqlString(Request.Form("sel_turn"))&","&valid
		conn.Execute sql
	Else	' 删除记录
		' 删除所选学生的全部填报信息
		sql="EXEC spDeleteApplyInfo 0,"&toSqlString(Request.Form("sel"))
		conn.Execute sql
		' 删除所选学生的指定填报信息
		sql="EXEC spDeleteApplyInfo 1,"&toSqlString(Request.Form("sel_turn"))
		conn.Execute sql
	End If
Case 1,2,3,4	' 未提交/导师未确认/导师已确认/导师已退回
	If stat=1 Or stat=2 Then
		' 设置所选学生的全部填报信息
		sql="EXEC spBatchSetApplyInfo 0,"&toSqlString(Request.Form("sel"))&",NULL,NULL,NULL,"&stat&",NULL"
		conn.Execute sql
	End If
	' 设置所选学生的指定填报信息
	sql="EXEC spBatchSetApplyInfo 1,"&toSqlString(Request.Form("sel_turn"))&",NULL,NULL,NULL,"&stat&",NULL"
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
	If bSendEmail Then
		Dim arrStatText:arrStatText=Array("未填报状态","未确认填报状态","导师未确认状态","导师已确认状态","导师已退回状态")
		For Each item In dictStu.Items
			stu_id=item
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
				stat_text=arrStatText(stat)
				fieldval=Array(stu_name,class_name,spec_name,stu_email,tutor_name,tutor_email,stat_text)
				bSuccess=sendAnnouncementEmail(mail_id(4),stu_email,fieldval)
				logtxt="行政人员["&Session("name")&"]在选导师系统执行学生填报状态变更操作["&stat_text&"]，通知邮件发至["&stu_name&":"&stu_email&"]"
				If bSuccess Then
					logtxt=logtxt&"成功。"
				Else
					logtxt=logtxt&"失败。"
				End If
				WriteLog logtxt
			End If
			CloseRs rs
		Next
	End If
End If
Set dictStu=Nothing
CloseConn conn
%>
<form method="post" action="applyList.asp">
	<input type="hidden" name="In_TEACHTYPE_ID" value="<%=stuType%>">
	<input type="hidden" name="In_PERIOD_ID" value="<%=period_id%>">
	<input type="hidden" name="finalFilter" value="<%=finalFilter%>">
	<input type="hidden" name="In_PageNo" value=<%=PageNo%>>
	<input type="hidden" name="In_PageSize" value=<%=PageSize%>>
</form>
<script type="text/javascript">
	alert("操作完成。");
	document.forms[0].submit();
</script>