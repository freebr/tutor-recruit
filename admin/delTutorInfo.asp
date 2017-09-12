<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
Dim ids,tid_string
ids=Request.Form("sel")
If Len(ids) Then
	tid_string="0"
	Connect conn
	' 删除填报信息和招生信息
	sql="DELETE FROM TUTOR_STUDENT_APPLY_INFO WHERE RECRUIT_ID IN (SELECT ID FROM TUTOR_RECRUIT_INFO WHERE LIST_ID IN ("&ids&"));"&_
			"DELETE FROM TUTOR_RECRUIT_INFO WHERE LIST_ID IN ("&ids&")"
	conn.Execute sql
	' 删除导师名单记录
	sql="SELECT TEACHER_ID FROM TUTOR_LIST WHERE ID IN ("&ids&")"
	GetRecordSetNoLock conn,rs,sql,result
	Do While Not rs.EOF
		tid_string=tid_string&","&rs(0)
		rs.MoveNext()
	Loop
	' 删除教师两个系统的权限
	sql="DELETE FROM TUTOR_LIST WHERE ID IN ("&ids&");"&_
		"UPDATE TEACHER_INFO SET WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'U6'),'I11'),"&_
		"READPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(READPRIVILEGETAGSTRING,'U6'),'I11') WHERE TEACHERID IN ("&tid_string&") AND NOT EXISTS(SELECT COUNT(ID) FROM TUTOR_LIST WHERE TEACHER_ID=TEACHERID)"
	conn.Execute sql
	CloseConn conn
End If
%><script type="text/javascript">
	alert("操作完成。");
	location.href="tutorList.asp";
</script>