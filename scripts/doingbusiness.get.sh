#!/bin/bash
#Create config xml

#Number of topics to be downloaded
numberOfTopics=11;

#Start and end year
#TODO: User input 
startYear=2003;
endYear=2014;
currentYear=$startYear;

#create cofig file
echo '<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#/"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#">' >../data/config.rdf;

#Needed because rdf file should only be created once.
firstLoopRun=1;

#Download data sources
for((currentYear; currentYear <= endYear; currentYear++))
do
	for ((i=0; i < numberOfTopics; i++))
		do
			#download
			let "topicId=$i+1";
			wget -O ../data/topicId.$currentYear.$topicId.html "http://www.doingbusiness.org/Custom-Query?topicIds=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$topicId&EconomyIds=2,3,4,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,36,33,34,35,38,39,41,42,46,47,48,49,50,51,52,54,55,56,57,58,59,60,61,62,63,64,65,66,68,69,70,72,73,74,75,76,77,79,81,82,83,84,85,86,43,87,88,89,90,91,92,93,95,96,97,98,99,100,101,102,104,375,105,106,107,108,109,110,111,112,114,115,116,117,118,119,120,121,122,123,124,125,127,128,129,131,210,132,133,134,135,136,137,140,141,142,143,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,561,162,163,164,206,165,166,167,168,169,170,172,545,173,174,175,176,177,178,179,180,181,182,183,45,184,185,186,209,187,188,189,190,191,193,194,195,196,197,198,199,200,201,202,204,205,207,208&Years=,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$currentYear&ajax=1&excel=true";

			#converte to csv
			ssconvert ../data/topicId.$currentYear.$topicId.html ../data/topicId.$currentYear.$topicId.csv;
			
			#remove html version
			rm ../data/topicId.$currentYear.$topicId.html;

			#get topic name and refine it
			topicName=$(head -1 ../data/topicId.$currentYear.$topicId.csv | cut -d ',' -f 5 | sed 's/"//g');
			lowerCaseName=$(echo $topicName | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g');
			echo $lowerCaseName;

			#write to rdf file if lower case topic name exist
			if [ -n "${lowerCaseName// }" ]; then
				if [  $firstLoopRun == 1 ]; then
				    echo "<rdf:Description rdf:about=\"/config/${lowerCaseName}\">
        <dcterms:identifier>${lowerCaseName}</dcterms:identifier>
        <dcterms:title>${topicName}</dcterms:title>
        <skos:notation>${topicId}</skos:notation>
    </rdf:Description>\n" >> ../data/config.rdf;
				fi
            fi

            #adjust year
            let "adjustedDateYear=$currentYear+1";
            mv ../data/topicId.$currentYear.$topicId.csv ../data/$lowerCaseName.$adjustedDateYear.csv;
		done

	#first run over
	firstLoopRun=0;
done

 echo "<rdf:Description rdf:about=\"/config/ease-of-doing-business\">
        <dcterms:identifier>ease-of-doing-business</dcterms:identifier>
        <dcterms:title>Ease of Doing Business</dcterms:title>
        <skos:notation>0</skos:notation>
    </rdf:Description>\n" >> ../data/config.rdf;

 let "year+=$startYear+1";
 echo "<rdf:Description rdf:about=\"/config/start-year\">
        <sdmx-dimension:refPeriod>$year</sdmx-dimension:refPeriod>
    </rdf:Description>\n" >> ../data/config.rdf;

echo "</rdf:RDF>" >> ../data/config.rdf;

