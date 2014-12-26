#!/bin/bash
#. ./config.sh
#Create config xml

#Number of topics to be downloaded
numberOfTopics=11;

#earliest year possible to download data
earliestYearPossible=2004;

#Get user input
clear;
while true; do
	while true; do
		echo "\nEnter the year you want to start downloading Doing Business data (YYYY). Earliest year possible; $earliestYearPossible";
		read -n 4 startYear

		expression='^[0-9]+$';
		if ! [[ $startYear =~ $expression ]] ; then
			clear;
			echo "Wrong input: This is not a 4 digits number...";
		elif [[ $startYear < $earliestYearPossible ]] ; then
			echo "\nYou entered a start year that is < 2004. Enter a start year >= 2004.";
		else
			break;
		fi
	done

	echo "\nStart year for download: $startYear";

	while true; do
		clear;
		echo "Start year: $startYear";
		echo "Enter the year you want to end downloading Doing Business data (YYYY). If you would like to start again enter 'redo'.";
		read -n 4 endYear

		if [[ $endYear == "redo" ]]; then
			endYear=0;
			break;
		fi
		expression='^[0-9]+$';
		if ! [[ $endYear =~ $expression ]] ; then
			clear;
			echo "Wrong input: This is not a 4 digits number...";
		else
			break;
		fi
	done

	#If endYear < $startYear, start again
	if [[ $endYear < $startYear ]]; then
		if [[ $endYear = 0 ]]; then
			clear;
			echo "Redo...";
		else
		clear;
		echo "\nThe end year ($endYear) is < the start year ($startYear). Please enter again...";
		fi
	else

		isDownloadStarting=0;

		while true; do
			echo "\nStart year: $startYear";
			echo "End year: $endYear";
			echo "Would you like to start the download now? (y/n)";
			echo "Enter 'y' to start the download or 'n' to restart.";
			read -n 1 yesOrNo

			case $yesOrNo in
					y|Y)
					isDownloadStarting=1;
					break;
						;;
					n|N)
					break;
						;;
					*)
					clear;
					echo "\nWrong input...";
						;;
				esac	
		done

		if [[ $isDownloadStarting == 1 ]]; then
			break;
		fi
		clear;
	fi
done

echo "End year for download: $endYear";

#adjust years. This has to be done due to an "error" in the DB-"API"
startYear=$(($startYear-1));
endYear=$(($endYear-1));

currentYear=$startYear;


#start creating cofig file
echo '<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#/"
    xmlns:opmw="http://www.opmw.org/ontology/"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#">' >../data/config.rdf;

#Download data sources
for((currentYear; currentYear <= endYear; currentYear++))
do
	for ((i=0; i < numberOfTopics; i++))
		do
			#download
			let "topicId=$i+1";
			let "realYear=$currentYear+1";
			query="http://www.doingbusiness.org/Custom-Query?topicIds=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$topicId&EconomyIds=2,3,4,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,36,33,34,35,38,39,41,42,46,47,48,49,50,51,52,54,55,56,57,58,59,60,61,62,63,64,65,66,68,69,70,72,73,74,75,76,77,79,81,82,83,84,85,86,43,87,88,89,90,91,92,93,95,96,97,98,99,100,101,102,104,375,105,106,107,108,109,110,111,112,114,115,116,117,118,119,120,121,122,123,124,125,127,128,129,131,210,132,133,134,135,136,137,140,141,142,143,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,561,162,163,164,206,165,166,167,168,169,170,172,545,173,174,175,176,177,178,179,180,181,182,183,45,184,185,186,209,187,188,189,190,191,193,194,195,196,197,198,199,200,201,202,204,205,207,208&Years=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$currentYear&ajax=1&excel=true";
			wget -O ../data/topicId.$realYear.$topicId.html $query;
		done
done

let "year+=$startYear+1";
let "end+=$endYear+1"
 echo "<rdf:Description rdf:about=\"/config/start-year\">
        <sdmx-dimension:refPeriod>$year</sdmx-dimension:refPeriod>
    </rdf:Description>\n" >> ../data/config.rdf;

 echo "<rdf:Description rdf:about=\"/config/end-year\">
        <sdmx-dimension:refPeriod>$end</sdmx-dimension:refPeriod>
    </rdf:Description>\n" >> ../data/config.rdf;
    
echo "</rdf:RDF>" >> ../data/config.rdf;

#describe workflow processes
#echo "<${workflowTemplate}extraction/download-excel-files> a opmw:WorkflowTemplateProcess;
#                 opmw:isStepOfTemplate <$workflowTemplate> ;
#                 #opmw:uses <????> ;
#                 ." >> $abstractWorkflowDescription;
#
#echo "<${workflowTemplate}extraction/convert-excel-csv> a opmw:WorkflowTemplateProcess;
#    opmw:isStepOfTemplate <$workflowTemplate> ;
#    p-plan:isPrecededBy <${workflowAccount}extraction/download-excel-files> ;
#    #opmw:uses <????> ; 
#    ." >> $abstractWorkflowDescription;
#
#
#echo "<${workflowAccount}extraction/download-excel-files> 
#a opmw:WorkflowExecutionProcess ;
#opmw:correspondsToTemplateProcess <$workflowTemplate/extraction/download-excel-files> ;
##opmw:used <????>;
#opmw:wasControlledBy $agent ;
#opmw:account $workflowAccount ;
#.
#" >> $workflowExecutionDescription;
#
#echo "<${workflowAccount}extraction/convert-excel-to-csv>
#a opmw:WorkflowExecutionProcess ; 
#opmw:correspondsToTemplateProcess <$workflowTemplate/extraction/download-excel-files> ;
##opmw:used <????> ;
#opmw:wasControlledBy $agent ;
#opmw:account $workflowAccount ;
#opmv:wasTriggeredBy <${workflowAccount}extraction/download-excel-files> ;
#.
#" >> $workflowExecutionDescription;
#
##finish rdf/xml 
# echo "<rdf:Description rdf:about=\"/config/ease-of-doing-business\">
#        <dcterms:identifier>ease-of-doing-business</dcterms:identifier>
#        <dcterms:title>Ease of Doing Business</dcterms:title>
#        <skos:notation>0</skos:notation>
#    </rdf:Description>\n" >> ../data/config.rdf;
#
# let "year+=$startYear+1";
# echo "<rdf:Description rdf:about=\"/config/start-year\">
#        <sdmx-dimension:refPeriod>$year</sdmx-dimension:refPeriod>
#    </rdf:Description>\n" >> ../data/config.rdf;
#
# echo "<rdf:Description rdf:about=\"conifg/start-time\">
# 		<opmw:overallStartTime>$startTime</opmw:overallStartTime>
# 		</rdf:Description>\n" >> ../data/config.rdf;
#
#echo "</rdf:RDF>" >> ../data/config.rdf;
#