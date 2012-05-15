LeedsPort	;Leeds demo portal application
Init(sessid)	;Initial application set up
	; get all tree data from database and set them to the session
	s EdDispWin=$$getRequestValue^%zewdAPI("EdDispWin",sessid)
	i EdDispWin'="" s EdDispWin=$s(EdDispWin=1:"EastPanel",1:"editMWin")
	i EdDispWin="" s EdDispWin=^LControl("winmode")
	d setSessionValue^%zewdAPI("EdDispWin",EdDispWin,sessid)
	n tree,tree2,tree3
	m tree=^LTree("tree1")
	d mergeArrayToSession^%zewdAPI(.tree,"TreeOpts",sessid)
	m tree2=^LTree("tree2")
	d mergeArrayToSession^%zewdAPI(.tree2,"TreeSels",sessid)
	m tree3=^LTree("tree3")
	d mergeArrayToSession^%zewdAPI(.tree3,"TreeSels2",sessid)
 QUIT ""
loadChart(sessid) ;Load data for the chart
	k tot
	s tot=0,A="*"
	f i="All","Emergency","Outpatient","Inpatient" s tot(i)=0
	S pix="" f  s pix=$o(^LPAT(pix)) q:pix=""  d
	. s prec=^LPAT(pix) i '$p(prec,A,8) q  ;No current Episode
	. s tot("All")=tot("All")+1
	. s prEP=^LPAT(pix,"E",$p(prec,A,8)),t=^Lopts("Etype",$p(prEP,A,4)) s tot(t)=tot(t)+1
	s i="" f c=0:1 s i=$o(tot(i)) q:i=""  s data(c,"name")=i,data(c,"data1")=tot(i),data(c,"data2")=0,data(c,"data3")=0,data(c,"data4")=0
	d mergeArrayToSession^%zewdAPI(.data,"chart1",sessid)
	q ""
loadChart2(sessid) ;Load data for the chart
	n arr
	f x="0-10","11-18","19-30","31-60","61-80",">80" s arr(x)=0
	s tot=0,A="*"
	S pid="" f  s pid=$o(^LPAT(pid)) q:pid=""  d
	. s prec=^LPAT(pid)
	. s dob=$p(prec,A,5)
	. s age=$j(($h-dob/365),0,0)
	. d
	.. i age<10 s arr("0-10")=arr("0-10")+1 q
	.. i age<19 s arr("11-18")=arr("11-18")+1 q
	.. i age<31 s arr("19-30")=arr("19-30")+1 q
	.. i age<61 s arr("31-60")=arr("31-60")+1 q
	.. i age<81 s arr("61-80")=arr("61-80")+1 q
	.. s arr(">80")=arr(">80")+1 q
	s x="" f i=0:1 s x=$o(arr(x)) q:x=""  d
	. s data(i,"name")=x,data(i,"data1")=arr(x),data(i,"data2")=0,data(i,"data3")=0,data(i,"data4")=0
	d mergeArrayToSession^%zewdAPI(.data,"chart2",sessid)
	q ""
dummylabel1	;----------------------------------all functions in this section
loadtext(in) ;function to format textarea
	n i
	s out=""
	f i=1:1:$l(in,$c(0)) s out=out_$p(in,$c(0),i)_"\n"
	s out=$p(out,"\n",1,$l(out,"\n")-1)
	q out
ChangeMode(sessid) ; this sets the system variable to change between popups and inline editing
	d setSessionValue^%zewdAPI("EdDispWin",$$getRequestValue^%zewdAPI("EdDispWin",sessid),sessid)
	q ""
Eout(e) Q $S(e="E":"Episode",e="N":"Clinical note",e="V":"Vitals",e="O":"Orders",e="R":"Results",e="T":"Treatments",e="M":"Medications",1:"Unknown")
EPout(e) q $s(e="E":"AddEpisode",e="N":"AddNote",e="V":"AddVitals",e="O":"AddOrders",e="R":"AddResults",e="T":"AddTreatments",e="M":"AddMeds",1:"")
dateOut(di) Q $ZDATE(di,"DD/MM/YEAR") ;function to standardise date format
timein(t) q:$p(t," ",2)="" t q:$p(t," ",2)="AM" $P(t," ",1) s:$p(t,":",1)<12 $p(t,":",1)=$p(t,":",1)+12 q $p(t," ",1)
savetext(in) q $tr(in,$c(10),$c(0)) ;function to format text area for save to db
getHeaders(sessid)	;get basic header values from grids and put on forms
	s EditMode=$$getRequestValue^%zewdAPI("EditMode",sessid)
	d setSessionValue^%zewdAPI("EditMode",EditMode,sessid)
	s patNo=$$getRequestValue^%zewdAPI("pn",sessid)
	s rowNo=$$getRequestValue^%zewdAPI("rowNo",sessid)
	s A="*"
	i patNo="",rowNo="" s patNo=$$getSessionValue^%zewdAPI("MPpatID",sessid),EditMode="false" ;must be getting called from grid button so already know it
	i patNo="" d
	. n grid,data
	. s grid=$$getRequestValue^%zewdAPI("g",sessid)
	. i grid="pg" d mergeArrayFromSession^%zewdAPI(.data,"patGrid",sessid)
	. i grid="clg" d mergeArrayFromSession^%zewdAPI(.data,"patDetGrid",sessid)
	. i '$d(data) q
	. s patNo=data(rowNo,"pid")
	i patNo="" q "not able to identify patient"
	s prec=$g(^LPAT(patNo))
	s CPepNO=$p(prec,A,8)
	d setSessionValue^%zewdAPI("CPpatFN",$p(prec,A,1),sessid)
	d setSessionValue^%zewdAPI("CPpatLN",$p(prec,A,2),sessid)
	d setSessionValue^%zewdAPI("CPpatID",patNo,sessid)
	d setSessionValue^%zewdAPI("CPepNO",CPepNO,sessid)
	d setSessionValue^%zewdAPI("MPpatFN",$p(prec,A,1),sessid)
	d setSessionValue^%zewdAPI("MPpatLN",$p(prec,A,2),sessid)
	d setSessionValue^%zewdAPI("MPpatID",patNo,sessid)
	d setSessionValue^%zewdAPI("MPepNO",CPepNO,sessid)
	q ""
PatIx(p,d,t,i,r) ;Create indices for patient
	;there are some bugs in the maintenance of the ^LSTAT data here so this data is no lonmger used
	n s,ep
	S A="*"
	L +^LPAT(p,"D",d) s s=$g(^LPAT(p,"D",d))+1,^LPAT(p,"D",d)=s L -^LPAT(p,"D",d)
	S ^LPAT(p,"D",d,s)=t_A_i
	i t="E" d
	. s ep=^LPAT(p,"E",i)
	. ;i $p(ep,A,3)=2 Q  ;don't update if this episode is created as closed
	. L +^LSTAT("Dept")
	. i $p(ep,A,3)=1 S $p(^LSTAT("Dept"),A,$P(ep,A,4))=$p(^LSTAT("Dept"),A,$P(ep,A,4))+1
	. i $p(ep,A,3)=2 S $p(^LSTAT("Dept"),A,$P(ep,A,4))=$p(^LSTAT("Dept"),A,$P(ep,A,4))-1
	. L -^LSTAT("Dept")
	i t'="E" i $g(r)'="" s ^LPAT(p,"E",r,t,i)=""
	Q

Dummylabel2	;-----------------------------------end of functions
InitOrder(sessid) ; initialise data for orders screen
	;EditMode has changed such that EditMode="true" means display only mode
	n patID,ORID,ORdate,ORtime,ORnote,ORtype,ORauth,DateOut,DateIn
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	i EditMode'="true" i 'CPepNO q "Can't add Order as no current episode"
	s ORNo=$$getRequestValue^%zewdAPI("ixn",sessid)
	d setSessionValue^%zewdAPI("ORtype","",sessid)
	d clearList^%zewdAPI("ORtype",sessid)
	d initialiseMultipleSelect^%zewdAPI("ORtype",sessid)
	s t="" f  s t=$o(^Lopts("Otype",t)) q:t=""  d appendToList^%zewdAPI("ORtype",^Lopts("Otype",t),t,sessid)
	if EditMode'="true" d
	. d setMultipleSelectOn^%zewdAPI("ORtype","",sessid)
	. d setSessionValue^%zewdAPI("ORID",($o(^LPAT(patNo,"O",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("ORdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("ORtime",$p($$FUNC^%T()," ",1),sessid)
	. d setSessionValue^%zewdAPI("ORnote","",sessid)
	. d setSessionValue^%zewdAPI("ORauth","",sessid)
	if EditMode="true",ORNo'="" d
	. s Orrec=$g(^LPAT(patNo,"O",ORNo))
	. d setSessionValue^%zewdAPI("ORID",ORNo,sessid)
	. s ort=$p(Orrec,A,4)
	. f i=1:1:$l(ort,",") d setMultipleSelectOn^%zewdAPI("ORtype",$p(ort,",",i),sessid)
	. ;s ort="[" f i=1:1:$l($p(Orrec,A,4),",") s ort=ort_"'"_$p($p(Orrec,A,4),",",i)_"',"
	. ;s ort=$p(ort,",",1,($l(ort,",")-1))
	. ;s ort=ort_"]" 
	. ;d setSessionValue^%zewdAPI("ORtype",ort,sessid)
	. d setSessionValue^%zewdAPI("ORdate",$$dateOut($p(Orrec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("ORtime",$p(Orrec,A,6),sessid)
	. d setSessionValue^%zewdAPI("ORnote",$$loadtext($p(Orrec,A,3)),sessid)
	. d setSessionValue^%zewdAPI("ORauth",$p(Orrec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Orrec,A,8),sessid)
	q ""
SaveOrder(sessid) ; save the order data
	n i,patID,ORID,ORdate,ORtime,ORnote,ORtype,ORauth,DaterOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s ORID=$$getSessionValue^%zewdAPI("ORID",sessid)
	s ORdate=$$getSessionValue^%zewdAPI("ORdate",sessid)
	s ORtime=$$timein($$getSessionValue^%zewdAPI("ORtime",sessid))
	s ORnote=$$savetext($$getSessionValue^%zewdAPI("ORnote",sessid))
	k ortypes d getMultipleSelectValues^%zewdAPI("ORtype",.ortypes,sessid)
	;s ORtype=$$getSessionValue^%zewdAPI("ORtype",sessid)
	s ORtype="",i="" f  s i=$o(ortypes(i)) q:i=""  s ORtype=ORtype_","_i
	s ORtype=$E(ORtype,2,$l(ORtype))
	s ORauth=$$getSessionValue^%zewdAPI("ORauth",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(ORID="")!(ORdate="")!(ORauth="")!(ORnote="")!(ORtime="")!(ORtype="") q "All fields must be entered, type= "_ORtype_" note= "_ORnote
	s DateOut=$p(ORdate,"/",2)_"/"_$p(ORdate,"/",1)_"/"_$p(ORdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	s rec=patID_A_ORauth_A_ORnote_A_ORtype_A_DateIn_A_ORtime_A_ORID_A_CPepNO
	s ^cpc("L","o")=rec
	S ^LPAT(patID,"O",ORID)=rec
	D PatIx(patID,DateIn,"O",ORID,CPepNO)
	q ""
InitResult(sessid) ; initialise data for Results screen
	n EditMode,patNo,RENo,rowNo,Rerec
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	s RENo=$$getRequestValue^%zewdAPI("ixn",sessid)
	i EditMode'="true" i 'CPepNO q "Can't add Result as no current episode"
	if EditMode'="true" d 
	. d setSessionValue^%zewdAPI("REID",($o(^LPAT(patNo,"R",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("REdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("REtime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("REnote","",sessid)
	. d setSessionValue^%zewdAPI("REauth","",sessid)
	S ^CPC("B")=RENo_A_patNo
	if EditMode="true",RENo'="" d
	. s Rerec=$g(^LPAT(patNo,"R",RENo))
	. d setSessionValue^%zewdAPI("REID",RENo,sessid)
	. d setSessionValue^%zewdAPI("REdate",$$dateOut($p(Rerec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("REtime",$p(Rerec,A,6),sessid)
	. d setSessionValue^%zewdAPI("REnote",$$loadtext($p(Rerec,A,3)),sessid)
	. d setSessionValue^%zewdAPI("REauth",$p(Rerec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Rerec,A,8),sessid)
	q ""
SaveResult(sessid) ; save the resuts data
	n patID,REID,REdate,REtime,REnote,REauth,DateOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s REID=$$getSessionValue^%zewdAPI("REID",sessid)
	s REdate=$$getSessionValue^%zewdAPI("REdate",sessid)
	s REtime=$$timein($$getSessionValue^%zewdAPI("REtime",sessid))
	s REnote=$$savetext($$getSessionValue^%zewdAPI("REnote",sessid))
	s REauth=$$getSessionValue^%zewdAPI("REauth",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(REID="")!(REdate="")!(REauth="")!(REnote="")!(REtime="") q "All fields must be entered"
	s DateOut=$p(REdate,"/",2)_"/"_$p(REdate,"/",1)_"/"_$p(REdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	S rec=patID_A_REauth_A_REnote_A_A_DateIn_A_REtime_A_REID_A_CPepNO
	s ^cpc("L","r")=rec
	S ^LPAT(patID,"R",REID)=rec
	D PatIx(patID,DateIn,"R",REID,CPepNO)
	q ""
gotPatient(sessid) ; this initialises the data for the north window patient display
	s A="*"
	s patNo=$$getRequestValue^%zewdAPI("pn",sessid)
	s rowNo=$$getRequestValue^%zewdAPI("rowNo",sessid)
	i patNo="" d
	. n grid,data
	. s grid=$$getRequestValue^%zewdAPI("g",sessid)
	. i grid="pg" d mergeArrayFromSession^%zewdAPI(.data,"patGrid",sessid)
	. i grid="clg" d mergeArrayFromSession^%zewdAPI(.data,"patDetGrid",sessid)
	. i '$d(data) q
	. s patNo=data(rowNo,"pid")
	. s prec=$g(^LPAT(patNo))
	. s CPepNO=$p(prec,A,8)
	. d setSessionValue^%zewdAPI("MPpatFN",$p(prec,A,1),sessid)
	. d setSessionValue^%zewdAPI("MPpatLN",$p(prec,A,2),sessid)
	. d setSessionValue^%zewdAPI("MPpatID",patNo,sessid)
	. d setSessionValue^%zewdAPI("MPepNO",CPepNO,sessid)
	. d setSessionValue^%zewdAPI("MPpatDOB",$$dateOut($p(prec,A,5)),sessid)
	q ""
InitMed(sessid) ;initialise the medications screen
	n EditMode,patNo,MENo,rowNo
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	s MENo=$$getRequestValue^%zewdAPI("ixn",sessid)
	i EditMode'="true" i 'CPepNO q "Can't add meds as no current episode"
	if EditMode'="true" d 
	. d setSessionValue^%zewdAPI("MEID",($o(^LPAT(patNo,"M",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("MEdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("MEtime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("MEnote","",sessid)
	. d setSessionValue^%zewdAPI("MEauth","",sessid)

	if EditMode="true",MENo'="" d
	. s Merec=$g(^LPAT(patNo,"M",MENo))
	. d setSessionValue^%zewdAPI("MEID",MENo,sessid)
	. d setSessionValue^%zewdAPI("MEdate",$$dateOut($p(Merec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("MEtime",$p(Merec,A,6),sessid)
	. d setSessionValue^%zewdAPI("MEnote",$$loadtext($p(Merec,A,3)),sessid)
	. d setSessionValue^%zewdAPI("MEauth",$p(Merec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Merec,A,8),sessid)
	q ""
SaveMeds(sessid) ;save the meds data
	n patID,MEID,MEdate,MEtime,MEnote,MEauth,DateOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s MEID=$$getSessionValue^%zewdAPI("MEID",sessid)
	s MEdate=$$getSessionValue^%zewdAPI("MEdate",sessid)
	s MEtime=$$timein($$getSessionValue^%zewdAPI("MEtime",sessid))
	s MEnote=$$savetext($$getSessionValue^%zewdAPI("MEnote",sessid))
	s MEauth=$$getSessionValue^%zewdAPI("MEauth",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(MEID="")!(MEdate="")!(MEauth="")!(MEnote="")!(MEtime="") q "All fields must be entered"
	s DateOut=$p(MEdate,"/",2)_"/"_$p(MEdate,"/",1)_"/"_$p(MEdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	s rec=patID_A_MEauth_A_MEnote_A_A_DateIn_A_MEtime_A_MEID_A_CPepNO
	s ^cpc("L","m")=rec
	S ^LPAT(patID,"M",MEID)=rec
	D PatIx(patID,DateIn,"M",MEID,CPepNO)
	q ""

InitTreat(sessid) ;initialise the Treatements screen
	n EditMode,patNo,TRNo,rowNo,Trrec
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret ;get standard variables
	s TRNo=$$getRequestValue^%zewdAPI("ixn",sessid) ;get Treatment no from request header
	i EditMode'="true" i 'CPepNO q "Can't add Treatment as no current episode"
	if EditMode'="true" d  ;set up default values for form fields
	. d setSessionValue^%zewdAPI("TRID",($o(^LPAT(patNo,"T",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("TRdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("TRtime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("TRnote","",sessid)
	. d setSessionValue^%zewdAPI("TRauth","",sessid)

	if EditMode="true",TRNo'="" d  ;set up actual form values from existing treatment record
	. s Trrec=$g(^LPAT(patNo,"T",TRNo))
	. d setSessionValue^%zewdAPI("TRID",TRNo,sessid)
	. d setSessionValue^%zewdAPI("TRdate",$$dateOut($p(Trrec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("TRtime",$p(Trrec,A,6),sessid)
	. d setSessionValue^%zewdAPI("TRnote",$$loadtext($p(Trrec,A,3)),sessid)
	. d setSessionValue^%zewdAPI("TRauth",$p(Trrec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Trrec,A,8),sessid)
	q ""
SaveTreatment(sessid) ;save the Treatments data
	n parID,TRID,TRdate,TRtime,TRnote,TRauth,DateOut,DateIn
	s A="*"
	;first get values from submitted form
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s TRID=$$getSessionValue^%zewdAPI("TRID",sessid)
	s TRdate=$$getSessionValue^%zewdAPI("TRdate",sessid)
	s TRtime=$$timein($$getSessionValue^%zewdAPI("TRtime",sessid))
	s TRnote=$$savetext($$getSessionValue^%zewdAPI("TRnote",sessid))
	s TRauth=$$getSessionValue^%zewdAPI("TRauth",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(TRID="")!(TRdate="")!(TRauth="")!(TRnote="")!(TRtime="") q "All fields must be entered"
	s DateOut=$p(TRdate,"/",2)_"/"_$p(TRdate,"/",1)_"/"_$p(TRdate,"/",3) ;swap date around
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut ;validate date
	s rec=patID_A_TRauth_A_TRnote_A_A_DateIn_A_TRtime_A_TRID_A_CPepNO ;set up data record
	s ^cpc("L","t")=rec ;debug
	S ^LPAT(patID,"T",TRID)=rec
	D PatIx(patID,DateIn,"T",TRID,CPepNO) ;update patient indices
	q ""
 
InitVital(sessid) ;initialise the Vitals screen
	n EditMode,patNo,VINo,rowNo,Virec
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	s VINo=$$getRequestValue^%zewdAPI("ixn",sessid)
	i EditMode'="true" i 'CPepNO q "Can't add Vitals as no current episode"
	if EditMode'="true" d 
	. d setSessionValue^%zewdAPI("VIID",($o(^LPAT(patNo,"V",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("VIdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("VItime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("VIauth","",sessid)
	. d setSessionValue^%zewdAPI("VIresp","",sessid)
	. d setSessionValue^%zewdAPI("VIheart","",sessid)
	. d setSessionValue^%zewdAPI("VIBP1","",sessid)
	. d setSessionValue^%zewdAPI("VIBP2","",sessid)
	. d setSessionValue^%zewdAPI("VIO2","",sessid)

	if EditMode="true",VINo'="" d
	. s Virec=$g(^LPAT(patNo,"V",VINo))
	. d setSessionValue^%zewdAPI("VIID",VINo,sessid)
	. d setSessionValue^%zewdAPI("VIdate",$$dateOut($p(Virec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("VItime",$p(Virec,A,6),sessid)
	. d setSessionValue^%zewdAPI("VIauth",$p(Virec,A,2),sessid)
	. d setSessionValue^%zewdAPI("VIresp",$p(Virec,A,3),sessid)
	. d setSessionValue^%zewdAPI("VIheart",$p(Virec,A,4),sessid)
	. d setSessionValue^%zewdAPI("VIBP1",$p(Virec,A,7),sessid)
	. d setSessionValue^%zewdAPI("VIBP2",$p(Virec,A,9),sessid)
	. d setSessionValue^%zewdAPI("VIO2",$p(Virec,A,10),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Virec,A,8),sessid)
	q ""
SaveVitals(sessid) ; save the Vitals data
	n patID,VIID,VIdate,VItime,VIAuth,VIresp,VIheart,VIBP1,VIBP2,VIO2,DateOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s VIID=$$getSessionValue^%zewdAPI("VIID",sessid)
	s VIdate=$$getSessionValue^%zewdAPI("VIdate",sessid)
	s VItime=$$timein($$getSessionValue^%zewdAPI("VItime",sessid))
	s VIauth=$$getSessionValue^%zewdAPI("VIauth",sessid)
	s VIresp=$$getSessionValue^%zewdAPI("VIresp",sessid)
	s VIheart=$$getSessionValue^%zewdAPI("VIheart",sessid)
	s VIBP1=$$getSessionValue^%zewdAPI("VIBP1",sessid)
	s VIBP2=$$getSessionValue^%zewdAPI("VIBP2",sessid)
	s VIO2=$$getSessionValue^%zewdAPI("VIO2",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(VIID="")!(VIdate="")!(VIauth="")!(VIresp="")!(VItime="")!(VIheart="")!(VIBP1="")!(VIBP2="")!(VIO2="") q "All fields must be entered"
	s DateOut=$p(VIdate,"/",2)_"/"_$p(VIdate,"/",1)_"/"_$p(VIdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	s rec=patID_A_VIauth_A_VIresp_A_VIheart_A_DateIn_A_VItime_A_VIBP1_A_CPepNO_A_VIBP2_A_VIO2_A_VIID
	s ^cpc("L","v")=rec
	S ^LPAT(patID,"V",VIID)=rec
	D PatIx(patID,DateIn,"V",VIID,CPepNO)
	q ""
 

InitNote(sessid) ;initialise the Notes screen
	n EditMode,patNo,NOID,rowNo,Norec
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	s NOID=$$getRequestValue^%zewdAPI("ixn",sessid)
	i EditMode'="true" i 'CPepNO q "Can't add Note as no current episode"
	if EditMode'="true" d 
	. d setSessionValue^%zewdAPI("NOID",($o(^LPAT(patNo,"N",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("NOdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("NOtime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("NOnote","",sessid)
	. d setSessionValue^%zewdAPI("NOauth","",sessid)

	if EditMode="true",NOID'="" d
	. s Norec=$g(^LPAT(patNo,"N",NOID))
	. D setSessionValue^%zewdAPI("NOID",NOID,sessid)
	. d setSessionValue^%zewdAPI("NOdate",$$dateOut($p(Norec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("NOtime",$p(Norec,A,6),sessid)
	. d setSessionValue^%zewdAPI("NOnote",$$loadtext($p(Norec,A,3)),sessid)
	. d setSessionValue^%zewdAPI("NOauth",$p(Norec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPepNO",$p(Norec,A,8),sessid)
	q ""
SaveNote(sessid) ; save the notes data
	n patID,NOID,NOdate,NOtime,NOnote,NOauth,DateOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s NOID=$$getSessionValue^%zewdAPI("NOID",sessid)
	s NOdate=$$getSessionValue^%zewdAPI("NOdate",sessid)
	s NOtime=$$timein($$getSessionValue^%zewdAPI("NOtime",sessid))
	s NOnote=$$savetext($$getSessionValue^%zewdAPI("NOnote",sessid))
	s NOauth=$$getSessionValue^%zewdAPI("NOauth",sessid)
	s CPepNO=$$getSessionValue^%zewdAPI("CPepNO",sessid)
	if (patID="")!(NOID="")!(NOdate="")!(NOauth="")!(NOnote="")!(NOtime="") q "All fields must be entered"
	s DateOut=$p(NOdate,"/",2)_"/"_$p(NOdate,"/",1)_"/"_$p(NOdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	s rec=patID_A_NOauth_A_NOnote_A_A_DateIn_A_NOtime_A_NOID_A_CPepNO
	s ^cpc("L","n")=rec
	S ^LPAT(patID,"N",NOID)=rec
	D PatIx(patID,DateIn,"N",NOID,CPepNO)
	q ""
getHeaders(sessid)	;get basic header values from grid and put on form
	s EditMode=$$getRequestValue^%zewdAPI("EditMode",sessid)
	d setSessionValue^%zewdAPI("EditMode",EditMode,sessid)
	s patNo=$$getRequestValue^%zewdAPI("pn",sessid)
	s rowNo=$$getRequestValue^%zewdAPI("rowNo",sessid)
	s A="*"
	i patNo="",rowNo="" s patNo=$$getSessionValue^%zewdAPI("MPpatID",sessid),EditMode="false" ;must be getting called from grid button so already know it
	i patNo="" d
	. n grid,data
	. s grid=$$getRequestValue^%zewdAPI("g",sessid)
	. i grid="pg" d mergeArrayFromSession^%zewdAPI(.data,"patGrid",sessid)
	. i grid="clg" d mergeArrayFromSession^%zewdAPI(.data,"patDetGrid",sessid)
	. i '$d(data) q
	. s patNo=data(rowNo,"pid")
	i patNo="" q "not able to identify patient"
	s prec=$g(^LPAT(patNo))
	s CPepNO=$p(prec,A,8)
	d setSessionValue^%zewdAPI("CPpatFN",$p(prec,A,1),sessid)
	d setSessionValue^%zewdAPI("CPpatLN",$p(prec,A,2),sessid)
	d setSessionValue^%zewdAPI("CPpatID",patNo,sessid)
	d setSessionValue^%zewdAPI("CPepNO",CPepNO,sessid)
	d setSessionValue^%zewdAPI("MPpatFN",$p(prec,A,1),sessid)
	d setSessionValue^%zewdAPI("MPpatLN",$p(prec,A,2),sessid)
	d setSessionValue^%zewdAPI("MPpatID",patNo,sessid)
	d setSessionValue^%zewdAPI("MPepNO",CPepNO,sessid)
	q ""
InitAddEp(sessid) ;initialise the espisodes screen
	n EditMode,CPdisp,patNo,EPNo,rowNo,t,Eprec
	s A="*"
	s ret=$$getHeaders(sessid) i ret'="" q ret
	i EditMode="true" s EPNo=$$getRequestValue^%zewdAPI("ixn",sessid)
	S CPdisp=""	
	if EditMode'="true" d 
	. d setSessionValue^%zewdAPI("EPID",($o(^LPAT(patNo,"E",""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("EPdate",$$dateOut(+$H),sessid)
	. d setSessionValue^%zewdAPI("EPstat",1,sessid)
	. d setSessionValue^%zewdAPI("EPtime",$zd($h,"24:60"),sessid)
	. d setSessionValue^%zewdAPI("EPauth","",sessid)
	. I $P(^LPAT(patNo),A,8) D
	..  S prEP=^LPAT(patNo,"E",$P(^LPAT(patNo),A,8))
	..  S CPdisp="Patient has existing open "_^Lopts("Etype",$p(prEP,A,4))_" episode No "_$p(prEP,A,7)_" Opened "_$$dateOut($p(prEP,A,5))_" at "_$p(prEP,A,6)_" Opening this new episode will close the previous at the same time as this is opened"
	d setSessionValue^%zewdAPI("CPdisp",CPdisp,sessid)
	d setSessionValue^%zewdAPI("EPdatC",$$dateOut(+$H),sessid)
	d setSessionValue^%zewdAPI("EPtimC",$zd($h,"24:60"),sessid)

	d clearList^%zewdAPI("EPtype",sessid)
	s t="" f  s t=$o(^Lopts("Etype",t)) q:t=""  d appendToList^%zewdAPI("EPtype",^Lopts("Etype",t),t,sessid)
	d clearList^%zewdAPI("EPstat",sessid)
	s t="" f  s t=$o(^Lopts("Estat",t)) q:t=""  d appendToList^%zewdAPI("EPstat",^Lopts("Estat",t),t,sessid)
	if EditMode="true",EPNo'="" d
	. s Eprec=$g(^LPAT(patNo,"E",EPNo))
	. d setSessionValue^%zewdAPI("EPID",EPNo,sessid)
	. d setSessionValue^%zewdAPI("EPdate",$$dateOut($p(Eprec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("EPtime",$p(Eprec,A,6),sessid)
	. d setSessionValue^%zewdAPI("EPtype",$p(Eprec,A,4),sessid)
	. d setSessionValue^%zewdAPI("EPstat",$p(Eprec,A,3),sessid)
	. d setSessionValue^%zewdAPI("EPauth",$p(Eprec,A,2),sessid)
	. i $p(Eprec,A,8)'="" d
	..  d setSessionValue^%zewdAPI("EPdatC",$$dateOut($p(Eprec,A,8)),sessid)
	..  d setSessionValue^%zewdAPI("EPtimC",$p(Eprec,A,9),sessid)
	q ""
SaveEpisode(sessid) ;save the espisodes data
	n patID,EPID,EPdate,EPtime,EPtype,EPstat,EPauth,DateOut,DateIn,rec
	s A="*"
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s EPID=$$getSessionValue^%zewdAPI("EPID",sessid)
	s EPdate=$$getSessionValue^%zewdAPI("EPdate",sessid)
	s EPtime=$$timein($$getSessionValue^%zewdAPI("EPtime",sessid))
	s EPtype=$$getSessionValue^%zewdAPI("EPtype",sessid)
	s EPstat=$$getSessionValue^%zewdAPI("EPstat",sessid)
	s EPauth=$$getSessionValue^%zewdAPI("EPauth",sessid)
	s EPdatC=$$getSessionValue^%zewdAPI("EPdatC",sessid)
	s EPtimC=$$timein($$getSessionValue^%zewdAPI("EPtimC",sessid))
	if (patID="")!(EPID="")!(EPdate="")!(EPauth="")!(EPstat="")!(EPtype="") q "All fields must be entered"
	if EPstat=2 i (EPdatC="")!(EPtimC="") q "Need closing date and time to close event"
	s DateOut=$p(EPdate,"/",2)_"/"_$p(EPdate,"/",1)_"/"_$p(EPdate,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	i EPdatC'="" s DateC=$p(EPdatC,"/",2)_"/"_$p(EPdatC,"/",1)_"/"_$p(EPdatC,"/",3)
	S DateInC=$$FUNC^%DATE(DateC) I DateInC'?5N q "invalid date "_DateInC_" from "_DateC
	s rec=patID_A_EPauth_A_EPstat_A_EPtype_A_DateIn_A_EPtime_A_EPID
	i EPstat=2 s rec=rec_A_DateInC_A_EPtimC
	s ^cpc("L","e")=rec
	S ^LPAT(patID,"E",EPID)=rec
	I $P(^LPAT(patID),A,8),$P(^LPAT(patID),A,8)'=EPID d  ;close previously opened Episode
	. s prEP=^LPAT(patID,"E",$p(^LPAT(patID),A,8))
	. S $P(prEP,A,3)=2,$P(prEP,A,8)=DateOut,$p(prEP,A,9)=EPtime
	. s ^LPAT(patID,"E",$p(^LPAT(patID),A,8))=prEP
	. L +^LSTAT("Dept")
	. S $p(^LSTAT("Dept"),A,$P(prEP,A,4))=$p(^LSTAT("Dept"),A,$P(prEP,A,4))-1
	. L -^LSTAT("Dept")
	s $p(^LPAT(patID),A,8)=$S(EPstat=2:0,1:EPID)
	D PatIx(patID,DateIn,"E",EPID)
	q ""
InitCrPat(sessid) ; intialise the create patient screen
	n EditMode,patNo,rowNo,prec
	s A="*"
	s EditMode=$$getRequestValue^%zewdAPI("EditMode",sessid)
	d setSessionValue^%zewdAPI("EditMode",EditMode,sessid)
	s patNo=$$getRequestValue^%zewdAPI("pn",sessid)
	s rowNo=$$getRequestValue^%zewdAPI("rowNo",sessid)
	d clearList^%zewdAPI("sex",sessid)
	d appendToList^%zewdAPI("sex","Male","M",sessid)
	d appendToList^%zewdAPI("sex","Female","F",sessid)
	if EditMode'="true" d
	. d setSessionValue^%zewdAPI("CPpatID",($o(^LPAT(""),-1))+1,sessid)
	. d setSessionValue^%zewdAPI("CPpatFN","",sessid)
	. d setSessionValue^%zewdAPI("CPpatLN","",sessid)
	. d setSessionValue^%zewdAPI("CPpatAdd","",sessid)
	. d setSessionValue^%zewdAPI("sex","",sessid)
	. d setSessionValue^%zewdAPI("CPpatDOB","",sessid)
	. d setSessionValue^%zewdAPI("CPpatAuth","",sessid)
	if EditMode="true" d
	. i patNo="",rowNo="" q
	. i patNo="" d
	..  n grid,data
	..  s grid=$$getRequestValue^%zewdAPI("g",sessid)
	..  i grid="pg" d mergeArrayFromSession^%zewdAPI(.data,"patGrid",sessid)
	..  ;i '$d(data) q
	..  s patNo=data(rowNo,"pid")
	..  s ^cpc("L",2)=patNo
	. s prec=$g(^LPAT(patNo))
	. d setSessionValue^%zewdAPI("CPpatFN",$p(prec,A,1),sessid)
	. d setSessionValue^%zewdAPI("CPpatLN",$p(prec,A,2),sessid)
	. d setSessionValue^%zewdAPI("CPpatID",patNo,sessid)
	. d setSessionValue^%zewdAPI("CPpatAdd",$$loadtext($p(prec,A,4)),sessid)
	. d setSessionValue^%zewdAPI("sex",$p(prec,A,6),sessid)
	. d setSessionValue^%zewdAPI("CPpatDOB",$$dateOut($p(prec,A,5)),sessid)
	. d setSessionValue^%zewdAPI("CPpatAuth",$p(prec,A,7),sessid)
	q ""
SavePatient(sessid) ;save the patient data
	n EditMode,patFN,patLN,patID,patAdd,patSex,patDOB,patAuth,DateOut,DateIn
	s A="*"
	s EditMode=$$getSessionValue^%zewdAPI("EditMode",sessid)
	s ^cpc("em")=EditMode
	s patFN=$$getSessionValue^%zewdAPI("CPpatFN",sessid)
	s patLN=$$getSessionValue^%zewdAPI("CPpatLN",sessid)
	s patID=$$getSessionValue^%zewdAPI("CPpatID",sessid)
	s patAdd=$$savetext($$getSessionValue^%zewdAPI("CPpatAdd",sessid))
	s patSex=$$getSessionValue^%zewdAPI("sex",sessid)
	s patDOB=$$getSessionValue^%zewdAPI("CPpatDOB",sessid)
	s patAuth=$$getSessionValue^%zewdAPI("CPpatAuth",sessid)
	s DateOut=$p(patDOB,"/",2)_"/"_$p(patDOB,"/",1)_"/"_$p(patDOB,"/",3)
	S DateIn=$$FUNC^%DATE(DateOut) I DateIn'?5N q "invalid date "_DateIn_" from "_DateOut
	if (patFN="")!(patLN="")!(patID="")!(patAdd="")!(patDOB="")!(patAuth="") q "All fields must be entered"
	i EditMode'="true" IF $D(^LPAT(patID)) q "Patient number "_patID_" already exists"
	s ^cpc("L","p")=patFN_A_patLN_A_patID_A_patAdd_A_DateIn_A_patSex_A_patAuth_A_0
	S ^LPAT(patID)=patFN_A_patLN_A_patID_A_patAdd_A_DateIn_A_patSex_A_patAuth_A_0
	q ""
InitPatGrid(sessid) ;Set up the main patients grid
	n column,data,i,pix,type,prec,Tno,tot,prEP
	s doPFilter=$$getRequestValue^%zewdAPI("doPFilter",sessid)
	i doPFilter'="" d  ;process the supplied filter data and translate into actual filter
	. n x,x2
	. I $l(doPFilter,"|")=2 s doPFilter=$p(doPFilter,"|",1)_"=="_$p(doPFilter,"|",2) q
	. s x=$p(doPFilter,"|",3)
	. I $l(doPFilter,"|")=3 s doPFilter=$p(doPFilter,"|",1)_$s(x="gt":">",1:"<")_$p(doPFilter,"|",2) q
	. s x2=$p(doPFilter,"|",4)
	. I $l(doPFilter,"|")=5 s doPFilter=$p(doPFilter,"|",1)_$s(x="gt":">",1:"<")_$p(doPFilter,"|",2)_" && "_$p(doPFilter,"|",1)_$s(x2="gt":">",1:"<")_$p(doPFilter,"|",5)
	d setSessionValue^%zewdAPI("doPFilter",doPFilter,sessid)
	s EdDispWin=$$getSessionValue^%zewdAPI("EdDispWin",sessid)
	;first set up the basic column definitions
	s column(1,"dataIndex")="name",column(1,"text")="Name",column(1,"width")=100
	s column(2,"dataIndex")="sex",column(2,"text")="Sex",column(2,"width")=30
	s column(3,"dataIndex")="age",column(3,"text")="Age",column(3,"width")=32
	s column(4,"dataIndex")="episodes",column(4,"text")="Eps",column(4,"width")=30
	s column(5,"dataIndex")="oc",column(5,"text")="Open",column(5,"width")=110
	s column(6,"dataIndex")="dept",column(6,"text")="Dept",column(6,"width")=80
	s column(7,"dataIndex")="notes",column(7,"text")="Notes",column(7,"width")=40
	s column(8,"dataIndex")="vitals",column(8,"text")="Vitals",column(8,"width")=40
	s column(9,"dataIndex")="orders",column(9,"text")="Orders",column(9,"width")=40
	s column(10,"dataIndex")="results",column(10,"text")="Rslts",column(10,"width")=35
	s column(11,"dataIndex")="treatments",column(11,"text")="Tments",column(11,"width")=40
	s column(12,"dataIndex")="meds",column(12,"text")="Meds",column(12,"width")=35
	;now the more complex one - the actions column containing clickable icons
	s column(13,"xtype")="actioncolumn"
	s column(13,"text")="Actions"
	s column(13,"width")="300"
	;set up the control strings that will be inserted into the handler functions for each icon
	s pattext="{nvp=nvp0+'&ext4_addTo=NorthPanel&ext4_removeAll=true'; EWD.ajax.getPage({page:'gotPatient',nvp:nvp});}"
	s handtext="function(grid, rowIndex, colIndex) {var nvp0='rowNo='+EWD.ext4.getGridRowNo(grid,rowIndex)+'&g=pg&f=ec';nvp=nvp0+'&ext4_addTo='+EdDispWin+'&ext4_removeAll=true';"
	s handtext=handtext_"Ext.getCmp(EdDispWin).show();"
	s edwintxt="	;Ext.getCmp('editMWin').show();"
	;now set up each icon
	s column(13,"icon",1,"icon")="/Icons/DutyRoster.png"
	s column(13,"icon",1,"tooltip")="See detailed view"
	s column(13,"icon",1,"handler")="function(grid, rowIndex, colIndex) {var nvp0='rowNo='+EWD.ext4.getGridRowNo(grid, rowIndex)+'&g=pg&f=dv';nvp=nvp0+'&ext4_addTo=CentrePanel'; EWD.ajax.getPage({page:'gridCl',nvp:nvp});nvp=nvp0+'&ext4_addTo=NorthPanel&ext4_removeAll=true'; EWD.ajax.getPage({page:'gotPatient',nvp:nvp})}"
	s column(13,"icon",2,"icon")="/Icons/PatientData.png"
	s column(13,"icon",2,"tooltip")="Edit User Details"
	s column(13,"icon",2,"handler")=handtext_"nvp=nvp+'&EditMode=true'; EWD.ajax.getPage({page:'CreatePatient',nvp:nvp});"_pattext_"}"
	s column(13,"icon",3,"icon")="/Icons/Hospital.png"
	s column(13,"icon",3,"tooltip")="Add Episode"
	s column(13,"icon",3,"handler")=handtext_" EWD.ajax.getPage({page:'AddEpisode',nvp:nvp});"_pattext_"}"
	s column(13,"icon",4,"icon")="/Icons/PatientFile.png"
	s column(13,"icon",4,"tooltip")="Add Note"
	s column(13,"icon",4,"handler")=handtext_" EWD.ajax.getPage({page:'AddNote',nvp:nvp});"_pattext_"}"
	s column(13,"icon",5,"icon")="/Icons/Stethoscope.png"
	s column(13,"icon",5,"tooltip")="Add Vitals"
	s column(13,"icon",5,"handler")=handtext_" EWD.ajax.getPage({page:'AddVitals',nvp:nvp});"_pattext_"}"
	s column(13,"icon",6,"icon")="/Icons/TestTubes.png"
	s column(13,"icon",6,"tooltip")="Add Orders"
	s column(13,"icon",6,"handler")=handtext_"EWD.ajax.getPage({page:'AddOrders',nvp:nvp});"_pattext_"}"
	s column(13,"icon",7,"icon")="/Icons/XRay.png"
	s column(13,"icon",7,"tooltip")="Add Results"
	s column(13,"icon",7,"handler")=handtext_"EWD.ajax.getPage({page:'AddResults',nvp:nvp});"_pattext_"}"
	s column(13,"icon",8,"icon")="/Icons/Pills.png"
	s column(13,"icon",8,"tooltip")="Add Medication"
	s column(13,"icon",8,"handler")=handtext_"EWD.ajax.getPage({page:'AddMeds',nvp:nvp});"_pattext_"}"
	s column(13,"icon",9,"icon")="/Icons/Syringe.png"
	s column(13,"icon",9,"tooltip")="Add Treatment"
	s column(13,"icon",9,"handler")=handtext_"EWD.ajax.getPage({page:'AddTreatments',nvp:nvp});"_pattext_"}"
	;
	d deleteFromSession^%zewdAPI("patGridcolDef",sessid)
	d mergeArrayToSession^%zewdAPI(.column,"patGridcolDef",sessid)
	;
	s A="*"
	s i=0,pix="" f  s pix=$o(^LPAT(pix)) q:pix=""  d
	. s i=i+1
	. s prec=^LPAT(pix)
	. f type="E","N","V","O","R","T","M" d  ;count up the number of each type of entity
	..  s tot(type)=0
	..  s Tno="" f  s Tno=$o(^LPAT(pix,type,Tno)) q:Tno=""  s tot(type)=tot(type)+1
	. s data(i,"name")=$p(prec,A,1)_" "_$p(prec,A,2)
	. s data(i,"sex")=$p(prec,A,6)
	. s data(i,"age")=$j(($h-$p(prec,A,5)/365),0,0)
	. s data(i,"episodes")=tot("E")
	. s data(i,"oc")=""
	. i $p(prec,A,8) s prEP=^LPAT(pix,"E",$p(prec,A,8)) s data(i,"oc")=$$dateOut($p(prEP,A,5))_" "_$P(prEP,A,6)
	. s data(i,"dept")=""
	. i $p(prec,A,8) s prEP=^LPAT(pix,"E",$p(prec,A,8)) s data(i,"dept")=^Lopts("Etype",$p(prEP,A,4))
	. s data(i,"notes")=tot("N")
	. s data(i,"vitals")=tot("V")
	. s data(i,"orders")=tot("O")
	. s data(i,"results")=tot("R")
	. s data(i,"treatments")=tot("T")
	. s data(i,"meds")=tot("M")
	. s data(i,"pid")=pix
	d deleteFromSession^%zewdAPI("patGrid",sessid)
	d mergeArrayToSession^%zewdAPI(.data,"patGrid",sessid)
	s ^cpc("pge")=sessid
	q ""
procGrid(sessid) ;set up the patient details grid
	n column,data,patNo,rowNo,i,d,s,Dateout,t
	S A="*"
	;
	s column(1,"dataIndex")="epgroup"
	s column(1,"groupField")="true"
	s column(1,"hidden")="true"
	s column(2,"dataIndex")="episode",column(2,"text")="Episode"
	s column(3,"dataIndex")="date",column(3,"text")="Date"
	s column(4,"dataIndex")="data",column(4,"text")="Data"
	s column(4,"filter")="true"
	s column(5,"dataIndex")="time",column(5,"text")="Time"
	s column(6,"dataIndex")="itemID",column(6,"text")="No"
	s column(7,"dataIndex")="source",column(7,"text")="Source"
	s column(8,"dataIndex")="page",column(8,"hidden")="true"
	d deleteFromSession^%zewdAPI("patDetGridcolDef",sessid)
	d mergeArrayToSession^%zewdAPI(.column,"patDetGridcolDef",sessid)
	;
	s patNo=$$getRequestValue^%zewdAPI("pn",sessid)
	s rowNo=$$getRequestValue^%zewdAPI("rowNo",sessid)
	s colName=$$getRequestValue^%zewdAPI("col",sessid)
	s btnname="" i colName'="" s btnname="btnAdd"_$e(colName,1)
	s colName=$s(colName="notes":"Clinical note",colName="meds":"Medications",colName="episodes":"Episode",1:colName)
	d setSessionValue^%zewdAPI("doFilter",colName,sessid)
	d setSessionValue^%zewdAPI("showbut",btnname,sessid)
	i patNo="",rowNo="" s patNo=$$getSessionValue^%zewdAPI("MPpatID",sessid),EditMode="false" ;must be getting called from saveform button so already know it
	i patNo="" d
	.  n grid,data
	.  s grid=$$getRequestValue^%zewdAPI("g",sessid)
	.  i grid="pg" d mergeArrayFromSession^%zewdAPI(.data,"patGrid",sessid)
	.  s patNo=data(rowNo,"pid")
	. s prec=$g(^LPAT(patNo))
	S i=0,d="" f  s d=$o(^LPAT(patNo,"D",d)) q:d=""  d
	. s s="" f  s s=$o(^LPAT(patNo,"D",d,s)) q:s=""  d
	..  s Dateout=$$dateOut(d)
	..  s x=^LPAT(patNo,"D",d,s)
	..  s t=$p(x,A,1),ID=$p(x,A,2)
	..  s epID=$s(t="E":ID,1:$p(^LPAT(patNo,t,ID),A,8))
	..  s epSD=$$dateOut($p(^LPAT(patNo,"E",epID),A,5))
	..  S epED="",xED=$p(^LPAT(patNo,"E",epID),A,8) I xED'="" s epED=$$dateOut(xED)
	..  s auth=$p(^LPAT(patNo,t,ID),A,2)
	..  s time=$p(^LPAT(patNo,t,ID),A,6)
	..  s i=i+1
	..  s grrec=epID_" Started "_epSD s:epED'="" grrec=grrec_" Closed "_epED
	..  s data(i,"epgroup")=grrec
	..  s data(i,"episode")=epID
	..  s data(i,"date")=Dateout
	..  s data(i,"time")=time
	..  s data(i,"itemID")=ID
	..  S data(i,"data")=$$Eout(t)
	..  s data(i,"source")=auth
	..  s data(i,"page")=$$EPout(t)
	..  s data(i,"pid")=patNo
	d deleteFromSession^%zewdAPI("patDetGrid",sessid)
	d mergeArrayToSession^%zewdAPI(.data,"patDetGrid",sessid)
	q ""