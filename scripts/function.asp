<%
'========================
FUNCTION GetDateTime(DateTime)

    dim datetimes(2)
    
    strNum = InStr(DateTime," ")
    datetimes(0) = Mid (DateTime, 1, strNum-1)
    datetimes(1) = Mid (DateTime, strNum, len(DateTime))
    GetDateTime = datetimes
    
End Function

Function SplitWords(ByVal mys,coun)
	If IsNull(mys) then exit Function
	Dim i,ts
	ts=0
	For i=1 To Len(mys)
		If Asc(Mid(mys,i,1))<0 Then
			ts=ts+2
		Else
			ts=ts+1
		End If
		If ts>=coun Then Exit For
	Next
	If ts>coun Then i=i-1
	If i<Len(mys) Then
		mys=Left(mys,i)&"…"
	End If
	SplitWords=mys
End Function

Function getHTTP(Content)

	dim i
	dim j
	dim k
	dim Start_i
	start_i=0
	k=0
	
	Content=replace(Content,"''","'")
	'Response.Write unStr(Content) &"<BR>"
	iContent=Content
	iContent=Replace(iContent,"<","&lt;")
	iContent=Replace(iContent,">","&gt;")
	for i=1 to len(Content)-7
		c=mid(Content,i,7)	
		if strComp(c,"http://")=0 then	
			
			for j=i+7 to len(Content)					
				d=mid(Content,j,1)
				if strComp(d,chr(32))=0 then					
					exit for
				end if
				if StrComp(d,vbCr)=0 or StrComp(d,vbLf)=0 then
					exit for
				end if
			next
				
			if j<>len(content)-1 then
				midStr=mid(Content,i,j-i)
				midch="<a href="& midStr & ">" & midStr & "</a>"
				if k=0 then
					ijContent=mid(icontent,1,i-1)
					iContent=ijContent&Replace(iContent,midStr,midch,i,1)
					Start_i=i+len(midch)-1
					k=k+1
				else
					start_i=start_i+j-i-7
					ijContent=Mid(iContent,1,Start_i-1)
					iContent=ijContent & Replace(iContent,midStr,midch,Start_i,1)
					Start_i=Start_i+len(midch)-1				
				end if
				
			else
				midStr=mid(Content,i,len(Content)-i)
				midch="<a href="& midStr & ">" & midStr & "</a>"
	
				if k=0 then
					ijContent=mid(icontent,1,i-1)
					iContent=ijContent&Replace(iContent,midStr,midch,i,1,1)
					Start_i=i+len(midch)-1
					k=k+1
				else
					start_i=len(icontent)-len(content)+i
					ijContent=Mid(iContent,1,Start_i-1)
					iContent=ijContent & Replace(iContent,midStr,midch,Start_i,1)

				end if

				exit for
			end if								
		end if
	next
	

	iContent=Replace(iContent,vbcrlf,"<br>")
	'iContent=replace(iContent,chr(32),"&nbsp;")
	getHTTP=iContent

end function
%>

