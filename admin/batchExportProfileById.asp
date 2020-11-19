<%Response.Expires=-1
Response.Charset="utf-8"%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<!--#include file="profilegen.inc"-->
<%ids=Request.Form("sel")
step=Request.QueryString("step")
Select Case step
Case vbNullString	' 选择页面
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% useStyleSheet "global" %>
<% useScript "jquery" %>
</head>
<body bgcolor="ghostwhite">
<center><font size=4><b>批量导出学生个人信息</b><br />
<form id="fmFetchFile" action="?step=2" method="POST">
<p>请输入学生ID，以换行符分隔：</p>
<p><textarea name="sel" style="width: 800px; height: 400px"></textarea></p>
<p>打包压缩文件名：<input type="text" name="rarfilename" size="40" value="学生个人信息"/>.rar&nbsp;</p>
<input type="submit" name="btnsubmit" value="导 出" />&nbsp;
<input type="button" name="btnret" value="返 回" onclick="history.go(-1)" /></p></form>
<p align="left"><span id="output" style="color:#000099;font-size:9pt"></span></p></center></body>
<script type="text/javascript">
$(document).ready(function(){
	var progfile="http://www.cnsba.com/TutorRecruit/admin/rar/prog_<%=Session("id")%>_batchExportProfile_asp.txt";
	$('form').submit(function() {
		$(':submit').val("正在处理，请稍候...")
			.attr('disabled',true);
		setInterval(refreshProgress,500);
	});
	$(':submit').attr('disabled',false);
	function refreshProgress() {
		$.get(progfile,function(data,status){
			$('#output').html(data);
		});
	}
});
</script></html><%
Case 2	' 导出和下载页面

	numRecord=UBound(Split(ids,vbNewLine))+1
	If numRecord=0 Then
		bError=True
		errdesc="请输入学生ID！"
	End If
	If bError Then
		showErrorPage errdesc, "提示"
	End If
	
	rarFilename=Trim(Request.Form("rarfilename"))
	If LCase(Right(rarFilename,4))=".rar" Then rarFilename=Trim(Left(rarFilename,Len(rarFilename)-4))
	If Len(rarFilename)=0 Then	' 取默认文件名
		rarFilename="学生个人信息(共"&numRecord&"份)"
	End If
	rarFilename=rarFilename&".rar"
	ConnectDb conn
	sql="SELECT * FROM ViewStudentInfo WHERE STU_ID IN ("&Replace(ids,vbNewLine,",")&")"
	GetRecordSet conn,rs,sql,result
	If rs.EOF Then
		showErrorPage "所选记录不存在！", "提示"
	End If
	
	Server.ScriptTimeout = 1800

	' 导出个人信息
	Dim pg:Set pg=New ProfileGen
	' 打包文件
	Dim progfile
	Dim fso,stream,streamlog,wsh
	Dim sourcefile,bIsMPAcc,tutor_outside
	Dim rarExe,rarFile,tmpDir,sourcefilelist,commentfile
	Dim comment,cmd
	Dim numFailed,numSucceeded,numTotal
	numFailed=0
	numSucceeded=0
	numTotal=1
	rarExe=Server.MapPath("rar/Rar.exe")
	rarFile=Server.MapPath("rar/"&rarFilename)
	tmpDir=Server.MapPath("rar/tmp")
	commentfile=tmpDir&"\comment_"&Timer&".txt"
	progfile=Server.MapPath("rar/prog_"&Session("id")&"_batchExportProfile_asp.txt")
	Set fso=Server.CreateObject("Scripting.FileSystemObject")
	Set streamlog=Server.CreateObject("ADODB.Stream")
	streamlog.Mode=3
	streamlog.Type=2
	streamlog.Open()
	
	' 删除已有目录
	If fso.FolderExists(tmpDir) Then fso.DeleteFolder tmpDir
	fso.CreateFolder tmpDir
	' 删除已有文件
	If fso.FileExists(rarFile) Then fso.DeleteFile rarFile
	Set wsh=Server.CreateObject("WScript.Shell")
	Do While Not rs.EOF
		bIsMPAcc=InStr(LCase(rs("CLASS_NAME")),"mpacc")>0
		
		streamlog.Flush()
		streamlog.WriteText "正在打包第 "&numTotal&" 份个人信息（"&rs("STU_NAME")&"）……"
		streamlog.SaveToFile progfile,2
		streamlog.Position=streamlog.Size
		pg.StuNo=rs("STU_NO")
		pg.StuName=rs("STU_NAME")
		pg.Gender=rs("SEX")
		pg.Birthday=rs("BIRTHDAY")
		pg.Nation=rs("NATION")
		pg.PoliticalVisage=rs("POLITY_VISAGENAME")
		pg.CardID=rs("IDCARD")
		pg.ClassName=rs("CLASS_NAME")
		pg.Tutor=rs("TEACHERNAME")
		pg.Speciality=rs("TUTOR_SPECIALITY_NAME")
		pg.Address=rs("FAMILY_ADDRESS")
		pg.NativePlace=rs("NATIVE_CITY")
		pg.Mobile=rs("SELF_TEL")
		pg.Email=rs("EMAIL")
		pg.TelHome=rs("FAMILY_TEL")
		pg.CompanyName=rs("BEFORE_UNIT")
		pg.DutyName=rs("DUTY")
		pg.Job=rs("JOB_LEVEL")
		pg.LastDegree=rs("DEGREE_NAME")
		pg.ShowTutorOutside=bIsMPAcc
		If bIsMPAcc Then
			tutor_outside=Split(rs("TUTOR_OUTSIDE"),",")
			pg.TutorOutside(0)=tutor_outside(0)
			pg.TutorOutside(1)=tutor_outside(1)
		End If
		pg.LastDiploma=rs("LEVEL_SCHOOL")
		pg.DissertationTopic=rs("THESIS_TOPIC")
		pg.PersonalResume=rs("PERSONAL_RESUME")
		pg.Experiences=rs("EXPERIENCES")
		pg.OccuPlan=rs("OCCU_PLAN")
		sourcefile=tmpDir&"\"&rs("STU_NAME")&"_"&rs("STU_NO")&".docx"
		ret=pg.generateProfile(sourcefile)
		streamlog.Flush()
		If ret=1 Then
			sourcefilelist=sourcefilelist&" """&sourcefile&""""
			numSucceeded=numSucceeded+1
			streamlog.WriteText "完成！<br/>"
		Else
			numFailed=numFailed+1
			streamlog.WriteText "失败！（返回值 "&ret&"）<br/>"
		End If
		streamlog.SaveToFile progfile,2
		streamlog.Position=streamlog.Size
		numTotal=numTotal+1
		rs.MoveNext()
	Loop
	CloseRs rs
	CloseConn conn
	
	' 打包压缩
	cmd=""""&rarExe&""" a -ep -m1 """&rarFile&""" "&tmpDir
	Set exec=wsh.Exec(cmd)
	streamLog.WriteText "正在生成压缩文件……<br/>"
	streamLog.SaveToFile progfile,2
	streamLog.Position=streamLog.Size
	exec.StdOut.ReadAll()
	If numSucceeded=0 Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">未生成任何表格！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
		Response.End
	End If
	' 添加压缩文件注释
	comment="打包报告："&vbNewLine&numSucceeded&" 个成功，"&numFailed&" 个失败。"&errMsg
	Set stream=fso.CreateTextFile(commentfile)
	streamlog.Flush()
	streamlog.WriteText comment
	streamlog.SaveToFile progfile,2
	streamlog.Position=streamlog.Size
	streamlog.Close()
	Set streamlog=Nothing
	
	stream.Write comment
	stream.Close()
	Set stream=Nothing
	cmd=""""&rarExe&""" c -w"""&tmpDir&""" -z"""&commentfile&""" """&rarFile&""""
	Set exec=wsh.Exec(cmd)
	exec.StdOut.ReadAll()
	Set exec=Nothing
	fso.DeleteFile progfile
	fso.DeleteFile commentfile
	fso.DeleteFolder tmpDir
	Set wsh=Nothing
	Set fso=Nothing
	url=resolvePath(baseUrl(),"admin/rar/"&rarFilename)
	Server.ScriptTimeout = 90
%><script type="text/javascript">
	alert("文件已打包完毕，点击“确定”按钮开始下载。")
	window.location.href='<%=url%>';
</script><%
End Select
%>