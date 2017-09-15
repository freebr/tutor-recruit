<!--#include file="../inc/global.inc"-->
<%
Function getTeacherIdByName(name)
	If IsNull(name) Then
		getTeacherIdByName=-1
		Exit Function
	End If
	Dim conn,rsTeacher,sql,num
	name=Replace(name," ",vbNullString)
	name=Replace(name,"　",vbNullString)
	name=Replace(name,"'","''")
	name=Replace(name,"""","""""")
	Connect conn
	sql="SELECT TEACHERID,TEACHERNAME FROM TEACHER_INFO WHERE TEACHERNAME='"&name&"' AND VALID=0"
	GetRecordSetNoLock conn,rsTeacher,sql,num
	If rsTeacher.EOF Then
		getTeacherIdByName=-1
	Else
		getTeacherIdByName=rsTeacher("TEACHERID")
	End If
	CloseRs rsTeacher
	CloseConn conn
End Function

Function isStudentExists(stuno)
	If IsNull(stuno) Then
		isStudentExists=False
		Exit Function
	End If
	Dim conn,rs,sql,num
	stuno=Trim(stuno)
	Connect conn
	sql="SELECT STU_NO FROM STUDENT_INFO WHERE STU_NO='"&stuno&"'"
	GetRecordSetNoLock conn,rs,sql,num
	isStudentExists=Not rs.EOF
	CloseRs rs
	CloseConn conn
End Function

Function getItemIdByName(name,field_id,field_name,table_name)
	If IsNull(name) Then
		getItemIdByName=0
		Exit Function
	End If
	Dim conn,rs,sql,num
	Connect conn
	sql="SELECT "&field_id&" FROM "&table_name&" WHERE "&field_name&"="&toSqlString(name)
	GetRecordSet conn,rs,sql,num
	If rs.EOF Then
		getItemIdByName=0
	Else
		getItemIdByName=rs(0)
	End If
	CloseRS rs
	CloseConn conn
End Function

Function getRecruitTypeValue(typename)
	Dim arr,i,ret
	arr=getDataArray(typename)
	ret=0
	For i=0 To UBound(arr)
		Select Case UCase(Trim(arr(i)))
		Case "MBA"
			ret=ret+1
		Case "EMBA"
			ret=ret+2
		Case "MPACC"
			ret=ret+4
		Case "工程硕士"
			ret=ret+8
		End Select
	Next
	getRecruitTypeValue=ret
End Function

Function getDataArray(data)
	Dim arr,i,delim
	Const enum_delim="/、，,;"
	If IsNull(data) Then
		ReDim arr(0)
		getDataArray=arr
		Exit Function
	End If
	For i=1 To Len(enum_delim)
		delim=Mid(enum_delim,i,1)
		If InStr(data,delim) Then
			arr=Split(data,delim)
			Exit For
		End If
	Next
	If Not IsArray(arr) Then
		arr=Split(data)
	End If
	getDataArray=arr
End Function

Function semesterList(ctlname,sel)	' 显示学期选择框
	Dim conn,comm,pmSem,rs
	Connect conn
	Set comm=Server.CreateObject("ADODB.Command")
	comm.ActiveConnection=conn
	comm.CommandText="getSemesterList"
	comm.CommandType=adCmdStoredProc
	Set pmSem=comm.CreateParameter("semester",adInteger,adParamInput,5,0)
	comm.Parameters.Append pmSem
	Set rs=comm.Execute()
	%><select id="<%=ctlname%>" name="<%=ctlname%>"><option value="0">请选择</option><%
	Do While Not rs.EOF %>
	<option value="<%=rs("PERIOD_ID")%>"<% If sel=rs("PERIOD_ID") Then %> selected<% End If %>><%=rs("PERIOD_NAME")%></option><%
		rs.MoveNext()
	Loop
	Set pmSem=Nothing
	Set comm=Nothing
	CloseRs rs
	CloseConn conn
	%></select><%
End Function

arrTurnName=Array("","第一志愿","第二志愿","第三志愿")
arrStuTypeId=Array("",5,6,7,9)
arrStuType=Array("","ME","MBA","EMBA","MPAcc")
%>