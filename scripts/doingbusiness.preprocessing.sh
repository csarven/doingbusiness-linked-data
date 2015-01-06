#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Date: 2014-12-21
#doingbusiness.preprocessing.sh
. ./config.sh
. ./common.sh

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
currentYear=$(xpath -e "//rdf:Description[1]/sdmx-dimension:refPeriod/text()" $path);
endYear=$(xpath -e "//rdf:Description[2]/sdmx-dimension:refPeriod/text()" $path);

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
			if [ ! -s ../data/$currentYear.$topicId.html ] ; then
  				rm ../data/$currentYear.$topicId.html;
  				continue;
			fi
			echo "converting";
			ssconvert ../data/$currentYear.$topicId.html ../data/$currentYear.$topicId.csv;
			#get topic name and refine it
			topicName=$(head -1 ../data/$currentYear.$topicId.csv | cut -d ',' -f 5 | sed 's/"//g');
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
            mv ../data/$currentYear.$topicId.csv ../data/$lowerCaseName.$currentYear.csv;

            #Describe workflow execution - Convert html to csv
 			date=`date +%Y%m%dT%H%M%S%Z`;
 			artifact=$(xpath -e "//opmw:WorkflowExecutionArtifact[@name='$topicId-$currentYear']/text()" $workflowConfig);
 			account=$(xpath -e "//rdf:Description[1]/opmo:account/text()" $workflowConfig);
 			echo "<$namespace/process/preprocessing/html-csv/$date>
 			a opmw:WorkflowExecutionProcess ;
 			opmw:correspondsToTemplateProcess <$workflowTemplate/preprocessing/html-csv>;
 			opmv:used <$artifact> ;
 			opmv:wasControlledBy <$agent> ;
 			opmo:account <$account> ;
 			.
 			" >> $workflowExecutionDescription;
 			echo "
 			<$namespace/data/$lowerCaseName-$currentYear/$date>
 			a opmw:WorkflowExecutionArtifact ;
 			opmo:account <$account> ;
 			opmv:wasGeneratedBy <$namespace/process/preprocessing/html-csv/$date> ;
 			opmw:correspondsToTemplateArtifact <$workflowTemplate/dataset-csv> ;
 			.
 			" >> $workflowExecutionDescription;
 			echo "done...";
            addWorkflowArtifact $lowerCaseName-$currentYear $namespace/data/$lowerCaseName-$currentYear/$date
		done

	#first run over
	firstLoopRun=0;

done 

#Describe abstract workflow process - convert html to csv
echo "<$workflowTemplate/preprocessing/html-csv> a opmw:WorkflowTemplateProcess ;
opmw:uses <$workflowTemplate/dataset-html> ;
opmw:isStepOfTemplate <$workflowTemplate> ;
." >> $abstractWorkflowDescription;

echo "<$workflowTemplate/dataset-csv>
a opmw:WorkflowTemplateArtifact, opmw:DataVariable ;
opmw:isGeneratedBy <$workflowTemplate/preprocessing/html-csv> ;
opmw:correspondsToTemplate <$workflowTemplate> ;
.
" >> $abstractWorkflowDescription;


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

	head -n 2 $file | tr '[:upper:]' '[:lower:]' | sed "1d" > $file.temp.refined.csv;

	tail -n+3 $file >> $file.temp.refined.csv;

	sed "1s/^/economy,refArea,refPeriod,rank-overall,dtf-overall,/" $file.temp.refined.csv > $file.temp2.refined.csv;

	rm $file.temp.refined.csv;

	filename=$(basename $file);
	filename="${filename%.*}"

	echo "Refining $filename...";
	sed "1s/(//g" $file.temp2.refined.csv | sed "1s/)//g" | sed "1s/ number//g" | sed "1s/ /-/g"  | sed "1s/time-//g" | sed "1s/%/in-percent/g" | sed 's/"//g' | sed 's/,,//g' | sed 's/\.\.//g' | sed 's/, /XXX/g' | sed 's/no practice//g' | sed '1s/[0-9]//g' | sed "1s/--\.//g" | sed '1s/--//g' | sed '1s/outcomeas-piecemeal-sale-andas-going-concern/outcome/g' | sed "1s/'//g" | sed '1s/to-export-days/days-to-export/' | sed '1s/to-import-days/days-to-import/' | sed "1s/us\\$/in-us-dollar/g" | sed "1s/deflated-us\\$/in-deflated-us-dollar/g" | sed "1s/min\./minimum/" >> ../data/$filename.refined.csv

	rm $file.temp2.refined.csv;

	#remove CRLF line terminators from data
	dos2unix ../data/$filename.refined.csv

	#sort refined files
	echo "Sort data files...";
	head -1 ../data/$filename.refined.csv > ../data/$filename.sorted.csv;
	sed 1d ../data/$filename.refined.csv | LANG=en_EN sort -k 1 -t',' >> ../data/$filename.sorted.csv;

	#remove unnecessary stuff..
	rm ../data/$filename.refined.csv;
done

#Sorting Codes
#refine country codes - mask ',' in country labels as XXX
echo "Refine country codes";
sed 1d ../data/countryCodes.csv | sed "s/\"//g" | sed "s/, /XXX/g" | awk -F"," '{print $1 "," $3 "," $4}' > ../data/countryCodes.refined.csv;

#remove CRLF line terminators from data
dos2unix ../data/countryCodes.refined.csv;

#sort country codes
echo "Sort country codes";
head -1 ../data/countryCodes.refined.csv > ../data/countryCodes.sorted.csv;
sed 1d ../data/countryCodes.refined.csv | env LC_COLLATE=C sort -k 3 -t',' >> ../data/countryCodes.sorted.csv;

#remove unnecessary stuff
rm ../data/countryCodes.refined.csv;

#convert DB codes
ssconvert DB-codes.xlsx ../data/DB-codes.csv;

#refine DB codes
echo "Refine codes from Doing Business";
sed 1d ../data/DB-codes.csv | sed "s/\"//g" | sed "s/, /XXX/g" | awk -F"," '{print $1 "," $3}' | sed "s/ ,/,/g" > ../data/DB-codes.refined.csv;

#remove unnecessary stuff
rm ../data/DB-codes.csv;

#remove CRLF line terminators from data
dos2unix ../data/DB-codes.refined.csv;

#sort DB codes
echo "Sort codes from Doing Business";
env LC_COLLATE=C sort -k 1 -t',' ../data/DB-codes.refined.csv > ../data/DB-codes.sorted.csv;

#remove unnecessary stuff
rm ../data/DB-codes.refined.csv;

#first join
echo "Joining...";
join -t',' -1 1 -2 3 -o 0 1.2 2.2 ../data/DB-codes.sorted.csv ../data/countryCodes.sorted.csv | awk -F"," '{print $2 "," $3}' > ../data/../data/mergedCodes.csv;

#remove unncessary stuff
rm ../data/DB-codes.sorted.csv;
rm ../data/countryCodes.sorted.csv;

#Add countries with sub-economies
echo "Insert economies with sub-economies";
echo "Japan - Osaka,JP-OSA" >> ../data/mergedCodes.csv;
echo "Japan - Tokyo,JP-TYO" >> ../data/mergedCodes.csv;
echo "Bangladesh - Chittagong,BD-CGP" >> ../data/mergedCodes.csv;
echo "Bangladesh - Dhaka,BD-DAC" >> ../data/mergedCodes.csv;
echo "Brazil - Rio de Janeiro,BR-RIO" >> ../data/mergedCodes.csv;
echo "Brazil - São Paulo,BR-SAO" >> ../data/mergedCodes.csv;
echo "China - Beijing,CN-BJS" >> ../data/mergedCodes.csv;
echo "China - Shanghai,CN-SGH" >> ../data/mergedCodes.csv;
echo "Indonesia - Jakarta,ID-JKT" >> ../data/mergedCodes.csv;
echo "Indonesia - Surabaya,ID-SUB" >> ../data/mergedCodes.csv;
echo "India - Delhi,IN-DEL" >> ../data/mergedCodes.csv;
echo "India - Mumbai,IN-BOM" >> ../data/mergedCodes.csv;
echo "Mexico - Mexico City,MX-MEX" >> ../data/mergedCodes.csv;
echo "Mexico - Monterrey,MX-MTY" >> ../data/mergedCodes.csv;
echo "Nigeria - Kano,NG-KAN" >> ../data/mergedCodes.csv;
echo "Nigeria - Lagos,NG-LOS" >> ../data/mergedCodes.csv;
echo "Pakistan - Karachi,PK-KHI" >> ../data/mergedCodes.csv;
echo "Pakistan - Lahore,PK-LHE" >> ../data/mergedCodes.csv;
echo "Russian Federation - Moscow,RU-MOW" >> ../data/mergedCodes.csv;
echo "Russian Federation - Saint Petersburg,RU-LED" >> ../data/mergedCodes.csv;
echo "United States - Los Angeles,US-LAX" >> ../data/mergedCodes.csv;
echo "United States - New York City,US-NYC" >> ../data/mergedCodes.csv;

#sort codes agin
echo "Sorting codes again...";
LANG=en_EN sort -s -t',' -k1 ../data/mergedCodes.csv > ../data/merged.sorted.codes.csv;

#remove unnecessary stuff
rm ../data/mergedCodes.csv;

sortedFiles=../data/*.2*.sorted.csv;

#second join
echo "Merge sorted codes with data";
for file in $sortedFiles ; do

	filename=$(basename $file);
	filename="${filename%.*}";
	newname=`echo "$filename" | sed -e 's/sorted/preprocessed/'`;
	referenceForWorkflowDescpription=`echo "$filename" | sed -e 's/\.sorted//' | sed -e 's/\./-/'`;
	head -1 $file > ../data/$newname.csv;
	sed 1d $file > ../data/temp.csv;
	LANG=en_EN join -t',' -1 1 -2 1 ../data/merged.sorted.codes.csv ../data/temp.csv >> ../data/$filename.tempjoin.csv;
	cat ../data/$filename.tempjoin.csv | awk -F, '{print "\""$1"\""}' | sed "s/XXX/, /g" > ../data/tempFirstLine.csv;
	cut -d',' -f2- ../data/$filename.tempjoin.csv > ../data/tempOtherLines.csv;
	paste -d',' ../data/tempFirstLine.csv ../data/tempOtherLines.csv >> ../data/$newname.csv;
	
	rm ../data/$filename.tempjoin.csv;
	rm ../data/tempFirstLine.csv;
	rm ../data/tempOtherLines.csv;
	rm ../data/temp.csv;
	#rm $file;

	#describe workflow processes
	#Workflow description - Merge Data
	date=`date +%Y%m%dT%H%M%S%Z`;
	artifactCountryCodes=$(xpath -e "//opmw:WorkflowExecutionArtifact[@name='countryCodes']/text()" $workflowConfig);
	artifactDatasets=$(xpath -e "//opmw:WorkflowExecutionArtifact[@name='$referenceForWorkflowDescpription']/text()" $workflowConfig);
	account=$(xpath -e "//rdf:Description[1]/opmo:account/text()" $workflowConfig);
	echo "<$namespace/process/preprocessing/merge-data/$date>
	a opmw:WorkflowExecutionProcess ;
	opmw:correspondsToTemplateProcess <$workflowTemplate/preprocessing/preprocessed-data> ;
	opmv:used <$artifactCountryCodes>, <$artifactDatasets> ; 
	opmv:wasControlledBy <$agent> ;
	opmo:account <$account> ;
	.
	" >> $workflowExecutionDescription;

	referenceForWorkflowDescpription+="-preprocessed"; 
	echo "
	<$namespace/data/$referenceForWorkflowDescpription/$date>
	a opmw:WorkflowExecutionArtifact ;
	opmo:account <$account> ;
	opmv:wasGeneratedBy <$namespace/process/preprocessing/merge-data/$date> ;
	opmw:correspondsToTemplateArtifact <$workflowTemplate/preprocessed-data>;
	.
	" >> $workflowExecutionDescription;

	addWorkflowArtifact $referenceForWorkflowDescpription $namespace/data/$referenceForWorkflowDescpription/$date
done

#remove unnecessary stuff
rm ../data/*2*sorted.csv;

echo "<$workflowTemplate/preprocessing/preprocessed-data> a opmw:WorkflowTemplateProcess ;
opmw:uses <$workflowTemplate/country-codes>, <$workflowTemplate/dataset-csv> ;
opmw:isStepOfTemplate <$workflowTemplate> ;
." >> $abstractWorkflowDescription;

echo "<$workflowTemplate/preprocessed-data>
a opmw:WorkflowTemplateArtifact, opmw:DataVariable ;
opmw:isGeneratedBy <$workflowTemplate/preprocessing/merge-data>;
opmw:correspondsToTemplate <$workflowTemplate> ;
.
" >> $abstractWorkflowDescription;
