#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch
#Date: 2014-12-21
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

			if [ ! -f ../data/topicId.$realYear.$topicId.html ] ; then
				query="http://www.doingbusiness.org/Custom-Query?topicIds=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$topicId&EconomyIds=2,3,4,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,36,33,34,35,38,39,41,42,46,47,48,49,50,51,52,54,55,56,57,58,59,60,61,62,63,64,65,66,68,69,70,72,73,74,75,76,77,79,81,82,83,84,85,86,43,87,88,89,90,91,92,93,95,96,97,98,99,100,101,102,104,375,105,106,107,108,109,110,111,112,114,115,116,117,118,119,120,121,122,123,124,125,127,128,129,131,210,132,133,134,135,136,137,140,141,142,143,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,561,162,163,164,206,165,166,167,168,169,170,172,545,173,174,175,176,177,178,179,180,181,182,183,45,184,185,186,209,187,188,189,190,191,193,194,195,196,197,198,199,200,201,202,204,205,207,208&Years=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$currentYear&ajax=1&excel=true";
				wget -O ../data/topicId.$realYear.$topicId.html $query;
		fi 
		done
done

#download country codes from World Bank
if [ ! -f ../data/countryCodes.csv ] ; then
	wget -O ../data/countryCodes.csv "http://worldbank.270a.info/sparql?query=%0D%0APREFIX+rdf%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0D%0APREFIX+rdfs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0D%0APREFIX+xsd%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%23%3E%0D%0APREFIX+owl%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2002%2F07%2Fowl%23%3E%0D%0APREFIX+dcterms%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2F%3E%0D%0APREFIX+foaf%3A+%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0D%0APREFIX+skos%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2004%2F02%2Fskos%2Fcore%23%3E%0D%0APREFIX+wgs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2003%2F01%2Fgeo%2Fwgs84_pos%23%3E%0D%0APREFIX+dbo%3A+%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0D%0APREFIX+dbp%3A+%3Chttp%3A%2F%2Fdbpedia.org%2Fproperty%2F%3E%0D%0APREFIX+dbr%3A+%3Chttp%3A%2F%2Fdbpedia.org%2Fresource%2F%3E%0D%0APREFIX+sdmx%3A+%3Chttp%3A%2F%2Fpurl.org%2Flinked-data%2Fsdmx%23%3E%0D%0APREFIX+sdmx-attribute%3A+%3Chttp%3A%2F%2Fpurl.org%2Flinked-data%2Fsdmx%2F2009%2Fattribute%23%3E%0D%0APREFIX+sdmx-dimension%3A+%3Chttp%3A%2F%2Fpurl.org%2Flinked-data%2Fsdmx%2F2009%2Fdimension%23%3E%0D%0APREFIX+sdmx-measure%3A+%3Chttp%3A%2F%2Fpurl.org%2Flinked-data%2Fsdmx%2F2009%2Fmeasure%23%3E%0D%0APREFIX+qb%3A+%3Chttp%3A%2F%2Fpurl.org%2Flinked-data%2Fcube%23%3E%0D%0APREFIX+year%3A+%3Chttp%3A%2F%2Freference.data.gov.uk%2Fid%2Fyear%2F%3E%0D%0APREFIX+void%3A+%3Chttp%3A%2F%2Frdfs.org%2Fns%2Fvoid%23%3E%0D%0A%0D%0APREFIX+wbld%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2F%3E%0D%0APREFIX+property%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fproperty%2F%3E%0D%0APREFIX+classification%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2F%3E%0D%0APREFIX+indicator%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Findicator%2F%3E%0D%0APREFIX+country%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fcountry%2F%3E%0D%0APREFIX+income-level%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fincome-level%2F%3E%0D%0APREFIX+lending-type%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Flending-type%2F%3E%0D%0APREFIX+region%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fregion%2F%3E%0D%0APREFIX+source%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fsource%2F%3E%0D%0APREFIX+topic%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Ftopic%2F%3E%0D%0APREFIX+currency%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fcurrency%2F%3E%0D%0APREFIX+project%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fproject%2F%3E%0D%0APREFIX+loan-status%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Floan-status%2F%3E%0D%0APREFIX+variable%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fvariable%2F%3E%0D%0APREFIX+global-circulation-model%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fglobal-circulation-model%2F%3E%0D%0APREFIX+scenario%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fclassification%2Fscenario%2F%3E%0D%0A%0D%0APREFIX+stats%3A+%3Chttp%3A%2F%2Fstats.270a.info%2Fvocab%23%3E%0D%0A%0D%0APREFIX+d-indicators%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fdataset%2Fworld-bank-indicators%3E%0D%0APREFIX+d-finances%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fdataset%2Fworld-bank-finances%2F%3E%0D%0APREFIX+d-climates%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fdataset%2Fworld-bank-climates%2F%3E%0D%0A%0D%0A%23USE+THESE+GRAPHS+%3A%29%0D%0APREFIX+g-void%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fvoid%3E%0D%0APREFIX+g-meta%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fmeta%3E%0D%0APREFIX+g-climates%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fworld-bank-climates%3E%0D%0APREFIX+g-finances%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fworld-bank-finances%3E%0D%0APREFIX+g-projects%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fworld-bank-projects-and-operations%3E%0D%0APREFIX+g-indicators%3A+%3Chttp%3A%2F%2Fworldbank.270a.info%2Fgraph%2Fworld-development-indicators%3E%0D%0A%0D%0Aselect+%3F2letterCode+%3Fname+%3F3letterCode+WHERE{%0D%0A%3Fcountry+a+dbo%3ACountry.%0D%0A%3Fcountry+skos%3Anotation+%3F2letterCode.%0D%0A%3Fcountry+skos%3AprefLabel+%3Fname.%0D%0A%3Fcountry+skos%3AexactMatch+%3FwbCountry.%0D%0A%3FwbCountry+skos%3Anotation+%3F3letterCode.%0D%0A}%0D%0A&default-graph-uri=&output=csv&stylesheet=&force-accept=text%2Fplain";
fi

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