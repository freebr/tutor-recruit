<!--#include file="../inc/global.inc"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
Dim ids,tid_string
ids=Request.Form("sel")
If Len(ids) Then
	tid_string="0"
	exclude_ids="0"
	exclude_tname_string=""
	Connect conn
	sql="SELECT DISTINCT LIST_ID,TEACHER_NAME,COUNT(LIST_ID) FROM ViewApplyInfoByTurn WHERE LIST_ID IN ("&ids&") GROUP BY LIST_ID,TEACHER_NAME"
	GetRecordSetNoLock conn,rs,sql,result
	Do While Not rs.EOF
		exclude_ids=exclude_ids&","&rs(0)
		exclude_tname_string=exclude_tname_string&rs(1)&"："&rs(2)&" 个学生选择"&vbNewLine
		rs.MoveNext()
	Loop
	CloseRs rs
	
	sql="SELECT TEACHER_ID FROM ViewTutorInfo WHERE ID IN ("&ids&") AND ID NOT IN ("&exclude_ids&")"
	GetRecordSetNoLock conn,rs,sql,result
	Do While Not rs.EOF
		tid_string=tid_string&","&rs(0)
		rs.MoveNext()
	Loop
	' 对无导师信息的教师删除两个系统的权限
	sql="DELETE FROM TutorInfo WHERE ID IN ("&ids&") AND ID NOT IN ("&exclude_ids&");"&_
		"UPDATE SCUT_MD.dbo.TeacherInfo SET WRITEPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(WRITEPRIVILEGETAGSTRING,'U6'),'I11'),"&_
		"READPRIVILEGETAGSTRING=dbo.removePrivilege(dbo.removePrivilege(READPRIVILEGETAGSTRING,'U6'),'I11') WHERE TEACHERID IN ("&tid_string&") AND NOT EXISTS(SELECT COUNT(ID) FROM ViewTutorInfo WHERE TEACHER_ID=TEACHERID)"
	conn.Execute sql
	CloseConn conn
	
	If Len(exclude_tname_string)=0 Then
		notice="操作完成。"
	Else
		notice="以下导师存在关联的学生填报记录，因此暂时无法被删除："&vbNewLine&exclude_tname_string
		If tid_string<>"0" Then
			notice=notice&"其余导师信息删除成功。"
		End If
	End If
End If
%><script type="text/javascript">
	alert("<%=toJsString(notice)%>");
	location.href="tutorList.asp";
</script>