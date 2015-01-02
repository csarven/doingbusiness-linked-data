#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch
#Date: 2014-12-21
#Abstract workflow file
. ./config.sh

#TODO: Contributor as defaut variable and possible user input!
#Setup
date=`date +%Y-%m-%d:%H:%M:%S`

echo "<$workflowTemplate/> a opmw:WorkflowTemplate ;
rdfs:label \"Workflow $agencyLabel\"@en ;
dc:contributor <http://renatostauffer.ch> ;
dc:creator <http://renatostauffer.ch> ;
." >> $abstractWorkflowDescription;
printf "\n" >> $abstractWorkflowDescription;
. ./doingbusiness.get.sh
. ./doingbusiness.preprocessing.sh
. ./doingbusiness.mapping.sh