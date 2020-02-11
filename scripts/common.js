function submitForm(fm,action,enctype) {
	if(!!action)fm.action=action;
	fm.encoding=(!enctype)?"application/x-www-form-urlencoded":enctype;
	fm.submit();
	return false;
}
function deleteTutor(fm,num) {
	if(confirm("删除导师记录将导致与该导师相关的双选记录失效，是否删除这"+num+"条记录？")) {
		submitForm(fm,"delTutorinfo.asp");
	}
	return;
}
function batchSetQuota() {
	submitForm(document.all.query,"setQuota.asp");
	return;
}
function batchRemoveRecruitInfo(num) {
	if(confirm("删除导师招生信息将导致与该导师相关的双选记录失效，是否删除这"+num+"条记录？")) {
		submitForm(document.all.query,"setQuota.asp?remove");
	}
	return;
}
function cancelConfirm(lid,id) {
	if(confirm("确实要撤销该导师的确认状态吗？")) {
		submitForm(document.all.query,"cancelConfirm.asp?lid="+lid);
	}
	return;
}
function showStudentInfo(id) {
	location.href="showStudentInfo.asp?id="+id;
	return false;
}
function setPermission(type) {
	var msg;
	switch(type) {
	case 0:msg="是否开放这"+countClk()+"名学员的系统权限？";break;
	case 1:msg="是否关闭这"+countClk()+"名学员的系统权限？";break;
	case 2:msg="是否删除这"+countClk()+"名学员的系统权限记录？\n注：删除后，您需要重新从Excel导入才能恢复记录。";break;
	}
	if (confirm(msg)) {
		submitForm(document.all.fmStuList,"setPermission.asp?type="+type);
	}
	return;
}