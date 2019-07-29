/* ################################################################
** AUTHOR:  Jeong-Gun Park,  July 2018
** ----------------------------------------------------------------
** PURPOSE: This Macro create adjusted event rate curve plot with 95% CI of study endpoint with a contious predictor variable using Cox PH regression model.
** ----------------------------------------------------------------
** Estimates of ajusted event rates in this Macro are obtained based on the paper published in JAMA 2001, by W.A. Ghali et al.:
** REFERENCE: William Ghali et al (2001). Comaprison of 2 Methods for Caculating Adjusted Survival Curves from Proportional Hazard Models. JAMA Vol 286 No 12. 
** The approach in this Macro uses "Corrected Group Prognosis Method". 
** ----------------------------------------------------------------
** This program runing may take a longer time as sample size increases.
** ################################################################ */


/** %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*** Description of Macro Variables
*** ---------------------------------------------
    INDATA   = Input dataset 
    RESPVAR  = Time-to-event variable 
    EVENTFU  = Censoring variable, which must conatin binary numeric value 0 (=censored) or 1 (=event) 
    PREDVAR  = The continuous predictor variable that is of interest for plot
    ADJCOV   = List of Covariates that are used for adjustment, including all of categorical variables
    CLASVAR  = List of Categorical variables for CLASS statement 
    ENDPTNM  = Name of endpoint that is printed on output plot 
    ATTIME   = Time at event of interest 
    TIMEUNIT = Unit of time at event (eg., months)  
    XLABEL   = Label on X-axis to be printed on output plot 
    OUTFNM   = Name of ouput file in RTF format (eq., H:\mydirectory\temp_AdjEventRate.rtf )
*** ===================================================================
*** Example of Macro run:
*** ---------------------
%AdjEventRate_CGPM(
                   indata = workZD, 
                   respvar = mths2pep, 
                   eventfu = pepfu, 
                   predvar = LDL1mval, 
				   adjcov = sex age region curr_smoke hxdiabet hxhypert priormi hxstroke hxpad,
                   clasvar = sex region curr_smoke hxdiabet hxhypert priormi hxstroke hxpad, 
                   endptnm = Primary Endpoint, 
                   attime = 36, 
                   timeunit = months,  
                   xlabel = LDL-C at 1 month, 
                   outfnm = H:\mydirectory\temp_AdjEventRate.rtf
                   );
*** %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  **/



*** ###################################;
%macro AdjEventRate_CGPM( indata=, respvar=, eventfu=, predvar=, adjcov=, clasvar=, endptnm=, attime=, timeunit=, xlabel=, outfnm= );

*** ======================================;
*** Knot locations in cubic spline smooting;
%let ncsknots = %str(.05 .25 .50 .75 .95) ;
*** ======================================;


data _workD; set &indata.;
  time2evt = &respvar. ;
  censvar = &eventfu. ;
  predvar = &predvar. ;
run;


*** =====================================================;
*** To calculate the bottom 1% and top 1%;
proc univariate data=_workD noprint;
  var &predvar.;
  output out=univoutD P1=P1v P99=P99v;   
run;
data _NULL_; set univoutD;
  call symput("Lowcut", P1v);
  call symput("Uppcut", P99v);
run;

*** -----------------------------;
data covartD; set _workD;
  keep predvar &adjcov.;  
run;

*** ======================================================;
*** PROC PHREG to estimate event rates;
proc phreg data=_workD;
  class &clasvar. ;
  model time2evt*censvar(0) = predvar &adjcov.; 

  baseline out=bloutD covariates=covartD  survival=survival lower=lower upper=upper; 
  ods output ParameterEstimates=prmestD;
run;

*** To see p-value for testing the coefficient of the predictor variable;
data prmestAD; set prmestD;
  if Parameter eq "predvar" then call symput("slope_p", put(ProbChiSq, 6.4));
run;
%put &slope_p.;

*** -------------------------------;
data tempD; set bloutD;
  *** time at event rate;
  if time2evt <= &attime.; 
  dummy = 1;
run;
proc sort data=tempD; by time2evt; run;
data _NULL_; set tempD; by dummy;
  if last.dummy then call symput("maxtm", time2evt);
run;
%put &maxtm.;

*** --------------------------------;
data bloutAD; set bloutD;
  if round(time2evt,0.001) eq round(&maxtm.,0.001);

  Failure = (1 - survival); 
  lower_fail = (1 - upper);   
  upper_fail = (1 - lower); 
run;
proc sort data=bloutAD; by predvar; run;

*** ---------------------------;
proc univariate data=bloutAD noprint;
  class predvar;
  var Failure lower_fail upper_fail;
  output out=bloutFD n=nv mean=Failure_m lower_fail_m upper_fail_m;
run;

*** ===================================;
data statsFD; set bloutFD;
  if predvar < &Lowcut. | predvar > &Uppcut. then delete;
run;

*** ------------------------------------;
*** Cubic spline smooting;
proc glmselect data=statsFD;
  effect spl = spline(predvar / naturalcubic knotmethod=rangefractions( &ncsknots. )); 
  model Failure_m = spl / selection=none ;  
  output out=predmD predicted;
run;
proc sort data=predmD; by predvar; run;

proc glmselect data=statsFD;
  effect spl = spline(predvar / naturalcubic knotmethod=rangefractions( &ncsknots. ));
  model lower_fail_m = spl / selection=none ;
  output out=predlD predicted;
run;
proc sort data=predlD; by predvar; run;

proc glmselect data=statsFD;
  effect spl = spline(predvar / naturalcubic knotmethod=rangefractions( &ncsknots. )); 
  model upper_fail_m = spl / selection=none ;
  output out=preduD predicted;
run;
proc sort data=preduD; by predvar; run;

*** -----------------------------------;
data statsZD; merge predmD predlD preduD; by predvar;  
run;



*** #####################################################;
*** PROC TEMPLATE procedure;
*** #####################################################;
proc template;
  define statgraph curveplot;
  beginGraph / border=FALSE; 
    entrytitle "Adjusted Event Rate of &endptnm. at &attime. &timeunit." / textattrs=(family="arial" size=11pt);
*    entryfootnote halign=left "Footnote goes here" / textattrs=(family="arial" size=8pt style=italic);
	layout lattice / border=FALSE rows=1 columns=1;
      layout overlay / xaxisopts=(label=("&xlabel.") 
                            labelattrs=(family="arial" size=10 weight=bold) tickvalueattrs=(family="arial" size=9) griddisplay=on)
                       yaxisopts=(label="Probability"  
                            labelattrs=(family="arial" size=10 weight=bold) tickvalueattrs=(family="arial" size=9) griddisplay=on);

		 bandplot x=predvar limitlower=p_lower_fail_m limitupper=p_upper_fail_m / fillattrs=(color=red transparency=0.6);
		 seriesplot x=predvar y=p_Failure_m / lineattrs=(pattern=1 thickness=3 color=red);

*		 layout gridded / columns=1 autoalign=(topleft) border=true;
*		   entry halign=left "p-value = %sysfunc(compress(&slope_p.)) for slope" / textattrs=(family="arial" size=10pt);
*		 endlayout;
      endlayout;
	endlayout;
  endGraph;
  end;
run;
*** ------------------------------;

*** =================================================;
*** ODS Graphics;
*** =================================================;
options orientation=landscape;

ods graphics on / reset height=600px width=840px;
ods escapechar='^';

ods rtf file="&outfnm." bodytitle;
proc sgrender data=statsZD template=curveplot;
  title;
run;
ods rtf close;

ods graphics off;
*** End of Graphics;

%mend AdjEventRate_CGPM;
*** ####################################;






*** ###########################################;
*** END of PROGRAM;
*** ###########################################;

