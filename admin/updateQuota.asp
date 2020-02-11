<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include File="common.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")

Dim bError,bUpdateQuota,bUpdateSel

sem_info=getCurrentSemester()
curyear=sem_info(0)
cur_semester=sem_info(1)

numNew=Request.QueryString("new")
numUpd=Request.QueryString("upd")
open=Request.QueryString("open")
bUpdateSel=Request.QueryString("updatesel")="1"
If bUpdateSel Then
	stuTypeUpdateQuota=Request.Form("stu_updatequota")&","
End If

Dim conn,rs,sql
Dim listID,teacherID,recruit_type,default_quota
Dim i,j,arr(3)

Connect conn
Set rs=conn.Execute("SELECT ID,TEACHER_ID,RECRUIT_TYPE,DEFAULT_QUOTA FROM TUTOR_LIST")
Do While Not rs.EOF
	listID=rs(0)
	teacherID=rs(1)
	recruit_type=rs(2)
	default_quota=rs(3)
	j=0
	If (recruit_type And 1)<>0 Then	' MBA
		arr(j)=6:j=j+1
	End If
	If (recruit_type And 2)<>0 Then	' EMBA
		arr(j)=7:j=j+1
	End If
	If (recruit_type And 4)<>0 Then	' MPAcc
		arr(j)=9:j=j+1
	End If
	If (recruit_type And 8)<>0 Then	' ME
		arr(j)=5:j=j+1
	End If
	For i=0 To j-1
		If Not bUpdateSel Then
			bUpdateQuota=True
		Else
			bUpdateQuota=InStr(stuTypeUpdateQuota,arr(i)&",")>0
		End If
		If bUpdateQuota Then
			sql=sql&"SELECT @num=Count(ID) FROM TUTOR_RECRUIT_INFO WHERE LIST_ID="&listID&" AND TEACHTYPE_ID="&arr(i)&_
							" AND RECRUIT_YEAR="&curyear&" AND RECRUIT_SEMESTER="&cur_semester&_
							";IF @num=0 INSERT INTO TUTOR_RECRUIT_INFO (LIST_ID,RECRUIT_YEAR,RECRUIT_SEMESTER,TEACHTYPE_ID,RECRUIT_QUOTA) VALUES("&_
							listID&","&curyear&","&cur_semester&","&arr(i)&","&default_quota&") ELSE "&_
							"UPDATE TUTOR_RECRUIT_INFO SET RECRUIT_QUOTA="&default_quota&" WHERE LIST_ID="&listID&" AND TEACHTYPE_ID="&arr(i)&_
							" AND RECRUIT_YEAR="&curyear&" AND RECRUIT_SEMESTER="&cur_semester&";"
	'			sql="SELECT Count(*) FROM VIEW_STUDENT_INFO WHERE TUTOR_RECRUIT_ID="&listID
	'			Set rs2=conn.Execute(sql)
	'			confirmedNum=rs2(0)
	'			CloseRs rs2
	'			If newQuota<confirmedNum Then
	'				bError=True
	'				errDesc=errDesc&"["&arrLineData(1)&"]老师面向["&teachtype&"]的学生名额数("&newQuota&")少于已确认的学生数("&confirmedNum&")。\n"
	'			Else
	'				sql="UPDATE TUTOR_RECRUIT_INFO SET RECRUIT_QUOTA="&newQuota&" WHERE LIST_ID="&listID
	'				conn.Execute sql
	'			End If
		End If
	Next
	rs.MoveNext()
Loop
sql="DECLARE @num int;"&sql
If Not bUpdateSel Then
	sql=sql&"DELETE FROM TUTOR_RECRUIT_INFO WHERE LIST_ID NOT IN (SELECT ID FROM TUTOR_LIST);"
End If
conn.Execute sql
CloseRs rs
CloseConn conn
If open="1" Then
%><form id="ret" method="post" action="systemSettings.asp?step=1"><input type="hidden" name="ok" value="1" /></form>
<script type="text/javascript">document.all.ret.submit();</script><%
Else
%><script type="text/javascript"><%
	If bError Then %>
	alert("导入时出错，其他记录已导入成功。出错原因为：\n<%=toJsString(errMsg)%>");
<%Else %>
	alert("操作成功，<%=numNew%>条记录已导入，<%=numUpd%>条记录已更新。");
<%End If
%>location.href="tutorList.asp";
</script><%
End If
%>