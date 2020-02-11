<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
Dim ids,tid_string
ids=Request.Form("sel")
If Len(ids) Then
	tid_string="0"
	Connect conn
	sql="SELECT TEACHER_ID FROM TUTOR_LIST WHERE ID IN ("&ids&")"
	GetRecordSetNoLock conn,rs,sql,result
	Do While Not rs.EOF
		tid_string=tid_string&","&rs(0)
		rs.MoveNext()
	Loop
	' 对无导师信息的教师删除两个系统的权限
	sql="DELETE FROM TUTOR_LIST WHERE ID IN ("&ids&");"&_
		"UPDATE TEACHER_INFO SET WRITEPRIVILEGETAGSTRING=REPLACE(WRITEPRIVILEGETAGSTRING,'U6,I11,',''),"&_
		"READPRIVILEGETAGSTRING=REPLACE(READPRIVILEGETAGSTRING,'U6,I11,','') WHERE TEACHERID IN ("&tid_string&") AND NOT EXISTS(SELECT COUNT(ID) FROM TUTOR_LIST WHERE TEACHER_ID=TEACHERID)"
	conn.Execute sql
	CloseConn conn
End If
%><script type="text/javascript">
	alert("操作完成。");
	location.href="tutorList.asp";
</script>