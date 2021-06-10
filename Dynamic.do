cd "C:\Users\nicho\Box\NCCAP\Data\NicholeShepherd"
import delimited "C:\Users\nicho\OneDrive\Рабочий стол\Work\NCCAP\6_02\Church+Attendance+Initiative+(Dynamic)_June+2,+2021_08.28.csv", clear 

*Drop observations with no attendance data
drop if (inpersonupd==. & onlineattendanceupd==.)

*Variable "startdate" formatting
	gen startdate2=date(startdate,"MDY##")
	format startdate2 %td
	drop startdate
	rename startdate2 startdate

*Variable "enddate" formatting
	gen enddate2=date(enddate,"MDY##")
	format enddate2 %td
	drop enddate
	rename enddate2 enddate
	
*Variable "recorddate" formatting
	gen recordeddate2=date(recordeddate,"MDY##")
	format recordeddate2 %td
	drop recordeddate
	rename recordeddate2 recordeddate
	
*Variable "reportweekend" formatting
	gen reportweekend2=date(reportweekend,"MDY##")
	format reportweekend2 %td
	drop reportweekend
	rename reportweekend2 reportweekend
	
	order reportweekend, after(emailupd)
	order startdate enddate recordeddate
	
*Dropping observations which report weekends before the start of the surveys
	drop if reportweekend < td(13apr2021)
	
*Generating april 2021 weekend entries
	forvalues i = 18(7)25 {
	gen reportweekendapr`i'=.
	gen onlineattendapr`i'=.
	gen numscreensapr`i'=.
	gen numservicesapr`i'=.
	gen paidstaffapr`i'=.
	}

*Generating may 2021 weekend entries
	forvalues i = 2(7)30 {
	gen reportweekendmay`i'=.
	gen onlineattendmay`i'=.
	gen numscreensmay`i'=.
	gen numservicesmay`i'=.
	gen paidstaffmay`i'=.
	}

*Generating june 2021 weekend entries
	forvalues i = 6(7)27 {
	gen reportweekendjun`i'=.
	gen onlineattendjun`i'=.
	gen numscreensjun`i'=.
	gen numservicesjun`i'=.
	gen paidstaffjun`i'=.
	}
	
*Trabsferring updated in-person attendance to corresponding weekend
foreach i in reportweekend {
		replace reportweekendapr18=inpersonupd if `i'==td(18apr2021)
		replace reportweekendapr25=inpersonupd if `i'==td(25apr2021)
		replace reportweekendmay9=inpersonupd if `i'==td(09may2021)
		replace reportweekendmay2=inpersonupd if `i'==td(02may2021)
		replace reportweekendmay16=inpersonupd if `i'==td(16may2021)
		replace reportweekendmay23=inpersonupd if `i'==td(23may2021)
		replace reportweekendmay30=inpersonupd if `i'==td(30may2021)
		replace reportweekendjun6=inpersonupd if `i'==td(06jun2021)
		replace reportweekendjun13=inpersonupd if `i'==td(13jun2021)
		replace reportweekendjun20=inpersonupd if `i'==td(20jun2021)
		replace reportweekendjun27=inpersonupd if `i'==td(27jun2021)
}

*Trabsferring updated online attendance to corresponding weekend
foreach i in reportweekend {
		replace onlineattendapr18=onlineattendanceupd if `i'==td(18apr2021)
		replace onlineattendapr25=onlineattendanceupd if `i'==td(25apr2021)
		replace onlineattendmay9=onlineattendanceupd if `i'==td(09may2021)
		replace onlineattendmay2=onlineattendanceupd if `i'==td(02may2021)
		replace onlineattendmay16=onlineattendanceupd if `i'==td(16may2021)
		replace onlineattendmay23=onlineattendanceupd if `i'==td(23may2021)
		replace onlineattendmay30=onlineattendanceupd if `i'==td(30may2021)
		replace onlineattendjun6=onlineattendanceupd if `i'==td(06jun2021)
		replace onlineattendjun13=onlineattendanceupd if `i'==td(13jun2021)
		replace onlineattendjun20=onlineattendanceupd if `i'==td(20jun2021)
		replace onlineattendjun27=onlineattendanceupd if `i'==td(27jun2021)
}
	
*Trabsferring updated number of screens to corresponding weekend
foreach i in reportweekend {
		replace numscreensapr18=numscreensupd if `i'==td(18apr2021)
		replace numscreensapr25=numscreensupd if `i'==td(25apr2021)
		replace numscreensmay9=numscreensupd if `i'==td(09may2021)
		replace numscreensmay2=numscreensupd if `i'==td(02may2021)
		replace numscreensmay16=numscreensupd if `i'==td(16may2021)
		replace numscreensmay23=numscreensupd if `i'==td(23may2021)
		replace numscreensmay30=numscreensupd if `i'==td(30may2021)
		replace numscreensjun6=numscreensupd if `i'==td(06jun2021)
		replace numscreensjun13=numscreensupd if `i'==td(13jun2021)
		replace numscreensjun20=numscreensupd if `i'==td(20jun2021)
		replace numscreensjun27=numscreensupd if `i'==td(27jun2021)
}

*Trabsferring updated number of services to corresponding weekend
foreach i in reportweekend {
		replace numservicesapr18=numservicesupd if `i'==td(18apr2021)
		replace numservicesapr25=numservicesupd if `i'==td(25apr2021)
		replace numservicesmay9=numservicesupd if `i'==td(09may2021)
		replace numservicesmay2=numservicesupd if `i'==td(02may2021)
		replace numservicesmay16=numservicesupd if `i'==td(16may2021)
		replace numservicesmay23=numservicesupd if `i'==td(23may2021)
		replace numservicesmay30=numservicesupd if `i'==td(30may2021)
		replace numservicesjun6=numservicesupd if `i'==td(06jun2021)
		replace numservicesjun13=numservicesupd if `i'==td(13jun2021)
		replace numservicesjun20=numservicesupd if `i'==td(20jun2021)
		replace numservicesjun27=numservicesupd if `i'==td(27jun2021)
}

*Trabsferring updated number paid staff to corresponding weekend
foreach i in reportweekend {
		replace paidstaffapr18=paidstaffupd if `i'==td(18apr2021)
		replace paidstaffapr25=paidstaffupd if `i'==td(25apr2021)
		replace paidstaffmay9=paidstaffupd if `i'==td(09may2021)
		replace paidstaffmay2=paidstaffupd if `i'==td(02may2021)
		replace paidstaffmay16=paidstaffupd if `i'==td(16may2021)
		replace paidstaffmay23=paidstaffupd if `i'==td(23may2021)
		replace paidstaffmay30=paidstaffupd if `i'==td(30may2021)
		replace paidstaffjun6=paidstaffupd if `i'==td(06jun2021)
		replace paidstaffjun13=paidstaffupd if `i'==td(13jun2021)
		replace paidstaffjun20=paidstaffupd if `i'==td(20jun2021)
		replace paidstaffjun27=paidstaffupd if `i'==td(27jun2021)
}
	
*Collapsing reported weekend info fpr identical churches
collapse loginid numservicesapr* numservicesmay* numservicesjun* reportweekendapr* reportweekendmay* reportweekendjun* onlinetrackmethod onlineattendapr* onlineattendmay* onlineattendjun* numscreensapr* numscreensmay* numscreensjun* paidstaffmay* paidstaffapr* paidstaffjun*, by(emailupd churchname)




