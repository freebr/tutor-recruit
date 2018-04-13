<!--#include file="inc/db.asp"--><%
If Request.QueryString()="logout" Then
	If Len(Session("Name")) Then
		msg="行政人员["&Session("Name")&"]登出."
	ElseIf Len(Session("StuName")) Then
		msg="学生["&Session("StuName")&"]登出."
	ElseIf Len(Session("TName")) Then
		If Session("IsExpert") Then
			msg="评阅专家["&Session("TName")&"]登出."
		Else
			msg="教师["&Session("TName")&"]登出."
		End If
	End If
	If Session("LoginFromCAS") Then
		Dim ids,gotoUrl
		Set ids=newLoginComp()
		gotoUrl="http://"&Request.ServerVariables("SERVER_NAME")&"/"
		redirectUrl=ids.getLogoutUrl()&"?goto="&Server.URLEncode(gotoUrl)
		msg=msg&"(通过统一认证系统)"
	Else
		redirectUrl="/"
	End If
	Session.Abandon()
	If Len(msg) Then WriteLog msg
	Response.Redirect(redirectUrl)
Else
	Dim usertype,conn,sql,rs,result
	usertype=Request.QueryString("usertype")
	ConnectOriginDb conn
	Select Case usertype
	Case "admin"
		sql="SELECT TEACHERID,TEACHERNO,TEACHERNAME,WRITEPRIVILEGETAGSTRING,READPRIVILEGETAGSTRING FROM TEACHER_INFO WHERE TEACHERID=863 AND VALID=0"
		GetRecordSet conn,rs,sql,result
		Session("Id")=rs("TEACHERID")
		Session("No")=rs("TEACHERNO")
		Session("Name")=rs("TEACHERNAME")
		Session("WritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
		Session("ReadPrivileges")=rs("READPRIVILEGETAGSTRING")
		CloseRs rs
		CloseConn conn
		url="admin"
	Case "student"
		stuno=Request.QueryString("no")
		If IsEmpty(stuno) Then stuno="201200000000"
		sql="SELECT * FROM VIEW_STUDENT_INFO WHERE STU_NO='"&stuno&"' AND VALID=0"
	  GetRecordSetNoLock conn,rs,sql,result
	  Session("StuId")=rs("STU_ID")
	  Session("StuNo")=rs("STU_NO")
	  Session("StuName")=rs("STU_NAME")
	  Session("WritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
	  Session("ReadPrivileges")=rs("READPRIVILEGETAGSTRING")
	  If rs("TEACH_TYPEID")=6 Then
			If InStr(LCase(rs("CLASS_NAME")),"mpacc") Then
				Session("StuType")=9
			Else
				Session("StuType")=6
			End If
		Else
			Session("StuType")=Session("StuObject")
		End If
	  Session("StuClass")=rs("CLASS_ID")
	  CloseRs rs
		CloseConn conn
		url="student"
	Case "tutor"
		username=Request.QueryString("name")
		If IsEmpty(username) Then username="daoshi"
		sql="SELECT TEACHERID,TEACHERNO,TEACHERNAME,WRITEPRIVILEGETAGSTRING,READPRIVILEGETAGSTRING FROM TEACHER_INFO WHERE TEACHERNO='"&username&"' AND VALID=0"
		GetRecordSet conn,rs,sql,result
    Session("TId")=rs("TEACHERID")
		Session("TNo")=rs("TEACHERNO")
    Session("TName")=rs("TEACHERNAME")
    Session("TWritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
    Session("TReadPrivileges")=rs("READPRIVILEGETAGSTRING")
   	CloseRs rs
		CloseConn conn
		url="tutor"
	Case Else
		Response.End()
	End Select
	Response.Redirect url
End If
%>