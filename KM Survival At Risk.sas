/***************************************************************/
/*						TIMI STUDY GROUP					   */
/***************************************************************/
/*Program: 	  KM Survival At Risk.sas						   */
/*Programmer: Erica Goodrich								   */
/*Date:	 	  11/9/2015										   */
/*Notes: 	  This program needs to be fed information 		   */
/*			  prior to using through the %let prompts at the   */
/*			  beginning and the  macro statement at the end.   */
/*Updates:	  11/18/2015 - Created output to be bolder, added  */
/*			  additional macro prompts to account for up to	   */
/*			  8 levels and create RTF or PDF output            */
/*			  automatically. Groups larger than 4 may need 	   */
/*			  additional coding for sizing in future update	   */
/*			  1/21/2016 - Adjusted y-label placement with long */
/*			  axis levels.									   */
/*			  2/5/2016 -  SAS 9.4 changes made effect the emf  */
/*			  file output. Please run commented code once on   */
/*			  any computers using 9.4.						   */
/***************************************************************/

/*Uncomment and run code below one time per SAS update. Not needed for every run as it saves to registry*/
/*%let workdir=%trim(%sysfunc(pathname(work)));*/
/*data _null_;*/
/*   file "&workdir./emf94.sasxreg";*/
/*   put '[CORE\PRINTING\PRINTERS\EMF\ADVANCED]';*/
/*   put '"Description"="Enhanced Metafile Format"';*/
/*   put '"Metafile Type"="EMF"';*/
/*   put '"Vector Alpha"=int:0';*/
/*   put '"Image 32"=int:1';*/
/*run;*/
/*proc registry import="&workdir./emf94.sasxreg";*/
/*run;*/

/*Note: For this program to be stand alone, these prompts need to be changed before hand*/
/*or addressed in the program they are using it in*/
%let rundate=%SYSFUNC(today(),yymmddn8.);

/*Enter folder path for output*/
%let output = 

/*Create RTF? If so, enter YES. If not, leave blank or enter NO.*/
%let create_RTF = ;

/*Create PDF? If so, enter YES. If not, leave blank or enter NO.*/
%let create_PDF = ;

/*Insert how many levels you have for stratification factors. Insert as a number 2-8*/
%let strata_lvl_count = ;

/*Enter each group of strata class values.*/ 
/*Note:  Only coded to handle up to 8 groups*/

%let strata1_class_lvl_nm = ;
%let strata2_class_lvl_nm = ;
%let strata3_class_lvl_nm = ;
%let strata4_class_lvl_nm = ;
%let strata5_class_lvl_nm = ;
%let strata6_class_lvl_nm = ;
%let strata7_class_lvl_nm = ;
%let strata8_class_lvl_nm = ;

/*Enter each group of strata names. Note: Only coded to handle up to 8 groups*/
%let strata1_class_label = ;
%let strata2_class_label = ;
%let strata3_class_label = ;
%let strata4_class_label = ;
%let strata5_class_label = ;
%let strata6_class_label = ;
%let strata7_class_label = ;
%let strata8_class_label = ;

/*Enter each color designated for each strata for graph. See color list at:*/
/*http://support.sas.com/publishing/authors/extras/62007_Appendix.pdf*/
%let strata1_color = red;
%let strata2_color = blue;
%let strata3_color = green;
%let strata4_color = orange;
%let strata5_color = purple;
%let strata6_color = pink;
%let strata7_color = brown;
%let strata8_color = gray;

/*List of line patterns to be used. 1 = Solid. See list at: */
/*https://support.sas.com/documentation/cdl/en/grstatproc/65235/HTML/default/viewer.htm#p0j7656q8p61utn1s3jihzencnf2.htm*/
%let strata1_pattern = 1;
%let strata2_pattern = 1;
%let strata3_pattern = 1;
%let strata4_pattern = 1;
%let strata5_pattern = 1;
%let strata6_pattern = 1;
%let strata7_pattern = 1;
%let strata8_pattern = 1;

/*Do you want the curves to have labels? (Defaulted to Failure %)*/
%let use_curve_label = YES;
/*Do you want a reference line? If so, enter YES. If not, leave blank or enter NO.*/
%let use_ref_line = NO; 


/*The next options are for a reference line only*/

%let ref_axis = ; *set for x or y axis for reference line;
%let ref_point = ; *set area where reference line should be drawn;
%let ref_text = ; *Set text to be displayed alongside reference line;


options symbolgen mlogic mprint orientation=landscape nonumber nofmterr nodate noquotelenmax;
ods escapechar = "#";

/*----------------------------------------------------------------------
Insert dataset and any necessary data here
------------------------------------------------------------------------*/

/*----------------------------------------------------------------------
End data insert here
------------------------------------------------------------------------*/

/***************************************************************/
/*KM Graph Macro - See below for prompt information 		   */
/***************************************************************/



/*----------------------------------------------------------------------
End data insert here
------------------------------------------------------------------------*/

/***************************************************************/
/*KM Graph Macro - See below for prompt information 		   */
/***************************************************************/


%macro KM_Graph(data, time, censor, censor_val, strata, atrisk_range, max_time,
				tick_list, g_title1, g_title2, g_footnote, max_y, x_axis_label, 
				y_axis_label, x_tick_list_ns, y_tick_list_ns, y_max, output_name);

proc format;
	value $stratf 	"&strata1_class_lvl_nm." = "&strata1_class_label."
		%if %sysevalf(&strata_lvl_count. GE 2) %then %do;
					"&strata2_class_lvl_nm." = "&strata2_class_label."
		%if %sysevalf(&strata_lvl_count. GE 3) %then %do;
					"&strata3_class_lvl_nm." = "&strata3_class_label."
		%if %sysevalf(&strata_lvl_count. GE 4) %then %do;
					"&strata4_class_lvl_nm." = "&strata4_class_label."
		%if %sysevalf(&strata_lvl_count. GE 5) %then %do;
					"&strata5_class_lvl_nm." = "&strata5_class_label."
		%if %sysevalf(&strata_lvl_count. GE 6) %then %do;
					"&strata6_class_lvl_nm." = "&strata6_class_label."
		%if %sysevalf(&strata_lvl_count. GE 7) %then %do;
					"&strata7_class_lvl_nm." = "&strata7_class_label."
		%if %sysevalf(&strata_lvl_count. = 8) %then %do;
					"&strata8_class_lvl_nm." = "&strata8_class_label."
	%end;%end;%end;%end;%end;%end;%end;;
run;

	data kmdata;
	set &data.;
		timevar = &time.;
		censorvar = &censor.;
		label timevar = "&x_axis_label.";
	run;

	/*Produce the survival plot and output the survival data from the LIFETEST procedure*/
	ods graphics on;
	ods output Failureplot	= failureplot 
			   HomTests 	= homtests;
	/*ods select failureplot(persist);*/

	proc lifetest data = kmdata plots = survival(failure test atrisk = &atrisk_range.);
		time timevar * censorvar(&censor_val.);
		strata &strata.;
	run;

	proc lifetest data = kmdata method = km timelist = &max_time. plots=none;
		time timevar * censorvar(&censor_val.);
		strata &strata./test=(logrank wilcoxon lr);
		ods output productlimitestimates=kmout;
	run;

	/*Creates output needed for KM curve labels*/
	data kmout1 (drop = Stratum rename = (stratum_char = Stratum));
	set kmout;
		curve_label = strip(trim(put(failure*100,5.2)))||"%";
		stratum_char = strip(trim(put(&strata., best8.)));
	run;

	/***************************************************************/
	/*	 Produce the survival plot using SGPLOT 				   */
	/***************************************************************/
	/* Save the p-value from the Logrank test to a macro variable- note: this isn't incorporated*/
	data _NULL_;
	set homtests;
		if test = "Log-Rank" then call symput ("LR_PVal",put(ProbChiSq, 5.3));
	run;

	/* Removes duplicates in the Failure dataset*/
	proc sort data = failureplot out = failureplot2 nodup;
	by time survival atrisk event censored tatrisk stratum stratumnum _1_survival_ _1_censored_;
	run;

	data failureplot3;
	set failureplot2;
		if tatrisk in (&tick_list.) then ticks = tatrisk;
		if _1_survival_ ne . then plot_surv = _1_survival_;
		else if _1_censored_ ne . then plot_surv = _1_censored_;
			format plot_surv percent8.4;
	run;


	proc sort data=kmout1;
		by stratum;
	run;

	proc sort data=failureplot3;
		by stratum;
	run;

	data failureplot4;
	merge failureplot3 kmout1;
		by Stratum;
	run;

	data failureplot5;
	set failureplot4;
		where time LE &max_time.;
	run;

	proc sort data=failureplot5;
	by stratumnum;
	run;

	/*Template for axis line thickness/color/options*/
	proc template;
		define style styles.mystyle; 
		parent=styles.HTMLBlue;
		style GraphAxisLines from GraphAxisLines /
		      linethickness = 3px 
			  contrastcolor=black;
		end;
	run;

	/* Template for Graph*/
	proc template;
	  define statgraph survivalplotatrisk_outside_scatter;
	    begingraph;
		/* First Title*/
	      entrytitle "&g_title1." /textattrs=(size=14);
		/* Option: Second Title*/
		  entrytitle  "&g_title2." / textattrs=(size=12);
		  entryfootnote halign=right "&g_footnote."/ textattrs=(size=12); ;
		discreteattrmap name = "lineattr" / ignorecase = true;
			 value "&strata1_class_label." / lineattrs = (pattern = &strata1_pattern. color = &strata1_color.)
			 markerattrs =(color = &strata1_color. symbol = circle);
		%if %sysevalf(&strata_lvl_count. GE 2) %then %do;
			 value "&strata2_class_label." / lineattrs = (pattern = &strata2_pattern. color = &strata2_color.)
			 markerattrs =(color = &strata2_color. symbol = square);
		%if %sysevalf(&strata_lvl_count. GE 3) %then %do;
			 value "&strata3_class_label." / lineattrs = (pattern=&strata3_pattern. color = &strata3_color.)
			 markerattrs =(color = &strata3_color. symbol = diamond);
		%if %sysevalf(&strata_lvl_count. GE 4) %then %do;
			 value "&strata4_class_label."/ lineattrs = (pattern=&strata4_pattern. color = &strata4_color.)
			 markerattrs =(color = &strata4_color. symbol = circlefilled);
		%if %sysevalf(&strata_lvl_count. GE 5) %then %do;
			 value "&strata5_class_label."/ lineattrs = (pattern=&strata5_pattern. color = &strata5_color.)
			 markerattrs =(color = &strata5_color. symbol = diamondfilled);
		%if %sysevalf(&strata_lvl_count. GE 6) %then %do;
			 value "&strata6_class_label."/ lineattrs = (pattern=&strata6_pattern. color = &strata6_color.)
			 markerattrs =(color = &strata6_color. symbol = squarefilled);
		%if %sysevalf(&strata_lvl_count. GE 7) %then %do;
			 value "&strata7_class_label."/ lineattrs = (pattern=&strata7_pattern. color = &strata7_color.)
			 markerattrs =(color = &strata7_color. symbol = diamondfilled);
		%if %sysevalf(&strata_lvl_count. = 8) %then %do;
			 value "&strata8_class_label."/ lineattrs = (pattern=&strata8_pattern. color = &strata8_color.)
			 markerattrs =(color = &strata8_color. symbol = squarefilled);
		%end; %end; %end; %end; %end; %end; %end;
		enddiscreteattrmap;

		discreteattrvar attrvar = groupmarkers var = stratum attrmap="lineattr"; 

		  /* Allows for multiple graphs rows*/
	      layout lattice / columns = 1 
						  rowweights = %if %sysevalf(&strata_lvl_count. = 2) %then %do;
										   (0.85 0.15)
									   %end;
									   %if %sysevalf(&strata_lvl_count. NE 2) %then %do;
										   (0.83 0.17) 
									   %end;
						   rowgutter = 5;
			/*X and Y axis options for KM GRAPH*/
	      	layout overlay /xaxisopts = (
										offsetmin = 0 
										label = "&x_axis_label."
										labelattrs=(
													size=12
													)
/*										display = (label tickvalues line)*/
										linearopts = (
													tickvaluelist = (&x_tick_list_ns.)
													)
										tickvalueattrs=(size=12)
										) 
						    walldisplay = none
							border = false
							yaxisopts = (
										label = "  "
										linearopts = (
														viewmin = 0 
														viewmax = &max_y.
														tickvaluelist = (&y_tick_list_ns.)
													  )
/*										display = (label tickvalues line)*/
										labelattrs=(
													size=12
													)
										tickvalueattrs=(size=12)
										/*griddisplay=on*/
										);
				/*--Draw the Y axis label closer to the axis--*/
				drawtext textattrs=(size=12) "&y_axis_label." / x=-8 y=50 anchor=bottom 
				xspace=wallpercent yspace=wallpercent rotate=90 width=50;

						%if %SYSEVALF(%upcase(&use_ref_line.) = YES) %then %do;
							 referenceline &ref_axis. = &ref_point. / lineattrs = (
																				thickness = 2
																				pattern = dash
																				 )
																		curvelabel = "&ref_text."
																		curvelabellocation = outside 
																		curvelabelposition = max 
																		curvelabelattrs =(
																							color = gray
																							family = "Arial"
																							size = 12pt
																						  )
																							;
						%end;
			/*Options for graphical input for KM curve*/
			stepplot x = time y = plot_surv / group=groupmarkers 
/*[!] Option*/
/*											Use this option if you want to make a variable*/
/*											that is attached to a HR or any other value*/
				%if %SYSEVALF(%upcase(&use_curve_label.) = YES) %then %do;
										   curvelabel = curve_label 
										   curvelabelattrs = (size = 12)
				%end;
										   lineattrs = (/*pattern=solid*/ thickness = 3) 
										   name = 's'
										   grouporder = data;

			/*Creates outside legend for table*/
			discretelegend "s" / location = inside 
								 across = 1 
/*[!] Option:				Change location of legend, change to top left if legend is in the way*/
								 valign = bottom 
								 halign = right	
								 border = false
								 sortorder = auto
								 valueattrs=(size= 12pt)
								 titleattrs=(size= 10pt);
			endlayout;


			/*X and Y axis options for RISK SET*/
	        layout overlay / xaxisopts = (
										 offsetmin = 0.03 
										 display = none
										 )  
							 walldisplay = none
	                         yaxisopts =( 
							 			 reverse = true
										 display = (tickvalues) 
										 tickvalueattrs=(size=12)
/*[!]Note: 								 If Risk set is too close to one another, change this option*/
/*										 offsetmin =.05 */
										 );
			/*Enters "Number at Risk" above Risk Set*/
			entry halign = left "Number at risk:" / location = outside 
												 	valign = top 
													textattrs =(
																 style = italic 
																 size = 12
																);
			/*Risk Set information*/
			scatterplot x = ticks y = stratum / /*group = groupmarkers */
	/*										 	grouporder = data*/
												markercharacter = atrisk
		                     					markercharacterattrs = (size = 12);
	        endlayout;
	      endlayout;
	    endgraph;
	  end;
	run;

	/*Uncomment out for RTF*/
	%if %SYSEVALF(%upcase(&create_RTF.) = YES) %then %do;
		ods rtf file="&output./&output_name.&rundate..rtf";
	%end;
	/*Uncomment out for PDF*/
	%if %SYSEVALF(%upcase(&create_PDF.) = YES) %then %do;
	ods pdf file="&output./&output_name.&rundate..pdf";
	%end;
	/*Survival Plot with outer Risk Table using Scatter Plot*/
/*	ods select all;*/
	ods listing gpath = "&output.";
	ods listing style=mystyle;
	ods graphics/reset = all width = 9in height = 8in noborder imagefmt=emf outputfmt = emf imagename = "&output_name._&rundate.";

	options orientation = landscape; *portrait;

	title " ";
	proc sgrender data = failureplot5 template = survivalplotatrisk_outside_scatter ;
		format stratum $stratf.;
	run;
		
	/*Uncomment out for PDF*/
	%if %SYSEVALF(%upcase(&create_PDF.) = YES) %then %do;
	ods pdf close;
	%end;
	/*Uncomment out for RTF*/
	%if %SYSEVALF(%upcase(&create_RTF.) = YES) %then %do;
	ods rtf close;
	%end;

%mend;



/*RTF/PDF title*/
title1 " ";
/*RTF/PDF footnote*/
footnote " ";

%KM_Graph(data		= , 
		time 		= ,
		censor		= , 
		censor_val	= ,
		strata		= ,
		atrisk_range= ,
		max_time	= ,
		tick_list	= %str(), 
		x_tick_list_ns= %str(),
		y_tick_list_ns= %str(),
		max_y    	= ,
		g_title1	= %str(), 
/*		g_title2	= %str(),*/
/*		g_footnote	= %str(),*/
		output_name = ,
		x_axis_label= ,
		y_axis_label= );


/********************************************************************/
/*KM_Graph Macro Prompts								   			*/
/********************************************************************/
/*data: 	  		Insert dataset name for analysis				*/
/*time: 	  		Insert time variable							*/
/*censor: 	 		Insert Censor variable							*/
/*censor_val: 		Censor value (e.g. 0 or 1)						*/
/*strata: 			Insert Strata variable							*/
/*atrisk_range:		Used for tickmarks and ranges for KM curve  	*/	
/*					Use the format min to max by number				*/
/*max_time:			Insert the maximum cutoff time value			*/
/*y_max:			Determine max Y axis (between 0 and 1 for %)	*/
/*tick_list:		Insert list for at-risk set. Seperate by comma	*/
/*					use %str() around your list						*/
/*x_tick_list_ns:	Enter list of tick marks separated by spaces	*/ 
/*					for x-axis. use %str() around your list.   		*/
/*y_tick_list_ns*:	Enter list of tick marks separated by spaces	*/
/*					for y-axis. use %str() around your list.    	*/
/*g_title1 : 		Insert text for Title1 INSIDE graphic			*/
/*g_title2 : 		Insert text for Title2 INSIDE graphic			*/
/*g_footnote:		Insert footnote INSIDE graphic					*/
/*output_name:  	Insert file name for EMF  (PDF/RTF if commented)*/
/*x_axis_label:  	X-axis label "e.g. time "						*/
/*y_axis_label:  	Y-axis label "Failure(%) "						*/
/********************************************************************/
