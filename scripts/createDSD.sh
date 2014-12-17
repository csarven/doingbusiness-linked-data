#!/bin/bash
#Creates dsd file for Doing Business

#variables
codeIndicators=(ease-of-doing-business dealing-with-construction-permits enforcing-contracts getting-credit getting-electricity paying-taxes protecting-minority-investors registering-property resolving-insolvency starting-a-business trading-across-borders);
codeIndicatorLabels=("Ease of Doing Business" "Dealing with Construction Permits" "Enforcing Contracts" "Getting Credit" "Getting Electricity" "Paying Taxes" "Protecting Minority Investors" "Registering Property" "Resolving Insolvency" "Starting a Business" "Trading Across Borders");
creators=("<http://renatostauffer.ch>" "<http://csarven.ca/#i>");
licence="<http://creativecommons.org/publicdomain/zero/1.0/>";
componentsEaseOfDoingBusiness=(overall-dtf);
componentsDealingWithConstructionPermits=(procedures days cost-in-percent-of-warehouse-value);
componentsEnforcingContraacts=(days cost-in-percent-of-claim procedures);
componentsGettingCredit=(strength-of-legal-rights-index depth-of-credit-information-index credit-registry-coverage-in-percent-of-adults credit-bureau-coverage-in-percent-of-adults);
componentsGettingElectricity=(procedures days cost-in-percent-of-income-per-capita);
componentsPayingTaxes=(payments-per-year hours-per-year profit-tax-in-percent labor-tax-and-contributions-in-percent other-taxes-in-percent total-tax-rate-in-percent-of-profit);
componentsProtectingMinorityInvestors=(extent-of-disclosure-index extent-of-director-liability-index ease-of-shareholder-suits-index extent-of-conflict-of-interest-regulation-index extent-of-shareholder-rights-index strength-of-governance-structure extent-of-corporate-transparency-index extent-of-shareholder-governance-index strength-of-minority-investor-protection-index);
componentsRegisteringProperty=(procedures days cost-in-percent-of-property-value);
componentsResolvingInsolvency=(years cost-in-percent-of-estate outcome recovery-rate commencement-of-proceedings-index management-of-debtor-assets-index reorganization-proceedings-index creditor-participation-index strength-of-insolvency-framework-index);
componentsStartingABusiness=(procedures days cost-in-percent-of-income-per-capita paid-in-minimum-capital-in-percent-of-income-per-capita);
componentsTradingAcrossBorders=(number-of-documents-to-export days-to-export cost-to-export-in-us-dollar-per-container cost-to-export-in-deflated-us-dollar-per-container number-of-documents-to-import days-to-import cost-to-import-in-us-dollar-per-container cost-to-import-in-deflated-us-dollar-per-container);

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
arrayLenght=${#codeIndicators[@]}

for ((i=0; i<${arrayLenght}; i++));
do
	echo "#" >> meta.ttl;
	echo "# ${codeIndicatorLabels[$i]} dataset" >> meta.ttl;
	echo "#" >> meta.ttl;
	printf "\n" >> meta.ttl;

	echo "dataset:${codeIndicators[$i]}
	qb:structure structure:${codeIndicators[$i]} ;
	rdfs:label \"Dooing Business - ${codeIndicatorLabels[$i]} dataset\"@en ;" >> meta.ttl;

	if [ ${codeIndicators[$i]} != ease-of-doing-business ]
    	then
			echo "\tfoaf:page <http://www.doingbusiness.org/data/exploretopics/${codeIndicators[$i]}> ;" >> meta.ttl;
    	fi

	echo "\tdcterms:issued \"2014-12-04T00:00:00Z\"^^xsd:dateTime ;
	dcterms:modified \"2014-12-04T00:00:00Z\"^^xsd:dateTime ;" >> meta.ttl;
    printf "\tdcterms:creator <http://renatostauffer.ch>,\n\t\t\t<http://csarven.ca/#i> ;\n" >> meta.ttl;
    echo "\tdcterms:license $licence ;" >> meta.ttl;
    echo "." >> meta.ttl;
    printf "\n" >> meta.ttl;

    echo "structure:${codeIndicators[$i]}
    a qb:DataStructureDefinition ;
    qb:component component:rank ;" >> meta.ttl;

    if [ ${codeIndicators[$i]} != ease-of-doing-business ]
    	then
			echo "\tqb:component component:dtf ;" >> meta.ttl;
    	fi
    
    echo "\tqb:component component:economy ;
    qb:component component:refPeriod ;
    qb:component component:indicator-${codeIndicators[$i]} ;" >> meta.ttl;

    #loop through each component of each code-indicator
    case "${codeIndicators[$i]}" in 
    	dealing-with-construction-permits)
			for component in "${componentsDealingWithConstructionPermits[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		enforcing-contracts)
			for component in "${componentsEnforcingContraacts[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		getting-credit)
			for component in "${componentsGettingCredit[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		getting-electricity)
			for component in "${componentsGettingElectricity[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		paying-taxes)
			for component in "${componentsPayingTaxes[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		protecting-minority-investors)
			for component in "${componentsProtectingMinorityInvestors[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		registering-property)
			for component in "${componentsRegisteringProperty[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		resolving-insolvency)
			for component in "${componentsResolvingInsolvency[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		starting-a-business)
			for component in "${componentsStartingABusiness[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		trading-across-borders)
			for component in "${componentsTradingAcrossBorders[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
				done
			;;
		ease-of-doing-business)
			for component in "${componentsEaseOfDoingBusiness[@]}"
				do
					echo "\tqb:component component:$component ;" >> meta.ttl;
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
	skos:definition \"\"@en ;
." >> meta.ttl;
    printf "\n" >> meta.ttl;
done

#create the indicators
echo "code:indicator
	skos:prefLabel \"Indicator Concept Scheme\"@en ;
	skos:hasTopConcept" >> meta.ttl;
#loop through every code-indicator and add it to skos:hasTopConcept.
for ((i=0; i<${arrayLenght}; i++));
do
	printf "\t\tcode-indicator:${codeIndicators[$i]}" >> meta.ttl;
	if [ $i == $(($arrayLenght-1)) ]
		then
			printf " ;\n" >> meta.ttl;
		else
			printf ",\n" >> meta.ttl;
		fi
done
echo "." >> meta.ttl;
printf "\n" >> meta.ttl;

#create the components for the indicators
for ((i=0; i<${arrayLenght}; i++));
do
	echo "component:indicator-${codeIndicators[$i]}
	a qb:ComponentSpecification ;
	qb:dimension code-indicator:${codeIndicators[$i]} ;
	." >> meta.ttl;
done

#Create components measures and dimensions

echo "component:economy
    a qb:ComponentSpecification ;
    qb:dimension sdmx-dimension:refArea ;
    .

component:refPeriod
    a qb:ComponentSpecification ;
    qb:dimension sdmx-dimension:refPeriod ;
    .
" >> meta.ttl;

otherComponents=(overall-dtf rank dtf procedures days cost-in-percent-of-warehouse-value cost-in-percent-of-claim strength-of-legal-rights-index depth-of-credit-information-index credit-registry-coverage-in-percent-of-adults credit-bureau-coverage-in-percent-of-adults cost-in-percent-of-income-per-capita payments-per-year hours-per-year profit-tax-in-percent labor-tax-and-contributions-in-percent other-taxes-in-percent total-tax-rate-in-percent-of-profit extent-of-disclosure-index extent-of-director-liability-index ease-of-shareholder-suits-index extent-of-conflict-of-interest-regulation-index extent-of-shareholder-rights-index strength-of-governance-structure extent-of-corporate-transparency-index extent-of-shareholder-governance-index strength-of-minority-investor-protection-index cost-in-percent-of-property-value years cost-in-percent-of-estate outcome recovery-rate commencement-of-proceedings-index management-of-debtor-assets-index reorganization-proceedings-index creditor-participation-index strength-of-insolvency-framework-index paid-in-minimum-capital-in-percent-of-income-per-capita number-of-documents-to-export days-to-export cost-to-export-in-us-dollar-per-container cost-to-export-in-deflated-us-dollar-per-container number-of-documents-to-import days-to-import cost-to-import-in-us-dollar-per-container cost-to-import-in-deflated-us-dollar-per-container );

otherComponentsLength=${#otherComponents[@]};

for ((i=0; i<${otherComponentsLength}; i++));
do
	echo "component:${otherComponents[$i]}
	a qb:ComponentSpecification ;
	qb:measure measure:${otherComponents[$i]} ;
    ." >> meta.ttl;
	printf "\n" >> meta.ttl;

	echo "measure:${otherComponents[$i]}
	a qb:MeasureProperty ;
    rdfs:label \"\"@en ;
    #TODO: Add range
    rdfs:range \"Has no range yet.\"@en ;
	." >> meta.ttl;
	printf "\n" >> meta.ttl;
done