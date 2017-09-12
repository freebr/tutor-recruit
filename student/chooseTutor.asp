<%Response.Expires=-1
Response.Charset="utf-8"
Server.ScriptTimeout=5000 %>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Suser")) Then Response.Redirect("../error.asp?timeout")
sem_info=getCurrentSemester()
period_id=sem_info(3)
choice_id=Request.Form("choice_id")
isConfirm=Request.QueryString("confirm")
isCancel=Request.QueryString("cancel")
stu_id=Session("Stuid")

If Not bOpen Then
%>{"error":true,"tip":"本专业上传通道已关闭或当前不在开放时间内，无法提交信息！\n(开放时间:<%=FormatDateTime(startdate,1)%>～<%=FormatDateTime(enddate,1)%>)"}<%
	Response.End
End If

If Not hasPrivilege(Session("writeprivileges"),"SA6") And Not hasPrivilege(Session("readprivileges"),"SA6") Then
%>{"error":true,"tip":"您没有选导师的权限！"}<%
	Response.End
End If

If Not checkIfProfileFilledIn() Then
%>{"error":true,"tip":"您尚未完善个人资料，请在右上方点击\"个人资料修改\"完成相关必填项再提交填报。"}<%
	Response.End
End If

Dim bAllowed,bSendEmail
Connect conn
sql="SELECT STU_ID FROM STUDENT_INFO WHERE STU_ID="&stu_id&" AND TUTOR_RECRUIT_STATUS IN (2,3,4)"
Set rs=conn.Execute(sql)
bAllowed=rs.EOF
CloseRs rs
If Not bAllowed Then
%>{"error":true,"tip":"信息已确认，不能修改！"}<%
	CloseConn conn
	Response.End
End If

bSendEmail=False
mail_id=getTutorSystemMailIdByType(Now)
If isConfirm="1" Then	' 确认填报

	sql="SELECT CLASS_NAME,TUTOR_SPECIALITY_NAME,EMAIL FROM VIEW_STUDENT_INFO_NEW WHERE STU_ID="&stu_id
	GetRecordSetNoLock conn,rs,sql,result
	If result Then
		class_name=rs(0)
		spec_name=rs(1)
		stu_email=rs(2)
	Else
%>{"error":true,"tip":"参数错误！"}<%
		CloseConn conn
		Response.End
	End If
	CloseRs rs
	sql="UPDATE VIEW_STUDENT_INFO_NEW SET TUTOR_RECRUIT_STATUS=2 WHERE STU_ID="&stu_id
	conn.Execute sql
	sql="UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=2 WHERE APPLY_STATUS<>4 AND STU_ID="&stu_id
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
		WriteLogForTutorSystem logtxt
	End If
	tip="操作成功，请等待进一步通知！\n若导师确认您的申请，将第一时间以邮件方式向您通知！谢谢！"
	
ElseIf isCancel="1" Then	' 取消填报
	sql="UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS=0 WHERE STU_ID="&stu_id&" AND TUTOR_RECRUIT_STATUS=1"
	conn.Execute sql
	sql="DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE APPLY_STATUS<>4 AND STU_ID="&stu_id
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
		Response.End
	End If
	
	Dim bEmpty
	For index=0 To UBound(arrRecId)
		rec_id=Trim(arrRecId(index))
		turn_num=index+1
		If Len(rec_id)=0 Then Exit For
		sql="SELECT TEACHER_ID,TEACHER_NAME,SPECIALITY_NAME,RECRUIT_QUOTA FROM VIEW_TUTOR_RECRUIT_INFO WHERE RECRUIT_ID="&rec_id&" AND VALID=1"
		Set rs=conn.Execute(sql)
		bEmpty=rs.EOF
		If bEmpty Then
			errdesc="参数错误（项目 "&rec_id&" 不存在）！"
			bError=True
			CloseRs rs
			Exit For
		End If
		tutor_id=rs(0)
		teacher_name=rs(1)
		spec_name=rs(2)
		recruit_quota=rs(3)
		CloseRs rs
		
		sql="SELECT 1 FROM TUTOR_STUDENT_APPLY_INFO WHERE APPLY_STATUS=4 AND STU_ID="&stu_id&" AND TURN_NUM="&turn_num
		Set rs=conn.Execute(sql)
		bEmpty=rs.EOF
		CloseRs rs
		If bEmpty Then
			sql="SELECT ("&recruit_quota&"-Count(*)) AS REMAINING_QUOTA FROM VIEW_STUDENT_INFO_NEW WHERE TUTOR_RECRUIT_ID="&rec_id&" AND TUTOR_RECRUIT_STATUS=3"
			Set rs=conn.Execute(sql)
			remaining_quota=rs(0)
			CloseRs rs
			If remaining_quota=0 Then
				errdesc=teacher_name&"老师的"&spec_name&"专业已没有名额，请选择其他项目！"
				bError=True
				Exit For
			End If
			
			sql_insert=sql_insert&"INSERT INTO TUTOR_STUDENT_APPLY_INFO (STU_ID,TUTOR_ID,RECRUIT_ID,PERIOD_ID,TURN_NUM,APPLY_TIME,APPLY_STATUS) VALUES("&stu_id&","&tutor_id&","&rec_id&","&period_id&","&turn_num&",'"&Now&"',1);"
		End If
	Next
	If bError Then
%>{"error":true,"tip":"<%=errdesc%>"}<%
		CloseConn conn
		Response.End
	End If
	
	If Len(sql_insert)=0 Then
		errdesc="请填报志愿！"
%>{"error":true,"tip":"<%=errdesc%>"}<%
		CloseConn conn
		Response.End
	End If
	
	sql="UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_STATUS=1 WHERE STU_ID="&stu_id&";"&_
			"DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE APPLY_STATUS<>4 AND STU_ID="&stu_id
	conn.Execute sql
	conn.Execute sql_insert
	tip="操作成功，请及时对您的填报信息执行确认操作！"
	
End If
CloseConn conn
%>{"error":false,"tip":"<%=toJsString(tip)%>"}