#!/bin/bash
#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch/
#Date: 2014-12-21

#Global variables
agency="doingbusiness";
agencyLabel="Doing Business";
agencyURL="http://www.doingbusiness.org/";
agent="http://renatostauffer.ch/#i";
data="../data";
namespace="http://$agency.270a.info";
workflowConfig="../data/config.execution.rdf";
metaConfig="../data/config.rdf";

workflowTemplate="${namespace}/workflow";
workflowAccount="${namespace}/account";

#create workflow description files and paths
workflowExecutionDescription="../data/workflowExecutionDescription.ttl";
abstractWorkflowDescription="../data/abstractWorkflowDescription.ttl";
