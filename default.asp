<!--#include file="inc/global.inc"--><%

If serverVar("REMOTE_ADDR")<>"::1" Then
	showErrorPage "禁止访问。", "提示"
End If

If Request.QueryString()="logout" Then
	If Len(Session("Name")) Then
		msg="行政人员["&Session("Name")&"]登出。"
	ElseIf Len(Session("StuName")) Then
		msg="学生["&Session("StuName")&"]登出。"
	ElseIf Len(Session("TName")) Then
		msg="教师["&Session("TName")&"]登出。"
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
	ConnectDb conn
	Select Case usertype
	Case "admin"
		sql="SELECT TEACHERID,TEACHERNO,TEACHERNAME,WRITEPRIVILEGETAGSTRING,READPRIVILEGETAGSTRING FROM ViewTeacherInfo WHERE TEACHERID=863 AND VALID=0"
		GetRecordSet conn,rs,sql,result
		Session("Id")=rs("TEACHERID")
		Session("No")=rs("TEACHERNO")
		Session("Name")=rs("TEACHERNAME")
		Session("WritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
		Session("ReadPrivileges")=rs("READPRIVILEGETAGSTRING")
		url="admin"
		CloseRs rs
		CloseConn conn
	Case "student"
		stuno=Request.QueryString("no")
		If IsEmpty(stuno) Then stuno="201200000000"
		sql="SELECT * FROM ViewStudentInfo WHERE STU_NO="&toSqlString(stuno)&" AND VALID=0"
	  GetRecordSet conn,rs,sql,result
	  If result>0 Then
		  Session("StuId")=rs("STU_ID")
		  Session("StuNo")=rs("STU_NO")
		  Session("StuName")=rs("STU_NAME")
		  Session("StuType")=rs("TEACHTYPE_ID")
		  Session("StuClass")=rs("CLASS_ID")
		  Session("WritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
		  Session("ReadPrivileges")=rs("READPRIVILEGETAGSTRING")
			url="student"
		End If
	  CloseRs rs
		CloseConn conn
	Case "tutor"
		username=Request.QueryString("name")
		If IsEmpty(username) Then username="daoshi"
		sql="SELECT TEACHERID,TEACHERNO,TEACHERNAME,WRITEPRIVILEGETAGSTRING,READPRIVILEGETAGSTRING FROM ViewTeacherInfo WHERE TEACHERNO='"&username&"' AND VALID=0"
		GetRecordSet conn,rs,sql,result
	  If result>0 Then
	    Session("TId")=rs("TEACHERID")
			Session("TNo")=rs("TEACHERNO")
	    Session("TName")=rs("TEACHERNAME")
	    Session("TWritePrivileges")=rs("WRITEPRIVILEGETAGSTRING")
	    Session("TReadPrivileges")=rs("READPRIVILEGETAGSTRING")
			url="tutor"
	  End If
   	CloseRs rs
		CloseConn conn
	Case Else
		Response.End()
	End Select
	
	If Len(url)=0 Then
		Response.Redirect("error.asp?user-not-exists")
	End If
	Response.Redirect url
End If
%>