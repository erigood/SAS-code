options mlogic mprint;

%MACRO BATCH(dir=);

	/*read in file names*/
	FILENAME dirfile PIPE "dir ""&dir"" /b" LRECL=200;
	DATA in;
	INFILE dirfile LENGTH=len;
	INPUT char $varying200. len;
	RUN;

	/*only choose sas program names*/
	DATA sasprg;
	SET in;
	IF INDEX(char,'.sas ') or  INDEX(char,'.SAS ');
	RUN;

	/*create statement*/
	DATA line;
	LENGTH name $250;
	SET sasprg;
	name="%include '"||trim(char)||"';";
	DROP char;
	RUN;

	/*write out to a file*/
	FILENAME fileref "&dir.[!!] Run all in Batch Mode.sas";
	DATA _null_;
	SET line;
	FILE fileref;
	PUT name;
	RUN;

	FILENAME fileref clear;
	%MEND;

%BATCH(dir=Y:\_TIMI_manuscripts_at_works\TIMI54-PEGASUS\Biomarker_AHA2016\ELG\Program\Spline Progams\);
