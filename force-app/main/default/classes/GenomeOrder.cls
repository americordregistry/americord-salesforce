/**
* GenomeOrder
* ------------------
* @author NAMEOFAUTHOR
*/
global class GenomeOrder {

    // FHIR-structured file to be uploaded to Veritas/
    //
    // 
    /* order message structure
    {
        "resourceType": "Bundle",
        "type": "message",
        "entry": [
        <MessageHeader>,
        <Patient>,
        <Practitioner>. //not using
        <ServiceRequest>,
        <Specimen>
        ]
       }
    */
    
    global class GenomeOrderMessage{
        global String resourceType {get;set;}
        global String type {get;set;}
        global List<String> entry {get;set;}
    }

    //MessageHeader
    global class GenomeOrderMessageHeader{
        global String fullUrl {get;set;}
        global GenomeOrderMessageHeaderResource resource {get;set;}        
    }
    global class GenomeOrderMessageHeaderResource{
        global String resourceType {get;set;}
        global GenomeOrderMessageHeaderResourceEventCoding eventCoding {get;set;}
        global GenomeOrderMessageHeaderSource source {get;set;}
    }
    global class GenomeOrderMessageHeaderResourceEventCoding{
        global String system_AMERICORD {get;set;} // reserved word
        global String code {get;set;}
    }
    global class GenomeOrderMessageHeaderSource{
        global String endpoint {get;set;}
    }
    
    global class GenomePatient{
        global String fullURL {get;set;}
        global GenomePatientResource resource {get;set;}
    }
    global class GenomePatientResource{
        global String resourceType {get;set;}
        global List<GenomePatientIdentifier> identifier {get;set;}
        global List<GenomePatientName> name {get;set;}
        global List<GenomePatientTelecom> telecom {get;set;}
        global String gender {get;set;}
        global String birthDate {get;set;}
        global List<GenomePatientAddress> address {get;set;}
        global List<GenomePatientExtension> extension {get;set;}      
    }
    global class GenomePatientIdentifier{
        global String value {get;set;}
    }
    global class GenomePatientName{
        global String family {get;set;}
        global List<String> given {get;set;}
    }
    global class GenomePatientTelecom{
        global String system_AMERICORD {get;set;}
        global String value {get;set;}
    }
    global class GenomePatientAddress{
        global List<String> line {get;set;}
        global String city {get;set;}
        global String state {get;set;}
        global String postalCode {get;set;}
        global String country {get;set;}
    }
    global class GenomePatientExtension{
        global List<String> extension {get;set;}
        global String url {get;set;}
    }

    global class GenomePracticioner{
        global String fullUrl {get;set;}
        global GenomePractitionerResource resource {get;set;}        
    }

    global class GenomePractitionerResource{
        global String resourceType {get;set;}
        global List<GenomePractitionerIdentifier> identifier {get;set;}
        global List<GenomePractitionerName> name {get;set;}
    }

    global class GenomePractitionerIdentifier{
        global String system_AMERICORD {get;set;}
        global String value {get;set;}
    }

    global class GenomePractitionerName{
        global String family {get;set;}
        global List<String> given {get;set;}
    }

    global class GenomeServiceRequest{
        global String fullUrl {get;set;}
        global GenomeServiceRequestResource resource {get;set;}
    }
    global class GenomeServiceRequestResource{
        global String resourceType {get;set;}
        global List<GenomeServiceRequestResourceIdentifier> identifier {get;set;}
        global String status {get;set;}
        global String intent {get;set;}
        global GenomeServiceRequestCode code {get;set;}
        global GenomeServiceRequestSubject subject {get;set;}
    }
    global class GenomeServiceRequestResourceIdentifier{
        global String value {get;set;}
    }
    global class GenomeServiceRequestCode{
        global List<GenomeServiceRequestCodeEntry> coding {get;set;}
    }
    global class GenomeServiceRequestCodeEntry{
        global String system_AMERICORD {get;set;}
        global String code {get;set;}
    }
    global class GenomeServiceRequestSubject{
        global String reference {get;set;}
    }

    global class GenomeSpecimen{
        global String fullUrl {get;set;}
        global GenomeSpecimenResource resource {get;set;}
    }
    global class GenomeSpecimenResource{
        global String resourceType {get;set;}
        global List<GenomeSpecimenResourceIdentifier> identifier {get;set;}
        global GenomeSpecimenResourceType type {get;set;}
        global GenomeSpecimenResourceCollection collection {get;set;}
    }
    global class GenomeSpecimenResourceIdentifier{
        global String value {get;set;}
    }
    global class GenomeSpecimenResourceType{
        global List<GenomeSpecimenResourceTypeCoding> coding {get;set;}
    }
    global class GenomeSpecimenResourceTypeCoding{
        global String system_AMERICORD {get;set;}
        global String code {get;set;}
        global String display {get;set;}
    }
    global class GenomeSpecimenResourceCollection{
        global String collectedDateTime {get;set;}
    }
}