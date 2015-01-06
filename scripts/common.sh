#!/bin/bash

addWorkflowArtifact() {
	name="$1"
	artifact="$2"
	sed "/<\/rdf:RDF>/d" $workflowConfig > temp.rdf;
 	cat temp.rdf > $workflowConfig;
 	rm temp.rdf;
 	echo "<rdf:Description rdf:about=\"/config/WorkflowExecutionArtifacts\">
            <opmw:WorkflowExecutionArtifact name=\"$name\">$artifact</opmw:WorkflowExecutionArtifact>
    	</rdf:Description>\n" >> $workflowConfig;
 	echo "</rdf:RDF>" >> $workflowConfig;
}
