DROP TABLE IF EXISTS `gbif_master`;
CREATE TABLE IF NOT EXISTS gbif_master (gbifID Int(11) PRIMARY KEY, abstract varchar(255) , acceptedNameUsage varchar(255) , acceptedNameUsageID varchar(255) , accessRights varchar(255) , accrualMethod varchar(255) , accrualPeriodicity varchar(255) , accrualPolicy varchar(255) , alternative varchar(255) , associatedOccurrences varchar(255) , associatedOrganisms varchar(255) , associatedReferences varchar(255) , associatedSequences varchar(255) , associatedTaxa varchar(255) , audience varchar(255) , available varchar(255) , basisOfRecord varchar(64) , bed varchar(255) , behavior varchar(255) , bibliographicCitation varchar(255) , catalogNumber varchar(255) , class varchar(255) , classKey Int(11) , collectionCode varchar(255) , collectionID varchar(255) , conformsTo varchar(255) , continent varchar(64) , contributor varchar(255) , coordinatePrecision varchar(255) , coordinateUncertaintyInMeters varchar(255) , countryCode Varchar(32) , county varchar(255) , coverage varchar(255) , created varchar(255) , creator varchar(255) , dataGeneralizations varchar(255) , datasetID varchar(255) , datasetKey varchar(255) , datasetName varchar(255) , date varchar(255) , dateAccepted varchar(255) , dateCopyrighted varchar(255) , dateIdentified varchar(255) , dateSubmitted varchar(255) , day varchar(255) , decimalLatitude Varchar(64) , decimalLongitude Varchar(64) , depth varchar(255) , depthAccuracy varchar(255) , description varchar(255) , disposition varchar(255) , distanceAboveSurface varchar(255) , distanceAboveSurfaceAccuracy varchar(255) , dynamicProperties varchar(255) , earliestAgeOrLowestStage varchar(255) , earliestEonOrLowestEonothem varchar(255) , earliestEpochOrLowestSeries varchar(255) , earliestEraOrLowestErathem varchar(255) , earliestPeriodOrLowestSystem varchar(255) , educationLevel varchar(255) , elevation varchar(255) , elevationAccuracy varchar(255) , endDayOfYear varchar(255) , establishmentMeans varchar(255) , eventDate varchar(255) , eventID varchar(255) , eventRemarks varchar(255) , eventTime varchar(255) , extensions varchar(255) , facts varchar(255) , extent varchar(255) , family varchar(255) , familyKey varchar(255) , fieldNotes varchar(255) , fieldNumber varchar(255) , footprintSpatialFit varchar(255) , footprintSRS varchar(255) , footprintWKT varchar(255) , format varchar(255) , formation varchar(255) , genericName varchar(255) , genus varchar(255) , genusKey Int(11) , geodeticDatum varchar(255) , geologicalContextID varchar(255) , georeferencedBy varchar(255) , georeferencedDate varchar(255) , georeferenceProtocol varchar(255) , georeferenceRemarks varchar(255) , georeferenceSources varchar(255) , georeferenceVerificationStatus varchar(255), groups varchar(255) , habitat varchar(255) , hasCoordinate varchar(255) , hasFormat varchar(255) , hasGeospatialIssues varchar(255) , hasPart varchar(255) , hasVersion varchar(255) , higherClassification varchar(255) , higherGeography varchar(255) , higherGeographyID varchar(255) , highestBiostratigraphicZone varchar(255) , identificationID varchar(255) , identificationQualifier varchar(255) , identificationReferences varchar(255) , identificationRemarks varchar(255) , identificationVerificationStatus varchar(255) , identifiedBy varchar(255) , identifier varchar(255) , individualCount varchar(255) , informationWithheld varchar(255) , infraspecificEpithet varchar(255) , institutionCode varchar(255) , institutionID varchar(255) , instructionalMethod varchar(255) , isFormatOf varchar(255) , island varchar(255) , islandGroup varchar(255) , isPartOf varchar(255) , isReferencedBy varchar(255) , isReplacedBy varchar(255) , isRequiredBy varchar(255) , issue varchar(255) , issued varchar(255) , key_main varchar(255) , isVersionOf varchar(255) , kingdom varchar(255) , kingdomKey Int(11) , language varchar(255) , lastCrawled varchar(255) , lastInterpreted varchar(255) , lastParsed varchar(255) , latestAgeOrHighestStage varchar(255) , latestEonOrHighestEonothem varchar(255) , latestEpochOrHighestSeries varchar(255) , latestEraOrHighestErathem varchar(255) , latestPeriodOrHighestSystem varchar(255) , license varchar(255) , lifeStage varchar(255) , lithostratigraphicTerms varchar(255) , locality varchar(255) , locationAccordingTo varchar(255) , locationID varchar(255) , locationRemarks varchar(255) , lowestBiostratigraphicZone varchar(255) , materialSampleID varchar(255) , maximumDistanceAboveSurfaceInMeters varchar(255) , mediator varchar(255) , mediaType varchar(255) , medium varchar(255), member varchar(255) , minimumDistanceAboveSurfaceInMeters varchar(255) , modified varchar(255) , month varchar(255) , municipality varchar(255) , nameAccordingTo varchar(255) , nameAccordingToID varchar(255) , namePublishedIn varchar(255) , namePublishedInID varchar(255) , namePublishedInYear varchar(255) , nomenclaturalCode varchar(255) , nomenclaturalStatus varchar(255) , occurrenceID varchar(255) , occurrenceRemarks varchar(255) , occurrenceStatus varchar(255) , orderstr varchar(255) , orderKey Int(11) , organismID varchar(255) , organismName varchar(255) , organismQuantity varchar(255) , organismQuantityType varchar(255) , organismRemarks varchar(255) , organismScope varchar(255) , originalNameUsage varchar(255) , originalNameUsageID varchar(255) , otherCatalogNumbers varchar(255) , ownerInstitutionCode varchar(255) , parentEventID varchar(255) , parentNameUsage varchar(255) , parentNameUsageID varchar(255) , phylum varchar(255) , phylumKey Int(11) , pointRadiusSpatialFit varchar(255) , preparations varchar(255) , previousIdentifications varchar(255) , protocol varchar(255) , provenance varchar(255) , publisher varchar(255) , publishingCountry varchar(255) , publishingOrgKey varchar(255) , recordedBy varchar(255) , recordNumber varchar(255) , reference varchar(255) , relation varchar(255) , repatriated varchar(255) , replaces varchar(255) , reproductiveCondition varchar(255) , requires varchar(255) , rights varchar(255) , rightsHolder varchar(255) , sampleSizeUnit varchar(255) , sampleSizeValue varchar(255) , samplingEffort varchar(255) , samplingProtocol varchar(255) , scientificName varchar(255) , scientificNameID varchar(255) , sex varchar(255) , source varchar(255) , spatia varchar(255) , species varchar(255) , speciesKey Int(11) , specificEpithet varchar(255) , startDayOfYear varchar(255) , stateProvince varchar(255) , subgenus varchar(255) , subgenusKey Int(11) , subject varchar(255) , tableOfContents varchar(255) , taxonConceptID varchar(255) , taxonID varchar(255) , taxonKey Int(11) , taxonomicStatus varchar(255) , taxonRank varchar(255) , taxonRemarks varchar(255) , temporal varchar(255) , title varchar(255) , type varchar(255) , typeStatus varchar(255) , typifiedName varchar(255) , valid varchar(255) , verbatimCoordinateSystem varchar(255) , verbatimDepth varchar(255) , verbatimElevation varchar(255) , verbatimEventDate varchar(255) , verbatimLocality varchar(255) , verbatimSRS varchar(255) , verbatimTaxonRank varchar(255) , vernacularName varchar(255) , waterBody varchar(255) , year Int(11)) engine=MyISAM;