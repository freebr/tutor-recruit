<%
' 个人信息表格生成器类
Class ProfileGen
	Dim m_stuno,m_stuname,m_gender,m_birthday,m_nation,m_pvisage,m_cardid,m_classname,m_tutor,m_speciality
	Dim m_address,m_nativeplace,m_mobile,m_email,m_telhome,m_companyname,m_job,m_dutyname,m_lastdegree
	Dim m_showtutoroutside,m_tutoroutside(1),m_lastdiploma
	Dim m_dissertationtopic,m_personalresume,m_experiences,m_occuplan

	Dim m_err_desc
	Public Property Let StuNo(val)
		If IsNull(val) Then val=""
		m_stuno=val
	End Property
	Public Property Let StuName(val)
		If IsNull(val) Then val=""
		m_stuname=val
	End Property
	Public Property Let Gender(val)
		If IsNull(val) Then val=""
		m_gender=val
	End Property
	Public Property Let Birthday(val)
		If IsNull(val) Then val=""
		m_birthday=val
	End Property
	Public Property Let Nation(val)
		If IsNull(val) Then val=""
		m_nation=val
	End Property
	Public Property Let PoliticalVisage(val)
		If IsNull(val) Then val=""
		m_pvisage=val
	End Property
	Public Property Let CardID(val)
		If IsNull(val) Then val=""
		m_cardid=val
	End Property
	Public Property Let ClassName(val)
		If IsNull(val) Then val=""
		m_classname=val
	End Property
	Public Property Let Tutor(val)
		If IsNull(val) Then val=""
		m_tutor=val
	End Property
	Public Property Let Speciality(val)
		If IsNull(val) Then val=""
		m_speciality=val
	End Property
	Public Property Let Address(val)
		If IsNull(val) Then val=""
		m_address=val
	End Property
	Public Property Let NativePlace(val)
		If IsNull(val) Then val=""
		m_nativeplace=val
	End Property
	Public Property Let Mobile(val)
		If IsNull(val) Then val=""
		m_mobile=val
	End Property
	Public Property Let Email(val)
		If IsNull(val) Then val=""
		m_email=val
	End Property
	Public Property Let TelHome(val)
		If IsNull(val) Then val=""
		m_telhome=val
	End Property
	Public Property Let CompanyName(val)
		If IsNull(val) Then val=""
		m_companyname=val
	End Property
	Public Property Let Job(val)
		If IsNull(val) Then val=""
		m_job=val
	End Property
	Public Property Let DutyName(val)
		If IsNull(val) Then val=""
		m_dutyname=val
	End Property
	Public Property Let LastDegree(val)
		If IsNull(val) Then val=""
		m_lastdegree=val
	End Property
	Public Property Let ShowTutorOutside(val)
		If IsNull(val) Then val=""
		m_showtutoroutside=val
	End Property
	Public Property Let TutorOutside(index,val)
		If IsNull(val) Then val=""
		m_tutoroutside(index)=val
	End Property
	Public Property Let LastDiploma(val)
		If IsNull(val) Then val=""
		m_lastdiploma=val
	End Property
	Public Property Let DissertationTopic(val)
		If IsNull(val) Then val=""
		m_dissertationtopic=val
	End Property
	Public Property Let PersonalResume(val)
		If IsNull(val) Then val=""
		m_personalresume=val
	End Property
	Public Property Let Experiences(val)
		If IsNull(val) Then val=""
		m_experiences=val
	End Property
	Public Property Let OccuPlan(val)
		If IsNull(val) Then val=""
		m_occuplan=val
	End Property
	Public Property Get ErrorDesc()
		ErrorDesc=m_err_desc
	End Property
	Public Function generateProfile(filepath)
		' 生成个人信息表
		Dim template_file
		Dim wd,doc,range
		'On Error Resume Next
		template_file=Server.MapPath("template")&"\profile.docx"
		Set wd=Server.CreateObject("Word.Application")
		Set doc=wd.Documents.Add(template_file)
		Set range=doc.Range()
		range.Select()
		range.Find.Execute "$stu_no",True,,,,,,1,,toWordString(m_stuno),True
		range.Find.Execute "$stu_name",True,,,,,,1,,toWordString(m_stuname),True
		range.Find.Execute "$gender",True,,,,,,1,,toWordString(m_gender),True
		range.Find.Execute "$birthday",True,,,,,,1,,toWordString(m_birthday),True
		range.Find.Execute "$nation",True,,,,,,1,,toWordString(m_nation),True
		range.Find.Execute "$native_place",True,,,,,,1,,toWordString(m_nativeplace),True
		range.Find.Execute "$p_visage",True,,,,,,1,,toWordString(m_pvisage),True
		range.Find.Execute "$card_id",True,,,,,,1,,toWordString(m_cardid),True
		range.Find.Execute "$class_name",True,,,,,,1,,toWordString(m_classname),True
		range.Find.Execute "$tutor",True,,,,,,1,,toWordString(m_tutor),True
		range.Find.Execute "$speciality",True,,,,,,1,,toWordString(m_speciality),True
		range.Find.Execute "$address",True,,,,,,1,,toWordString(m_address),True
		range.Find.Execute "$tel_home",True,,,,,,1,,toWordString(m_telhome),True
		range.Find.Execute "$mobile",True,,,,,,1,,toWordString(m_mobile),True
		range.Find.Execute "$email",True,,,,,,1,,toWordString(m_email),True
		range.Find.Execute "$company_name",True,,,,,,1,,toWordString(m_companyname),True
		range.Find.Execute "$job",True,,,,,,1,,toWordString(m_job),True
		range.Find.Execute "$duty_name",True,,,,,,1,,toWordString(m_dutyname),True
		range.Find.Execute "$last_degree",True,,,,,,1,,toWordString(m_lastdegree),True
		If 	m_showtutoroutside Then
			range.Find.Execute "$tutor_outside1",True,,,,,,1,,toWordString(m_tutoroutside(0)),True
			range.Find.Execute "$tutor_outside2",True,,,,,,1,,toWordString(m_tutoroutside(1)),True
		Else
			doc.Tables(1).Rows(10).Delete()
		End If
		If range.Find.Execute("$last_diploma",True,,,,,,1) Then
			range.Text=m_lastdiploma
		End If
		If range.Find.Execute("$dissertation_topic",True,,,,,,1) Then
			range.Text=m_dissertationtopic
		End If
		If range.Find.Execute("$personal_resume",True,,,,,,1) Then
			range.Text=m_personalresume
		End If
		If range.Find.Execute("$experiences",True,,,,,,1) Then
			range.Text=m_experiences
		End If
		If range.Find.Execute("$occu_plan",True,,,,,,1) Then
			range.Text=m_occuplan
		End If
		doc.BuiltInDocumentProperties(3)="华南理工大学工商管理学院"
		doc.SaveAs filepath
		doc.Close(False)
		Set range=Nothing
		Set doc=Nothing
		wd.Quit()
		Set wd=Nothing
		m_err_desc=Err.Description
		If Err.Number=0 Then
			generateProfile=1
		Else
			generateProfile=0
		End If
	End Function
	Private Function toWordString(s)
		If IsNull(s) Then Exit Function
		Dim ret
		ret=s
		ret=Replace(ret,"^","^^")
		ret=Replace(ret,vbNewLine,"^p")
		ret=Replace(ret,vbCr,"^p")
		ret=Replace(ret,vbLf,"^p")
		toWordString=ret
	End Function
End Class
%>