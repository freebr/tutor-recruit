<!--#include file="../inc/global.inc"-->
<!--#include file="common.asp"-->
<%If IsEmpty(Session("Id")) Then Response.Redirect("../error.asp?timeout")
	stu_id=Request.QueryString("id")
	If Len(stu_id)=0 Then
		Response.Write "<center><font color=red>参数错误！</font></center>"
		Response.End()
	End If
	stu_id=toSqlString(stu_id)
	Connect conn
  sql="SELECT * FROM ViewStudentInfo WHERE STU_ID="&stu_id
  GetRecordSetNoLock conn,rs,sql,result
  If result=0 Then
    Response.Write "<center><font color=red>该学生资料不存在！</font></center>"
    Response.End()
  End If
  
  Stu_Type=rs("TEACHTYPE_ID")
  If Not IsNull(rs("TUTOR_OUTSIDE")) Then
  	Tutor_Outside=Split(rs("TUTOR_OUTSIDE"),",")
  Else
  	ReDim Tutor_Outside(1)
  End If
	'第一次进入程序给默认显示的变量赋值
	If Request.Form("Teachtype_Id").Count=0 Then
		Servb_Teachtype_Str=rs("Teachtype_Id")
		Servb_Dept_Str=rs("Dept_Id")
		Servb_Class_Str=rs("Class_Id")
		Servb_Tutor_Str=rs("Tutor_Id")
		Servb_Dept_Term=" And Teachtype_Id="&Servb_Teachtype_Str&" And Dept_Id="&Servb_Dept_Str
		Showstudent_Stu_No_Term=rs("Stu_No")
		Showstudent_Stu_Name_Term=rs("Stu_Name")
	End If
	thesis_topic=toPlainString(rs("THESIS_TOPIC"))
	personal_resume=toPlainString(rs("PERSONAL_RESUME"))
	experiences=toPlainString(rs("EXPERIENCES"))
	occu_plan=toPlainString(rs("OCCU_PLAN"))
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="theme-color" content="#2D79B2" />
<% useStyleSheet "global" %>
<script type="text/javascript" src="../scripts/admin.js"></script>
<% useScript "common" %>
</head>
<body bgcolor="ghostwhite">
<center>
<table width="800" cellspacing=1 cellpadding="3" bgcolor="#999999" style="color:#000000">
  <caption><font size=3><b>学生基本资料</b></font></caption>
  <tr bgcolor="white">
    <td width="100">学号</td>
	<%If request.Form("Stu_No")<>"" then Showstudent_Stu_No_Term=request.Form("Stu_No") End If%>
    <td><%=HtmlEncode(SHOWSTUDENT_STU_NO_Term)%></td>
    <td>姓名</td>
	<%If request.Form("Stu_Name")<>"" then Showstudent_Stu_Name_Term=request.Form("Stu_Name") End If%>
    <td width="183"><%=HtmlEncode(SHOWSTUDENT_STU_NAME_Term)%></td>
    <td width="76">性别</td>
    <td width="149"><%=rs("Sex")%></td>
  </tr>
  <tr bgcolor="white">
	<td>出生年月</td>
	<td colspan=3><%If rs("birthday")<>"空" Then Response.write rs("birthday")%></td>
	<td>民族</td>
	<td><%=rs("Nation")%></td>
  </tr>
  <tr bgcolor="white">
	<td>政治面貌</td>
  <td><%=rs("Polity_VisageName")%></td>
	<td>身份证号</td>
	<td><%=rs("Idcard")%></td>
	<td>留学生</td>
	<td><%=rs("Ifforeign")%></td>
  </tr>
	<tr bgcolor="white">
	<!--<td><%=rs("Sort_No")%></td>-->
	<td>班级名称</td>
	<td><%=rs("CLASS_NAME")%></td>
	<td>确认导师</td>
	<td><%=rs("TeacherName")%></td>
	<td>专业</td>
	<td><%=rs("SPECIALITY_NAME")%></td>
	</tr>
  <tr bgcolor="white">
	<td>家庭通讯地址</td>
	<td colspan=3><%=rs("Family_Address")%></td>
	<td>籍贯</td>
	<td><%=rs("Native_City")%></td>
  </tr>
  <%if Servb_Teachtype_Str = "3"  Or Servb_Teachtype_Str = "4" then %>
  <tr bgcolor="white">
	<td>手机</td>
	<td><%=rs("Self_Tel")%></td>
	<td>家长姓名</td>
	<td><%=rs("HouseHolder")%></td>
 	<td>家庭联系电话</td>
	<td><%=rs("Family_Tel")%></td>
  </tr>
  <tr bgcolor="white">
	<td>毕业中学</td>
	<td colspan=5><%=rs("Before_Unit")%></td>
  </tr>
  <%else%>
  <tr bgcolor="white">
	<td>手机</td>
	<td><%=rs("Self_Tel")%></td>
	<td>电子邮箱</td>
	<td><%=rs("EMAIL")%></td>
	<td>家庭联系电话</td>
	<td><%=rs("Family_Tel")%></td>
  </tr>
  <tr bgcolor="white">
  <td>工作单位</td>
	<td colspan=5><%=rs("Before_Unit")%></td>
  </tr>
  <tr bgcolor="white">
	<td>职务</td>
	<td><%=rs("Duty")%></td>
	<td>职称</td>
	<td><%=rs("Job_Level")%></td>
	<td>入学前学位</td>
  <td><%=rs("Degree_Name")%></td>
  </tr>
  <tr bgcolor="white">
	<td>最后学历</td>
	<td colspan=5><%=rs("LEVEL_SCHOOL")%></td>
  </tr><%
  	If Stu_Type=9 Then %>
  <tr bgcolor="white">
	<td>校外导师</td>
	<td colspan="2">第一志愿：<%=Tutor_Outside(0)%></td>
	<td colspan="3">第二志愿：<%=Tutor_Outside(1)%></td>
  </tr><%
		End If %>
  <%end if%>
  <tr bgcolor="white">
	<td valign="top">拟撰写论文方向</td><td colspan="5" height="50"><%=thesis_topic%></td>
  </tr>
  <tr bgcolor="white">
	<td valign="top">工作简历</td><td colspan="5" height="50"><%=personal_resume%></td>
  </tr>
  <tr bgcolor="white">
	<td valign="top">受教育及培训经历</td><td colspan="5" height="50"><%=experiences%></td>
  </tr>
  <tr bgcolor="white">
	<td valign="top">未来职业规划</td><td colspan="5" height="50"><%=occu_plan%></td>
  </tr></table>
<br><input type="button" id="btnclose" value="关 闭" onclick="closeWindow()"></center>
</body></html>
<%
  CloseConn conn
  CloseRs rs
%>