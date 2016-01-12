LKB v24.07.15

This is Inertial Explorer WORKFLOW manual. Make sure that you read Problem.log for all problems/solutions. Reading Inertial Explorer manual is very useful as well. 8.5 Manual is referenced as ->UMxx where xx is page number

1) COLLECT DATA

* Standard NGI van setup include POSRS as a main sensor and SPAN as a check. Both should be connected to same antenna. As a check I recommend to include additional GNSS receiver, connected to different antenna then POSRS/SPAN.
* POSRS/SPAN GNSS receivers are set to 1Hz, additional receiver should be set to higher frequency, if possible.
* I recommend at least 10-15min static at the beginning and end of the data collection. Ideally this should be in clean GNSS environment. Otherwise extend static period accordingly.
* POSRS is VERY sensitive to power. Make sure that batteries are charged before and as-rule of thumb, 3 batteries run for about 5hrs.


###When starting SPAN will have a specific light sequence:

EVENT | SD_ligtht | GPS1_ligtht | GPS2_light | INS_light | IMU_light | note
:--:  |  :--:  |  :--:  |  :--:  |  :--:  |  :--:  |  :--:
receiver start | all flashes red | flashing green | orange | orange | red | IMU_light -- 1s red then none
GPS got fix | flashing green | green | red* | red | none |
IMU working | flashing green | green | red* | red | green |
IMU aligned | flashing green | green | red* | green | green | will only happen after movement is applied

		: *if two antennas are connected this light sequence will follow GPS1_light one


###POSSIBLE PROBLEMS AND SOLUTIONS

* if GPS light stays orange check GPS connection
* if SD_ligtht is not flashing press logging button (next to SD card slot)
* if SD_ligtht is red, check SD card
* if IMU_light is off:
	* wait until GPS1_light turn green, IMU_light should turn green soon after
	* if not, check all connections

###SPAN POWER CONNECTION
I assume that power is provided via "brick" using Black & Red pins.

* For IMU connect
	* green (ground) + black to brick Black
	* red to brick Red
* For Receiver connect
	* green (ground) + black (ground) to brick Black
	* red (-Vin) + white (+Vin) to brick Red

###PTDL (Microstrain), Footracker:

	* working system should blink
	* SD_light	GPS_light	3G_light
	* bink	blink	blink
	* Microstrain unit light should blink slow and then fast -> this is when data is being recorded.


2) Convert DATA

*** SPAN data extraction
	Inertial Explorer
		File->Convert->Raw GNSS data to Waypoint generic
			select folder with SPAN *.log files
			Auto Add All
				Program will recognise file format as NovAtel OEM4/OEV/OEM6
			Press Convert
				new window show processing information for both GNSS and IMU data
					Message Options->check Automatically log messages to file to save logfile
			output file are *.epp *.gpb (GNSS) *.imr (IMU). If any file is missing data was not properly recorded. Log file should be about 50MB/h


*** POSRS data extraction
	Use POSPac to extract IMU and GPS data
		Extract->Extract POS data
			POS Data File Name => input first file name (eq. NT240114_001_aaa.000)
			Pos Data extraction time=>All data
			Output=>Selected Group ; Select=>IMU, Primary GPS, Secondary GPS
		Press RUN

	Inertial Explorer
		File->"Convert raw IMU data to Waypoint generic" to convert imu_{output_kernel}.dat
			Use POSRS profile (see .\ChrisNotes\cimu02.PNG)
			One I created is called POSRS
		File->Convert->Raw GNSS data to Waypoint generic
			convert mgps_{output_kernel}.nov
			Program will recognise file format as NovAtel OEM4/OEV/OEM6


*** Microstrain data extraction
	Run extractMicrostrain.bat
	cut bad records from txt file
		cat LOG010_IMU.TXT | awk -F " " "{i=1; if ($i >100.0) {print $0} }" > IMU.txt
	convert LOG0xx_IMU.TXT into bin using microstrainToBinary.m


***LEICA format conversion
	Inertial Explorer
		File->Convert->Raw GNSS data to Waypoint generic
			select folder with Leica *.m00 files
			Auto Add All
				Program will recognise file format as Leica System 1200
			Press Convert
				new window show processing information
			In case of any problems convert data to RINEX using teqc or going via LGO and then use File->Convert->Raw GNSS data to Waypoint generic
			Merge files to single one using File->GPB Utilities->Concatenate, Splice and Resample
				this will change station information if processed from *.m00! Make sure that proper coordinates are entered.

3) Check if L2C Phase is correct for all data
	View->Raw GNSS data
		select *.GPB data
		Edit->L2 Phase Correction
			check L2C Phase correction enabled
			values below should be:
				Novatel +.25 cy (confirmed by Marcus)
				all Leica +.25 cy (this agree with Chris Hide and Leica support but IE by default use -0.25!!!!)
				Leica RINEX +0.25 cy (tested on one RINEX file processed by LGO8.3)
				Javad ??
				Trimble ??
			File->Close (do not use File->Save As)
		Conduct it for each raw file. Those setting should be correct for Novatel


5) Create a New project in Inertial Explorer
	File->New Project->Project Wizard
		navigate to project folder and name processing accordingly (SPAN, POSRS, MicroStrain ect)
		select GNSS & IMU file
		ant ht meas: 0m (see notes below) use antenna profile if possible (need to verify but should help)
		measure to ARP (??)

		I would like add Base Station Data
			Don't check any options
		Add Station From File
			Note that for converted files (unless RINEX was used) coordinates for Base will be likely wrong as IE estimated them using averaged observations.
			select base station GNSS data and make sure that NGB2 settings are
			ant ht meas: 0.502m LEIAR25.R4 uncheck all options, measured to ARP
			52° 57' 06.95636" N 1° 11' 02.39879" W 91.2006m
		NEXT, NEXT, Finish, Finish

NOTES SECTION
	IE use a very strange naming convention for the height. Ant height will only be applied to export, Arms need to INCLUDE antenna height. Other words to match GPS and IMU one need to: GPS (add_ht), Arms (add_ht), Export (no_ht!). This is VERY CONFUSING so, following CH I suggest:
			GPS_Rover (ht=0), Arms (add_ht), Export (add_ht)


6) Process GPS
Processing GNSS will generate *.cmb file (combined GPS file), which is used in next step (those values are estimated at antenna, without applying ht!)

	GNSS WORKFLOW
	It is vital that all stations are in the same datum. In IE processing Datum is the same as Master. You cant change one without the other, neither can you have one station in different datum, so its vital to make sure that all coordinates are correct. Nevertheless SV coordinates has to be converted to current datum during KF processing. Therefore it is important to properly set processing datum in IE!!! For more details see GNSS.log
	Practical example show that actual effect on position between ITRF89 & WGS84 is below 4mm.
	Make sure that measured to ARP is selected for both master and rover.


	1) Check if you have proper data by plotting File Data Coverage and base on distance to base station decide on single/multibaseline solution

	2) Check observations
		Check frequency of base/rover (POSRS data is 2Hz). IE8.5 will automatically up-sample base data if rover obs freq is different! Be careful.
		To minimalist file sizes use View->GNSS Observation->Master{..}->Resample/Fill gaps, using-> Remote Time Interval
			all data outside of remote time will be removed
		To check L2C offset use View->GNSS Observations->{Master/Rover}->View Raw GNSS data.

	2) Download precise orbits&clocks if available. GPS/GLONASS precise orbits/clocks latency is 12-18 days, GPS rapid orbits/clocks about one day.
		File->Add precise Files
			Set proper time and date, uncheck GLONASS and press Download for GPS data
			Set proper time and date, check GLONASS and press Download for GLONASS data (some files will be overwritten)
			If you have existing files click Add and browse of those files (see notes below)
			Press OK to exit window
		In View->Project Overview you should be able to see all the files you added

	3) Process all data
	To process single baseline GNSS go to Process->Process GNSS
			Processing Method	Differential GNSS
			Processing Direction->Both
			Profile	GNSS Ground Vehicle
			Add description/User name

	To process multi base GNSS data add all bases before going to Process->Process GNSS
		Processing Method	Differential GNSS
		Processing Direction->Both
		Profile	GNSS Ground Vehicle
		go to Advanced.. and limit baseline to 30km for better results (EKF will use all BS otherwise)
		Add description/User name
		In IE8.50 software will automatically use most convenient selection of all BS data. Just process data as usual. To check Local Level Vector (pay attention to height component!!) and Distance Separation. You cant use Distance Separation plot. Use Export->Plot Multi-Base instead

		NOTE!!!
		 For VS leaving baseline limit at standard 70km makes no difference and it seems that VS is slightly more precise for those baselines. If you keep 30km limit both results show same precision. The larger the limit the longer it takes to process data. Maximum baselines you can process at one time is 8.
		To save results to HTML, plot my normal group plots, then Plot Multi-Base and then use Output->Build HTML Report.

	5) Define static sessions and check Static Session Convergence plot.
		use File->GPB Utility->Insert Static/Kinematic Markers
			ht value here is not important. Its only for static file.
		check NavNet850 p32 for details, file line ex
				NGB_Yard 201200.0 203505.0 Preparation

		NOTE!!!
		To get static periods
		* do Velocity Profile graph and stats for the static period
		* CtrC
		* getclip | grep -A 1 Start: | tr -s "\t" "," | tr "\n" "," | cut -d, -f2,7 | awk -F "," "{printf \"NGB_Yard %.1f %.1f Period%.1f\n\",$1,$2,$2-$1}" >> static.txt

	4) Analyse results
		Check following plots: Combined Separation, Combined Separation(Fix), Quality factor, Float/Fixed Ambiguity Status, RMS -  Carrier Phase. In case of Multi-baseline solution last plot is wrong, use MB plot instead.
		To estimate data gaps in the GNSS file use python FindDataGaps.py -l xx.xx
		To compare View->Processing summary:
			grep "Missing Fwd or Rev" -A3 *.sum
			grep RMS -A3 *.sum
		Also plot data on Google Earth (GE) to check any outages observed. Especially useful is Show elevation profile (right click on Epochs)

	6) Prepare best possible GNSS dataset taking into consideration length of datagaps, quality of data ect.
		Try to prepare raw data so it can be reprocessed
		If not possible (time, datagaps ect) edit *.cmb by hand
		To use only specific QN data use...
	7) Rename *.cmb and use it for remaining processing
	8*) If u are running QC solution on other antenna, apply all the above settings (especially static data) and run it. Most of the time is best to limit QN to 1,2 for comparison with POSRS.

	Best working practice is to have a full GPS trajectory in one file, even if there are multiple IMU sessions

NOTES SECTION
	Make sure that IE is not applying any datum conversion!!!
	If you ever close map, use Output->Show Map window

	The more advanced option for precise orbits/clocks is	Tools->Download Service Data
		Set proper time and date
			Output data interval	Leave "as is"
			Most of the time there no need to download station data so you can ignore Add from List and Add Closest
			In Options select Precise ephemeris and clock files for GPS and check all items from Other files
		Click download
			Once all is downloaded the Stop button will change to Close. Press Close
		In Options select Precise ephemeris and clock files for GLONASS and all other files
		Click download
			Once all is downloaded the Stop button will change to Close. Press Close
		Press Close to close window
		File->Add precise Files
			click Add and browse of those files
	NOTE!!! Most of the time is better to use File->Add precise Files !!!



7) Process LC
	Decide on trajectory, most of the time it should be Update data: GNSS combined but sometimes you should use External trajectory (*.cmb file, see prev step). For source GNSS data try to use only QN1-4 (position acc < 1.0). Note that settings here should match that for GNSS processing and given Van/Train level arms are to ARP!

	Rule of thumb acc with gaps (those value are approximate only)
		POSRS	0.16m at 100s, 1.2m at 300
		SPAN	0.6m at 100s, 2.8m at 300 (estimated at double difference)
		see tables in the student handout for more up-to-date data.

	To determine which processing option to use plot File Data Coverage and Velocity profile  ->UM14
	make sure that values are correct. Check orientation of axis, values (c, gravity etc), level arm --> values AFTER the rotation.
	once happy Process->Process LC
		SPAN
			Profile: SPAN Ground (LCI)
			use lever arms indicated as SPAN_*
			MAKE SURE to select Z to ARP if antenna profile is used!
				NOTE: lever arms are estimated to point, not to ARP if antenna corrections was applied for Remote!
			Body2IMU Rotation: 0,0,90
		POSRS
			Profile: SPAN Airborne (uIRS)
			use lever arms indicated as POSRS_*
				MAKE SURE to select Z to ARP if antenna profile is used!
				NOTE: lever arms are estimated to point, not to ARP if antenna corrections was applied for Remote!
			Body2IMU Rotation: 180,0,90
			also check .\ChrisNotes\cimu01.PNG
		Microstrain
			Profile: SPAN Ground (ADIS16488)
				in advanced select: Automotive (Low Precision)
			use lever arms indicated as POSRS_* !!! depends on how it was mounted!!
			Body2IMU Rotation: 180,0,90 !!! depends on how it was mounted!!


	check results
	Plot Attitude separation to check IMU initialisation. To check final position, and quality of LC results plot Combined Separation, Combined Separation (fix) and IMU/GPS position misclosure.
	Heading (orientation of axis) can be checked by plotting Heading minus COG and Attitude(Azimuth/Heading).
		Check times where van is kinematic (ideally large acc changes->Acc profile plot and GPS is good match with IMU->Position Misclosure Plot (match should be perfect) and then one where IMU/GPS match is poor - there should be out-layers but apart from that, good fit)
	To check lever arm use Process->Process LC
		go to Advanced...=>States
			check "Solve lever arm values as add KF states"
		Plot results => IMU/IMU-GPS Level Arm and compare results. This will show both level arms and axis!

POSRS WORKFLOW
	A) Run all automatic.
		There might be small separation between pitch and roll (up to 10 arc-min), aligned with large jumps in heading at the beginning and the end (up to 50 arc-min). This tend to indicate weak starting (and finishing) angle estimate. Everything else should be smooth (within few arc-min).
	B) Try to run Static Coarse+Fine alignment. Compare results with automatic.
		settings (UM16) Coarse: 60-100s, Fine 100-200s
		If you know any static periods in between you can add them using Advanced...=>Updates User Entered Zero Velocity but most of the time IE can detect those automatically
		Results should be under few arc-min, there should be no separation between pitch and roll. There will be large jumps in heading at the beginning and end (up to 20 arc-min)
	C) Transfer alignment rev 2 forward and fwd 2 revers. Make sure that Std Dev is x10 estimated. Then select the same in Enter Position and Velocity
		Results should be within 10-20 arc-sec, there should be no separation between pitch and roll.
		If results are higher (few arc-min) heading should be largest in the middle and no jumps at the beginning/end. Data is not so smooth then.
		If all agrees cut processing to 40-70s of static from each side
	D) Process data using only GNSS qn1-2 (or if large gaps 1-4) against data obtained in C). Its paramount to use TA from C) as final determination can be more precise than one obtained it this step.

SPAN WORKFLOW
	A) Run all automatic.
	B) Try to run Static Coarse+Fine alignment. Compare results with automatic.
		settings (UM16) Coarse: 120s, Fine 480s
		There might be small separation between pitch and roll (up to 10 arc-min), aligned with large jumps in heading at the beginning and the end (up to 100 arc-min). This tend to indicate weak starting (and finishing) angle estimate. Everything else should be smooth (within few arc-min).
	C) Transfer alignment from POSRS. Accuracy should be within 10-20 arc-min. Keep StdDev estimation.
	D*) If you dont have POSRS transfer alignment rev 2 forward and fwd 2 reverse. Make sure that Std Dev is x10 estimated. Compare results.

Microstrain WORKFLOW
	A) Transfer alignment from POSRS
	B)

	PROBLEMS:
		sinusoidal behaviour of Az. Error model is wrong.

*7) Process TC & Combine Solutions
	TC does not seems to give better results all the time and prone to user errors. Ignore if possible and progress to next step.
	Combine solution will mix two solutions. Only useful in very specific scenarios. Ignore if possible and progress to next step.

8) Combine solution
	Combines GNSS and IMU solution. Required before output can be produced.

*9) Smooth solution (Process->Smooth Solution)
	Be careful to use it. Its not recommended and can hide bad result.


10) PROCESS IMU DATA ON ITS OWN
	Process->Process LC
		check "Process IMU Data Only"
		make sure that all settings are correct (as per step 7)
		in Advanced make sure that Fwd/Rev Alignment is set. Ideally by Transfer Mode.



11) Send data to client
	Output->Export Wizard
	remember to apply proper level arm	see Problem.log
	NOTE: lever arms are calculated to ARP so if you done both GPS and LC processing to ARP you should use exactly the use same lever arms as for IMU (step 7).
	Otherwise, if you didn't process LC to ARP you might need to add L1/L2 height offset in order to get height matching GNSS results from IE.
	OS coordinates output is wrong by up to 100m. Do not use!

CHECKS:
	1. Prepare RTK (qn1) GNSS solution only and check it against IMU solution. Make sure you transfer alignment from complete solution as this will be most precise. Export with the same arms as for IMU calculation, SUBSTRACT any L1/L2 height offsets. It should agree to a few cm (mm on train). (use my CompareDataSets.bat)
	2. If you have antenna on another mount, calculate its RTK (qn1) GNSS solution only and check it against IMU solution, with arm estimated to this mount (icl L1 offset). It should agree to a few cm in clean environment.
	2. Check between different IMU solutions if using more then one sensor. SPAN/POSRS should agree to approx cm. (use my CompareDataSets.bat)
	3. Save and check all the plots listed in this walk trough. You should have at least two set of plots (testing and final) for each sensor!  (use my PrepareIEOutput.bat)
	4. Export to GE and check the trajectory against the background (sanity check). See ge.log
	5. Check GPS data outages (by exporting gps data and using FindDataGaps.py) and check IMU performance in those gaps
	I tend to create one GNSS file for IMU antenna and QN12 for opposite antenna solution. I will check sensor against its antenna for blunders and determine time of large outages which then need to be checked on GE. I will check sensor against opposite antenna (another mount) for proper QC.
	If you compare POSRS vs SPAN make sure that they got INDEPENDENT initialisation!!
	6. Check LC against GNSS only solution. Any visible offsets should be in height only (wrong ARP) which should be equal to antenna L1/L2 height offset.

LKB.2012-2014
TODO:
	step 7
	GPS and INS time offset recorded in IMR file header can be checked in *.fil. To apply go to Advanced, User Cmds and use TIME_OFFSET (check manual and check if this works!!!)
	clock offset For POSRS 0.00700 s (from header, check)
		David's estimate(!!) SPAN attitude latency is 2.5ms (0.0025s).  Thios might be wrong.
		Microstrain latency is 0.015s.






