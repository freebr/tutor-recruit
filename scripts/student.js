function showTeacherResume(tid) {
	window.open("/index/teacher_resume.asp?id="+tid,"_blank");
	return false;
}
function chooseTutor(turn_num,spec_name,rec_id,tutor_id,tutor_name) {
	window.tabmgr.tabs[window.index].opener.callback(arguments);
	window.tabmgr.close(window);
	return false;
}
function submitChoice() {
	// 验证数据有效性
	var $choices=$('tr.choicenew').find('td:eq(1)');
	var choice_id=[];
	$choices.each(function(){choice_id.push($(this).text())});
	var arr=['一','二','三'];
	try {
		if(!choice_id[0].length) throw '第一志愿不能为空！';
		if(!choice_id[1].length) throw '第二志愿不能为空！';
		for(var i=0;i<choice_id.length-1;i++) {
			for(var j=i+1;j<choice_id.length;j++) {
				if(choice_id[i]==choice_id[j]) throw '第'+arr[i]+'志愿所填信息与第'+arr[j]+'志愿重复！';
			}
		}
	} catch (ex) {
		alert(ex);
		return;
	}
	$.post("chooseTutor.asp",{"choice_id":choice_id.toString()},function(data,status){
		alert(data.tip);
		if(!data.error) location.reload();
		$('button').attr('disabled',null);
	},'json');
	$('button').attr('disabled','disabled');
	return false;
}
function cancelChoice() {
	if(confirm("确定要取消当前的填报吗？")) {
		$.getJSON("chooseTutor.asp?cancel=1",function(data,status){
			alert(data.tip);
			if(!data.error) location.reload();
		$('button').attr('disabled',null);
		});
		$('button').attr('disabled','disabled');
	}
	return false;
}
function confirmChoice() {
	if(confirm("真的确认当前的填报信息吗？一旦确认将不能修改。")) {
		$.getJSON("chooseTutor.asp?confirm=1",function(data,status){
			alert(data.tip);
			if(!data.error) location.reload();
		$('button').attr('disabled',null);
		});
		$('button').attr('disabled','disabled');
	}
	return false;
}

function copyChoiceFromSaved(link) {
	var $tr=$(link).parents('tr');
	var $tr_src=$('tr.choicesaved').eq($tr.index());
	var $tr_cells=$tr.children();
	var $tr_src_cells=$tr_src.children();
	for(var i=1;i<=3;i++) {
		$tr_cells.eq(i).text($tr_src_cells.eq(i).text());
	}
	$tr.find('div.choicecontrol').show();
	return false;
}
function recruitMoveUp() {
	if(!arguments.length) return;
	// 传入参数为数字或链接DOM
	var index=typeof arguments[0]==='number'?arguments[0]:$(arguments[0]).parents('tr.choicenew').index();
	if(index<=0) return;
	var $cur=$('tr.choicenew').eq(index);
	var $prev=$cur.prev();
	if($prev.hasClass('hidden')) return;
	swapCells($cur.children().eq(0),$prev.children().eq(0));
	var html=$prev.html();
	$prev.html($cur.html());
	$cur.html(html);
	return;
}
function recruitMoveDown() {
	if(!arguments.length) return;
	// 传入参数为数字或链接DOM
	var index=typeof arguments[0]==='number'?arguments[0]:$(arguments[0]).parents('tr').index();
	if(index>=2) return;
	var $cur=$('tr.choicenew').eq(index);
	var $next=$cur.next();
	if(!$next.size()) return;
	swapCells($cur.children().eq(0),$next.children().eq(0));
	var html=$next.html();
	$next.html($cur.html());
	$cur.html(html);
	return;
}
function swapCells(cell1,cell2) {
	var html=$(cell1).html();
	$(cell1).html($(cell2).html());
	$(cell2).html(html);
	return;
}
function selectTutor(link) {
	var turn_num=$(link).parents('tr').index()+1;
	window.tabmgr.goTo('/TutorRecruit/student/recruitList.asp?turn='+turn_num,'选择导师',true,window);
	return false;
}
function clearSelection(link) {
	var $tr=$(link).parents('tr');
	var index=$tr.index();
	$tr.children(':gt(0):lt(3)').text('');
	$tr.find('div.choicecontrol').hide();
	return false;
}