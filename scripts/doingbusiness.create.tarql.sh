#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Date: 2014-12-21
#generate traql file

path="../data/config.rdf";

#grab the first year
startYear=$(xpath -e "//rdf:Description[1]/sdmx-dimension:refPeriod/text()" $path);
endYear=$(xpath -e "//rdf:Description[2]/sdmx-dimension:refPeriod/text()" $path);
echo "First year = $startYear";
echo "Last year to process = $endYear";

if [ ! -f $path ]; then
    >&2 echo "Error: the the following path and/or file does not exist: $path. Make sure to run previous workflow step first (doingbusiness.get.sh, doingbusiness.preprocessing.sh).";
    exit 1;
fi

numberOfTopics=$(grep -c "Description rdf:about=" $path);

codeIndicators=();
codeIndicatorLabels=();
licence="<http://creativecommons.org/publicdomain/zero/1.0/>";

index=0;
for((i=0; i <= ${numberOfTopics}; i++));
do
    let index+=1;
    topic=$(xpath -e "//rdf:Description[$index]/dcterms:identifier/text()" $path);
    if [ ! -z "$topic" ]; then
        codeIndicators+=($topic);
    fi

    label=("$(xpath -e "//rdf:Description[$index]/dcterms:title/text()" $path)");
    if [ ! -z "$label" ]; then
        codeIndicatorLabels+=("$label");
    fi
done

#Loop years
for ((startYear;startYear<=endYear;startYear++)); do

#Loop indicators
arrayLength=${#codeIndicators[@]}

for ((i=0; i<${arrayLength}; i++)); do

echo "prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 
PREFIX dcterms: <http://purl.org/dc/terms/> 
PREFIX foaf: <http://xmlns.com/foaf/0.1/> 
PREFIX qb: <http://purl.org/linked-data/cube#> 
PREFIX sdmx: <http://purl.org/linked-data/sdmx#> 
PREFIX sdmx-attribute: <http://purl.org/linked-data/sdmx/2009/attribute#> 
PREFIX sdmx-code: <http://purl.org/linked-data/sdmx/2009/code#> 
PREFIX sdmx-concept: <http://purl.org/linked-data/sdmx/2009/concept#> 
PREFIX sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#> 
PREFIX sdmx-measure: <http://purl.org/linked-data/sdmx/2009/measure#> 
PREFIX sdmx-metadata: <http://purl.org/linked-data/sdmx/2009/metadata#> 
PREFIX doingbusiness: <http://doingbusiness.270a.info/> 
PREFIX measure: <http://doingbusiness.270a.info/measure/> 
PREFIX doingbusiness-dataset: <http://doingbusiness.270a.info/dataset/> 
PREFIX doingbusiness-structure: <http://doingbusiness.270a.info/structure/> 
PREFIX dataset: <http://doingbusiness.270a.info/dataset/>
PREFIX structure: <http://doingbusiness.270a.info/structure/> 
PREFIX component: <http://doingbusiness.270a.info/component/> 
PREFIX dimension: <http://doingbusiness.270a.info/dimension/> 
PREFIX concept: <http://doingbusiness.270a.info/concept/> 
PREFIX concept-indicator: <http://doingbusiness.270a.info/concept/indicator/> 
PREFIX code: <http://doingbusiness.270a.info/code/> 
PREFIX code-indicator: <http://doingbusiness.270a.info/code/indicator/> 
PREFIX economy: <http://doingbuinsess.270a.info/code/economy/>

" > doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;

echo "CONSTRUCT{" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;

if [ ${codeIndicators[$i]} != ease-of-doing-business ]
     then

echo "?observation
    a qb:Observation ; 
    qb:dataSet <http://doingbusiness.270a.info/dataset/${codeIndicators[$i]}> ;
    rdfs:label ?label ;
    measure:rank ?rankValue ;
    dimension:economy ?eco ;
    dimension:refPeriod ?year ;
    code:indicator ?indicator ;" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;

        #Loop components of indicator
        componentsToLoop=$(head -n 1 ../data/${codeIndicators[$i]}.$startYear.preprocessed.csv | cut -d',' -f8- | sed 's/,/ /g' | sed 's/-/_/g');
        components=();
        components+=($componentsToLoop);

        nonEscapedComponents=$(head -n 1 ../data/${codeIndicators[$i]}.$startYear.preprocessed.csv | cut -d',' -f8- | sed 's/,/ /g');
        componentsNonEscaped=();
        componentsNonEscaped+=($nonEscapedComponents);

        numberOfComponents=${#components[@]};

        for ((j=0; j<${numberOfComponents}; j++)); do
            echo "    measure:${componentsNonEscaped[$j]} ?${components[$j]}Value;" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
        done
        echo "measure:dtf ?dtfValue ;" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
     else
        echo "?observation
    a qb:Observation ; 
    qb:dataSet <http://doingbusiness.270a.info/dataset/${codeIndicators[$i]}> ;
    rdfs:label ?label ;
    measure:rank ?rankValue ;
    dimension:economy ?eco ;
    dimension:refPeriod ?year ;
    code:indicator ?indicator ;
    measure:overall-dtf ?dtfValue;" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
     fi

    echo "." >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
    echo "";

if [ ${codeIndicators[$i]} != ease-of-doing-business ]
     then

    echo "}
FROM <../data/${codeIndicators[$i]}.$startYear.transformable.csv>
WHERE {
    BIND (REPLACE(?refArea, \"^ + | +$\", '') AS ?area)
    BIND (STR(\"$startYear\") AS ?period)
    BIND (REPLACE(?economy, \"^ + | +$\", '') AS ?economyName)
    BIND (URI(\"http://doingbusiness.270a.info/code/indicator/${codeIndicators[$i]}\") AS ?indicator)
    BIND (URI(CONCAT(\"http://doingbuinsess.270a.info/code/economy/\", ?area, \"\")) AS ?eco)
    BIND (URI(CONCAT(\"http://doingbusiness.270a.info/dataset/${codeIndicators[$i]}/\", ?area ,\"/\", ?period, \"\")) AS ?observation)
    BIND (STRDT(REPLACE(?rank, \" +\", ''), xsd:integer) AS ?rankValue)
    BIND (URI(CONCAT(\"http://reference.data.gov.uk/id/year/\", ?period, \"\")) AS ?year)
    BIND (STRLANG(CONCAT(\"Observation for \", ?economyName ,\"for the indicator ${codeIndicatorLabels[$i]} in \", ?period, \"\"),\"en\") AS ?label)" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt; 

        #Loop components of indicator
        componentsToLoop=$(head -n 1 ../data/${codeIndicators[$i]}.$startYear.preprocessed.csv | cut -d',' -f8- | sed 's/,/ /g' | sed 's/-/_/g');
        components=();
        components+=($componentsToLoop);

        nonEscapedComponents=$(head -n 1 ../data/${codeIndicators[$i]}.$startYear.preprocessed.csv | cut -d',' -f8- | sed 's/,/ /g');
        componentsNonEscaped=();
        componentsNonEscaped+=($nonEscapedComponents);
    
        numberOfComponents=${#components[@]};
        for ((j=0; j<${numberOfComponents}; j++)); do
            echo "  BIND (STRDT(REPLACE(?${components[$j]}, \" +\", ''), xsd:decimal) AS ?${components[$j]}Value)" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt; 
        done

        echo "  BIND (STRDT(REPLACE(?dtf, \" +\", ''), xsd:decimal) AS ?dtfValue)" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
     else

    #take "random" file to map the ease-of-doing-business
    indicatorFiles=../data/*.$startYear.transformable.csv
    usedFile="";
    for file in $indicatorFiles
    do
        usedFile=$file;
        break;
    done
     echo "}
FROM <$usedFile>
WHERE {
    BIND (REPLACE(?refArea, \"^ + | +$\", '') AS ?area)
    BIND (STR(\"$startYear\") AS ?period)
    BIND (REPLACE(?economy, \"^ + | +$\", '') AS ?economyName)
    BIND (STRDT(REPLACE(?rank_overall, \" +\", ''), xsd:integer) AS ?rankValue)
    BIND (STRDT(REPLACE(?dtf_overall, \" +\", ''), xsd:decimal) AS ?dtfValue)
    BIND (URI(CONCAT(\"http://doingbuinsess.270a.info/code/economy/\", ?area, \"\")) AS ?eco)
    BIND (URI(\"http://doingbusiness.270a.info/code/indicator/${codeIndicators[$i]}\") AS ?indicator)
    BIND (URI(CONCAT(\"http://doingbusiness.270a.info/dataset/${codeIndicators[$i]}/\", ?area ,\"/\", ?period, \"\")) AS ?observation)
     "  >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
     fi

echo "}
OFFSET 1" >> doingbusiness.tarql.query.${codeIndicators[$i]}.$startYear.txt;
done

done 
