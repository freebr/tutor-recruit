<!--#include file="../inc/upload_5xsoft.inc"-->
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%
curStep=Request.QueryString("step")
Select Case curStep
Case 1	' 上传进程

	Dim fso,Upload,File
	
	Set Upload=New upload_5xsoft
	Set File=Upload.file("upfile")
	Set fso=Server.CreateObject("Scripting.FileSystemObject")
	strUpFile=Upload.Form("filen")
	
	' 检查上传目录是否存在
	strUploadPath = Server.MapPath("upload")
	If Not fso.FolderExists(strUploadPath) Then fso.CreateFolder(strUploadPath)
	
	' 获取文件名和扩展名
	k = InStrRev(strUpFile, ".")
	If k Then
		fileExt = LCase(Mid(strUpFile, k + 1))
	End If
	
	If fileExt <> "xls" And fileExt <> "xlsx" Then	' 不被允许的文件类型
		bError = True
		errstring = "所选择的不是 Excel 文件！"
	Else
		
		' 生成日期格式文件名
		fileid = FormatDateTime(Now(),1)&Int(Timer)
		strDestFile = fileid&"."&fileExt
		strDestPath = strUploadPath&"\"&strDestFile
		byteFileSize = File.FileSize
		' 保存
		File.SaveAs strDestPath
		
	End If
	Set fso=Nothing
	Set File=Nothing
	Set Upload=Nothing
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<title>导入自EXCEL文件</title>
<link href="../css/global.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="ghostwhite">
<center><br /><b>导入自EXCEL文件</b><br /><br /><%
	If Not bError Then %>
<form id="fmUploadFinish" action="?step=2" method="POST">
<input type="hidden" name="filename" value="<%=strDestFile%>" />
<p><%=byteFileSize%> 字节已上传，正在导入开放系统学员名单...</p></form>
<script type="text/javascript">setTimeout("document.all.fmUploadFinish.submit()",500);</script><%
	Else
%>
<script type="text/javascript">alert("<%=errstring%>");history.go(-1);</script><%
	End If
%></center></body></html><%
Case 2	' 数据读取，导入到数据库

	Function addData()
		' 添加数据
		Dim sql,conn
		Dim numNewRec
		Dim stuno,s,i
		numNewRec=0
		Connect conn
		Do While Not rs.EOF
			If IsNull(rs(0)) Or Len(Trim(rs(0)))=0 Then Exit Do
			' 学号
			stuno=rs(0)
			' 姓名
			s=rs(1)
			If Not isStudentExists(stuno) Then
				bError=True
				errMsg=errMsg&"学号不存在:"""&stuno&"""("&s&")。"&vbNewLine
				'addData=-1
				'Exit Function
			Else
				' 增加学生权限
				If numNewRec>0 Then sql=sql&","
				sql=sql&stuno
				numNewRec=numNewRec+1
			End If
			rs.MoveNext()
		Loop
		If numNewRec>0 Then
			sql="EXEC spSwitchStudentPrivilegeByStuNo "&toSqlString(sql)&",1,0;"
			conn.Execute sql
		End If
		CloseConn conn
		addData=numNewRec
	End Function
	
	Dim bError,errMsg,numNewRec
	
	filename=Request.Form("filename")
	filepath=Server.MapPath("upload/"&filename)
	Set connExcel=Server.CreateObject("ADODB.Connection")
	connstring="Provider=Microsoft.ACE.OLEDB.12.0;Data Source="&filepath&";Extended Properties=""Excel 12.0;HDR=yes;IMEX=1"""
	connExcel.Open connstring
	
	Set rsTables=connExcel.OpenSchema(adSchemaTables)
	Do While Not rsTables.EOF
		If rsTables("TABLE_TYPE")="TABLE" Then
			table_name=rsTables("TABLE_NAME")
			If InStr(LCase(table_name),"filter")=0 Then
				sql="SELECT * FROM ["&table_name&"]"
				Set rs=connExcel.Execute(sql)
				' 添加数据
				numNewRec=numNewRec+addData()
			End If
		End If
		rsTables.MoveNext()
	Loop
	CloseRs rsTables
	CloseConn connExcel
%><script type="text/javascript"><%
	If bError Then %>
	alert("导入时出错，其他记录已导入成功。出错原因为：\n<%=toJsString(errMsg)%>");
<%Else %>
	alert("操作成功，<%=numNewRec%>个学员的导师系统权限已开放。");
<%End If
%>location.href="permissionList.asp";
</script><%
End Select
%>