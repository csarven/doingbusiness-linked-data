#Author: Renato Stauffer
#Author URL: http://renatostauffer.ch
#Date: 2014-12-21

#Global variables
agency="doingbusiness";
agencyLabel="Doing Business";
agencyURL="http://www.doingbusiness.org/";
agent="Renato Stauffer";
data="../data";
namespace="http://$agency.270a.info/";

workflowTemplate="${namespace}workflow/";
workflowAccount="${namespace}account/";

#function for a timestamp
timestamp(){
	date +"%Y%m%dT%H%M%S%N010000";
}

#create workflow description files and paths
echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> . 
@prefix opmv: <http://purl.org/net/opmv/ns#> . 
@prefix opmw: <http://www.opmw.org/ontology/> ." > ../data/workflowExecutionDescription.desc;

echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> . 
@prefix opmv: <http://purl.org/net/opmv/ns#> . 
@prefix opmw: <http://www.opmw.org/ontology/> ." > ../data/abstractWorkflowDescription.desc;

workflowExecutionDescription="../data/workflowExecutionDescription.ttl";
abstractWorkflowDescription="../data/abstractWorkflowDescription.ttl";

#Paths to description for workflows
#wfDesc="$data/wfDescription/";
#wfDescMainProcess="$[wfDesc]/$agency.ttl";

#wfDescInspection="$[wfDesc]wfDescInspection/inspection-$agency.ttl";
#wfDescExtraction="$[wfDesc]wfDescExtraction/extraction-$agency.ttl";
#wfDescPreprocessing="$[wfDesc]wfDescPreprocessing/preprocessing-$agency.ttl";
#wfDescMapping="$[wfDesc]wfDescMapping/mapping-$agency.ttl";

#Paths to workflow steps
#wfExtractionSteps="wfExtraction.d";
#wfInspectionSteps="wfInspection.d";
#wfPreprocessingSteps="wfPreprocessing.d";
#wfMappingSteps="wfMapping.d";
#wfCleanupSteps="wfCleanup.d";