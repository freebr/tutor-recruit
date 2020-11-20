<%
	date_sel=Request.QueryString("date_sel")
	If Len(date_sel)=0 Then date_sel=Date
	year_sel=Year(date_sel)
	month_sel=Month(date_sel)
	day_sel=Day(date_sel)
	
	date_format=Request.QueryString("fmt")
	if IsEmpty(date_format) Then date_format="y/m/d"
%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">
<!--
	table.calendar {
		text-align:center;
		width:100%;
		height:175px;
		background-color:#fff;
		border:1px solid #eee;
	}
	table.calendar thead { background-color:#ddf }
	table.calendar thead td { height:20px;vertical-align:middle }
	table.calendar td.field { font-size:9pt;text-align:center }
	table.calendar td.field p { line-height:15px }
	table.calendar td.calendarbody { vertical-align:top }
	table.calendar td.calendarbody a { color:#000 }
	table.calendar td.calendarbody span { line-height:18px }
	table.calendar td.calendarbody table { border-collapse:collapse;background:url(/index/images/calendarbg.png) center no-repeat }
	table.calendar p { color:#000 }
	table.calendar .sat { color:#0a0 }
	table.calendar .sun { color:#d00 }
	table.calendar td.day { background:none;font-size:9pt;text-align:center;border:1px solid #eee;cursor:pointer }
	table.calendar td.day a:hover { text-decoration:none }
	table.calendar td.selected { background-color:#ef9 }
	table.calendar td.today { background-color:#9f9 }
	table.calendarDatePicker a:visited { color:#00a;background-color:none }
	table.calendarDatePicker a:link { color:#00a;background-color:none;text-decoration:none }
	table.calendarDatePicker a:hover { color:#00a;background-color:#ef9;text-decoration:none }
	table.calendarDatePicker span { display:inline-block;font-size:10pt;color:#00c }
	span#spanCalendarMonth { width:17px;text-align:center }
-->
</style>
</head>
<body>
<table width="100%" cellspacing=0 cellpadding=0>
<tr><td align="center"><strong>请选择日期</strong></td></tr>
<tr><td align="center">
<table class="calendarDatePicker" width="100%" cellspacing=0 cellpadding=0>
<tr><td width="49%" align="right"><a href="#" id="lnkCalendarPrevYear">&laquo;</a><span id="spanCalendarYear"><%=Year(Now)%></span><a href="#" id="lnkCalendarNextYear">&raquo;</a></td>
<td width="2%"></td>
<td align="left"><a href="#" id="lnkCalendarPrevMonth">&laquo;</a><span id="spanCalendarMonth"><%=Month(Now)%></span><a href="#" id="lnkCalendarNextMonth">&raquo;</a></td></tr></table></td></tr>
<tr><td id="tdcalendar">
</td></tr></table>
<input type="hidden" name="date_format" value="<%=date_format%>" />
<script type="text/javascript" src="../scripts/calendar.js"></script>
<script type="text/javascript">
	objName="<%=Request.QueryString("objName")%>";
	setDate(<%=year_sel%>,<%=month_sel%>,<%=day_sel%>);
</script></body></html>