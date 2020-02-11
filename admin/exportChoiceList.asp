<%Response.Charset="utf-8"%>
<!--#include file="../inc/db.asp"-->
<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
filename=Request.QueryString("fn")
If Len(filename)=0 Then
	filename=FormatDateTime(Now(),1) & Int(Timer)
	bFilenameSpec=False
Else
	bFilenameSpec=True
End If
retlink=Request.QueryString("ret")
exportall=Request.QueryString("exportall")
nTurn=Request.QueryString("turn")

object=Request.Form("In_TEACHTYPE_ID")
period_id=Request.Form("In_PERIOD_ID")
query_recruit_status=Request.Form("In_RECRUIT_STATUS")
finalFilter=Request.Form("finalFilter2")
If Len(finalFilter) Then PubTerm=" AND "&finalFilter
If Len(query_recruit_status) And query_recruit_status<>"-1" Then
	PubTerm=PubTerm&" AND TUTOR_RECRUIT_STATUS="&query_recruit_status
End If
FormGetToSafeRequest(object)
FormGetToSafeRequest(period_id)

If period_id="" or object="" Then
%><body bgcolor="ghostwhite"><center><font color=red size="4">信息不完整或格式不正确！</font><br /><input type="button" value="返 回" onclick="history.go(-1)" /></center></body><%
	Response.end
End If

Class ExcelGen
	Private spSheet
	Private iColOffset
	Private iRowOffset
	
	Sub Class_Initialize()
	  Set spSheet = Server.CreateObject("OWC11.Spreadsheet")
	  spSheet.DisplayToolBar = True
	  iRowOffSet = 2
	  iColOffSet = 2
	End Sub
	
	Sub Class_Terminate()
	  Set spSheet = Nothing 'Clean up
	End Sub
	
	Public Property Let ColumnOffset(iColOff)
	  If iColOff > 0 then
	    iColOffSet = iColOff
	  Else
	    iColOffSet = 2
	  End If
	End Property
	
	Public Property Let RowOffset(iRowOff)
	  If iRowOff > 0 then
	     iRowOffSet = iRowOff
	  Else
	     iRowOffSet = 2
	  End If
	End Property
	
	Function GenerateWorksheet(arrFields, rs)
	  'Populates the Excel worksheet based on a Recordset's contents
	  'Start by displaying the titles
	  Dim iCol,iRow,i
	  Dim nSheetId,nRecNum
	  Dim rsCur,sheet
	  
	  Set rsCur=rs
	  nSheetId=0
	  Do While Not rsCur Is Nothing
		  nRecNum=0
		 	If nSheetId>0 Then
	  		Set sheet=sheet.Next
	  		If sheet Is Nothing Then
	  			Set sheet=spSheet.Sheets.Add()
	  		End If
	  		sheet.Activate()
	  	Else
	  		Set sheet=spSheet.ActiveSheet
	  	End If
		  If Not rsCur.EOF Then
				iCol=iColOffset
				iRow=iRowOffset
	  		sheet.Name=rsCur("SHEET_NAME")
				For i=0 To UBound(arrFields)
					strFieldName = arrFields(i)
					spSheet.Cells(iRow, iCol).Value = strFieldName
					spSheet.Cells(iRow, iCol).Font.Bold = True 
					spSheet.Cells(iRow, iCol).Font.Italic = False
					spSheet.Cells(iRow, iCol).Font.Size = 10
					spSheet.Cells(iRow, iCol).HorizontalAlignment = -4108 ' 居中
					spSheet.Columns(iCol).AutoFit()
					iCol = iCol + 1
				Next
				'Display all of the data
				Do While Not rsCur.EOF
				 	iRow = iRow + 1
				 	iCol = iColOffset
				 	For j=0 To UBound(arrFields)
				    If IsNull(rsCur(j)) Then
				      spSheet.Cells(iRow, iCol).Value = ""
				    Else
				    	If iCol=iColOffset Then
				    		spSheet.Cells(iRow, iCol).Value = iRow-iRowOffset
				    	Else
				      	spSheet.Cells(iRow, iCol).Value = CStr(rsCur(j))
				      End If
							spSheet.Cells(iRow, iCol).Font.Bold = False
							spSheet.Cells(iRow, iCol).Font.Italic = False
							spSheet.Cells(iRow, iCol).Font.Size = 10 
							spSheet.Columns(iCol).AutoFit()
				    End If
				  	iCol = iCol + 1
					Next
					nRecNum=nRecNum+1
					rsCur.MoveNext()
				Loop
				nSheetId=nSheetId+1
			End If
			Set rsCur=rsCur.NextRecordSet()
		Loop
		GenerateWorksheet=nRecNum
	End Function
	
	Function SaveWorksheet(strFileName)
		'Save the worksheet to a specified filename
		On Error Resume Next
		Call spSheet.Export(strFileName, 0)
		SaveWorksheet = (Err.Number = 0)
	End Function
End Class

ReDim arrFields(9)
arrFields(0) = "序号"
arrFields(1) = "学号"
arrFields(2) = "姓名"
arrFields(3) = "工作单位"
arrFields(4) = "职务"
arrFields(5) = "班级"
arrFields(6) = "所选导师"
arrFields(7) = "移动电话"
arrFields(8) = "电子邮箱"
arrFields(9) = "状态"

Dim rs
Connect conn

If exportall=1 Then
	ReDim obj(2)
	obj(0)=5
	obj(1)=6
	obj(2)=9
Else
	ReDim obj(0)
	obj(0)=object
End If
sql=""
sql2=""
For i=0 To UBound(obj)
	Select Case obj(i)
	Case 5:obj_name="ME"
	Case 6:obj_name="MBA"
	Case 9:obj_name="MPAcc"
	End Select
	sheetName=obj_name&"双选结果"
	PubTerm2="VALID=0 AND TUTOR_PERIOD_ID="&period_id&" AND TEACHTYPE_ID="&obj(i)&" AND TUTOR_ID<>0"&PubTerm
	If nTurn<>0 Then
		sheetName=sheetName&"(第 "&nTurn&" 批)" 
		PubTerm2=PubTerm2&" AND STU_ID NOT IN (SELECT STU_ID FROM TUTOR_SYSTEM_EXPORT_INFO WHERE PERIOD_ID="&period_id&")"
	End If
	sql=sql&"SELECT STU_ID,''''+STU_NO AS STU_NO,STU_NAME,BEFORE_UNIT,DUTY,CLASS_NAME,TEACHERNAME,(SELF_TEL+Char(9)) AS SELF_TEL,EMAIL,dbo.getApplyStatusText(TUTOR_RECRUIT_STATUS),SHEET_NAME='"&sheetName&"' FROM VIEW_STUDENT_INFO_NEW WHERE "&PubTerm2&" ORDER BY Stu_Name;"
	sql2=sql2&"INSERT INTO TUTOR_SYSTEM_EXPORT_INFO (STU_ID,PERIOD_ID,TURN_ID) SELECT STU_ID,"&period_id&","&nTurn&" FROM VIEW_STUDENT_INFO WHERE "&PubTerm2&";"
Next
Set rs=conn.Execute(sql)
If nTurn<>0 Then
	conn.Execute sql2
End If

Dim fso
Set fso=Server.CreateObject("Scripting.FileSystemObject")
Do
	If bFilenameSpec Then
		ExcelPath = "export/spec/"&filename&".xls"
	Else
		ExcelPath = "export/"&filename&".xls"
	End If
	filename=filename&"(2)"
Loop While fso.FileExists(Server.MapPath(ExcelPath))
Set fso=Nothing

Set objExcel=New ExcelGen
objExcel.RowOffSet=1
objExcel.ColumnOffSet=1
nRecNum=objExcel.GenerateWorksheet(arrFields, rs)
If nRecNum>0 Then
	If objExcel.SaveWorksheet(Server.MapPath(ExcelPath)) then
		nResult=1
	Else
		nResult=2
	End If
Else
	nResult=0
End If
Set objExcel = Nothing
CloseRs rs
CloseConn conn
If Len(retlink) Then
	Response.Redirect retlink
End If
%><html><head><link href="../css/global.css" rel="stylesheet" type="text/css"></head><body bgcolor="ghostwhite"><p align="center"><%
Select Case nResult
Case 0
%>未生成Excel文件，因为没有数据库记录!<%
Case 1
%>已保存为Excel文件，<a href="<%=ExcelPath%>" target="_blank">点击下载</a>（直接点击打开，点击右键另存为下载）<%
Case 2
%>保存过程中发生错误!<%
End Select
%><br><a href="javascript:history.go(-1)">返回</a></p></body></html>