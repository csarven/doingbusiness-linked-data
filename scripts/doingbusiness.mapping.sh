#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch
#Mdoingbusiness.mapping.sh

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

#remove existing file 
if [ -f ../data/doingbusiness.ttl ]; then
	rm ../data/doingbusiness.ttl;
fi

#use tarql to map the data
transformableFiles=./*tarql.query*.txt
for file in $transformableFiles
do
	echo "Still mapping...";
	echo "...";
	tarql $file >> ../data/doingbusiness.ttl;
done

echo "Mapping finished";

#remove unnecessary rows
sed -i '/@prefix/d' ../data/doingbusiness.ttl;

#add necessary rows
echo "@prefix doingbusiness-dataset:  <http://doingbusiness.270a.info/dataset/> .
@prefix concept:  <http://doingbusiness.270a.info/concept/> .
@prefix measure:  <http://doingbusiness.270a.info/measure/> .
@prefix sdmx-attribute:  <http://purl.org/linked-data/sdmx/2009/attribute#> .
@prefix sdmx-concept:  <http://purl.org/linked-data/sdmx/2009/concept#> .
@prefix sdmx-code:  <http://purl.org/linked-data/sdmx/2009/code#> .
@prefix dcterms:  <http://purl.org/dc/terms/> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix concept-indicator:  <http://doingbusiness.270a.info/concept/indicator/> .
@prefix code-indicator:  <http://doingbusiness.270a.info/code/indicator/> .
@prefix doingbusiness-structure:  <http://doingbusiness.270a.info/structure/> .
@prefix component:  <http://doingbusiness.270a.info/component/> .
@prefix doingbusiness:  <http://doingbusiness.270a.info/> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix sdmx-dimension:  <http://purl.org/linked-data/sdmx/2009/dimension#> .
@prefix sdmx-measure:  <http://purl.org/linked-data/sdmx/2009/measure#> .
@prefix structure:  <http://doingbusiness.270a.info/structure/> .
@prefix foaf:  <http://xmlns.com/foaf/0.1/> .
@prefix economy:  <http://doingbuinsess.270a.info/code/economy/> .
@prefix code:  <http://doingbusiness.270a.info/code/> .
@prefix qb:  <http://purl.org/linked-data/cube#> .
@prefix dimension:  <http://doingbusiness.270a.info/dimension/> .
@prefix dataset:  <http://doingbusiness.270a.info/dataset/> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix sdmx-metadata:  <http://purl.org/linked-data/sdmx/2009/metadata#> .
@prefix sdmx:  <http://purl.org/linked-data/sdmx#> .
@prefix skos:  <http://www.w3.org/2004/02/skos/core#> ." | cat - ../data/doingbusiness.ttl > temp && mv temp ../data/doingbusiness.ttl;