<%Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")

Dim sem_info,stuTypeUpdateQuota
Dim bError,errMsg
Dim countInsert,countUpdate

stuTypeUpdateQuota=Request.Form("stu_type_upquota")
sem_info=getCurrentSemester()
sql="CREATE TABLE #ret(CountInsert int,CountUpdate int,CountError int,IsError bit,ErrMsg nvarchar(MAX));"&_
		"INSERT INTO #ret EXEC sp_updateRecruitQuota "&sem_info(0)&","&sem_info(1)&",NULL,'"&stuTypeUpdateQuota&"',1,0; SELECT * FROM #ret"
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