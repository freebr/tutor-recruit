<!--#include file="../inc/upload_5xsoft.inc"-->
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%
curStep=Request.QueryString("step")
Select Case curStep
Case vbNullstring ' 文件选择页面
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>导入自EXCEL文件</b><br>
<form id="fmUpload" action="?step=1" method="POST" enctype="multipart/form-data">
<p>请选择要导入的 Excel 文件：<br />文件名：<input type="file" name="excelFile" size="100" />
<input type="hidden" name="filen" id="filen" />
<input type="button" name="btnret" value="返 回" onclick="history.go(-1)" /></p></form></center>
<script type="text/javascript">
	document.all.fmUpload.excelFile.onchange=function() {
		var fileName = this.value;
		var fileExt = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
		if (fileExt != ".xls" && fileExt != ".xlsx") {
			alert("所选文件不是 Excel 文件！");
			this.form.reset();
			return false;
		}
		document.all.filen.value=document.all.excelFile.value;
		this.form.submit();
	}
</script></body></html><%
Case 1	' 上传进程

	Dim fso,Upload,File
	
	Set Upload=New upload_5xsoft
	Set File=Upload.file("excelFile")
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
		strDestPath = Server.MapPath("upload")&"\"&strDestFile
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
<link href="css.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="ghostwhite">
<center><br /><b>导入自EXCEL文件</b><br /><br /><%
	If Not bError Then %>
<form id="fmUploadFinish" action="?step=2" method="POST">
<input type="hidden" name="filename" value="<%=strDestFile%>" />
<p><%=byteFileSize%> 字节已上传，正在导入硕士生导师名单...</p></form>
<script type="text/javascript">setTimeout("document.all.fmUploadFinish.submit()",500);</script><%
	Else
%>
<script type="text/javascript">alert("<%=errstring%>");history.go(-1);</script><%
	End If
%></center></body></html><%
Case 2	' 数据读取，导入到数据库

	Function updateData()
		Connect conn
		Do While Not rs.EOF
			sql="SELECT TEACHER_ID,RECRUIT_ID FROM ViewRecruitInfo WHERE TEACHTYPE_ID=9 AND PERIOD_ID=20142 AND TEACHER_NAME='"&rs(0)&"'"
			'sql="SELECT Count(*) FROM ViewRecruitInfo WHERE TEACHTYPE_ID=9 AND PERIOD_ID=20142 AND TEACHER_NAME='"&rs(0)&"'"
			Set rs2=conn.Execute(sql)
			'response.write rs2(0) &"<br/>"
			sql="UPDATE STUDENT_INFO SET TUTOR_ID="&rs2("TEACHER_ID")&", TUTOR_RECRUIT_ID="&rs2("RECRUIT_ID")&" WHERE STU_NAME='"&rs(1)&"' AND TEACH_TYPEID=6 AND STU_NO LIKE '2013%' AND VALID=0"
			conn.Execute(sql)
			rs.MoveNext()
		Loop
	End Function
	
	Dim errMsg
	Dim output
	
	filename=Request.Form("filename")
	filepath=Server.MapPath("upload/"&filename)
	Set connExcel=Server.CreateObject("ADODB.Connection")
	connstring="Provider=Microsoft.ACE.OLEDB.12.0;Data Source="&filepath&";Extended Properties=""Excel 12.0;HDR=Yes;IMEX=1"""
	connExcel.Open connstring
	
	Set rs=connExcel.OpenSchema(adSchemaTables)
	Do While Not rs.EOF
		If rs("TABLE_TYPE")="TABLE" Then
			table_name=rs("TABLE_NAME")
			Exit Do
		End If
		rs.MoveNext()
	Loop
	
	sql="SELECT * FROM ["&table_name&"]"
	Set rs=connExcel.Execute(sql)
	
	updateData()
	
	CloseConn connExcel
End Select
%>