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

echo "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix qb: <http://purl.org/linked-data/cube#> .
@prefix sdmx: <http://purl.org/linked-data/sdmx#> .
@prefix sdmx-attribute: <http://purl.org/linked-data/sdmx/2009/attribute#> .
@prefix sdmx-code: <http://purl.org/linked-data/sdmx/2009/code#> .
@prefix sdmx-concept: <http://purl.org/linked-data/sdmx/2009/concept#> .
@prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#> .
@prefix sdmx-measure: <http://purl.org/linked-data/sdmx/2009/measure#> .
@prefix sdmx-metadata: <http://purl.org/linked-data/sdmx/2009/metadata#> .
@prefix doingbusiness: <http://doingbusiness.270a.info/> .
@prefix measure: <http://doingbusiness.270a.info/measure/> .
@prefix doingbusiness-dataset: <http://doingbusiness.270a.info/dataset/> .
@prefix doingbusiness-structure: <http://doingbusiness.270a.info/structure/> .
@prefix dataset: <http://doingbusiness.270a.info/dataset/> .
@prefix structure: <http://doingbusiness.270a.info/structure/> .
@prefix component: <http://doingbusiness.270a.info/component/> .
@prefix dimension: <http://doingbusiness.270a.info/dimension/> .
@prefix concept: <http://doingbusiness.270a.info/concept/> .
@prefix concept-indicator: <http://doingbusiness.270a.info/concept/indicator/> .
@prefix code: <http://doingbusiness.270a.info/code/> .
@prefix code-indicator: <http://doingbusiness.270a.info/code/indicator/> .
@prefix economy: <http://doingbuinsess.270a.info/code/economy/> ." > meta.ttl;
printf "\n" >> meta.ttl;

#loop every indicator to create the DataStructureDefinition and the dataset
arrayLength=${#codeIndicators[@]}

    #take "random" file to map the ease-of-doing-business
    indicatorFiles=doingbusiness.tarql.dsd.query.*
    for file in $indicatorFiles
    do
        tarql $file > temp.ttl;
        sed '/^@/ d' temp.ttl >> meta.ttl;
    done

#create the indicators
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

indicatorsToLoop=();
for((i=0; i < ${arrayLenght}; i++));
do
    if [ ${codeIndicators[$i]} == 'ease-of-doing-business' ];
        then
            echo "component:economy
    a qb:ComponentSpecification ;
    qb:dimension sdmx-dimension:refArea ;
        .

component:refPeriod
    a qb:ComponentSpecification ;
    qb:dimension sdmx-dimension:refPeriod ;
        .
    " >> meta.ttl;

    if [ ! -f "../data/${codeIndicators[0]}.$startDate.preprocessed.csv" ]; then
        >&2 echo "Error: the the following path and/or file does not exist: ../data/${codeIndicators[0]}.$startDate.preprocessed.csv. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
        exit 1;
    fi
    
    indicators=$(head -n 1 ../data/${codeIndicators[0]}.$startDate.preprocessed.csv | cut -d',' -f3-4 | sed 's/,/ /g');
    indicatorsToLoop+=($indicators);
        else
                if [ ! -f "../data/${codeIndicators[0]}.$startDate.preprocessed.csv" ]; then
                    >&2 echo "Error: the the following path and/or file does not exist: ../data/${codeIndicators[0]}.$startDate.preprocessed.csv. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
                    exit 1;
                fi
                
                indicators=$(head -n 1 ../data/${codeIndicators[$i]}.$startDate.preprocessed.csv | cut -d',' -f5- | sed 's/,/ /g');
                indicatorsToLoop+=($indicators);
    fi
done

sortedUniqueIndicators+=($(echo "${indicatorsToLoop[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));

sortedUniqueIndicatorsLength=${#sortedUniqueIndicators[@]};

for ((i=0; i<${sortedUniqueIndicatorsLength}; i++));
do
    echo "component:${sortedUniqueIndicators[$i]}
    a qb:ComponentSpecification ;
    qb:measure measure:${sortedUniqueIndicators[$i]} ;
    ." >> meta.ttl;
    printf "\n" >> meta.ttl;

    echo "measure:${sortedUniqueIndicators[$i]}
    a qb:MeasureProperty ;
    rdfs:label \"\"@en ;
    #TODO: Add range
    ." >> meta.ttl;
    printf "\n" >> meta.ttl;
done