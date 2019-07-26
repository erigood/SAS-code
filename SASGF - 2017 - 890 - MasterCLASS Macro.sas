/**********************************************************************************************************
* MasterCLASS Macro
* This macro determines which variables should be added into the class statement
* Author: Erica Goodrich, Dan Sturgeon
* Update Log: 09/16/2016 - DJS - Majority working code for MasterCLASS macro, and practice paper 
			  included at bottom.
			  1/6/2017 - ELG - Split paper away. Worked on additional commenting and logic checks.
			  Considering if param=ref is needed. CTRL+F [!]
			  Fixed length issue to remove warn.ing on varying lengths on merge. Added in working 
			  model at the end.
			  
***********************************************************************************************************/
/**********************************************************************************************************
MasterCLASS data prompts:
DATA =   Dataset name of interest
VARS =   list of variables to be added to the model of interest as covariates.
LEVELS = Lower limit for numeric variablesbefore considering it categorical. The default is set at 10
***********************************************************************************************************/




%MACRO MasterCLASS(DATA=, VARS=, LEVELS=10); 

	/*Grabs metadata from the dataset of interest*/
	PROC CONTENTS DATA=&DATA out=OUTCONTENT noprint;
	RUN;

	/*Creates empty datasets for later use*/
	DATA _VARS;
		LENGTH NAME $255.;
		SET _NULL_;
	RUN;

	DATA CAT;
		LENGTH NAME $255.;
		SET _NULL_;
	RUN;

	DATA CONT;
		LENGTH NAME $255.;
		SET _NULL_;
	RUN;

	/*Count the number of variables of interest*/
	%LET CNT1 = %SYSFUNC(countw(&VARS,' '));

	/*Setting up the do loop through the variable list*/
	%DO I = 1 %TO &CNT1;
		/*This will scan through the list of &VARS. one at a time separated by a space, until it reaches the end.*/
		%LET VAR = %SCAN(&VARS.,&I.,' ');

		/*Get the count of levels to determine type of numeric*/	
		PROC SQL;
			CREATE TABLE _A AS
			SELECT DISTINCT
				   "&VAR" AS NAME,
				   COUNT(DISTINCT &VAR) as LEVELS
			FROM &DATA;
		QUIT;

		/*Create a table where variable information regarding levels is kept*/
		DATA _VARS;
			SET _VARS _A;
		RUN;
	%END;

	/*Combine level counts with data type for the categorical variables that have many levels*/
	PROC SQL;
		CREATE TABLE _VARS1 AS
		SELECT A.NAME,
			   A.LEVELS,
			   B.TYPE
		  FROM _VARS A,
			   OUTCONTENT B
		 WHERE UPCASE(A.NAME) = UPCASE(B.NAME);
	QUIT;

	/*If the number of levels < than the minimum we defined OR the type is string then they are lumped into categorical*/
	DATA CONT CAT;
		SET _VARS1;
		IF LEVELS < &LEVELS OR TYPE = 2 THEN OUTPUT CAT;
		ELSE OUTPUT CONT;
	RUN;

	PROC SQL noprint;
		SELECT COUNT(*)
		  INTO :CATROW
		  FROM CAT;
		SELECT COUNT(*)
		  INTO :CONTROW
		  FROM CONT;
	QUIT;


	/*Next, the continuous variables are noted*/
	%IF &CONTROW GE 1 %THEN %DO;

		PROC SQL noprint;
			SELECT NAME
			  INTO :CONTINUOUS SEPARATED BY " "
			FROM CONT;
		QUIT;

	%END;

	%IF &CONTROW GE 1 %THEN %DO;

		/*Combine two categorical types: those that are numeric and those that are not.*/
		PROC SQL noprint;
			SELECT NAME
			  INTO :CATEGORICAL1 SEPARATED BY " "
			 FROM CAT
			WHERE TYPE = 1;
		QUIT;

		PROC SQL noprint;
			SELECT NAME
			  INTO :CATEGORICAL2 SEPARATED BY " "
			 FROM CAT
			WHERE TYPE = 2;
		QUIT;

		/*Gather counts for both of those groups*/
		PROC SQL noprint;
			SELECT COUNT(*)
			  INTO :CNT2
			  FROM CAT
			WHERE TYPE = 1;
		QUIT;

		PROC SQL noprint;
			SELECT COUNT(*)
			  INTO :CNT3
			  FROM CAT
			WHERE TYPE = 2;
		QUIT;

		/*First go through the string categorical variables*/
		%IF &CNT3 GE 1 %THEN %DO;

			DATA CAT2;
			/*LENGTH LEVEL $255.;*/
				SET &DATA;
				ARRAY CATVAR[&CNT3] &CATEGORICAL2;
				DO J = 1 TO &CNT3;
					VARIABLE = SCAN("&CATEGORICAL2",J,' ');
					LEVEL = CATVAR[j];
					OUTPUT;
				END;

				KEEP VARIABLE LEVEL;
			RUN;

		%END;

		%ELSE %DO;
			DATA CAT2;
				SET _NULL_;
			RUN;
		%END;

		%IF &CNT2 GE 1 %THEN %DO;
			/*Now with numeric variables, since type must match since the arrays cannot handle different types*/
			DATA CAT3;
				SET &DATA;
				ARRAY CATVAR[&CNT2] &CATEGORICAL1;
				DO J = 1 TO &CNT2;
					VARIABLE = SCAN("&CATEGORICAL1",J,' ');
					LEVEL = COMPRESS(INPUT(CATVAR[j],$255.));
					LEVRAW = CATVAR[j];
					OUTPUT;
				END;

				KEEP VARIABLE LEVEL LEVRAW;
			RUN;

		%END;

		%ELSE %DO;
			DATA CAT3;
				SET _NULL_; 
			RUN;
		%END;

		DATA CATCOMB;
			LENGTH LEVEL $255.;
			SET CAT2 CAT3;
			IF LEVRAW = . THEN LEVRAW = 0;
		RUN;

		/*Combines the results and defining the variable references*/
		/*[!] QUESTION: ELG: Should this just be set for picking ascending, descending, or ref since this is sorting?*/
		PROC SQL noprint;
			CREATE TABLE CAT_ALL AS
			SELECT DISTINCT 
				   VARIABLE,
				   LEVEL,
				   LEVRAW,
				   COMPRESS(VARIABLE||"(REF='"||LEVEL||"')") AS CLASS
			  FROM CATCOMB
			WHERE LEVEL NE ''
			GROUP BY VARIABLE
			ORDER BY 1,3,2;
		QUIT;

		DATA CAT_ALL;
			SET CAT_ALL;
			BY VARIABLE;
				IF FIRST.VARIABLE NE 1 THEN DELETE;
		RUN;

	%END;

	%GLOBAL MODEL CLASS VARIABLE; /*These are the macro variables we will use in our model*/

	PROC SQL noprint;
		SELECT VARIABLE,
			   CLASS
		  INTO :VARIABLE SEPARATED BY ' ',
			   :CLASS SEPARATED BY  ' '
		  FROM CAT_ALL;
	QUIT;

	%LET MODEL = &VARIABLE &CONTINUOUS;

	/*Housekeeping: Delete all tables except the working table we are using*/
	PROC DATASETS noprint;
		DELETE CAT CAT2 CAT3 CAT_ALL _VARS _VARS1 CAT CONT OUTCONTENT _A;
	RUN;
	QUIT;

	/*Housekeeping: Clear macro variables used during run in case of re-run*/
	%LET CATROW =;
	%LET CONTROW =;
	%LET CONTINUOUS =;
	%LET CATEGORICAL1 =;
	%LET CATEGORICAL2 =;
	%LET CNT2=;
	%LET CNT3=;
%MEND;
/*Example using built in SAS dataset, CARS. This is a terrible model and should not be used outside of showing how the variables 
can be filled in*/
%MasterCLASS(DATA=SASHELP.CARS, VARS=ORIGIN MAKE TYPE MPG_CITY WEIGHT Cylinders DriveTrain EngineSize Horsepower mpg_Highway weight wheelbase length);

/*Outputs MODEL and CLASS macro variable output to the log*/
%PUT &MODEL;
%PUT &CLASS;
%PUT &VARIABLE;
/*Changes made to create a binary variable*/
DATA CARS;
	SET SASHELP.CARS;
	IF MSRP LT 25000 THEN UNDER25K = 1;
	ELSE UNDER25K = 0;
	LABEL UNDER25K ="CAR MSRP UNDER 25K? (1=YES, 0=NO)"; 
RUN;

/*An example could be using this model to show a saturated model and then use a selction method*/
PROC LOGISTIC DATA=CARS DESCENDING;
	CLASS &CLASS./PARAM=REF;
	MODEL UNDER25K = &MODEL./SELECTION=BACKWARD;
RUN;

proc freq data=cars;
table Cylinders ENGINESIZE;
run;

%MasterCLASS(DATA=CARS, VARS= ORIGIN MPG_CITY WEIGHT DRIVETRAIN ENGINESIZE HORSEPOWER MPG_HIGHWAY WEIGHT WHEELBASE LENGTH);
%put &CLASS;
%put &variable;
%put &model;

DATA CARS;
	SET SASHELP.CARS;
	IF MSRP LT 25000 THEN UNDER25K = 1;
	ELSE UNDER25K = 0;
	LABEL UNDER25K ="CAR MSRP UNDER 25K? (1=YES, 0=NO)"; 
RUN;

PROC LOGISTIC DATA=CARS DESCENDING;
	CLASS &CLASS./PARAM=REF;
	MODEL UNDER25K = &MODEL.;
RUN;

QUIT;
