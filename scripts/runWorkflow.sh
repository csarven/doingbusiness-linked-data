#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Date: 2014-12-21
#Abstract workflow file
. ./config.sh

#TODO: Contributor as defaut variable and possible user input!
#Setup

date=`date +%Y%m%dT%H%M%S%Z`;
dateFormated=`date --utc +%FT%TZ`;

echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> . 
@prefix opmv: <http://purl.org/net/opmv/ns#> .
@prefix opmw: <http://www.opmw.org/ontology/> .
@prefix opmo: <http://openprovenance.org/model/opmo#> ." > $workflowExecutionDescription; 

echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> . 
@prefix opmv: <http://purl.org/net/opmv/ns#> . 
@prefix opmw: <http://www.opmw.org/ontology/> .
@prefix dc:  <http://purl.org/dc/terms/> .
" > $abstractWorkflowDescription;

echo "<$workflowTemplate>
     a opmw:workflowTemplate ;
     rdfs:label \"Workflow $agencyLabel\"@en ;
     dc:creator <$agent> ;
     dc:contributor <$agent> ;
." >> $abstractWorkflowDescription;

 echo "<$workflowAccount/$date> 
     a opmw:WorkflowExecutionAccount ;
     rdfs:label \"Workflow execution from $dateFormated\"@en ;
     opmw:executedInWorkflowSystem <https://github.com/Factual/drake> ;
     opmw:hasStartTime \"$dateFormated\"^^xsd:dateTime ;
     opmw:hasEndTime XXXENDTIMEXXX^^xsd:dateTime ;
     opmw:correspondsToTemplate <$workflowTemplate> ;
 ." >> $workflowExecutionDescription;

. ./doingbusiness.get.sh
. ./doingbusiness.preprocessing.sh
. ./doingbusiness.mapping.sh

 dateFormated=`date --utc +%FT%TZ`;
 sed -i "s/opmw:hasEndTime XXXENDTIMEXXX^^xsd:dateTime ;/opmw:hasEndTime \"$dateFormated\"^^xsd:dateTime ;/" $workflowExecutionDescription;
