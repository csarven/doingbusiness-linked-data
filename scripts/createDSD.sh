#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Date: 2014-12-21
#Creates dsd file for Doing Business
. ./config.sh

#grab the first year
startDate=$(xpath -e "//rdf:Description[1]/sdmx-dimension:refPeriod/text()" $metaConfig);
echo "First year = $startDate";

if [ ! -f $metaConfig ]; then
    >&2 echo "Error: the the following path and/or file does not exist: $metaConfig. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
    exit 1;
fi

numberOfTopics=$(grep -c "Description rdf:about=" $metaConfig);
echo "$numberOfTopics number of topics!";
codeIndicators=();
codeIndicatorLabels=();
licence="<http://creativecommons.org/publicdomain/zero/1.0/>";

index=0;
for((i=0; i <= ${numberOfTopics}; i++));
do
    let index+=1;
    topic=$(xpath -e "//rdf:Description[$index]/dcterms:identifier/text()" $metaConfig);
    if [ ! -z "$topic" ]; then
        codeIndicators+=($topic);
    fi

    label=("$(xpath -e "//rdf:Description[$index]/dcterms:title/text()" $metaConfig)");
    if [ ! -z "$label" ]; then
        codeIndicatorLabels+=("$label");
    fi
done

echo "#Meta file" > meta.ttl;
#loop every indicator to create the DataStructureDefinition and the dataset
arrayLength=${#codeIndicators[@]}

    indicatorFiles=doingbusiness.tarql.dsd.query.*
    for file in $indicatorFiles
    do
        echo "Mapping $file";
        tarql $file > temp.ttl;
        sed '/^@/ d' temp.ttl >> meta.ttl;
    done

#create the indicators
echo "Creating indicators...";

echo "code:indicator
    skos:prefLabel \"Indicator Concept Scheme\"@en ;
    skos:hasTopConcept" >> meta.ttl;

#loop through every code-indicator and add it to skos:hasTopConcept.
for ((i=0; i<${arrayLength}; i++));
do
    printf "        code-indicator:${codeIndicators[$i]}" >> meta.ttl;
    if [ $i == $(($arrayLength-1)) ]
        then
            printf " ;\n" >> meta.ttl;
        else
            printf ",\n" >> meta.ttl;
        fi
done
echo "." >> meta.ttl;
printf "\n" >> meta.ttl;

#create the components for the indicators
echo "Creating components for the indicators...";
arrayLenght=${#codeIndicators[@]};
for((i=0; i < ${arrayLenght}; i++));
do
    tarql create-components-of-${codeIndicators[$i]} >> meta.ttl;
done

tarql create-shared-components >> meta.ttl;

sed '/^@/ d' meta.ttl > temp.ttl;

echo "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix qb: <http://purl.org/linked-data/cube#> .
@prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#> .
@prefix measure: <http://doingbusiness.270a.info/measure/> .
@prefix dataset: <http://doingbusiness.270a.info/dataset/> .
@prefix structure: <http://doingbusiness.270a.info/structure/> .
@prefix component: <http://doingbusiness.270a.info/component/> .
@prefix dimension: <http://doingbusiness.270a.info/dimension/> .
@prefix concept: <http://doingbusiness.270a.info/concept/> .
@prefix code: <http://doingbusiness.270a.info/code/> .
@prefix code-indicator: <http://doingbusiness.270a.info/code/indicator/> .
@prefix economy: <http://doingbuinsess.270a.info/code/economy/> ." > meta.ttl;
printf "\n" >> meta.ttl;
cat temp.ttl >> meta.ttl;