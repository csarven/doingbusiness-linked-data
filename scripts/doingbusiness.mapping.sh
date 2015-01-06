#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Mdoingbusiness.mapping.sh
. ./config.sh
. ./common.sh

filesTarql=../data/*mapping.*.2*.txt
filesPreprocessed=../data/*.preprocessed.csv

#add underscores to header of transformable file for tarql
for file in $filesPreprocessed
do
	filename=$(basename $file);
	filename="${filename%.*}";
	newname=`echo "$filename" | sed -e 's/preprocessed/transformable/'`; 
	head -n 1 $file | sed 's/-/_/g' > ../data/$newname.csv;
	sed 1d $file >> ../data/$newname.csv;
done

#create the tarql queries
. ./doingbusiness.create.tarql.sh

#use tarql to map the data
transformableFiles=./*tarql.query*.txt
for file in $transformableFiles
do
	echo "Still mapping...";
	echo "...";
	filename=$(basename $file);
	filename="${filename%.*}";
	newname=`echo "$filename" | sed -e 's/tarql\.query\./mapped\./'`; 
	helper=`echo "$filename" | sed -e 's/doingbusiness\.tarql\.query\.//' | sed 's/\./-/'`; 
	tarql $file >> ../data/$newname.ttl;


	referenceToDescription="$helper-preprocessed";
	mappedData="$helper-turtle-data";
	date=`date +%Y%m%dT%H%M%S%Z`;
	artifact=$(xpath -e "//opmw:WorkflowExecutionArtifact[@name='$referenceToDescription']/text()" $workflowConfig);
	if [ ! -z $artifact ]; then
	account=$(xpath -e "//rdf:Description[1]/opmo:account/text()" $workflowConfig);
	
	echo "<$namespace/process/mapping/csv-rdf/$date>
	a opmw:WorkflowExecutionProcess ;
	opmw:correspondsToTemplateProcess <$workflowTemplate/mapping/csv-rdf> ;
	opmv:used <$artifact> ; 
	opmv:wasControlledBy <$agent> ;
	opmo:account <$account> ;
	.
	" >> $workflowExecutionDescription;

	echo "
	<$namespace/data/$mappedData/$date>
	a opmw:WorkflowExecutionArtifact ;
	opmo:account <$account> ;
	opmv:wasGeneratedBy <$namespace/process/mapping/csv-rdf/$date> ;
	opmw:correspondsToTemplateArtifact <$workflowTemplate/turtle-data> ;
	.
	" >> $workflowExecutionDescription;

	addWorkflowArtifact $newname $namespace/data/$newname/$date
fi
done

echo "<$workflowTemplate/mapping/csv-rdf> a opmw:WorkflowTemplateProcess ;
opmw:uses <$workflowTemplate/preprocessing/preprocessed-data> ;
opmw:isStepOfTemplate <$workflowTemplate> ;
." >> $abstractWorkflowDescription;

echo "<$workflowTemplate/turtle-data>
a opmw:WorkflowTemplateArtifact, opmw:DataVariable ;
opmw:isGeneratedBy <$workflowTemplate/mapping/csv-rdf> ;
opmw:correspondsToTemplate <$workflowTemplate> ;
.
" >> $abstractWorkflowDescription;

echo "Mapping finished";
