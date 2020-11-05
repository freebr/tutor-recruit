<%Response.Expires=-1
Server.ScriptTimeout=5000 %>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("StuId")) Then Response.Redirect("../error.asp?timeout")
sem_info=getCurrentSemester()
cur_period_id=sem_info(3)
choice_id=Request.Form("choice_id")
isConfirm=Request.QueryString("confirm")
isCancel=Request.QueryString("cancel")
stu_id=Session("Stuid")

If Not bSystemOpen Then
%>{"error":true,"tip":"本专业上传通道已关闭或当前不在开放时间内，无法提交信息！\n(开放时间:<%=FormatDateTime(startdate,1)%>～<%=FormatDateTime(enddate,1)%>)"}<%
	Response.End()
End If

If Not hasPrivilege(Session("writeprivileges"),"SA6") And Not hasPrivilege(Session("readprivileges"),"SA6") Then
%>{"error":true,"tip":"您没有选导师的权限！"}<%
	Response.End()
End If

If Not checkIfProfileFilledIn() Then
%>{"error":true,"tip":"您尚未完善个人资料，请在右上方点击\"个人资料修改\"完成相关必填项再提交填报。"}<%
	Response.End()
End If

Dim bApplySubmitted,bSendEmail
Dim conn,rs,sql
ConnectDb conn
sql="SELECT dbo.isApplySubmitted("&stu_id&")"
Set rs=conn.Execute(sql)
bApplySubmitted=rs(0).Value
CloseRs rs
If bApplySubmitted Then
%>{"error":true,"tip":"信息已确认，不能修改！"}<%
	CloseConn conn
	Response.End()
End If

bSendEmail=False
mail_id=getTutorSystemMailIdByType(Now)
If isConfirm="1" Then	' 确认填报
	sql="SELECT CLASS_NAME,TUTOR_SPECIALITY_NAME,EMAIL FROM ViewStudentInfo WHERE STU_ID="&stu_id
	GetRecordSetNoLock conn,rs,sql,result
	If result Then
		class_name=rs(0).Value
		spec_name=rs(1).Value
		stu_email=rs(2).Value
	Else
%>{"error":true,"tip":"参数错误！"}<%
		CloseConn conn
		Response.End()
	End If
	CloseRs rs
	sql="EXEC spStudentClientSetApplyStatus "&stu_id&",2"
	conn.Execute sql
	
	fieldval=Array(Session("StuName"),class_name,spec_name,stu_email,tutor_name,tutor_email)
	If bSendEmail Then
		bSuccess=sendAnnouncementEmail(mail_id(1),tutor_email,fieldval)
		logtxt="学生["&Session("StuName")&"]在选导师系统执行确认填报操作，通知邮件发至["&tutor_name&":"&tutor_email&"]"
		If bSuccess Then
			logtxt=logtxt&"成功。"
		Else
			logtxt=logtxt&"失败。"
		End If
		WriteLog logtxt
	End If
	tip="操作成功，请等待进一步通知！"&vbNewLine&"若导师确认您的申请，将第一时间以邮件方式向您通知！谢谢！"
ElseIf isCancel="1" Then	' 取消填报
	sql="EXEC spStudentClientSetApplyStatus "&stu_id&",0"
	conn.Execute sql
	tip="操作成功，请重新选择导师！"
Else	' 提交填报
	Dim arrRecId
	If Len(choice_id)=0 Then
		errdesc="信息不完整或格式不正确！"
		bError=True
	Else
		arrRecId=Split(choice_id,",")
		If UBound(arrRecId)<1 Then
			errdesc="必须至少填报两个志愿！"
			bError=True
		ElseIf Len(arrRecId(0))=0 Then
			errdesc="第一志愿不能为空！"
			bError=True
		ElseIf Len(arrRecId(1))=0 Then
			errdesc="第二志愿不能为空！"
			bError=True
		Else
			For i=0 To 1
				For j=i+1 To UBound(arrRecId)
					If arrRecId(i)=arrRecId(j) Then
						errdesc="第"&arrRecId(i)&"志愿所填信息与第"&arrRecId(j)&"志愿重复！"
						bError=True
						Exit For
					End If
				Next
			Next
		End If
	End If
	If bError Then
%>{"error":true,"tip":"<%=errdesc%>"}<%
		CloseConn conn
		Response.End()
	End If
	
	Dim sql_exec:sql_exec=""
	For i=0 To UBound(arrRecId)
		Dim bEmpty,status,turn_num,tutor_id,teacher_name,spec_name,recruit_id,recruit_quota,confirmed_count
		recruit_id=Trim(arrRecId(i))
		If Len(recruit_id)=0 Then Exit For
		turn_num=i+1
		sql="SELECT TEACHER_ID,TEACHER_NAME,SPECIALITY_NAME,RECRUIT_QUOTA FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruit_id&" AND VALID=1"
		Set rs=conn.Execute(sql)
		bEmpty=rs.EOF
		If bEmpty Then
			errdesc="招生信息 #"&recruit_id&" 不存在！"
			bError=True
			CloseRs rs
			Exit For
		End If
		tutor_id=rs(0).Value
		teacher_name=rs(1).Value
		spec_name=rs(2).Value
		recruit_quota=rs(3).Value
		CloseRs rs
		
		sql="SELECT dbo.getApplyStatusOfStudent("&stu_id&","&turn_num&")"
		Set rs=conn.Execute(sql)
		status=rs(0).Value
		CloseRs rs
		If status<=1 Then
			sql="SELECT dbo.countOfConfirmedApply("&recruit_id&")"
			Set rs=conn.Execute(sql)
			confirmed_count=rs(0).Value
			CloseRs rs
			If recruit_quota=confirmed_count Then
				errdesc=teacher_name&"老师的"&spec_name&"专业名额已满，请选择其他项目！"
				bError=True
				Exit For
			End If
			
			sql_exec=sql_exec&"EXEC spSetApplyInfo "&stu_id&","&cur_period_id&","&turn_num&","&tutor_id&","&recruit_id&",1;"
		End If
	Next
	If bError Then
%>{"error":true,"tip":"<%=errdesc%>"}<%
		CloseConn conn
		Response.End()
	End If
	
	If Len(sql_exec)=0 Then
		errdesc="信息已确认，不能修改！"
%>{"error":true,"tip":"<%=errdesc%>"}<%
		CloseConn conn
		Response.End()
	End If
	
	sql="EXEC spStudentClientSetApplyStatus "&stu_id&",1"
	conn.Execute sql
	conn.Execute sql_exec
	tip="操作成功，请及时对您的填报信息执行确认操作！"
End If
CloseConn conn
%>{"error":false,"tip":"<%=toJsString(tip)%>"}