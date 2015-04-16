//
//  CSVParser.m
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "CSVParser.h"

// XML tag and attribute names
NSString *CSVParserXMLRootKey								= @"station";
NSString *CSVParserDTDKey									= @"http://www.imn.htwk-leipzig.de/~lhauswal/DBS/CRNH0203-2013-CO_Dinosaur_2_E.dtd";
NSString *CSVParserXSDKey									= @"CRNH0203-2013-CO_Dinosaur_2_E.xsd";
NSString *CSVParserWBANNumberKey							= @"wbanno";
NSString *CSVParserLongitudeKey								= @"longitude";
NSString *CSVParserLatitudeKey								= @"latitude";
NSString *CSVParserDataSetKey								= @"set";
NSString *CSVParserUTCDateKey								= @"utc_d";
NSString *CSVParserUTCTimeKey								= @"utc_t";
NSString *CSVParserDataLoggerVersionNumberKey				= @"dl_vn";
NSString *CSVParserTemperatureSetKey						= @"temp";
NSString *CSVParserAverageTemperatureKey					= @"avg";
NSString *CSVParserAverageTemperatureDuringEntireHourKey	= @"hr";
NSString *CSVParserMaximumTemperatureKey					= @"max";
NSString *CSVParserMinimumTemperatureKey					= @"min";
NSString *CSVParserSolarRadiationSetKey						= @"solar";
NSString *CSVParserSolarRadiationFlagKey					= @"flag";
NSString *CSVParserAverageSolarRadiationKey					= @"avg";
NSString *CSVParserMaximumSolarRadiationKey					= @"max";
NSString *CSVParserMinimumSolarRadiationKey					= @"min";
NSString *CSVParserSurfaceTemperatureSetKey					= @"sur";
NSString *CSVParserSurfaceTemperatureTypeKey				= @"type";
NSString *CSVParserSurfaceTemperatureFlagKey				= @"flag";
NSString *CSVParserAverageSurfaceTemperatureKey				= @"avg";
NSString *CSVParserMaximumSurfaceTemperatureKey				= @"max";
NSString *CSVParserMinimumSurfaceTemperatureKey				= @"min";
NSString *CSVParserRHAverageKey								= @"rh";
NSString *CSVParserRHAverageFlagKey							= @"flag";
NSString *CSVParserSoilSetKey								= @"soil";
NSString *CSVParserSoilMoisture50cmKey						= @"m_50";
NSString *CSVParserSoilMoisture100cmKey						= @"m_100";
NSString *CSVParserSoilTemperature5cmKey					= @"t_5";
NSString *CSVParserSoilTemperature10cmKey					= @"t_10";
NSString *CSVParserSoilTemperature20cmKey					= @"t_20";
NSString *CSVParserSoilTemperature50cmKey					= @"t_50";
NSString *CSVParserSoilTemperature100cmKey					= @"t_100";

enum : NSUInteger {
	CSVParserWBANNumberIndex								= 0,
	CSVParserUTCDateIndex									= 1,
	CSVParserUTCTimeIndex									= 2,
	CSVParserLocalDateIndex									= 3,
	CSVParserLocalTimeIndex									= 4,
	CSVParserDataLoggerVersionNumberIndex					= 5,
	CSVParserLongitudeIndex									= 6,
	CSVParserLatitudeIndex									= 7,
	CSVParserAverageTemperatureIndex						= 8,
	CSVParserAverageTemperatureDuringEntireHourIndex		= 9,
	CSVParserMaximumTemperatureIndex						= 10,
	CSVParserMinimumTemperatureIndex						= 11,
	CSVParserPrecipitationIndex								= 12,
	CSVParserAverageSolarRadiationIndex						= 13,
	CSVParserAverageSolarRadiationFlagIndex					= 14,
	CSVParserMaximumSolarRadiationIndex						= 15,
	CSVParserMaximumSolarRadiationFlagIndex					= 16,
	CSVParserMinimumSolarRadiationIndex						= 17,
	CSVParserMinimumSolarRadiationFlagIndex					= 18,
	CSVParserSurfaceTemperatureTypeIndex					= 19,
	CSVParserAverageSurfaceTemperatureIndex					= 20,
	CSVParserAverageSurfaceTemperatureFlagIndex				= 21,
	CSVParserMaximumSurfaceTemperatureIndex					= 22,
	CSVParserMaximumSurfaceTemperatureFlagIndex				= 23,
	CSVParserMinimumSurfaceTemperatureIndex					= 24,
	CSVParserMinimumSurfaceTemperatureFlagIndex				= 25,
	CSVParserRHAverageIndex									= 26,
	CSVParserRHAverageFlagIndex								= 27,
	CSVParserSoilMoisture5cmIndex							= 28,
	CSVParserSoilMoisture10cmIndex							= 29,
	CSVParserSoilMoisture20cmIndex							= 30,
	CSVParserSoilMoisture50cmIndex							= 31,
	CSVParserSoilMoisture100cmIndex							= 32,
	CSVParserSoilTemperature5cmIndex						= 33,
	CSVParserSoilTemperature10cmIndex						= 34,
	CSVParserSoilTemperature20cmIndex						= 35,
	CSVParserSoilTemperature50cmIndex						= 36,
	CSVParserSoilTemperature100cmIndex						= 37
};

@implementation CSVParser

+ (NSXMLDocument *)XMLDocumentFromFileAtURL:(NSURL *)sourceFile
{
    // Read file
	NSString *input = [NSString stringWithContentsOfURL:sourceFile encoding:NSUTF8StringEncoding error:NULL];

	if (!input)
		return nil;
	
	// Initialize XML document
	NSXMLElement *stationElement = [NSXMLElement elementWithName: CSVParserXMLRootKey];
	NSXMLDocument *xmlDocument = [NSXMLDocument documentWithRootElement: stationElement];
	xmlDocument.version = @"1.0";
	xmlDocument.characterEncoding = @"UTF-8";
	
	NSXMLDTD *xmlDTD = [NSXMLDTD new];
	xmlDTD.name = CSVParserXMLRootKey;
	xmlDTD.systemID = CSVParserDTDKey;
	xmlDocument.DTD = xmlDTD;
	
	[stationElement addNamespace:[NSXMLElement namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	[stationElement addAttribute:[NSXMLElement attributeWithName:@"xsi:noNamespaceSchemaLocation" stringValue:CSVParserXSDKey]];

	// Split into array of lines
	NSArray *lines = [[input stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsSeparatedByCharactersInSet: NSCharacterSet.newlineCharacterSet];
	
	// Add basic info
	[stationElement addChild: [NSXMLElement elementWithName:CSVParserWBANNumberKey stringValue:[self splitLine:lines[0]][CSVParserWBANNumberIndex]]];
	[stationElement addChild: [NSXMLElement elementWithName:CSVParserLongitudeKey stringValue:[self splitLine:lines[0]][CSVParserLongitudeIndex]]];
	[stationElement addChild: [NSXMLElement elementWithName:CSVParserLatitudeKey stringValue:[self splitLine:lines[0]][CSVParserLatitudeIndex]]];

	// Add update info
	for (NSString *line in lines) {
		NSArray *updateInfo = [self splitLine: line];
		if (!updateInfo) {
			return nil;
		}
		NSXMLElement *setElement = [[NSXMLElement alloc] initWithName: CSVParserDataSetKey];
		
		[setElement addChild: [NSXMLElement elementWithName:CSVParserUTCDateKey stringValue:updateInfo[CSVParserUTCDateIndex]]];
		[setElement addChild: [NSXMLElement elementWithName:CSVParserUTCTimeKey stringValue:updateInfo[CSVParserUTCTimeIndex]]];
		[setElement addChild: [NSXMLElement elementWithName:CSVParserDataLoggerVersionNumberKey stringValue:updateInfo[CSVParserDataLoggerVersionNumberIndex]]];
		
		// Temperature element
		NSXMLElement *tempElement = [NSXMLElement elementWithName: CSVParserTemperatureSetKey];
		[tempElement addChild: [NSXMLElement elementWithName:CSVParserAverageTemperatureKey stringValue:updateInfo[CSVParserAverageTemperatureIndex]]];
		[tempElement addChild: [NSXMLElement elementWithName:CSVParserAverageTemperatureDuringEntireHourKey stringValue:updateInfo[CSVParserAverageTemperatureDuringEntireHourIndex]]];
		[tempElement addChild: [NSXMLElement elementWithName:CSVParserMaximumTemperatureKey stringValue:updateInfo[CSVParserMaximumTemperatureIndex]]];
		[tempElement addChild: [NSXMLElement elementWithName:CSVParserMinimumTemperatureKey stringValue:updateInfo[CSVParserMinimumTemperatureIndex]]];
		[setElement addChild: tempElement];
		
		// Solar radiation element
		NSXMLElement *solarElement = [NSXMLElement elementWithName: CSVParserSolarRadiationSetKey];
		[CSVParser addSubElementWithName:CSVParserAverageSolarRadiationKey value:updateInfo[CSVParserAverageSolarRadiationIndex] attribute:CSVParserSolarRadiationFlagKey attributeValue:updateInfo[CSVParserAverageSolarRadiationFlagIndex] toParentElement:solarElement];
		[CSVParser addSubElementWithName:CSVParserMaximumSolarRadiationKey value:updateInfo[CSVParserMaximumSolarRadiationIndex] attribute:CSVParserSolarRadiationFlagKey attributeValue:updateInfo[CSVParserMaximumSolarRadiationFlagIndex] toParentElement:solarElement];
		[CSVParser addSubElementWithName:CSVParserMinimumSolarRadiationKey value:updateInfo[CSVParserMinimumSolarRadiationIndex] attribute:CSVParserSolarRadiationFlagKey attributeValue:updateInfo[CSVParserMinimumSolarRadiationFlagIndex] toParentElement:solarElement];
		[setElement addChild: solarElement];
		
		// Surface temperature element
		NSXMLElement *surElement = [NSXMLElement elementWithName: CSVParserSurfaceTemperatureSetKey];
		NSXMLElement *surAttribute = [NSXMLElement attributeWithName:CSVParserSurfaceTemperatureTypeKey stringValue:updateInfo[CSVParserSurfaceTemperatureTypeIndex]];
		[surElement addAttribute:surAttribute];
		[CSVParser addSubElementWithName:CSVParserAverageSurfaceTemperatureKey value:updateInfo[CSVParserAverageSurfaceTemperatureIndex] attribute:CSVParserSurfaceTemperatureFlagKey attributeValue:updateInfo[CSVParserAverageSurfaceTemperatureFlagIndex] toParentElement:surElement];
		[CSVParser addSubElementWithName:CSVParserMaximumSurfaceTemperatureKey value:updateInfo[CSVParserMaximumSurfaceTemperatureIndex] attribute:CSVParserSurfaceTemperatureFlagKey attributeValue:updateInfo[CSVParserMaximumSurfaceTemperatureFlagIndex] toParentElement:surElement];
		[CSVParser addSubElementWithName:CSVParserMinimumSurfaceTemperatureKey value:updateInfo[CSVParserMinimumSurfaceTemperatureIndex] attribute:CSVParserSurfaceTemperatureFlagKey attributeValue:updateInfo[CSVParserMinimumSurfaceTemperatureFlagIndex] toParentElement:surElement];
		[setElement addChild: surElement];
		
		// RH-HR-AVG
		NSXMLElement *rhElement = [NSXMLElement elementWithName:CSVParserRHAverageKey stringValue:updateInfo[CSVParserRHAverageIndex]];
		NSXMLElement *rhAttribute = [NSXMLElement attributeWithName:CSVParserRHAverageFlagKey stringValue:updateInfo[CSVParserRHAverageFlagIndex]];
		[rhElement addAttribute: rhAttribute];
		[setElement addChild: rhElement];
		
		// Soil element
		NSXMLElement *soilElement = [NSXMLElement elementWithName:CSVParserSoilSetKey];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilMoisture50cmKey stringValue:updateInfo[CSVParserSoilMoisture50cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilMoisture100cmKey stringValue:updateInfo[CSVParserSoilMoisture100cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilTemperature5cmKey stringValue:updateInfo[CSVParserSoilTemperature5cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilTemperature10cmKey stringValue:updateInfo[CSVParserSoilTemperature10cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilTemperature20cmKey stringValue:updateInfo[CSVParserSoilTemperature20cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilTemperature50cmKey stringValue:updateInfo[CSVParserSoilTemperature50cmIndex]]];
		[soilElement addChild: [NSXMLElement elementWithName:CSVParserSoilTemperature100cmKey stringValue:updateInfo[CSVParserSoilTemperature100cmIndex]]];
		[setElement addChild: soilElement];
		
		[stationElement addChild: setElement];
	}

	return xmlDocument;
}

+ (NSArray *)splitLine:(NSString *)fullLine
{
	// Replace multiple separation space characters by one space character
	NSString *line = [fullLine stringByReplacingOccurrencesOfString:@"[ ]+"
														 withString:@" "
															options:NSRegularExpressionSearch
															  range:NSMakeRange(0, fullLine.length)];

	NSMutableArray *updateInfos = [[line componentsSeparatedByCharactersInSet: NSCharacterSet.whitespaceCharacterSet] mutableCopy];

	if (updateInfos.count < 38)
		return nil;

	return updateInfos;
}

+ (NSXMLElement *)addSubElementWithName:(NSString *)name value:(NSString *)value attribute:(NSString *)attr attributeValue:(NSString *)attrValue toParentElement:(NSXMLElement *)parent
{
	NSXMLElement *child = [[NSXMLElement alloc] initWithName:name stringValue:value];
	NSXMLElement *attribute = [NSXMLElement attributeWithName:attr stringValue:attrValue];
	[child addAttribute: attribute];
	[parent addChild: child];
	return parent;
}

@end
