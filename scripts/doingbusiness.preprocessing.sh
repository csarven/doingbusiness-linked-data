#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch
#Date: 2014-12-21
#doingbusiness.preprocessing.sh

files=../data/*.2*.txt;
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
currentYear=$(xpath -e "//rdf:Description[1]/sdmx-dimension:refPeriod/text()" $path);
endYear=$(xpath -e "//rdf:Description[2]/sdmx-dimension:refPeriod/text()" $path);
echo $endYear;
echo $currentYear;

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
			ssconvert -O 'separator=;' ../data/topicId.$currentYear.$topicId.html ../data/topicId.$currentYear.$topicId.txt;

			#get topic name and refine it
			topicName=$(head -1 ../data/topicId.$currentYear.$topicId.txt | cut -d ';' -f 5 | sed 's/"//g');
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
            mv ../data/topicId.$currentYear.$topicId.txt ../data/$lowerCaseName.$currentYear.txt;


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

#refine data files
for file in $files ; do

	if [ ! -f $file ]; then
    	>&2 echo "Error: the the following path and/or file does not exist: $file. Make sure to run previous workflow step first (doingbusiness.get.sh).";
    	exit 1;
	fi
	head -n 2 $file | tr '[:upper:]' '[:lower:]' | sed "1d" > $file.temp.refined.txt;

	tail -n+3 $file >> $file.temp.refined.txt;

	sed "1s/^/economy;refPeriod;rank-overall;dtf-overall;/" $file.temp.refined.txt > $file.temp2.refined.txt;

	rm $file.temp.refined.txt;

	filename=$(basename $file);
	filename="${filename%.*}"

	echo "Refining $filename...";
	sed "1s/(//g" $file.temp2.refined.txt | sed "1s/)//g" | sed "1s/ number//g" | sed "1s/ /-/g"  | sed "1s/time-//g" | sed "1s/%/in-percent/g" | sed 's/"//g' | sed 's/;;//g' | sed 's/\.\.//g' | sed '1s/[0-9]//g' | sed "1s/--\.//g" | sed '1s/--//g' | sed '1s/outcomeas-piecemeal-sale-andas-going-concern/outcome/g' | sed "1s/'//g" | sed '1s/to-export-days/days-to-export/' | sed '1s/to-import-days/days-to-import/' | sed "1s/us\\$/in-us-dollar/g" | sed "1s/deflated-us\\$/in-deflated-us-dollar/g" | sed "1s/min\./minimum/" >> ../data/$filename.refined.txt

	rm $file.temp2.refined.txt;

	#remove CRLF line terminators from data
	dos2unix ../data/$filename.refined.txt

	#sort refined files
	echo "Sort data files...";
	head -1 ../data/$filename.refined.txt > ../data/$filename.sorted.txt;
	sed 1d ../data/$filename.refined.txt | LANG=en_EN sort -k 1 -t';' >> ../data/$filename.sorted.txt;

done

#refine country codes
echo "Refine country codes";
sed 1d ../data/countryCodes.csv | sed "s/\"//g" | sed "s/, /XXX/g"  > ../data/countryCodes.refined.csv;

#remove CRLF line terminators from data
dos2unix ../data/countryCodes.refined.csv;

#sort country codes
echo "Sort country codes";
head -1 ../data/countryCodes.refined.csv > ../data/temp.txt;
sed 1d ../data/countryCodes.refined.csv | sort -k 3 -t',' >> ../data/temp.txt;

#change deliminater
sed "s/,/;/g" ../data/temp.txt | sed "s/XXX/, /g" > ../data/countryCodes.sorted.txt;
rm ../data/temp.txt; 

#convert DB codes
ssconvert -O 'separator=;' DB-codes.xlsx ../data/DB-codes.txt;

#refine DB codes
echo "Refine codes from Doing Business";
sed 1d ../data/DB-codes.txt | sed "s/\"//g" | awk -F";" '{print $1 ";" $3}' | sed "s/ ;/;/g" > ../data/DB-codes.refined.txt;

#remove CRLF line terminators from data
dos2unix ../data/DB-codes.refined.txt;

#sort DB codes
echo "Sort codes from Doing Business";
env LC_COLLATE=C sort -k 1 -t';' ../data/DB-codes.refined.txt > ../data/DB-codes.sorted.txt;

#first join
echo "Joining...";
join -t';' -1 1 -2 3 -o 0 1.2 2.1 ../data/DB-codes.sorted.txt ../data/countryCodes.sorted.txt | awk -F";" '{print $2 ";" $3}' > ../data/../data/mergedCodes.txt;

#Add countries with sub-economies
echo "Insert economies with sub-economies";
echo "Japan - Osaka;JP-OSA" >> ../data/mergedCodes.txt;
echo "Japan - Tokyo;JP-TYO" >> ../data/mergedCodes.txt;
echo "Bangladesh - Chittagong;BD-CGP" >> ../data/mergedCodes.txt;
echo "Bangladesh - Dhaka;BD-DAC" >> ../data/mergedCodes.txt;
echo "Brazil - Rio de Janeiro;BR-RIO" >> ../data/mergedCodes.txt;
echo "Brazil - São Paulo;BR-SAO" >> ../data/mergedCodes.txt;
echo "China - Beijing;CN-BJS" >> ../data/mergedCodes.txt;
echo "China - Shanghai;CN-SGH" >> ../data/mergedCodes.txt;
echo "Indonesia - Jakarta;ID-JKT" >> ../data/mergedCodes.txt;
echo "Indonesia - Surabaya;ID-SUB" >> ../data/mergedCodes.txt;
echo "India - Delhi;IN-DEL" >> ../data/mergedCodes.txt;
echo "India - Mumbai;IN-BOM" >> ../data/mergedCodes.txt;
echo "Mexico - Mexico City;MX-MEX" >> ../data/mergedCodes.txt;
echo "Mexico - Monterrey;MX-MTY" >> ../data/mergedCodes.txt;
echo "Nigeria - Kano;NG-KAN" >> ../data/mergedCodes.txt;
echo "Nigeria - Lagos;NG-LOS" >> ../data/mergedCodes.txt;
echo "Pakistan - Karachi;PK-KHI" >> ../data/mergedCodes.txt;
echo "Pakistan - Lahore;PK-LHE" >> ../data/mergedCodes.txt;
echo "Russian Federation - Moscow;RU-MOW" >> ../data/mergedCodes.txt;
echo "Russian Federation - Saint Petersburg;RU-LED" >> ../data/mergedCodes.txt;
echo "United States - Los Angeles;US-LAX" >> ../data/mergedCodes.txt;
echo "United States - New York City;US-NYC" >> ../data/mergedCodes.txt;

#sort codes agin
echo "Sorting codes again...";
LANG=en_EN sort -s -t';' -k1 ../data/mergedCodes.txt > ../data/merged.sorted.codes.txt;

sortedFiles=../data/*.2*.sorted.txt;

#second join
echo "Merge sorted codes with data";
for file in $sortedFiles ; do

	filename=$(basename $file);
	filename="${filename%.*}"

	echo $file; 
	head -1 $file > ../data/$filename.merged.txt;
	sed 1d $file > ../data/temp.txt;
	LANG=en_EN join -t';' -1 1 -2 1 ../data/merged.sorted.codes.txt ../data/temp.txt >> ../data/$filename.merged.txt;
	rm ../data/temp.txt;
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