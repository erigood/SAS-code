/**************************************************************/
/*BURST macro 												  */
/**************************************************************/
/*See Burst Reporting With the Help of PROC SQL				  */
/*from MWSUG 2014 (Paper RF-08-2014)						  */
/*By Dan Sturgeon, Edits by Erica Goodrich					  */
/**************************************************************/

/**************************************************************/
/*MACRO PROMPTS:											  */
/*Data=	 Dataset of interest for grouping					  */
/*group_name= Column that has assigned name tied to each ID	  */
/*unique_id= Column that has unique identifier for the group  */
/*Code= code to be pushed through with unique combinations,   */
/*		since BURST is just used as a wrapper				  */
/**************************************************************/

%MACRO BURST(data, group_name, unique_id, code);
	PROC SQL NOPRINT;
		/*Creating a dataset with the unique ID's and Names, plus a row
		counter*/
		CREATE TABLE meta AS
			SELECT distinct unique_id,
			group_name,
			monotonic() AS rank /*similar to using n = _n_ in the datastep*/
			FROM 
				(SELECT distinct &unique_id AS unique_id,
				&group_name AS group_name
				FROM &data);

		/*Creates a macro variable for how many groups are in the meta set*/
		SELECT count(*)
		INTO :group_cnt /*Works similarly to CALL SYMPUT in the data step*/
		FROM meta;
	QUIT;

	/*Here is the start of the loop that grabs the information based on the row number*/
	%DO I = 1 %TO &group_cnt;
		PROC SQL NOPRINT;
			SELECT unique_id,
					group_name
			INTO :id, /*Variable for unique ID*/
				  :name /*Variable for grouping name. This does not need to be unique*/
			FROM meta
			WHERE rank = &I;
		QUIT;
		/*The Below LET statements remove leading and trailing blanks*/
		%LET Name = %SYSFUNC(strip(&name));
		%LET id = %SYSFUNC(strip(&id));
		/*Here is where the MACRO is put*/
		&Code.
	%END;
%MEND;
