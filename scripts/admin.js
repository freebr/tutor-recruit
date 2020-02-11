function chkForm() {
	if (!verifyDateTime(document.all.stu_startdate.value)) {
		alert("学生端开始日期格式错误！");
		document.all.stu_startdate.focus();
		return false;
	} else if (!verifyDateTime(document.all.stu_enddate.value)) {
		alert("学生端结束日期格式错误！");
		document.all.stu_enddate.focus();
		return false;
	} else if (!verifyDateTime(document.all.teach_startdate.value)) {
		alert("导师端开始日期格式错误！");
		document.all.teach_startdate.focus();
		return false;
	} else if (!verifyDateTime(document.all.teach_enddate.value)) {
		alert("导师端结束日期格式错误！");
		document.all.teach_enddate.focus();
		return false;
	}
	return true;
}

function switchMailContent(n) {
	var value;
	for (var i=1;i<=4;i++) {
		if (n==i) value="block"; else value="none";
		eval("document.all.divmailcontent"+i).style.display=value;
	}
	return;
}