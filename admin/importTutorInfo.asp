<!--#include file="../inc/upload_5xsoft.inc"-->
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"--><%
curStep=Request.QueryString("step")
Select Case curStep
Case vbNullstring ' 文件选择页面
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="../css/global.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../scripts/jquery-1.6.3.min.js"></script>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>导入导师名单自EXCEL文件</b><br>
<form id="fmUpload" action="?step=1" method="POST" enctype="multipart/form-data">
<p>请选择导师名单适用的学生类型：<%
	For i=1 To SYS_STUTYPE_COUNT
%>&emsp;<label for="stu_types<%=i%>"><input type="checkbox" name="stu_types" id="stu_types<%=i%>" value="<%=arrStuTypeId(i)%>" /><%=arrStuType(i)%></label><%
	Next
%></p>
<p><label for="remove_all_rec_info"><input type="checkbox" name="remove_all_rec_info" id="remove_all_rec_info" />刷新名额前，删除本学期所选学生类型的招生信息</label></p>
<p><label for="append_quota"><input type="checkbox" name="append_quota" id="append_quota" />作为追加名额导入</label></p>
<p>请选择要导入的 Excel 文件：<br />文件名：<input type="file" name="upfile" size="100" /><br /><a href="template/tutorinfo.xlsx" target="_blank">点击下载导师名单模板</a><br />
<input type="submit" name="btnupload" value="上 传" />&nbsp;
<input type="button" name="btnret" value="返 回" onclick="history.go(-1)" /></p></form></center></body>
<script type="text/javascript">
$(document).ready(function(){
	$('form').submit(function() {
		var valid=checkIfExcel(this.excelFile)&&checkIfRar(this.rarFile);
		if(valid) {
			$(':submit').val("正在上传，请稍候...").attr('disabled',true);
		}
		return valid;
	});
	$(':submit').attr('disabled',false);
});
</script></body></html><%
Case 1	' 上传进程

	Dim fso,Upload,File
	
	Set Upload=New upload_5xsoft
	Set tableFile=Upload.File("upfile")
	Set fso=Server.CreateObject("Scripting.FileSystemObject")
	stuTypes=Upload.Form("stu_types")
	removeAllRecInfo=Upload.Form("remove_all_rec_info")
	appendQuota=Upload.Form("append_quota")
	
	' 检查上传目录是否存在
	strUploadPath = Server.MapPath("upload")
	If Not fso.FolderExists(strUploadPath) Then fso.CreateFolder(strUploadPath)
	
	' 获取文件名和扩展名
	fileExt = tableFile.FileExt
	If fileExt <> "xls" And fileExt <> "xlsx" Then	' 不被允许的文件类型
		bError = True
		errstring = "所选择的不是 Excel 文件！"
	Else
		
		' 生成日期格式文件名
		fileid = FormatDateTime(Now(),1)&Int(Timer)
		strDestFile = fileid&"."&fileExt
		strDestPath = strUploadPath&"\"&strDestFile
		byteFileSize = tableFile.FileSize
		' 保存
		tableFile.SaveAs strDestPath
		
	End If
	Set fso=Nothing
	Set tableFile=Nothing
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
<input type="hidden" name="stu_types" value="<%=stuTypes%>" />
<input type="hidden" name="remove_all_rec_info" value="<%=removeAllRecInfo%>" />
<input type="hidden" name="append_quota" value="<%=appendQuota%>" />
<p><%=byteFileSize%> 字节已上传，正在导入硕士生导师名单...</p></form>
<script type="text/javascript">setTimeout("document.all.fmUploadFinish.submit()",500);</script><%
	Else
%>
<script type="text/javascript">alert("<%=errstring%>");history.go(-1);</script><%
	End If
%></center></body></html><%
Case 2	' 数据读取，导入到数据库

	Function addData()
		' 添加数据
		Dim fieldValue(7)
		Dim arrSpec,specId,specName
		Dim sql,sql2,sql3,conn,rsDb
		Dim numNewRec,numNewTeacher,numUpdTeacher
		Dim bIsUpdated
		Dim arrRet(1)
		Dim s,i,j
		numNewRec=0
		numUpdTeacher=0
		numNewTeacher=0
		Connect conn
		
		Do While Not rs.EOF
			If IsNull(rs("姓名")) Then Exit Do
			bIsUpdated=False
			' 姓名
			s=getTeacherIdByName(rs("姓名"))
			If s=-1 Then
				bError=True
				errMsg=errMsg&"教师不存在:"""&rs("姓名")&"""。\n"
				'addData=-1
				'Exit Function
			Else
				fieldValue(0)=s
				' 职称
				s=getItemIdByName(rs("职称"),"PRO_DUTYID","PRO_DUTYNAME","ViewDutyInfo")
				fieldValue(1)=s
				
				' 专业学位类型
				fieldValue(2)=getRecruitTypeValue(rs("专业学位类型"))
				' 工程领域名称
				fieldValue(3)=toSqlString(rs("工程领域名称"))
				' 主副岗
				fieldValue(4)=toSqlString(rs("主岗"))
				fieldValue(5)=toSqlString(rs("兼岗"))
				' 名额
				fieldValue(6)=rs("指导名额")
				If Not IsNumeric(fieldValue(6)) Or IsNull(fieldValue(6)) Then
					fieldValue(6)="0"
				End If
				' 备注
				fieldValue(7)=toSqlString(rs("备注"))
				' 学术型招生专业名称
				For j=0 To rs.Fields.Count-1
					If InStr(rs.Fields(j).Name,"专业名称") Then
						arrSpec=getDataArray(rs(j))
						Exit For
					End If
				Next
				For i=0 To UBound(arrSpec)
					specId=getItemIdByName(arrSpec(i),"SPECIALITY_ID","SPECIALTY_NAME","ViewSpecialityInfo")
					If specId=0 Then
						specName=toSqlString(arrSpec(i))
					Else
						specName="NULL"
					End If
					
					sql3="SELECT ID FROM ViewTutorInfo WHERE "
					If Len(arrSpec(i))=0 Then
						sql3=sql3&"SPECIALITY_NAME IS NULL"
					Else
						sql3=sql3&"SPECIALITY_NAME="&toSqlString(arrSpec(i))
					End If
					sql3=sql3&" AND TEACHER_ID="&fieldValue(0)
					Set rsDb=conn.Execute(sql3)
					If rsDb.EOF Then	' 新建记录
						If numNewRec>0 Then sql=sql&" UNION ALL "
						sql=sql&"SELECT "&fieldValue(0)&","&fieldValue(1)&","&fieldValue(2)&","&fieldValue(6)&","&fieldValue(4)&","&_
										fieldValue(5)&","&specId&",0,"&specName&","&fieldValue(3)&","&fieldValue(7)&","&updateTime&",1"
						numNewRec=numNewRec+1
					Else					' 更新记录
						sql2=sql2&"UPDATE TutorInfo SET PRO_DUTYID="&fieldValue(1)&",RECRUIT_TYPE="&fieldValue(2)&_
								 ",DEFAULT_QUOTA="&fieldValue(6)&",PRIMARY_TYPE="&fieldValue(4)&",SECOND_TYPE="&fieldValue(5)&_
								 ",SPECIALITY_ID="&specId&",RESEARCH_WAYID=0,APPLY_SPECIALITY="&specName&",APPLY_RESEARCH="&fieldValue(3)&_
								 ",MEMO="&fieldValue(7)&",UPDATE_TIME="&updateTime&",VALID=1 WHERE ID="&rsDb(0)&";"
						bIsUpdated=True
					End If
					CloseRs rsDb
				Next
				If bIsUpdated Then
					numUpdTeacher=numUpdTeacher+1
				Else
					numNewTeacher=numNewTeacher+1
				End If
			End If
			rs.MoveNext()
		Loop
		If numNewRec>0 Then
			sql="INSERT INTO TutorInfo (TEACHER_ID,PRO_DUTYID,RECRUIT_TYPE,DEFAULT_QUOTA,PRIMARY_TYPE,SECOND_TYPE,SPECIALITY_ID,RESEARCH_WAYID,APPLY_SPECIALITY,APPLY_RESEARCH,MEMO,UPDATE_TIME,VALID) "&sql
			conn.Execute sql
		End If
		If numUpdTeacher>0 Then conn.Execute sql2
		' 添加教师权限
		sql="EXEC spSwitchAllTutorPrivilege 1"
		conn.Execute sql
		CloseConn conn
		arrRet(0)=numNewTeacher
		arrRet(1)=numUpdTeacher
		addData=arrRet
	End Function
	
	Dim bError,errMsg,arr
	Dim updateTime:updateTime=toSqlString(Now)
	
	filename=Request.Form("filename")
	filepath=Server.MapPath("upload/"&filename)
	stuTypes=Request.Form("stu_types")
	removeAllRecInfo=Abs(Int(Request.Form("remove_all_rec_info")="on"))
	appendQuota=Abs(Int(Request.Form("append_quota")="on"))
	Set connExcel=Server.CreateObject("ADODB.Connection")
	connstring="Provider=Microsoft.ACE.OLEDB.12.0;Data Source="&filepath&";Extended Properties=""Excel 12.0;HDR=Yes;IMEX=1"""
	connExcel.Open connstring
	
	Set rs=connExcel.OpenSchema(adSchemaTables)
	Do While Not rs.EOF
		If rs("TABLE_TYPE")="TABLE" Then
			table_name=rs("TABLE_NAME")
			If InStr("硕导总名单$",table_name) Then Exit Do
		End If
		rs.MoveNext()
	Loop
	
	sql="SELECT * FROM ["&table_name&"A2:M]"
	Set rs=connExcel.Execute(sql)
	
	' 定位到数据行
	'rs.Move 1
	
	' 添加数据
	arr=addData()
	
	CloseConn connExcel
	
	' 刷新指导名额
	Dim countInsert,countUpdate
	
	sql="CREATE TABLE #ret(CountInsert int,CountUpdate int,CountError int,IsError bit,ErrMsg nvarchar(MAX));"&_
			"INSERT INTO #ret EXEC spUpdateRecruitQuota "&sem_info(0)&","&sem_info(1)&","&updateTime&",'"&stuTypes&"',"&removeAllRecInfo&","&appendQuota&"; SELECT * FROM #ret"
	Connect conn
	Set rs=conn.Execute(sql).NextRecordSet
	countInsert=rs("CountInsert")
	countUpdate=rs("CountUpdate")
	bError=bError Or rs("IsError")
	errMsg=errMsg&rs("ErrMsg")
	CloseRs rs
	CloseConn conn
	
%><script type="text/javascript"><%
	If bError Then
		errMsg="\n导入时发生以下错误：\n"&toJsString(errMsg)
	End If %>
alert("操作成功，结果如下：\n导师信息：<%=arr(0)%>条已导入，<%=arr(1)%>条已更新，已自动设为开放状态。\n招生信息：<%=countInsert%>条已导入，<%=countUpdate%>条已更新。<%=errMsg%>");
location.href="tutorList.asp";
</script><%
End Select
%>