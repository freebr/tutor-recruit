<%Response.Expires=-1
Server.ScriptTimeout=5000 %>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Suser")) Then Response.Redirect("../error.asp?timeout")
recruit_id=Request.QueryString("id")
isConfirm=Request.QueryString("confirm")
isCancel=Request.QueryString("cancel")
stu_id=Session("Stuid")

If Not bOpen Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">本专业上传通道已关闭或当前不在开放时间内，无法提交信息！<br />
(开放时间:<%=FormatDateTime(startdate,1)%>～<%=FormatDateTime(enddate,1)%>)</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If

If Not hasPrivilege(Session("writeprivileges"),"SA6") And Not hasPrivilege(Session("readprivileges"),"SA6") Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您没有选导师的权限！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If

If Not checkIfProfileFilledIn() Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">您尚未完善个人资料，请在右上方点击&quot;个人资料修改&quot;完成相关必填项再提交填报。</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If

Dim bAllowed,bSendEmail
Connect conn
sql="SELECT STU_ID FROM STUDENT_INFO WHERE STU_ID="&stu_id&" AND TUTOR_RECRUIT_STATUS IN (2,3,4)"
Set rs=conn.Execute(sql)
bAllowed=rs.EOF
CloseRs rs
If Not bAllowed Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息已提交，不能修改！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.End
End If

sem_info=getCurrentSemester()
Dim nTurn
sql="SELECT TURN_NUM FROM TUTOR_SYSTEM_SETTINGS WHERE USE_YEAR="&sem_info(0)&" AND USE_SEMESTER="&sem_info(1)
Set rs=conn.Execute(sql)
nTurn=rs(0)
CloseRs rs

bSendEmail=False
mail_id=getTutorSystemMailIdByType(Now)
If isConfirm="1" Then

	sql="SELECT CLASS_NAME,TUTOR_SPECIALITY_NAME,A.EMAIL,A.TEACHERNAME,B.EMAIL FROM VIEW_STUDENT_INFO_NEW A "&_
			"LEFT JOIN TEACHER_INFO B ON B.TEACHERID=A.TUTOR_ID WHERE STU_ID="&stu_id&" AND TUTOR_RECRUIT_STATUS=1"
	GetRecordSetNoLock conn,rs,sql,result
	If result Then
		class_name=rs(0)
		spec_name=rs(1)
		stu_email=rs(2)
		tutor_name=rs(3)
		tutor_email=rs(4)
	Else
	%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End
	End If
	CloseRs rs
	sql="UPDATE VIEW_STUDENT_INFO_NEW SET TUTOR_RECRUIT_STATUS=2 WHERE STU_ID="&stu_id
	conn.Execute sql
	sql="UPDATE TUTOR_STUDENT_APPLY_INFO SET APPLY_STATUS=2 WHERE STU_ID="&stu_id
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
	
ElseIf isCancel="1" Then
	sql="UPDATE STUDENT_INFO SET TUTOR_ID=0,TUTOR_RECRUIT_ID=0,TUTOR_RECRUIT_STATUS=0 WHERE STU_ID="&stu_id&" AND TUTOR_RECRUIT_STATUS=1"
	conn.Execute sql
	sql="DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id
	conn.Execute sql
	tip="操作成功，请重新选择导师！"
Else
	If Len(recruit_id)=0 Or Not IsNumeric(recruit_id) Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整或格式不正确！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End
	End If
	
	sql="SELECT TEACHER_ID,RECRUIT_QUOTA FROM ViewRecruitInfo WHERE RECRUIT_ID="&recruit_id&" AND VALID=1"
	Set rs=conn.Execute(sql)
	If rs.EOF Then
	%><body bgcolor="ghostwhite"><center><font color=red size="4">参数错误！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End
	End If
	
	tutor_id=rs(0)
	recruit_quota=rs(1)
	CloseRs rs
	
	sql="SELECT ("&recruit_quota&"-Count(*)) AS REMAINING_QUOTA FROM VIEW_STUDENT_INFO_NEW WHERE TUTOR_RECRUIT_ID="&recruit_id&" AND TUTOR_RECRUIT_STATUS=3"
	Set rs=conn.Execute(sql)
	remaining_quota=rs(0)
	CloseRs rs
	If remaining_quota=0 Then
		%><body bgcolor="ghostwhite"><center><font color=red size="4">该项目已没有名额，请选择其他项目！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End
	End If
	
	sql="UPDATE STUDENT_INFO SET TUTOR_ID="&tutor_id&",TUTOR_RECRUIT_ID="&recruit_id&",TUTOR_RECRUIT_STATUS=1 WHERE STU_ID="&stu_id
	conn.Execute sql
	sql="IF EXISTS(SELECT STU_ID FROM TUTOR_STUDENT_APPLY_INFO WHERE STU_ID="&stu_id&")"&_
			"UPDATE TUTOR_STUDENT_APPLY_INFO SET TUTOR_ID="&tutor_id&",RECRUIT_ID="&recruit_id&",TURN_NUM="&nTurn&",APPLY_TIME='"&Now&"',APPLY_STATUS=1 WHERE STU_ID="&stu_id&_
			" ELSE INSERT INTO TUTOR_STUDENT_APPLY_INFO (STU_ID,TUTOR_ID,RECRUIT_ID,TURN_NUM,APPLY_TIME,APPLY_STATUS) VALUES("&stu_id&","&tutor_id&","&recruit_id&","&nTurn&",'"&Now&"',1)"
	conn.Execute sql
	tip="操作成功，请及时对您的填报信息执行确认操作！"
End If
CloseConn conn
%><form id="ret" method="post" action="default.asp#chooseinfo">
<input type="hidden" name="finalFilter" value="<%=Request.Form("finalFilter")%>">
<input type="hidden" name="pageSize" value="<%=Request.Form("pageSize")%>">
<input type="hidden" name="pageNo" value="<%=Request.Form("pageNo")%>"></form>
<script type="text/javascript">
	alert("<%=tip%>");
	document.all.ret.submit();
</script>