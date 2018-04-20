function doChoice(type) {
	switch (type) {
	case 0:
		if (confirm("是否确认选择这"+countClk()+"名学生？"))
			document.all.fmConfirm.submit();
		break;
	case 1:
		if (confirm("是否退回这"+countClk()+"名学生的填报？")) {
			if (document.all.withdrawreason.value==-1) {
				alert("请选择退回原因！");
				return;
			}
			document.all.fmConfirm.action="doChoice.asp?type=1";
			document.all.fmConfirm.submit();
		}
		break;
	}
	return;
}
function switchReason(v) {
	document.all.reasontext.style.display=(v=='')?"inline":"none";
	document.all.reasontext.value=(v=='')?"<请输入原因>":v;
	return;
}
function showStudentInfo(id) {
	top.mainF.tabmgr.goTo("showStudentInfo.asp?id="+id,"查看学生信息",true);
	return false;
}