local root="C:\Users\nicho\Box\"
*local root="C:\Users\Cole\Documents\"
*local root="C:\Users\ryan\Box\"
*local root="C:\Users\enochhill\Box\"

cd "`root'NCCAP\Data\MasterDo"
import delimited "`root'NCCAP\Data\20210602\20210602Data.csv", clear


//_________________________________________SECTION#1: VARIABLE & LABEL FORMATTING _________________________________________________//

*Variable "startdate" formatting
	gen startdate2=date(startdate,"MDY##")
	order startdate startdate2
	format startdate2 %td
	drop startdate
	rename startdate2 startdate

*Variable "enddate" formatting
	gen enddate2=date(enddate,"MDY##")
	order enddate enddate2
	format enddate2 %td
	drop enddate
	rename enddate2 enddate

*Variable "recorddate" formatting
	gen recordeddate2=date(recordeddate,"MDY##")
	order recordeddate recordeddate2
	format recordeddate2 %td
	drop recordeddate
	rename recordeddate2 recordeddate

*Incorrect zipcode format fix
	replace zipcode="75214" if loginid==3773781983

*Turning string zipcode into numeric zip for merging data
	destring zipcode, generate(zip)
	drop zipcode

*Variable "responder" identification
	label define responder1 1 "seniorpastor" 2 "onbehalf" 3 "staff" 4 "other"
	label values responder responder1
	
*Variable "denomination" numerical identification
	label define denomination1 611 "Adventist" 608 "Anglican" 601 "Baptist" 600 "Catholic" 610 "Congregational Church" 609 "Holiness" 605 "Lutheran" 603 "Methodist/Wesleyan" 602 "Nondenominational" 604 "Pentecostal" 606 "Presbyterian/Reformed" 607 "Restorationist" 612 "Other"
	label values denomination denomination1

*Variable "onlineservices" numerical identification
	label define onlineservices1 1 "Yes" 0 "No" -99 "No response"
	label values onlineservices onlineservices1

*Variable "trackonline" numerical identification
	label define trackonline1 1 "Yes" 0 "No" -99 "No response"
	label values trackonline trackonline1

*Variable "trackonlinehow" numerical identification
	label define trackonlinehow1 1 "Screens" 2 "Viewers" 3 "Both" 4 "Other"
	label values trackonlinehow trackonlinehow1
	
*Fixing variable name typos
	rename contryother countryother


//_________________________________________SECTION#2: CLEANING AND FLAGGING DATA _________________________________________________//

drop if missing(security)
drop if email==""

*Flagged IDs
	gen flag="New Church" if loginid==1898682227
	replace flag="Large Online to some In Person" if loginid==5381936596
	replace flag="Error in Jan 2020 Attendance?" if loginid==9275200923
	replace flag="Jan2020 suspect" if loginid==5368830490
	replace flag="Online only" if loginid==2030355526
	replace flag="Almost all online, odd pattern" if loginid==2235356149

*Error in attendance data?
	drop if loginid==9275200923 
	drop if loginid==5368830490
	drop if loginid==2235356149

*This one seems like an error, only had attendance in Jan 2021 but not in Jan 2020 or April 2021?
	drop if loginid==1898682227 

*seems like a fake entry
	drop if loginid==1851175199 

*Editing international zipcodes 
	replace country=3 if zip==100 
	replace countryother="Kenya" if zip==100
	replace country=3 if zip==184
	replace countryother="Cameroon" if zip==184
	replace country=3 if zip==234
	replace countryother="Nigeria" if zip==234
	replace country=3 if zip==256
	replace countryother="South Africa" if zip==256
	replace country=3 if zip==18765
	replace countryother="Jamaica" if zip==18765
	replace country=3 if zip==20219
	replace countryother="Republic of Congo" if zip==20219
	replace country=3 if zip==57100
	replace countryother="Malaysia" if zip==57100
	replace country=3 if zip==77500
	replace countryother="Mexico" if zip==77500
	replace country=2 if loginid==775007269248510
	replace postalcanada="N5Z 5A9" if loginid==775007269248510
	replace country=3 if loginid==775007269248510
	replace countryother="Costa Rica" if loginid==4444303639

*Real churches, unknown location 
	replace country=1 if zip==263
	replace flag=flag+"Unknown US location; " if loginid==7289550079
	replace flag=flag+"Unknown church location; " if loginid==6933425060
	replace country=1 if loginid==7499627604
	replace flag=flag+"Unknown US location; " if loginid==7499627604
	replace flag=flag+"Unknown church location; " if loginid==8847224583
	replace country=1 if loginid==5281416655
	replace flag=flag+"Unknown US location; " if loginid==5281416655

*Typo according to the church website
	replace zip=98072 if zip==98082
	replace zip=60108 if zip==160
	replace zip=29180 if zip==29189
	replace zip=02339 if zip==2340
	replace zip=73003 if loginid==4794961958

*Identical county and city
	replace zip=99801 if zip==99803
	replace zip=27505 if zip==27506
	replace zip=75214 if loginid==3773781983

*Counsultant Entry, not church
	drop if loginid==6502446840 

*Handling duplicate entries
	drop if inlist(loginid,8524012957,5249223802,2967820084,7656503535,1921755777,1528778903,9234282297,9344416335,9654498424,///
			5026045169,5157188521,5865794741,8525332015,9311857213,6192038870,9416397423,7486703372,7725390990,2167668752,///
			4642612033,8781390528,7358814931,5125390311,3454215584,4707619583,3486802190,3047365053,3609179829,4174744250,7761941020,1837292030)
*Note: 4174744250 is legit but it's a different week for the same church as 8407078484
	replace flag=flag+"There was a second entry for this church with Login ID: 4174744250; " if loginid==8407078484
	
*Merge Berean Baptist Church (loginid, 4501526154, 7761941020)
	replace trackonlinehow=3 if loginid==4501526154
	replace screensjan2020=0 if loginid==4501526154
	replace screensjan2021=225 if loginid==4501526154
	replace screensmostrecent=270 if loginid==4501526154	
	
*Merge The Chapel (loginid,1837292030, 7287147509)
	replace budgetgiving=4582000 if loginid==7287147509
	replace actualgiving=3550263 if loginid==7287147509
	replace paidstaffjan2020="0" if paidstaffjan2020=="nil"
	replace paidstaffjan2020="67" if loginid==7287147509
	replace paidstaffcurrent=58 if loginid==7287147509
	replace cares=2 if loginid==7287147509
	replace reasonnocaresnaunknown=1 if loginid==7287147509
	
* Generate a flag for small churches which couldn't be verified as existing through online search
* This flag should be set to 1 for all churches with <100 in the field inpersonjan2020 which were unable to be verified as existing through an online search
	gen unverifiedSmall=0


//_________________________________________SECTION#3: COUNTY FIPS & POLITICAL AFFILIATION MERGE _________________________________________________//

*Adding FIPS identification based on zip
	merge m:1 zip using ziptofips

*Dropping empty merge & non-US observations
	drop if responseid==""
	drop if country==2 | country==3
	drop _merge

*Adding presidential election info (party votes by county)
	merge m:m county_fips using densitypolit
	drop if responseid==""
	sort _merge
	

//_________________________________________SECTION#4: TYPES OF ONLINE VIEWING TRACKING (MULTIPLIERS,ETC) _________________________________________________//

*Handle unusual multipliers
	replace trackviewershowmultiplier="1.7" if trackviewershowmultiplier=="1.7 per viewer"
	replace trackviewershowmultiplier="2" if trackviewershowmultiplier=="x2" | trackviewershowmultiplier=="X2" | trackviewershowmultiplier=="two"
	replace trackviewershowmultiplier="2.5" if trackviewershowmultiplier=="Engagements x 2.5" | trackviewershowmultiplier=="Screens x 2.5"
	replace trackviewershowmultiplier="1" if trackviewershowmultiplier=="None"
	replace trackviewershowmultiplier="1" if trackviewershowmultiplier == "150-200 weekly" | trackviewershowmultiplier == "3800" | trackviewershowmultiplier == "300"
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowmultiplier,"simply record number of views. *")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowmultiplier,"Weig*")

*Handle "other" view methods
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Don't know*")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"I look at Facebook analytics and track viewers who engage for longer than 60 seconds.*")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Number of views greater than 1 or 3 minutes")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Numbers provided by Facebook")	
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Online connect card allows multiple viewers to be accounted for")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Online form to take attendance.")
	replace trackviewershowmultiplier="1.7" if strmatch(trackviewershowother,"Peak Live Views X 1.7*")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"Track online vs on-demand as separate metrics")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We actually count individuals connected")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We are a small church have an accurate accounting")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We ask for people to mark their attendance")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We count the number of people that watch when it broadcast")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We only track number of views")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We track total minutes of live message viewed / 45 minutes per HH to come up with a concervative measure of HH watching via Livestream. We also track unique views for YouTube channel.")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"We use number of views reported by FB and YouTube")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"don't use a multiplier*")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"number of comments and feedback from viewers")
	replace trackviewershowmultiplier="1" if strmatch(trackviewershowother,"number of views as shown weekly")


*Handle other watching methods (trackonlinehow)
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"30 minute views")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Engagements")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Google Analytics")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Households-Unique IP addresses")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"I don't know")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"I don't know.")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"I have no idea")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"I'm not totally sure.")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Ip addresses")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Maximum simultanious viewers")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Not sure")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Number of views plus an online guestbook to tell us how many viewers ")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Online Connection Card")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Online Engagement")
	replace trackviewershowmultiplier="2" if strmatch(trackonlinehowother,"*as follows: the amount of viewers watching YouTube during the live broadcast times and that is multiplied by 2.*")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Peak live viewers on FB")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Reach")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"Views and logged attendance via website")
	replace trackviewershowmultiplier="0.8" if strmatch(trackonlinehowother,"Views x .8")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"We ask viewers to comment their attendance")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"We communicate online and people identify themselves along with views.")
	
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"We use a combo of interactions and streaming report data ")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"We use the reporting feature of Zoom to track precisely who is logged in on Zoom. We also livestream through Facebook Live. We track the number of views, even though we don't know how long the video was viewed, and we ask people to leave a comment so that we know they worshiped with us.")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"comments/viewers")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"count views on FB and YouTube")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"ip addresses")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"sustained viewing only of unique viewers")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"we did it by phone")
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"we track in person attendance")

* Seems like this next one is using a multiplier but no way to tell what it is without asking them
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"viewer/engagement formula")
	replace flag=flag+"Multiplier may be off; " if loginid==3212710790
	
*Seems like this one may be counting minutes hard to tell from the description
	replace trackviewershowmultiplier="1" if strmatch(trackonlinehowother,"We track minutes consumed although we have all data captured and available.  We decided it was a fools bargain to try an equate online attendance to in-person attendance but with pre-registered in-person, we're able to do some interesting analysis on equating minutes into people.")
	replace flag=flag+"Multiplier may be off (although missing attendance data so doesn't really matter); " if loginid==1931762904

*Fixed error from Dr. Hill's code (Ryan)
	replace trackviewershowmultiplier="1" if trackviewershowmultiplier=="-99"
	destring trackviewershowmultiplier, replace

*Computing online numbers for different time periods based on different ways of tracking
	replace onlinejan2020=screensjan2020 if trackonlinehow==1 | trackonlinehow==3
	replace onlinejan2020=viewersjan2020/trackviewershowmultiplier if trackonlinehow==2
	replace onlinejan2020=onlinejan2020/trackviewershowmultiplier if trackonlinehow==4

	replace onlinejan2021=screensjan2021 if trackonlinehow==1 | trackonlinehow==3
	replace onlinejan2021=viewersjan2021/trackviewershowmultiplier if trackonlinehow==2
	replace onlinejan2021=onlinejan2021/trackviewershowmultiplier if trackonlinehow==4

	replace onlinemostrecent=screensmostrecent if trackonlinehow==1 | trackonlinehow==3
	replace onlinemostrecent=viewersmostrecent/trackviewershowmultiplier if trackonlinehow==2
	replace onlinemostrecent=onlinemostrecent/trackviewershowmultiplier if trackonlinehow==4


//_________________________________________SECTION#:5 RYAN'S SWEEP OF ONLINE & IN-PERSON ATTENDANCE _________________________________________________//
*RYAN'S CLEANING:

*Fixing some negative numbers (people said they estimated the number of viewers with a multiplier but didn't record any online attendence data, resulting in the -99s being divided by 2 and then impacting attendance data)
	tab onlinejan2020
	replace onlinejan2020= -99 if onlinejan2020<0 & onlinejan2020>-99
	tab onlinejan2020

	tab onlinejan2021
	replace onlinejan2021= -99 if onlinejan2021<0 & onlinejan2021>-99
	tab onlinejan2021

	tab onlinemostrecent
	replace onlinemostrecent= -99 if onlinemostrecent<0 & onlinemostrecent>-99
	tab onlinemostrecent

*Checking for any typos in reported attendance data (easier this way than doing eye test for every data point)
*The point of this exercise is to generate a value or ratio for how much the attendance varies for each church over the three time snapshots. The higher the ratio, the more the variance. I flagged all of the ones above 0.89, although some of them may be just fine.
preserve
	replace onlinejan2020=. if onlinejan2020== -99
	replace onlinejan2021=. if onlinejan2021== -99
	replace onlinemostrecent=. if onlinemostrecent== -99
	replace inpersonjan2020=. if inpersonjan2020== -99
	replace inpersonjan2021=. if inpersonjan2021== -99
	replace inpersonmostrecent=. if inpersonmostrecent== -99

	gen totalattendancejan2020=onlinejan2020+inpersonjan2020
	gen totalattendancejan2021=onlinejan2021+inpersonjan2021
	gen totalattendancemostrecent=onlinemostrecent+inpersonmostrecent
	gen attendancediff=((abs(totalattendancejan2020-totalattendancejan2021)+abs(totalattendancejan2020-totalattendancemostrecent)+abs(totalattendancejan2021-totalattendancemostrecent))/3)
	tab attendancediff
	sum attendancediff
	gen avgattendance=((totalattendancejan2020+totalattendancejan2021+totalattendancemostrecent)/3)
	gen attendanceratio=attendancediff/avgattendance
	tab attendanceratio
	sum attendanceratio
	histogram attendanceratio
	
*Maybe investigate drastic changes in attendance further to make sure they weren't typos (some are just megachurches that shifted online). Honestly though, it seems reasonable that a few churches had really drastic attendance changes during the pandemic. None of these seem like deliberate typos
	export delimited "attendancediff", replace
restore

*Flag suspicious entries (if attendanceratio>0.89) using file I just created. NOTE: some of these may not actually be wrong...I would expect there to be a few churches that have a big change in attendance during the pandemic. 
	replace flag=flag+"suspicious variation in attendance; " if loginid==4952626801
	replace flag=flag+"suspicious variation in attendance; " if loginid==1513955401
	replace flag=flag+"suspicious variation in attendance; " if loginid==8039939879
	replace flag=flag+"suspicious variation in attendance; " if loginid==1017681536
	replace flag=flag+"suspicious variation in attendance; " if loginid==2746175480
	replace flag=flag+"suspicious variation in attendance; " if loginid==3577265032
	replace flag=flag+"suspicious variation in attendance; " if loginid==5281416655
	replace flag=flag+"suspicious variation in attendance; " if loginid==9611610292
	replace flag=flag+"suspicious variation in attendance; " if loginid==5443313159
	replace flag=flag+"suspicious variation in attendance; " if loginid==4533734020
	replace flag=flag+"suspicious variation in attendance; " if loginid==3351272792

*Checking potential issues with # of services
	tab numservices

*ones to drop (based on ratio of attendance to numservices using eye test):
	replace flag=flag+"suspicious numservices; " if numservices>26 & numservices!=.
	replace flag=flag+"suspicious numservices; " if loginid==1063942572
	replace flag=flag+"suspicious numservices; " if loginid==6068997846
	replace flag=flag+"suspicious numservices; " if loginid==4783252749
	replace flag=flag+"suspicious numservices; " if loginid==9146673329
	replace flag=flag+"suspicious numservices; " if loginid==6925724888
	replace flag=flag+"suspicious numservices; " if loginid==4794961958
	replace flag=flag+"suspicious numservices; " if loginid==1498894439
*For the following church I checked their website, they have 2 services not 20, it must have been a typo
	replace numservices=2 if loginid==4387233961


*Churches to flag and maybe drop (that aren't real churches) (also some other random changes and notes)
	replace flag=flag+"not a Christian church (it's a 'new age spiritual center' or something); " if loginid==4031001069
	replace flag=flag+"Dr. Hill's sample; " if loginid==1047698506
	replace flag=flag+"Church in Germany; " if loginid==4220605590
	replace flag=flag+"its a ministry not a church; " if loginid==5346578815
	replace flag=flag+"Church in Mexico; " if loginid==4950754297
	replace flag=flag+"zip code should be 53146; " if loginid==5166998442
	replace flag=flag+"name should be Van Nest Assembly of God (not Can Nest); " if loginid==8007502691
	replace flag=flag+"not a church, no idea what this is; " if loginid==8628775416
	replace flag=flag+"not sure what/where this is (IFGF?), couldn't find it on google; " if loginid==6225679965
	replace flag=flag+"don't think this is a church; " if loginid==3648699035
	replace flag=flag+"this is a retirement home, not a church; " if loginid==3938655173
	replace flag=flag+"not a church; " if loginid==5663217349
	replace flag=flag+""church in nigeria; " if loginid==2597394048
	replace flag=flag+"catholic church!; " if loginid==7248275069
	replace flag=flag+"church name not written in a readable language; " if loginid==9893706952
	
*NOTE: We will have to decide which ones to drop eventually


//_________________________________________SECTION#:6 _________________________________________________//

*CHARTS AND GRAPHS
*Scatterplot Charts
preserve
keep inpersonjan2020 inpersonjan2021 inpersonmostrecent

drop if missing(inpersonjan2020)
drop if inpersonjan2020==-99
replace inpersonjan2021=. if inpersonjan2021==-99
replace inpersonmostrecent=. if inpersonmostrecent==-99
export delimited "inperson20210503", replace
restore

*bargraph charts
preserve
keep inpersonjan2020 inpersonjan2021 inpersonmostrecent online* trackonline email loginid
drop if missing(inpersonjan2020)
drop if inpersonjan2020==-99
replace inpersonjan2021=. if inpersonjan2021==-99
replace inpersonmostrecent=. if inpersonmostrecent==-99
replace onlinejan2020=. if onlinejan2020==-99
replace onlinejan2021=. if onlinejan2021==-99
replace onlinemostrecent=. if onlinemostrecent==-99

gen size=1 if inpersonjan2020<100
replace size=2 if inpersonjan2020>=100 & inpersonjan2020<1000
replace size=3 if inpersonjan2020>=1000
replace size=3 if loginid==5381936596
replace size=3 if loginid==2030355526

recode inpersonjan2020 onlinejan2020 inpersonjan2021 onlinejan2021 inpersonmostrecent onlinemostrecent (missing = 0) , prefix (missingzero_)
gen totaljan2020=missingzero_inpersonjan2020+missingzero_onlinejan2020
gen totaljan2021=missingzero_inpersonjan2021+missingzero_onlinejan2021
gen totalmostrecent=missingzero_inpersonmostrecent+missingzero_onlinemostrecent

*gen proportiononlinejan2020=onlinejan2020/inpersonjan2020
*gen proportiononlinejan2021=onlinejan2021/inpersonjan2021
*gen proportiononlinemostrecent=onlinemostrecent/inpersonmostrecent

gen dif=abs(inpersonjan2021-inpersonjan2020)


replace onlineservice=. if onlineservice==-99
replace trackonline=. if trackonline==-99

sort inpersonjan2020
collapse (count) loginid (sum) inperson* online* trackonline total*,by(size) 
gen shareonlinejan2021=onlinejan2021/onlinejan2020
gen shareonlinemostrecent=onlinemostrecent/onlinejan2020
gen shareinpersonjan2021=inpersonjan2021/inpersonjan2020
gen shareinpersonmostrecent=inpersonmostrecent/inpersonjan2020
gen sharetotal2021=totaljan2021/totaljan2020
gen sharetotalmostrecent=totalmostrecent/totaljan2020
gen proportiononlinejan2020=onlinejan2020/totaljan2020
gen proportiononlinejan2021=onlinejan2021/totaljan2021
gen proportiononlinemostrecent=onlinemostrecent/totalmostrecent
order size loginid onlineservices trackonline
export delimited "ratios20210503", replace
restore

*bargraph charts with totals
preserve
keep inpersonjan2020 inpersonjan2021 inpersonmostrecent online* trackonline email loginid
drop if missing(inpersonjan2020)
drop if inpersonjan2020==-99
replace inpersonjan2021=. if inpersonjan2021==-99
replace inpersonmostrecent=. if inpersonmostrecent==-99
replace onlinejan2020=. if onlinejan2020==-99
replace onlinejan2021=. if onlinejan2021==-99
replace onlinemostrecent=. if onlinemostrecent==-99

gen size=1 if inpersonjan2020<100
replace size=2 if inpersonjan2020>=100 & inpersonjan2020<1000
replace size=3 if inpersonjan2020>=1000
replace size=3 if loginid==5381936596
replace size=3 if loginid==2030355526

recode inpersonjan2020 onlinejan2020 inpersonjan2021 onlinejan2021 inpersonmostrecent onlinemostrecent (missing = 0) , prefix (missingzero_)
gen totaljan2020=missingzero_inpersonjan2020+missingzero_onlinejan2020
gen totaljan2021=missingzero_inpersonjan2021+missingzero_onlinejan2021
gen totalmostrecent=missingzero_inpersonmostrecent+missingzero_onlinemostrecent

replace onlineservice=. if onlineservice==-99
replace trackonline=. if trackonline==-99

*Only include those who either don't have online services or track online
*keep if trackonline==0 & size==2
keep if trackonline==1 | onlineservice==0
sort inpersonjan2020
collapse (count) loginid (sum) inperson* online* trackonline tota*,by(size) 
gen shareonlinejan2021=onlinejan2021/onlinejan2020
gen shareonlinemostrecent=onlinemostrecent/onlinejan2020
gen shareinpersonjan2021=inpersonjan2021/inpersonjan2020
gen shareinpersonmostrecent=inpersonmostrecent/inpersonjan2020
gen sharetotal2021=totaljan2021/totaljan2020
gen sharetotalmostrecent=totalmostrecent/totaljan2020
gen proportiononlinejan2020=onlinejan2020/totaljan2020
gen proportiononlinejan2021=onlinejan2021/totaljan2021
gen proportiononlinemostrecent=onlinemostrecent/totalmostrecent
order size loginid onlineservices trackonline
export delimited "ratiostrack20210503", replace
restore


*Financial charts
preserve
keep budgetgiving actualgiving email loginid inpersonjan2020 cares
replace inpersonjan2020=. if inpersonjan2020==-99
gen size=1 if inpersonjan2020<100
replace size=2 if inpersonjan2020>=100 & inpersonjan2020<1000
replace size=3 if inpersonjan2020>=1000
replace size=3 if loginid==5381936596
replace size=3 if loginid==2030355526
drop if budgetgiving==-99
drop if actualgiving==-99
*Giving ratio of 0.0008
drop if loginid==9678452034 
*Online only church and giving appears off by factor of 10, don't know how to correct
drop if loginid==5381936596
*Data is wrong, don't know how to correct
drop if loginid==6808953928
*Giving off by a factor of 10 or 100 move towards average giving
replace budgetgiving=budgetgiving/100 if loginid==8470224329
replace actualgiving=actualgiving*10 if loginid==9146673329
replace budgetgiving=budgetgiving*10 if loginid==5051158751

drop if missing(budgetgiving)
gen givingPerCapita=budgetgiving/inpersonjan2020
sort givingPerCapita
gen givingratiobyChurch=actualgiving/budgetgiving
gen up=1 if actualgiving>=budgetgiving
gen down=1 if actualgiving<budgetgiving
collapse (sum) budgetgiving actualgiving up down (mean) givingratiobyChurch (count) loginid, by(size cares)
gen givingratio=actualgiving/budgetgiving
export delimited "budget20210503", replace
restore


*bargraph charts COVID activities
preserve
keep inpersonjan2020 inpersonjan2021 inpersonmostrecent online* trackonline email loginid covidactions*
drop if missing(inpersonjan2020)
drop if inpersonjan2020==-99
replace inpersonjan2021=. if inpersonjan2021==-99
replace inpersonmostrecent=. if inpersonmostrecent==-99
replace onlinejan2020=. if onlinejan2020==-99
replace onlinejan2021=. if onlinejan2021==-99
replace onlinemostrecent=. if onlinemostrecent==-99

gen size=1 if inpersonjan2020<100
replace size=2 if inpersonjan2020>=100 & inpersonjan2020<1000
replace size=3 if inpersonjan2020>=1000
replace size=3 if loginid==5381936596
replace size=3 if loginid==2030355526

recode inpersonjan2020 onlinejan2020 inpersonjan2021 onlinejan2021 inpersonmostrecent onlinemostrecent (missing = 0) , prefix (missingzero_)
gen totaljan2020=missingzero_inpersonjan2020+missingzero_onlinejan2020
gen totaljan2021=missingzero_inpersonjan2021+missingzero_onlinejan2021
gen totalmostrecent=missingzero_inpersonmostrecent+missingzero_onlinemostrecent

*gen proportiononlinejan2020=onlinejan2020/inpersonjan2020
*gen proportiononlinejan2021=onlinejan2021/inpersonjan2021
*gen proportiononlinemostrecent=onlinemostrecent/inpersonmostrecent

gen dif=abs(inpersonjan2021-inpersonjan2020)


replace onlineservice=. if onlineservice==-99
replace trackonline=. if trackonline==-99

sort inpersonjan2020
collapse (count) loginid (sum) inperson* online* trackonline total*,by(covidactionsmasksreq) 
gen shareonlinejan2021=onlinejan2021/onlinejan2020
gen shareonlinemostrecent=onlinemostrecent/onlinejan2020
gen shareinpersonjan2021=inpersonjan2021/inpersonjan2020
gen shareinpersonmostrecent=inpersonmostrecent/inpersonjan2020
gen sharetotal2021=totaljan2021/totaljan2020
gen sharetotalmostrecent=totalmostrecent/totaljan2020
gen proportiononlinejan2020=onlinejan2020/totaljan2020
gen proportiononlinejan2021=onlinejan2021/totaljan2021
gen proportiononlinemostrecent=onlinemostrecent/totalmostrecent
order covidactionsmasksreq loginid onlineservices trackonline
export delimited "ratiosCOVID20210503", replace
restore

*Employment
preserve
keep paidstaffjan2020 paidstaffcurrent email loginid inpersonjan2020
replace inpersonjan2020=. if inpersonjan2020==-99
gen size=1 if inpersonjan2020<100
replace size=2 if inpersonjan2020>=100 & inpersonjan2020<1000
replace size=3 if inpersonjan2020>=1000
replace size=3 if loginid==5381936596
replace size=3 if loginid==2030355526

replace paidstaffjan2020="0" if strmatch(paidstaffjan2020,"nil")
replace paidstaffjan2020="0.5" if strmatch(paidstaffjan2020,"2-Jan")
destring paidstaffjan2020, replace force
sort paidstaffjan2020
drop if paidstaffjan2020>500

drop if paidstaffjan2020==-99
drop if missing(paidstaffjan2020)
drop if paidstaffcurrent==-99

gen up=1 if paidstaffcurrent>paidstaffjan2020
gen down=1 if paidstaffcurrent<paidstaffjan2020
gen equal=1 if paidstaffcurrent==paidstaffjan2020

collapse (sum) paidstaffcurrent paidstaffjan2020 up down equal (count) loginid, by(size)
gen staffratio=paidstaffcurrent/paidstaffjan2020 
export delimited "staff20210503", replace
restore
