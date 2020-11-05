﻿<!--#include file="adovbs.inc"-->
<!--#include file="config.inc"--><%
' 建立本系统数据库连接
Function ConnectDb(conn)
	Set conn=Server.CreateObject("ADODB.Connection")
	conn.CommandTimeout=300
	conn.CursorLocation=adUseClient
	conn.Open getConnectionString(uriDatabaseServer, "TutorRecruitSys")
	Set ConnectDb = conn
End Function
' 建立教务系统数据库连接
Function ConnectJWDb(conn)
	Set conn=Server.CreateObject("ADODB.Connection")
	conn.CommandTimeout=300
	conn.CursorLocation=adUseClient
	conn.Open getConnectionString(uriJWDatabaseServer, "SCUT_MD")
	Set ConnectJWDb = conn
End Function
Function getConnectionString(uriServer,initDbName)
	Dim ret
	ret="Provider=SQLNCLI10;Persist Security Info=True;User ID=PaperReviewSystem;Password=HgggLwpy@87114057;Initial Catalog="&initDbName
	ret=ret&Format(";Data Source={0};Pooling=true;Max Pool Size=512;Min Pool Size=50;Connection Lifetime=999;",uriServer)
	getConnectionString=ret
End Function
' 构造命令参数对象
Function CmdParam(name,ptype,size,value)
	Dim cmd:Set cmd=Server.CreateObject("ADODB.Command")
	Set CmdParam=cmd.CreateParameter(name,ptype,adParamInput,size,value)
	Set cmd=Nothing
End Function
%>
<script language="jscript" runat="server">
	function ExecQuery(conn,sql) {
		// 执行查询或存储过程
		if (!conn) ConnectDb(conn);
		var cmd=new ActiveXObject("ADODB.Command");
		cmd.ActiveConnection=conn;
		cmd.CommandText=sql;
		for (var i=2;i<arguments.length;++i) {
			if (arguments[i]) cmd.Parameters.Append(arguments[i]);
		}
		var rs=cmd.Execute();
		var dict=CreateDictionary();
		dict.Add("rs", rs);
		if (rs.State === adStateOpen) {
			dict.Add("count", rs.RecordCount);
		}
		return dict;
	}
	function ExecNonQuery(conn,sql) {
		// 执行不返回记录的存储过程
		if (!conn) ConnectDb(conn);
		var countAffected=0;
		var cmd=new ActiveXObject("ADODB.Command");
		cmd.ActiveConnection=conn;
		cmd.CommandText=sql;
		for (var i=2;i<arguments.length;++i) {
			if (arguments[i]) cmd.Parameters.Append(arguments[i]);
		}
		cmd.Execute(countAffected);
		return countAffected;
	}
</script><%

Sub GetRecordSet(conn,rs,sqlStr,count)
	'================判断SQL注入漏洞如果出现SELECT、exec、0x两次就报错====================
	PSafeRequest(sqlStr)
	'===================================================
	Set rs=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rs.activeConnection=conn
	rs.source=sqlStr
	rs.Open , ,AdOpenKeyset,AdLockOptimistic
	count=rs.RecordCount
End Sub
'========================

Sub GetRecordSetNoLock(conn,rsNoLock,sqlStr,count)
	'================判断SQL注入漏洞如果出现SELECT、exec、0x两次(或一次就报错====================
	'PSafeRequest(sqlStr)
	'===================================================
	Set rsNoLock=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsNoLock.activeConnection=conn
	rsNoLock.source=sqlStr
	rsNoLock.Open , ,AdOpenKeyset,AdLockReadOnly
	count=rsNoLock.RecordCount
End Sub

'========================
Sub GetMenu(table,fieldName,optionText,filter,fieldValue)
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	rsMenu.source="SELECT "&fieldName&","&optionText&" FROM "&table&" WHERE VALID=0 AND "&filter
	'Response.write rsMenu.source
	'Response.End()
	rsMenu.Open , ,AdOpenKeyset
	While Not rsMenu.EOF
	Response.write "<OPTION VALUE='"&HtmlEncode(rsMenu(fieldName))&"'"
	If CStr(rsMenu(fieldName))=Cstr(fieldValue) Then Response.write " SELECTED "
	Response.write ">"&HtmlEncode(rsMenu(optionText))&"</OPTION>"&vbcrlf
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub
'======================== add by yao 2004-12-17
Sub GetDistinctMenu(table,fieldName,fieldId,optionText,filter,fieldValue)
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	rsMenu.source="SELECT "&fieldName&","&fieldId&","&optionText&" FROM "&table&" WHERE VALID=0 AND "&filter
	'Response.write rsMenu.source
	'Response.End()
	rsMenu.Open , ,AdOpenKeyset
	While Not rsMenu.EOF
	Response.write "<OPTION VALUE='"&HtmlEncode(rsMenu(fieldId))&"'"
	If CStr(rsMenu(fieldId))=Cstr(fieldValue) Then Response.write " SELECTED "
	Response.write ">"&HtmlEncode(rsMenu(optionText))&"</OPTION>"&vbcrlf
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub
'=======================
Sub GetLable(Table,FieldId,FieldName,PubTerm)
	LableStr="Select "&FieldId&","&FieldName&" From "&Table&" Where Valid=0"
	If PubTerm<>"" Then
		LableStr=LableStr&PubTerm
	End If
	ConnectDb conn
	GetRecordSetNoLock conn,rsLable,LableStr,countLable
	For Lable_i=1 To resultLable
		Response.write rsLable(FieldName)
		If Lable_i<>1 Then Response.write "&nbsp;"
		rsLable.MoveNext
	Next
	CloseRs rsLable
End Sub
'=======================
Sub GetMenuList(table,fieldName_1,fieldName_2,fieldValue)
	'================判断SQL注入漏洞如果出现SELECT、exec、0x两次(或一次就报错====================
	'PSafeRequest(sqlStr)
	'===================================================
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	rsMenu.source="SELECT * FROM "&table&" WHERE VALID=0"
	 'response.write rsMenu.source
	rsMenu.Open , ,AdOpenKeyset
	While Not rsMenu.EOF
	 'response.write fieldValue
	Response.write "<OPTION VALUE='"&rsMenu(fieldName_1)&"'"
	If rsMenu(fieldName_1)=fieldValue Then Response.write " SELECTED "
	Response.write ">"&rsMenu(fieldName_2)&"</OPTION>"&vbcrlf
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub
'========================
Sub GetMenuList_1(table,fieldName_1,fieldName_2,fieldValue,object,id)
	'================判断SQL注入漏洞如果出现SELECT、exec、0x两次(或一次就报错====================
	'PSafeRequest(sqlStr)
	'===================================================
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	rsMenu.source="SELECT * FROM "&table&" WHERE VALID=0 and "&id&"= "&object&""
	rsMenu.Open , ,AdOpenKeyset
	While Not rsMenu.EOF
	Response.write "<OPTION VALUE='"&rsMenu(fieldName_1)&"'"
	If CStr(rsMenu(fieldName_1))=CStr(fieldValue) Then Response.write " SELECTED "
	Response.write ">"&rsMenu(fieldName_2)&"</OPTION>"&vbcrlf
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub
'=======================
Sub GetMenuListPubTerm(table,FieldID,FieldName,fieldValue,TermStr)
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	If FieldID="" Then
		rsMenu.source="SELECT "
	Else
		rsMenu.source="SELECT DISTINCT "&FieldID&","
	End If
	If TermStr="" Then
		rsMenu.source=rsMenu.source&fieldName&" FROM "&table&" WHERE VALID=0 "
	Else
		rsMenu.source=rsMenu.source&fieldName&" FROM "&table&" WHERE VALID=0 "&TermStr
	End If
	'Response.write rsMenu.source
	'Response.End()

	rsMenu.Open , ,AdOpenKeyset
	'Response.write Cstr(rsMenu(fieldID))
	'response.write Cstr(fieldValue)

	While Not rsMenu.EOF
	If rsMenu(fieldName)<>"" Then
	Response.write "<OPTION VALUE='"&rsMenu(FieldID)&"'"
	If Cstr(rsMenu(fieldID))=Cstr(fieldValue) Then Response.write " SELECTED "
	Response.write ">"&rsMenu(fieldName)&"</OPTION>"&vbcrlf
	End If
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub

Sub GetMenuListPubOrder(table,FieldID,FieldName,fieldValue,TermStr)
	Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
	If IsEmpty(conn) Then ConnectDb conn
	rsMenu.activeConnection=conn
	If FieldID="" Then
		rsMenu.source="SELECT "
	Else
		rsMenu.source="SELECT DISTINCT "&FieldID&","
	End If
	If TermStr="" Then
		rsMenu.source=rsMenu.source&fieldName&" FROM "&table&" WHERE VALID=0 "
	Else
		rsMenu.source=rsMenu.source&fieldName&" FROM "&table&" WHERE VALID=0 "&TermStr
	End If
	rsMenu.source=rsMenu.source&" order by "&FieldID&" desc"

	'Response.write rsMenu.source
	'Response.End()

	rsMenu.Open , ,AdOpenKeyset
	'Response.write Cstr(rsMenu(fieldID))
	'response.write Cstr(fieldValue)

	While Not rsMenu.EOF
	If rsMenu(fieldName)<>"" Then
	Response.write "<OPTION VALUE='"&rsMenu(FieldID)&"'"
	If Cstr(rsMenu(fieldID))=Cstr(fieldValue) Then Response.write " SELECTED "
	Response.write ">"&rsMenu(fieldName)&"</OPTION>"&vbcrlf
	End If
	rsMenu.MoveNext
	Wend
	Set rsMenu=Nothing
End Sub
'=====================================
Sub CloseConn(conn)
	If Not IsEmpty(conn) Then Set conn=Nothing
End Sub
'======================
Sub CloseRs(rs)
	If Not IsEmpty(rs) Then Set rs=Nothing
End Sub
'======================
Function HtmlEncode(fieldVal)
	If Not IsNull(fieldVal) Then HtmlEncode=Server.HTMLEncode(fieldVal)
End Function
'======================
Function GetTime(timeVal)
	If IsDate(timeVal) Then 
	    GetTime=timeVal
	Else
	    GetTime=Null
        End If
End Function

Function xz(id)
 Set rsMenu=Server.CreateObject("ADODB.RECORDSET")
 If IsEmpty(conn) Then ConnectDb conn
 rsMenu.activeConnection=conn
 rsMenu.source="select ADMIN_DUTYNAME from CODE_ADMIN_DUTY where ADMIN_DUTYID=" & id
 '================判断SQL注入漏洞如果出现SELECT、exec、0x两次(或一次就报错====================
 'PSafeRequest(rsMenu.source)
 '===================================================
 rsMenu.Open , ,AdOpenKeyset
 xz=rsMenu("ADMIN_DUTYNAME")
 set rsMenu=nothing
End Function

function seacher_year(id,term)
  str="select ENTER_YEAR from CODE_CLASS where CLASS_ID='"&id&"' and VALID=0"
  GetRecordSet conn,rsMenu,str,count
  if not rsMenu.eof then 
    if term mod 2 =1 then
       term_1=term-1
    else
       term_1=term-2
    end if
    ENTER_YEAR=rsMenu("ENTER_YEAR")
    xuenian_1=ENTER_YEAR+(term_1-(term_1 mod 2))/2
    xuenian_2=xuenian_1+1
  end if
  seacher_year=xuenian_1&","&xuenian_2
  
end function

'=====================判断子字串在母字串中出现的次数==========================
Function RegExpTest(patrn, Fstring)
   Dim regEx,Match,Matches,RegExpSum   '建立变量。
   Set regEx = New RegExp   '建立一般表达式。
   regEx.Pattern= patrn   '设置模式。
   regEx.IgnoreCase = True   '设置是否区分大小写。
   regEx.Global = True   '设置全局可用性。
   Set Matches=regEx.Execute(Fstring)   '执行搜索。
   RegExpSum=0
   For each match in matches   '重复匹配集合
	  RegExpSum=RegExpSum+1
      'RetStr=RetStr &i&"Match found at position "
      'RetStr=RetStr&Match.FirstIndex&".Match Value is '"
      'RetStr=RetStr&Match.Value&"'."&vbCRLF
   Next
   RegExpTest=RegExpSum
End Function
'============================================================================

'========================从GetRecordSet判断SQL注入漏洞如果出现SELECT两次就报错===========================
Function PSafeRequest(SqlStr)
'		Response.write RegExpTest("seLect",sqlStr)&"fff"&sqlStr
'	If Cint(RegExpTest(";",sqlStr))>=1 Then 
'		Response.write "</select>"
'		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
'		Response.write "alert('非法操作');"
'		Response.write "window.history.back();"
'		Response.write "</script>"
'		Response.End()
'	End If 
	If Cint(RegExpTest("select",sqlStr))>1 Then 
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("exec",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("0x",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
End Function
'===================================================
'========================判断SQL注入漏洞如果出现SELECT两次就报错===========================
Function FormProcSafeRequest(SqlStr)
'		Response.write RegExpTest("seLect",sqlStr)&"fff"&sqlStr
	If Cint(RegExpTest(";",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("select",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("exec",sqlStr))>=2 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("0x",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
End Function

'===================================================

'========================从Get数据中判断SQL注入漏洞如果出现非法字符就报错===========================
Function FormGetToSafeRequest(SqlStr)
'		Response.write RegExpTest("seLect",sqlStr)&"fff"&sqlStr
	If Cint(RegExpTest(";",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("'",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("select",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("exec",sqlStr))>=1 Then 
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("0x",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
End Function
Function FormGetToSafeRequest2(SqlStr)
'		Response.write RegExpTest("seLect",sqlStr)&"fff"&sqlStr
	If Cint(RegExpTest(";",sqlStr))>=1 Then 
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("seLect",sqlStr))>=1 Then 
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("exec",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
	If Cint(RegExpTest("0x",sqlStr))>=1 Then
		Response.write "<SCRIPT LANGUAGE='JavaScript'>"
		Response.write "alert('非法操作');"
		Response.write "window.history.back();"
		Response.write "</script>"
		Response.End()
	End If 
End Function
'===================================================
'===================================================
'在SESSION里边判断TID是否存在~如果不存在的话就跳超时页面
Function IfSession()
	If Session("id")="" Then
		 Response.Redirect("../error.asp?timeout")
	End If
End Function
'===================================================

'=============================多项下拉列表=======================================
Sub Get_SpeListMenu(ArrayList,j)
		'ArrayList 是传入的一数组  j为传入数组下标的值
		'例如 ArrayList数组有下例值 每个单元分别表示为
		'ArrayList(0,0)="类型"					'显示的名字
		'ArrayList(0,1)=Table					'表名
		'ArrayList(0,2)="TEACHTYPE_ID"			'SELECT VALUE的值
		'ArrayList(0,3)="TEACHTYPE_NAME"			'SELECT 显示出来的值
		'ArrayList(0,4)="4"						'SELECT 默认值
		'ArrayList(0,5)=""						'SELECT 默认的条件值
	For  i=0 To j
		If ((i+1) mod 3)=1 Then
			Response.write "<tr bgcolor=""ghostwhite"">"
		End If
		'===========================================================
		'类型 博士,硕士,本科  （下拉列表） 如果类型表中没有TEACHTYPE_ID请自行到视图中加上
		Response.write "<td width=50>"&ArrayList(i,0)&"</td>"&vbcrlf
		Response.write "<td"
		Response.write ">"
		Response.write "<input type='hidden' name='List_"&ArrayList(i,2)&"_TermStr'>"&vbcrlf
		Response.write "<select name='"&ArrayList(i,2)&"' "
		If i<>j Then
			'最后一个不用运行JAVASCRIPT
			Response.write "onchange=""List_OnChange();this.form.submit();"""
		End If
		Response.write ">"&vbcrlf
		Response.write "<OPTION VALUE=""-1"">请选择"&ArrayList(i,0)&"</option>"&vbcrlf
		If request.Form(ArrayList(i,2)).count<>0 then
		'初始值的选定值
			List_ID=request.Form(ArrayList(i,2))
		Else
			List_ID=ArrayList(i,4)
		End If
		If request.Form(ArrayList(i,2)).count<>0 then
		'初始值的条件值
			If i>0 Then
				TermSqlStr=Request.Form("List_"&ArrayList(i-1,2)&"_TermStr")
			End If
			If i=0 Then
				TermSqlStr=ArrayList(i,5)
			End If
		Else
			TermSqlStr=ArrayList(i,5)
		End If
		GetMenuListPubTerm ArrayList(i,1),ArrayList(i,2),ArrayList(i,3),List_ID,TermSqlStr 
		Response.write 	"</select>"
		Response.write "</td>"&vbcrlf
		If ((i+1) mod 3)=0 and i<>2 Then	'or i=j
			Response.write "</tr>"&vbcrlf
		End If
	Next

'--------------------------------------------------------
	
	Response.write "<SCRIPT>"&vbcrlf
	Response.write "function List_OnChange(){"&vbcrlf
	'这个JAVASCRIPT FUNCTION 的功能转换条件
	For  i=0 To j
		Response.write "document.all.List_"&ArrayList(i,2)&"_TermStr.value = "
		If i>0 Then
			Response.write "document.all.List_"&ArrayList(i-1,2)&"_TermStr.value  +"
		End If
		Response.write "' and "&""&ArrayList(i,2)&"='+"&"""'"""&"+document.all."&ArrayList(i,2)&".value+""'"""&";"&vbcrlf
	Next
	Response.write "}"&vbcrlf

	Response.write "function List_OnSubmit(){"&vbcrlf
	'这个JAVASCRIPT FUNCTION 的功能是把最终要提交到下一个FORM的变量传到公共变量中
	Response.write "List_OnChange();"&vbcrlf
	Response.write "document.all.PubTerm.value=document.all.List_"&ArrayList(j,2)&"_TermStr.value;"&vbcrlf
	Response.write "}"&vbcrlf
	Response.write "</SCRIPT>"&vbcrlf
End Sub
'====================================================================
Function GetDBData(SQLCommand)
   Dim DB
   Dim cn
   Set cn = Server.CreateObject("ADODB.Connection") 
   cn.ConnectionString=getConnectionString()
   cn.CommandTimeout = 0
   cn.Open
   Set DB=Server.CreateObject("ADODB.Recordset")
   DB.CursorType = 1      'adOpenKeySet
   DB.CursorLocation = 3  'adUseClient
   DB.ActiveConnection = cn
   DB.Open(SQLCommand)
   If DB.State <>0 Then     
      If DB.RecordCount > 0 Then
            db.MoveFirst
            Set GetDBData = DB
      Else
           Set getdbdata = nothing
      End If   
   Else
       Set getdbdata = nothing
   End If
End Function
%>