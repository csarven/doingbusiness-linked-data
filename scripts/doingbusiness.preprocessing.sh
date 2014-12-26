#!/bin/bash
#doingbusiness.preprocessing.sh

files=../data/*.2*.csv;
htmlFiles=../data/*.2*.html;
numberOfTopics=11;

#Needed because topics in the config.rdf file should only be genearted once
firstLoopRun=1;

if [ ! -f $file ]; then
    >&2 echo "Error: the the following path and/or file does not exist: $file. Make sure to run previous workflow step first (doingbusiness.get.sh).";
    exit 1;
fi

path="../data/config.rdf";

#get starting and ending year
currentYear=$(xpath $path "//rdf:Description[1]/sdmx-dimension:refPeriod/text()");
endYear=$(xpath $path "//rdf:Description[2]/sdmx-dimension:refPeriod/text()");
echo $endYear;

#open rdf for more info
sed "/<\/rdf:RDF>/d" ../data/config.rdf > temp.rdf;
cat temp.rdf > ../data/config.rdf;
rm temp.rdf;

#convert html files
for((currentYear; currentYear <= endYear; currentYear++))
do
	for ((i=0; i < numberOfTopics; i++))
		do
			#download
			let "topicId=$i+1";

			#converte to csv
			ssconvert ../data/topicId.$currentYear.$topicId.html ../data/topicId.$currentYear.$topicId.csv;

			#get topic name and refine it
			topicName=$(head -1 ../data/topicId.$currentYear.$topicId.csv | cut -d ',' -f 5 | sed 's/"//g');
			lowerCaseName=$(echo $topicName | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g');

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
            mv ../data/topicId.$currentYear.$topicId.csv ../data/$lowerCaseName.$currentYear.csv;
		done

	#first run over
	firstLoopRun=0;

done 

##finish rdf/xml 
echo "<rdf:Description rdf:about=\"/config/ease-of-doing-business\">
        <dcterms:identifier>ease-of-doing-business</dcterms:identifier>
        <dcterms:title>Ease of Doing Business</dcterms:title>
        <skos:notation>0</skos:notation>
    </rdf:Description>\n" >> ../data/config.rdf;

echo "</rdf:RDF>" >> ../data/config.rdf;

for file in $files ; do

	if [ ! -f $file ]; then
    	>&2 echo "Error: the the following path and/or file does not exist: $file. Make sure to run previous workflow step first (doingbusiness.get.sh).";
    	exit 1;
	fi
	head -n 2 $file | tr '[:upper:]' '[:lower:]' | sed "1d" > $file.temp.refined.csv;

	tail -n+3 $file >> $file.temp.refined.csv;

	sed "1s/^/economy,refPeriod,rank-overall,dtf-overall,/" $file.temp.refined.csv > $file.temp2.refined.csv;

	rm $file.temp.refined.csv;

	filename=$(basename $file);
	filename="${filename%.*}"

	echo "Refining $filename...";
	sed "1s/(//g" $file.temp2.refined.csv | sed "1s/)//g" | sed "1s/ number//g" | sed "1s/ /-/g"  | sed "1s/time-//g" | sed "1s/%/in-percent/g" | sed 's/"//g' | sed 's/,,//g' | sed 's/\.\.//g' | sed '1s/[0-9]//g' | sed "1s/--\.//g" | sed '1s/--//g' | sed '1s/outcomeas-piecemeal-sale-andas-going-concern/outcome/g' | sed "1s/'//g" | sed '1s/to-export-days/days-to-export/' | sed '1s/to-import-days/days-to-import/' | sed "1s/us\\$/in-us-dollar/g" | sed "1s/deflated-us\\$/in-deflated-us-dollar/g" | sed "1s/min\./minimum/" >> ../data/$filename.refined.csv

	rm $file.temp2.refined.csv;
done

#describe workflow processes
##echo "<${workflowTemplate}preprocessing/refine-csv-file>
 #   a opmw:WorkflowTemplateProcess;
 #   opmw:isStepOfTemplate <$workflowTemplate> ;
 #   p-plan:isPrecededBy <${workflowTemplate}extraction/convert-excel-csv> ;
 #   #opmw:uses <????> ;
 #   ." >> $abstractWorkflowDescription;
#
#echo "<${workflowAccount}preprocessing/refine-csv-file>
#a opmw:WorkflowExecutionProcess ; 
#opmw:correspondsToTemplateProcess <${workflowTemplate}preprocessing/refine-csv-file> ;
##opmw:used <????> ;
#opmw:wasControlledBy $agent ;
#opmw:account $workflowAccount ;
#opmv:wasTriggeredBy <${workflowAccount}extraction/convert-excel-to-csv> ;
#.
#" >> $workflowExecutionDescription;
#