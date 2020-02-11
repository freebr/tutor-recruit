<%
Class User
Private mDept 
Private mPolName
Private mSex
Private mNation
Private mBirthday
Private mNativePlace
Private mAddress
Private mCareerT
Private mPolitics
Private mJoinT
Private mCulLvl
Private mDuty
Private mWorkT
Private mPolLvl
Private mPolId
Private mPolNo
Private mTid
Private mpolpayno

Private mPrivileges()

Private mwriteprivileges()  '写权限
Private mreadprivileges()  '读权限
Private mexamineprivileges()  '审批权限

Private mPassword
Private mPolType
'=====================
Public Property Get dept()
	dept = mDept
End Property
Public Property Let dept(vDept)
	mDept=vDept
End Property
'=====================
Public Property Get polName()
	polName = mPolName
End Property
Public Property Let polName(vPolName)
	mPolName=vPolName
End Property
'=====================
Public Property Get sex()
	sex = mSex
End Property
Public Property Let sex(vSex)
	mSex=vSex
End Property
'=====================
Public Property Get nation()
	nation = mNation
End Property
Public Property Let nation(vNation)
	mNation=vNation
End Property
'=====================
Public Property Get birthday()
	birthday = mBirthday
End Property
Public Property Let birthday(vBirthday)
	mBirthday=vBirthday
End Property
'=====================
Public Property Get nativePlace()
	nativePlace = mNativePlace
End Property
Public Property Let nativePlace(vNativePlace)
	mNativePlace=vNativePlace
End Property
'=====================
Public Property Get address()
	address = mAddress
End Property
Public Property Let address(vAddress)
	mAddress=vAddress
End Property
'=====================
Public Property Get careerT()
	careerT = mCareerT
End Property
Public Property Let careerT(vCareerT)
	mCarrerT=vCarrerT
End Property
'=====================
Public Property Get politics()
	politics = mPolitics
End Property
Public Property Let politics(vPolitics)
	mPolitics=vPolitics
End Property
'=====================
Public Property Get joinT()
	joinT = mJoinT
End Property
Public Property Let joinT(vJoinT)
	mJoinT=vJoinT
End Property
'=====================
Public Property Get culLvl()
	culLvl = mCulLvl
End Property
Public Property Let culLvl(vCulLvl)
	mCulLvl=vCulLvl
End Property
'=====================
Public Property Get duty()
	duty = mDuty
End Property
Public Property Let duty(vDuty)
	mDuty=vDuty
End Property
'=====================
Public Property Get workT()
	workT = mWorkT
End Property
Public Property Let workT(vWorkT)
	mWorkT=vWorkT
End Property
'=====================
Public Property Get polLvl()
	polLvl = mPolLvl
End Property
Public Property Let polLvl(vPolLvl)
	mPolLvl=vPolLvl
End Property
'=====================
Public Property Get polId()
	polId = mPolId
End Property
Public Property Let polId(vPolId)
	mPolId=vPolId
End Property
'=====================
Public Property Get polNo()
	polNo = mPolNo
End Property
Public Property Let polNo(vPolNo)
	mPolNo=vPolNo
End Property
'=====================
Public Property Get Tid()
	Tid = mTid
End Property
Public Property Let Tid(vTid)
	mTid=vTid
End Property
'=====================
Public Property Get polpayno()
	polpayno = mpolpayno
End Property
Public Property Let Tuser(vpolpayno)
	mpolpayno=vpolpayno
End Property
'================================
Public Property Get privileges()
	privileges = mPrivileges
End Property
Public Property Let privileges(vPrivilegesStr)
	beginPos=1
	endPos=1
	index=0
	Dim pArr()
	l=Len(vPrivilegesStr)
	If l=0 Then Exit Property
	Redim pArr(1)
	endPos = inStr(beginPos,vPrivilegesStr,",")
	While inStr(beginPos,vPrivilegesStr,",")<>0
		endPos = inStr(beginPos,vPrivilegesStr,",")
		pArr(index)=Mid(vPrivilegesStr,beginPos,endPos-beginPos)
		Redim Preserve pArr(Ubound(pArr)+1)
		beginPos = endPos+1
		index=index+1
        Wend
        pArr(index)=Mid(vPrivilegesStr,beginPos)
	mPrivileges = pArr
End Property
'=====================
Public Property Get writeprivileges()       '写权限
	writeprivileges = mwritePrivileges
End Property

Public Property Let writeprivileges(vwritePrivilegesStr)
	beginPos=1
	endPos=1          
	index=0
	Dim pArr()
	l=Len(vwritePrivilegesStr)
	If l=0 Then Exit Property
	Redim pArr(1)
	endPos = inStr(beginPos,vwritePrivilegesStr,",")
	While inStr(beginPos,vwritePrivilegesStr,",")<>0
		endPos = inStr(beginPos,vwritePrivilegesStr,",")
		pArr(index)=Mid(vwritePrivilegesStr,beginPos,endPos-beginPos)
		Redim Preserve pArr(Ubound(pArr)+1)
		beginPos = endPos+1
		index=index+1
        Wend
        pArr(index)=Mid(vwritePrivilegesStr,beginPos)
	mwritePrivileges = pArr
End Property
'=====================
Public Property Get readprivileges()       '读权限
	writeprivileges = mreadprivileges
End Property
Public Property Let readprivileges(vreadPrivilegesStr)
	beginPos=1
	endPos=1          
	index=0
	Dim pArr()
	l=Len(vreadPrivilegesStr)
	If l=0 Then Exit Property
	Redim pArr(1)
	endPos = inStr(beginPos,vreadPrivilegesStr,",")
	While inStr(beginPos,vreadPrivilegesStr,",")<>0
		endPos = inStr(beginPos,vreadPrivilegesStr,",")
		pArr(index)=Mid(vreadPrivilegesStr,beginPos,endPos-beginPos)
		Redim Preserve pArr(Ubound(pArr)+1)
		beginPos = endPos+1
		index=index+1
        Wend
        pArr(index)=Mid(vreadPrivilegesStr,beginPos)
	mreadPrivileges = pArr
End Property
'======================
Public Property Get examineprivileges()       '审批权限
	examineprivileges = mexamineprivileges
End Property
Public Property Let examineprivileges(vexaminePrivilegesStr)
	beginPos=1
	endPos=1          
	index=0
	Dim pArr()
	l=Len(vexaminePrivilegesStr)
	If l=0 Then Exit Property
	Redim pArr(1)
	endPos = inStr(beginPos,vexaminePrivilegesStr,",")
	While inStr(beginPos,vexaminePrivilegesStr,",")<>0
		endPos = inStr(beginPos,vexaminePrivilegesStr,",")
		pArr(index)=Mid(vexaminePrivilegesStr,beginPos,endPos-beginPos)
		Redim Preserve pArr(Ubound(pArr)+1)
		beginPos = endPos+1
		index=index+1
        Wend
        pArr(index)=Mid(vexaminePrivilegesStr,beginPos)
	mexaminePrivileges = pArr
End Property

'======================
Public Property Get password()
	password = mPassword
End Property
Public Property Let password(vPassword)
	mPassword=vPassword
End Property
'=====================
Public Property Get polType()
	polType = mPolType
End Property
Public Property Let polType(vPolType)
	mPolType=vPolType
End Property
End Class
'================================
Sub extractPrivileges(vPrivilegesStr,pArr())
	beginPos=1
	endPos=1
	index=0
	'Dim pArr()
	l=Len(vPrivilegesStr)
	If l=0 Then Exit Sub
	Redim pArr(1)
	endPos = inStr(beginPos,vPrivilegesStr,",")
	While inStr(beginPos,vPrivilegesStr,",")<>0
		endPos = inStr(beginPos,vPrivilegesStr,",")
		pArr(index)=Mid(vPrivilegesStr,beginPos,endPos-beginPos)
		Redim Preserve pArr(Ubound(pArr)+1)
		beginPos = endPos+1
		index=index+1
        Wend
        pArr(index)=Mid(vPrivilegesStr,beginPos)
End Sub
'================================
Function hasPrivilege(pArr,privilege)
    If IsEmpty(pArr) Then 
       hasPrivilege=false
       Exit Function
    End If
	pArr=split(pArr,",")
    For i=0 To Ubound(pArr)-1
	   If pArr(i)=privilege Then
          hasPrivilege=true
          Exit Function
       End If 
    Next
    hasPrivilege=false
End Function
%>