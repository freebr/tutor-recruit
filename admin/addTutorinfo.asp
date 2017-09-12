<%If IsEmpty(Session("user")) Then Response.Redirect("../error.asp?timeout")
Response.Charset="utf-8"
Response.Expires=-1%>
<!--#include file="../inc/db.asp"-->

<%
AddStudentTeachTypeId=Request.QueryString("object")

Connect conn
on error resume Next
sqlStr="SELECT * FROM STUDENT_INFO WHERE STU_NO='"&Request.Form("addSTU_STU_NO_text")&"'"
'RESPONSE.WRITE SQLSTR
GetRecordSet conn,rs,sqlStr,result
If result=1 Then 
    Response.Write "<center><font color='red'>该编号已存在"&Request.Form("addSTU_STU_NO_text")&"</font></center>"
    Response.End
End If

ClassSumManSqlStr="SELECT * FROM CODE_CLASS where class_id="&Request.Form("addSTU_CLASS_ID_text")
GetRecordSet conn,rsClassSumMan,ClassSumManSqlStr,resultClassSumMan
If rsClassSumMan.eof Then
    Response.Write "<center><font color='red'>数据库中没有该班级,请检查</font></center>"
    Response.End
Else
	If (rsClassSumMan("class_sum")+1)>=rsClassSumMan("class_limit") Then
	    Response.Write "<center><font color='red' size='4'>该班级人数已经满，您不能再添加学生进该班级了</font></center>"
	    Response.End
	End If
End If
	
rs.AddNew

If AddStudentTeachTypeId="4" Then
	sqlStr=""
	sqlStr="SELECT * FROM VIEW_TEACHING_PLAN_INFO WHERE teachtype_id="&Request.Form("addSTU_TEACH_TYPEID_text")&" and begin_year='"&Request.Form("addSTU_begin_year_text")&"' and dept_id="&Request.Form("addSTU_DEPT_ID_text")&" and speciality_id="&Request.Form("addSTU_SPECIALITY_ID_text")
	GetRecordSet conn,rsPlan,sqlStr,result
	'response.write sqlStr
	If rsPlan.Eof Then 
	    Response.Write "<center><font color='red'>输入错误,教学任务表里边没有所选班级</font></center>"
	    Response.End
	End If
	rs("TEACHING_PLANID")=rsPlan("TEACHING_PLANID")
End If 

If AddStudentTeachTypeId="2" or AddStudentTeachTypeId="1" Then
	rs("tutor_id")=Request.Form("addSTU_tutor_id_text")
Else
	rs("tutor_id")=0
End If
rs("STU_NO")=Request.Form("addSTU_STU_NO_text")
rs("STU_NAME").value=Request.Form("addSTU_STU_NAME_text")
rs("sex").value=Request.Form("addSTU_sex_text")

rs("marry")=Request.Form("addSTU_marry_text")
If Request.Form("addSTU_birthday_text")<>"" Then
	rs("birthday")=Request.Form("addSTU_birthday_text")
End If
rs("NATION")=Request.Form("addSTU_NATION_text")

rs("POLITY_VISAGEID")=Request.Form("addSTU_POLITY_VISAGEID_text")
rs("IDCARD")=Request.Form("addSTU_IDCARD_text")
rs("IFFOREIGN")=Request.Form("addSTU_IFFOREIGN_text")

rs("FAMILY_ADDRESS")=Request.Form("addSTU_FAMILY_ADDRESS_text")
rs("FAMILY_TEL")=Request.Form("addSTU_FAMILY_TEL_text")
rs("SELF_TEL")=Request.Form("addSTU_SELF_TEL_text")

rs("MENBER_ID")=Request.Form("addSTU_MENBER_ID_text")
rs("BEFORE_UNIT")=Request.Form("addSTU_BEFORE_UNIT_text")
rs("DUTY")=Request.Form("addSTU_DUTY_text")

rs("JOB_LEVEL")=Request.Form("addSTU_JOB_LEVEL_text")
rs("LEVEL_SCHOOL")=Request.Form("addSTU_LEVEL_SCHOOL_text")
rs("PERSONAL_RESUME")=Request.Form("addSTU_PERSONAL_RESUME_text")


rs("TEACH_TYPEID")=Request.Form("addSTU_TEACH_TYPEID_text")
rs("CLASS_ID")=Request.Form("addSTU_CLASS_ID_text")
rs.Update

'===============调用过程计算班级的总人数=====================
ClassSumManProcStr="exec COUNT_CLASS_SUM_MAN "&Request.Form("addSTU_CLASS_ID_text")
conn.Execute ClassSumManProcStr
'====================================

CloseRs rs
CloseRs ClassSumManSqlStr
CloseRs rsrsPlan
CloseConn conn

Skip_Point="STUDENTbasic_List.asp?object="&AddStudentTeachTypeId

Response.write "<SCRIPT LANGUAGE='JavaScript'>"
Response.write "alert('添加完成');"
Response.write "window.location.href='"&Skip_Point&"';"
Response.write "</script>"

%>