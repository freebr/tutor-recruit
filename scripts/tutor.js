function doChoice(form,type) {
	switch (type) {
	case 0:
		if (confirm("是否确认选择这"+countClk()+"名学生？"))
			form.submit();
		break;
	case 1:
		if (confirm("是否退回这"+countClk()+"名学生的填报？")) {
			if (form.withdrawreason.value==-1) {
				alert("请选择退回原因！");
				return;
			}
			form.action="doChoice.asp?type=1";
			form.submit();
		}
		break;
	}
	return;
}
function switchReason(form,v) {
	form.reasontext.style.display=(v=='')?"inline":"none";
	form.reasontext.value=(v=='')?"<请输入原因>":v;
	return;
}
function showStudentInfo(id) {
	var tabmgr=window.tabmgr||parent.tabmgr;
	tabmgr.goTo("/TutorRecruit/tutor/showStudentInfo.asp?id="+id,"查看学生信息",true);
	return false;
}