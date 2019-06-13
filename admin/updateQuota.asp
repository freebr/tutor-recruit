<%Response.Expires=-1%>
<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

Dim stuTypeUpdateQuota:stuTypeUpdateQuota=Request.Form("stu_type_upquota")
Dim bError,errMsg
Dim countInsert,countUpdate

sql="CREATE TABLE #ret(CountInsert int,CountUpdate int,CountError int,IsError bit,ErrMsg nvarchar(MAX));"&_
		"INSERT INTO #ret EXEC spUpdateRecruitQuota "&sem_info(0)&","&sem_info(1)&",NULL,'"&stuTypeUpdateQuota&"',0,0; SELECT * FROM #ret"
Connect conn
Set rs=conn.Execute(sql).NextRecordSet
countInsert=rs("CountInsert")
countUpdate=rs("CountUpdate")
bError=rs("IsError")
errMsg=rs("ErrMsg")
CloseRs rs
CloseConn conn
%><form id="ret" method="post" action="systemSettings.asp?step=1"><input type="hidden" name="ok" value="1" /></form>
<script type="text/javascript">document.all.ret.submit();</script>