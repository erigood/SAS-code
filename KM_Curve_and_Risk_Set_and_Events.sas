/******************************************************************************************/
/* TIMI STUDY GROUP										                                  */
/******************************************************************************************/
/*Program: 	  KM Survival At Risk.sas						                              */
/*Programmer: Erica Goodrich								                              */
/*Edited by:  Rose Hamershock                                                             */
/*Date:	 	  11/9/2015										                              */
/*Notes: 	  This program requires one run of the code above the macro per SAS update.   */
/*Updates:	  11/18/2015 - Created output to be bolder, added additional macro prompts to */
/*			       		   account for up to 8 levels and create RTF or PDF output        */
/*			       		   automatically. Groups larger than 4 may need additional coding */
/*			       		   for sizing in future update                                    */
/*			  01/21/2016 - Adjusted y-label placement with long axis levels.              */
/*			  02/05/2016 - SAS 9.4 changes made effect the emf file output. Please run    */
/*			     		   commented code once on any computers using 9.4.                */
/*            08/29/2016 - Combined beginning %let statements into macro call. Added      */
/*			      		   option to print Number of Events into table at bottom of       */
/*                    	   Figure. Combined x-axis tick mark and at-risk variables into   */
/*				  		   variable called multiple times within macro.                   */
/******************************************************************************************/


/******************************************************************************************/
/* KM_Graph MACRO PROMPTS								   		    	                  */
/******************************************************************************************/
/*data: 	  		    Insert dataset name for analysis				                  */
/*time: 	  		    Insert time variable							                  */
/*censor: 	 		    Insert Censor variable							                  */
/*censor_val: 		    Censor value (e.g. 0 or 1)						                  */
/*																		                  */
/*strata: 			    Insert Strata variable							                  */
/*strata_lvl_count:     Insert number of stratification factors.                          */
/*					    Insert as a number from 2 - 8                                     */
/*																		                  */
/*strata1_class_lvl_nm: Insert first strata level value                                   */         
/*strata2_class_lvl_nm: Insert second strata level value                                  */
/*strata3_class_lvl_nm: Insert third strata level value, if one exits                     */
/*strata4_class_lvl_nm: Insert fourth strata level value, if one exits                    */
/*strata5_class_lvl_nm: Insert fifth strata level value, if one exits                     */
/*strata6_class_lvl_nm: Insert sixth strata level value, if one exits                     */
/*strata7_class_lvl_nm: Insert seventh strata level value, if one exits                   */
/*strata8_class_lvl_nm: Insert eighth strata level value, if one exits                    */
/*																		                  */
/*strata1_class_label:  Insert first strata name                                          */
/*strata2_class_label:  Insert second strata name                                         */
/*strata3_class_label:  Insert third strata name, if one exists                           */
/*strata4_class_label:  Insert fourth strata name, if one exists                          */
/*strata5_class_label:  Insert five strata name, if one exists                            */
/*strata6_class_label:  Insert sixth strata name, if one exists                           */
/*strata7_class_label:  Insert seventh strata name, if one exists                         */
/*strata8_class_label:  Insert eighth strata name, if one exists                          */
/*																		                  */
/*events:               Insert YES to print number of events per at risk period. Otherwise*/
/*						insert NO or leave blank. Default NO.                             */
/*																		                  */
/*atrisk_list:		    Used for tickmarks and ranges for KM curve. Insert one value per  */
/*						tick mark separated by a space. Ex) The first 90 days at 10 day   */
/*						intervals, insert: 0 10 20 30 40 50 60 70 80 90                   */	
/*x_axis_label:    	    X-axis label "e.g. time "						                  */
/*																		                  */
/*y_tick_list_ns:	   Enter list of tick marks separated by spaces	for y-axis            */
/*max_y:		  	   Determine max Y axis (between 0 and 1 for %)	                      */
/*y_axis_label:  	   Y-axis label. Ex) "Failure(%)"					                  */
/*																		                  */
/*strata1_color:       First strata trend line color. Default red. See color list at:     */
/*					   http://support.sas.com/publishing/authors/extras/62007_Appendix.pdf*/
/*strata2_color:       Second strata trend line color. Default blue                       */
/*strata3_color:       Third strata trend line color. Default green                       */
/*strata4_color:       Fourth strata trend line color. Default orange                     */
/*strata5_color:       Fifth strata trend line color. Default purple                      */
/*strata6_color:       Sixth strata trend line color. Default pink                        */
/*strata7_color:       Seventh strata trend line color. Default brown                     */
/*strata8_color:       Eighth strata trend line color. Default gray                       */
/*																		                  */
/*strata1_pattern:     First strata trend line pattern. Default solid. See list at:       */
/*					   https://support.sas.com/documentation/cdl/en/grstatproc/65235/HTML */
/*					   /default/viewer.htm#p0j7656q8p61utn1s3jihzencnf2.htm               */
/*strata2_pattern:     Second strata trend line pattern. Default solid.                   */
/*strata3_pattern:     Third strata trend line pattern. Default solid.                    */
/*strata4_pattern:     Fourth strata trend line pattern. Default solid.                   */
/*strata5_pattern:     Fifth strata trend line pattern. Default solid.                    */
/*strata6_pattern:     Sixth strata trend line pattern. Default solid.                    */
/*strata7_pattern:     Seventh strata trend line pattern. Default solid.                  */
/*strata8_pattern:     Eighth strata trend line pattern. Default solid.                   */
/*																		                  */
/*g_title1: 		   Insert text for Title1 INSIDE graphic			                  */
/*g_title2: 		   Insert text for Title2 INSIDE graphic			                  */
/*g_footnote:		   Insert footnote INSIDE graphic					                  */
/*use_curve_label:     Insert YES for curves to have labels. (Defaulted to failure %)     */
/*																		                  */
/*use_ref_line:        Insert YES to use a reference line. Otherwise leave blank or       */
/*                     enter NO.                                                          */
/*ref_axis:            For use when use_ref_line=YES. Set x or y axis for line            */
/*ref_point:           For use when use_ref_line=YES. Set area where line should be drawn */
/*ref_text:            For use when use_ref_line=YES. Set text to be displayed alongside  */
/*                     reference line.													  */
/*																		                  */
/*output_name:  	   Insert file name for EMF (also PDF/RTF if indicated)               */
/*output:              Enter folder path for output                                       */
/*create_RTF:          Enter YES to create an RTF. Otherwise insert NO or leave blank.    */
/*					   Default NO.														  */
/*create_PDF:          Enter YES to create an PDF. Otherwise insert NO or leave blank.    */
/*					   Default NO.														  */
/******************************************************************************************/



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



%macro KM_Graph(data=, time=, censor=, censor_val=, strata=, strata_lvl_count=, 
				strata1_class_lvl_nm=, strata2_class_lvl_nm=, strata3_class_lvl_nm=, strata4_class_lvl_nm=, 
				strata5_class_lvl_nm=, strata6_class_lvl_nm=, strata7_class_lvl_nm=, strata8_class_lvl_nm=,
				strata1_class_label=, strata2_class_label=, strata3_class_label=, strata4_class_label=,
				strata5_class_label=, strata6_class_label=, strata7_class_label=, strata8_class_label=,
				events=, atrisk_list=, x_axis_label=, y_tick_list_ns=, max_y=, y_axis_label=, 
				strata1_color = red, strata2_color = blue, strata3_color = green, strata4_color = orange,
				strata5_color = purple, strata6_color = pink, strata7_color = brown, strata8_color = gray,
				strata1_pattern = 1, strata2_pattern = 1, strata3_pattern = 1, strata4_pattern = 1,
				strata5_pattern = 1, strata6_pattern = 1, strata7_pattern = 1, strata8_pattern = 1,
				g_title1=, g_title2=, g_footnote=, use_curve_label=, 
				use_ref_line=, ref_axis=, ref_point=, ref_text=,
				output_name=, output=, create_RTF=NO, create_PDF=NO);



/*--------------------------------------------------------------------------------------------*/
/**----------                Set page options and formats for figure                ----------*/
/*--------------------------------------------------------------------------------------------*/

options symbolgen mlogic mprint orientation=landscape nonumber nofmterr nodate noquotelenmax;
ods escapechar = "#";

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



/*--------------------------------------------------------------------------------------------*/
/**----------                        Get KM data for figure                        ----------**/
/*--------------------------------------------------------------------------------------------*/

*standardize names of time and censor variables;
data kmdata;
set &data.;
	timevar = &time.;
	censorvar = &censor.;
	label timevar = "&x_axis_label.";
run;

*create needed variables from at risk time list;
proc sql noprint;
	select distinct tranwrd("&atrisk_list.", " ", ", ") into :tick_list from kmdata;
	select distinct scan("&atrisk_list.", -1, " ")      into :max_time  from kmdata;
quit;

*Output the survival data from the LIFETEST procedure;
ods graphics on;

ods exclude all;
*find number of events and number at risk for desired at risk time points;
proc lifetest data = kmdata plots = survival(failure test atrisk = &atrisk_list.) timelist=&atrisk_list. atrisk;
	time timevar * censorvar(&censor_val.);
	strata &strata.;
	ods output homtests=homtests failureplot=failureplot productlimitestimates=riskset;
run;

*output all survival information to plot;
proc lifetest data = kmdata method = km timelist = &max_time. plots=none;
	time timevar * censorvar(&censor_val.);
	strata &strata./test=(logrank wilcoxon lr);
	ods output productlimitestimates=kmout;
run;

*find number of events that occurred between two at risk time points;
data riskset2 (drop = Stratum rename = (stratum_char = Stratum));
	set riskset;
	stratum_char = strip(trim(put(&strata., best8.)));
	failed_diff = Failed - lag(Failed);
	if first.&strata. then failed_diff=0;
	by &strata.;
run;

*Remove unnecessary datasets from proc lifetest output;
proc datasets;
	delete _doctm:;
run;

*Create output needed for KM curve labels;
data kmout1 (drop = Stratum rename = (stratum_char = Stratum));
	set kmout;
	curve_label = strip(trim(put(failure*100,5.2)))||"%";
	stratum_char = strip(trim(put(&strata., best8.)));
run;

ods exclude none;
quit;




/*--------------------------------------------------------------------------------------------*/
/**----------                Produce the survival plot using SGPLOT                ----------**/
/*--------------------------------------------------------------------------------------------*/

*Save the p-value from the Logrank test to a macro variable- note: this isnt incorporated;
data _NULL_;
	set homtests;
	if test = "Log-Rank" then call symput ("LR_PVal",put(ProbChiSq, 5.3));
run;

*Remove duplicates in the Failure dataset;
proc sort data = failureplot out = failureplot2 nodup;
	by time survival atrisk event censored tatrisk stratum stratumnum _1_survival_ _1_censored_;
run;

*Set tick marks and points to plot on the figure;
data failureplot3;
	set failureplot2;
	if tatrisk in (&tick_list.) then ticks = tatrisk;
	if _1_survival_ ne . then plot_surv = _1_survival_;
	else if _1_censored_ ne . then plot_surv = _1_censored_;
	format plot_surv percent8.4;
run;

*merge KM data;
proc sort data=kmout1; by stratum;
proc sort data=failureplot3; by stratum Time; 
proc sort data=Riskset2; by stratum Timelist;
run;

data failureplot4;
	merge failureplot3 kmout1;
	by Stratum;
run;

data failureplot4;
	merge failureplot4  Riskset2(keep=Stratum NumberAtRisk Failed Failed_diff Timelist rename=(Timelist=Time));
	by Stratum Time;
run;

*keep only data up through the last at risk time point;
data failureplot5;
	set failureplot4;
	where time LE &max_time.;
run;

proc sort data=failureplot5;
	by stratumnum;
run;

*Remove unnecessary intermediary datasets;
ods exclude all;
proc datasets;
	delete km: Failureplot FailurePlot1-FailurePlot4;
run;
ods exclude none;
quit;




/*--------------------------------------------------------------------------------------------*/
/**----------                             Create graph                             ----------**/
/*--------------------------------------------------------------------------------------------*/

*Template for axis line thickness/color/options;
proc template;
	define style styles.mystyle; 
	parent=styles.HTMLBlue;
	style GraphAxisLines from GraphAxisLines /
	      linethickness = 3px 
		  contrastcolor=black;
	end;
run;

*Template for Graph;
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
		  			%if &events.=YES %then %do;
						  rowweights = %if %sysevalf(&strata_lvl_count. = 2) %then %do;
										   (0.80 0.10 0.10)
									   %end;
									   %if %sysevalf(&strata_lvl_count. NE 2) %then %do;
										   (0.74 0.13 0.13) 
									   %end;
					%end;
					%if &events.=NO %then %do;
						  rowweights = %if %sysevalf(&strata_lvl_count. = 2) %then %do;
										   (0.90 0.10)
									   %end;
									   %if %sysevalf(&strata_lvl_count. NE 2) %then %do;
										   (0.84 0.16) 
									   %end;

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
													tickvaluelist = (%str(&atrisk_list.))
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
										 tickvalueattrs=(size=10)
/*[!]Note: 								 If Risk set is too close to one another, change this option*/
/*										 offsetmin =.05 */
										 );
			/*Enters "Number at Risk" above Risk Set*/
			entry halign = left "Number at risk:" / location = outside 
												 	valign = top 
													textattrs =(
																 style = italic 
																 size = 10
																);
			/*Risk Set information*/
			scatterplot x = ticks y = stratum / /*group = groupmarkers */
	/*										 	grouporder = data*/
												markercharacter = NumberAtRisk
		                     					markercharacterattrs = (size = 10);
	        endlayout;


		%if &events.=YES %then %do;
			/*X and Y axis options for EVENT SET*/
	        layout overlay / xaxisopts = (
										 offsetmin = 0.03 
										 display = none
										 )  
							 walldisplay = none
	                         yaxisopts =( 
							 			 reverse = true
										 display = (tickvalues) 
										 tickvalueattrs=(size=10)
/*[!]Note: 								 If Event set is too close to one another, change this option*/
/*										 offsetmin =.05 */
										 );
			/*Enters "Number of Events" above Event Set*/
			entry halign = left "Number of events:" / location = outside 
												 	valign = top 
													textattrs =(
																 style = italic 
																 size = 10
																);
			/*Risk Set information*/
			scatterplot x = ticks y = stratum / /*group = groupmarkers */
	/*										 	grouporder = data*/
												markercharacter = Failed_diff
		                     					markercharacterattrs = (size = 10);
	        endlayout;
		%end;
      endlayout;
    endgraph;
  end;
run;




/*--------------------------------------------------------------------------------------------*/
/**----------                            Output results                            ----------**/
/*--------------------------------------------------------------------------------------------*/

%let rundate=%SYSFUNC(today(),yymmddn8.);

*output for RTF;
%if %SYSEVALF(%upcase(&create_RTF.) = YES) %then %do;
	ods rtf file="&output.&output_name.&rundate..rtf";
%end;

*output for PDF;
%if %SYSEVALF(%upcase(&create_PDF.) = YES) %then %do;
	ods pdf file="&output.&output_name.&rundate..pdf";
%end;

	*Survival Plot with outer Risk Table using Scatter Plot;
	ods listing gpath = "&output.";
	ods listing style=mystyle;
	ods graphics/reset = all width = 9in height = 8in noborder imagefmt=emf outputfmt = emf imagename = "&output_name._&rundate.";

	options orientation = landscape; *portrait;

	title " ";
	proc sgrender data = failureplot5 template = survivalplotatrisk_outside_scatter ;
		format stratum $stratf.;
	run;
			
*Close for PDF;
%if %SYSEVALF(%upcase(&create_PDF.) = YES) %then %do;
	ods pdf close;
%end;

*Close for RTF;
%if %SYSEVALF(%upcase(&create_RTF.) = YES) %then %do;
	ods rtf close;
%end;

ods exclude all;
proc datasets;
	delete _doctm: FailurePlot: Homtests Riskset:;
run;
ods exclude none;
quit;

%mend;





				
		







