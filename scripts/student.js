function showTeacherListByResearch(rid) {
	window.open("showTeaListByRes.asp?Object=<%=object%>&Id="+rid,"_blank");
	return false;
}
function showTeacherResume(tid) {
	window.open("/index/teacher_resume.asp?id="+tid,"_blank");
	return false;
}
function chooseTutor(id) {
	document.all.search.action="chooseTutor.asp?id="+id;
	document.all.search.submit();
	return false;
}
function cancelConfirm() {
	if(confirm("确定要取消当前的填报吗？")) {
		document.all.search.action="chooseTutor.asp?cancel=1";
		document.all.search.submit();
		document.all.btnCancelChoice.disabled="true";
		document.all.btnConfirmChoice.disabled="true";
	}
	return false;
}
function goConfirm() {
	if(confirm("真的确认当前的填报信息吗？一旦确认将不能修改。")) {
		document.all.search.action="chooseTutor.asp?confirm=1";
		document.all.search.submit();
		document.all.btnCancelChoice.disabled="true";
		document.all.btnConfirmChoice.disabled="true";
	}
	return false;
}