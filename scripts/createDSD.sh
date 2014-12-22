#!/bin/bash
#Creates dsd file for Doing Business

path="../data/config.rdf";

if [ ! -f $path ]; then
    >&2 echo "Error: the the following path and/or file does not exist: $path. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
    exit 1;
fi
numberOfTopics=$(grep -c dcterms:identifier $path);
codeIndicators=();
codeIndicatorLabels=();
licence="<http://creativecommons.org/publicdomain/zero/1.0/>";

for((i=1; i <= ${numberOfTopics}; i++));
do
    topic=$(xpath $path "//rdf:Description[$i]/dcterms:identifier/text()");
    codeIndicators+=($topic);
    label=$(xpath $path "//rdf:Description[$i]/dcterms:title/text()");
    codeIndicatorLabels+=("$(xpath $path "//rdf:Description[$i]/dcterms:title/text()")");
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

for ((i=0; i<${arrayLength}; i++));
do
    echo "#" >> meta.ttl;
    echo "# ${codeIndicatorLabels[$i]} dataset" >> meta.ttl;
    echo "#" >> meta.ttl;
    printf "\n" >> meta.ttl;

    echo "dataset:${codeIndicators[$i]}
    a qb:DataSet ;
    qb:structure structure:${codeIndicators[$i]} ;
    dcterms:title \"${codeIndicatorLabels[$i]}\"@en ;" >> meta.ttl;

    if [ ${codeIndicators[$i]} != ease-of-doing-business ]
        then
            echo "    foaf:page <http://www.doingbusiness.org/data/exploretopics/${codeIndicators[$i]}> ;" >> meta.ttl;
        fi
    #TODO: Generate Date, no hardcode
    echo '    dcterms:issued "2014-12-04T00:00:00Z"^^xsd:dateTime ;
    dcterms:creator
        <http://renatostauffer.ch/> ,
        <http://csarven.ca/#i> ;
    dcterms:license '"${licence}"' ;
    .'>> meta.ttl;

    echo "
structure:${codeIndicators[$i]}
    a qb:DataStructureDefinition ;
    qb:component component:rank ;" >> meta.ttl;

    if [ ${codeIndicators[$i]} != ease-of-doing-business ]
        then
            echo "    qb:component component:dtf ;" >> meta.ttl;
        fi
    
    echo "    qb:component component:economy ;
    qb:component component:refPeriod ;
    qb:component component:indicator-${codeIndicators[$i]} ;" >> meta.ttl;

    #loop through each component of each code-indicator
    case "${codeIndicators[$i]}" in 
        dealing-with-construction-permits)
            for component in "${componentsDealingWithConstructionPermits[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        enforcing-contracts)
            for component in "${componentsEnforcingContraacts[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        getting-credit)
            for component in "${componentsGettingCredit[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        getting-electricity)
            for component in "${componentsGettingElectricity[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        paying-taxes)
            for component in "${componentsPayingTaxes[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        protecting-minority-investors)
            for component in "${componentsProtectingMinorityInvestors[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        registering-property)
            for component in "${componentsRegisteringProperty[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        resolving-insolvency)
            for component in "${componentsResolvingInsolvency[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        starting-a-business)
            for component in "${componentsStartingABusiness[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        trading-across-borders)
            for component in "${componentsTradingAcrossBorders[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;
        ease-of-doing-business)
            for component in "${componentsEaseOfDoingBusiness[@]}"
                do
                    echo "    qb:component component:$component ;" >> meta.ttl;
                done
            ;;            
        *) echo "Error: This code-indicator does not exist..." >> meta.ttl;
            ;;    
    esac
    echo "." >> meta.ttl;
    printf "\n" >> meta.ttl;

    echo "code-indicator:${codeIndicators[$i]}
    a skos:Concept ;
    skos:inScheme code:indicator ;
    skos:topConceptOf code:indicator ;
    #TODO: Add definition
    #skos:definition \"\"@en ;
." >> meta.ttl;
    printf "\n" >> meta.ttl;
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
arrayLenght=${#codeIndicators[@]};
startDate=$(xpath $path "//rdf:Description/sdmx-dimension:refPeriod/text()");

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

    if [ ! -f "../data/${codeIndicators[0]}.$startDate.refined.csv" ]; then
        >&2 echo "Error: the the following path and/or file does not exist: ../data/${codeIndicators[0]}.$startDate.refined.csv. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
        exit 1;
    fi
    
    indicators=$(head -n 1 ../data/${codeIndicators[0]}.$startDate.refined.csv | cut -d',' -f3-4 | sed 's/,/ /g');
    indicatorsToLoop+=($indicators);

        else
                if [ ! -f "../data/${codeIndicators[0]}.$startDate.refined.csv" ]; then
                    >&2 echo "Error: the the following path and/or file does not exist: ../data/${codeIndicators[0]}.$startDate.refined.csv. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
                    exit 1;
                fi
                
                indicators=$(head -n 1 ../data/${codeIndicators[$i]}.$startDate.refined.csv | cut -d',' -f5- | sed 's/,/ /g');
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