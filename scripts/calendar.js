<!--

/*
	Calendar Picker created by Freebr
	2015.1
*/
function createCalendar() {
	var ch=new Array('日','一','二','三','四','五','六');
	var code='<table id="calendar" class="calendar" align="center" cellspacing=0 cellpadding=0><thead><tr>'
					+'<td><table width="100%" cellspacing=0 cellpadding=0><tr>';
	for(var i=0;i<7;i++) {
		code+='<td class="field">';
		if (i==0) {
			code+='<p class="sun">';
		} else if (i==6) {
			code+='<p class="sat">';
		} else {
			code+='<p>';
		}
		code+=ch[i]+'</p></td>';
	}
	code+='</tr></table></td></tr></thead><tbody><tr><td class="calendarbody" id="dates"></td></tr></tbody></table>';
	document.all.tdcalendar.innerHTML=code;
	tblcalendar=document.all.calendar;
	tblbody=document.all.dates;
	return;
}
function setDatePicker() {
	document.all.lnkCalendarPrevYear.onclick=function() {
		setDate(cYear-1,cMonth);
		displayCalendar();
		return false;
	}
	document.all.lnkCalendarNextYear.onclick=function() {
		setDate(cYear+1,cMonth);
		displayCalendar();
		return false;
	}
	document.all.lnkCalendarPrevMonth.onclick=function() {
		setDate(cYear,cMonth-1);
		displayCalendar();
		return false;
	}
	document.all.lnkCalendarNextMonth.onclick=function() {
		setDate(cYear,cMonth+1);
		displayCalendar();
		return false;
	}
}
function initDate() {
	thisYear=cYear;
	thisMonth=cMonth;
	thisDate=cDate;
	return;
}
function setDate(year,month,dt) {
	if(year<2000||year>thisYear+10) return false;
	if(month==0) {
		return setDate(year-1,12);
	} else if(month==13) {
		return setDate(year+1,1);
	}
	cYear=year;
	cMonth=month;
	cDate=dt;
	document.all.spanCalendarYear.innerText=cYear;
	document.all.spanCalendarMonth.innerText=cMonth;
	return true;
}
function displayCalendar() {
	var dt=new Date();
	var max_date,leap_year;
	var code;
	dt.setYear(cYear);dt.setMonth(cMonth-1);dt.setDate('1');
	leap_year=cYear%4==0||cYear%400==0;
	switch(cMonth) {
	case 1:case 3:case 5:case 7:case 8:case 10:case 12:
		max_date=31;
		break;
	case 2:
		if (leap_year) max_date=29; else max_date=28;
		break;
	default:
		max_date=30;
	}
	day=dt.getDay()%7;
	code='<table width="100%" cellspacing=0 cellpadding=3><tr>';
	for(i=0;i<day;i++) {
		code+='<td></td>';
	}
	for(i=1;i<=max_date;i++,day=(day+1)%7) {
		if(day==0) {
			code3='sun';
			code4='</span></td>';
		} else if(day==6) {
			code3='sat';
			code4='</span></td></tr>';
		} else {
			code3='';
			code4='</span></td>';
		}
		code2='day';
		if(cYear==thisYear)
			if(cMonth==thisMonth)
				if(i==thisDate)
					code2+=' today';
		code1='<td id="d'+i+'" class="'+code2+'" onmouseover="highlightDay('+i+')" onclick="selectDay();return false">';
		if(day==0)code1='<tr>'+code1;
		if(code3.length)
			code3='<span class="'+code3+'">';
		else
			code3='<span>';
		num=i;
		code+=code1+code3+num+code4;
	}
	if(day<6)code+='</tr>';
	code+='</table>';
	tblbody.innerHTML=code;
	return;
}
function highlightDay(id) {
	if (cDate) {
		eval('d'+cDate).className=eval('d'+cDate).className.replace(" selected",'');
		if (id)
			eval('d'+id).className+=" selected";
	}
	cDate=id;
}
function selectDay() {
	var fmt=document.getElementsByName('date_format').item(0).value;
	opener.document.getElementsByName(objName).item(0).value=fmt.replace(/y/g,cYear).replace(/m/g,cMonth).replace(/d/g,cDate);
	window.close();
}
this.onload=function() {
	if(document.all.tdcalendar) {
		initDate();
		createCalendar();
		setDatePicker();
		displayCalendar();
	}
}

var cYear,cMonth,cDate;
var thisYear,thisMonth,thisDate;
var tblcalendar,tblbody;

-->