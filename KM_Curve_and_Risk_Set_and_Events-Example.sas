
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


*pull in example data and change days to years;
libname in "Y:\_TIMI_Program_Library\SAS_programs\KM_Curve_and_Risk_Set_and_Events";
data temp;	
	set in.engage_example;
	yrs2net = days2net/365.25;
run;

*pull in SAS macro;
filename kmgraph 'Y:\_TIMI_Program_Library\SAS_programs\KM_Curve_and_Risk_Set_and_Events\KM_Curve_and_Risk_Set_and_Events.sas';
%include kmgraph;

*run macro;
%KM_Graph(
		data		         = temp, 
		time 		         = yrs2net,
		censor		         = netfu, 
		censor_val	         = 0,
		strata		         = randgrp3,
		strata_lvl_count     = 3,
		strata1_class_lvl_nm = 0,
		strata2_class_lvl_nm = 1,
		strata3_class_lvl_nm = 2,
		strata1_class_label  = Warfarin,
		strata2_class_label  = LDER,
		strata3_class_label  = HDER,
		events               = YES,
		atrisk_list          = 0 0.5 1 1.5 2 2.5 3 3.5,
		x_axis_label         = Years,
		y_tick_list_ns       = 0.0 0.05 0.10 0.15 0.20 0.25,
		max_y    	         = 0.26,
		y_axis_label         = Failure(%),
		g_title1	         = %str(Net Outcome), 
		use_curve_label      = YES,
		output_name          = netoutcome,
		output               = Y:\_TIMI_Program_Library\SAS_programs\KM_Curve_and_Risk_Set_and_Events\,
		create_RTF           = YES
);




				
		







