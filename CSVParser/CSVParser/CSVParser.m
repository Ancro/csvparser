//
//  CSVParser.m
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "CSVParser.h"

// XML tag and attribute names
NSString *CSVParserXMLRootKey = @"station";
NSString *CSVParserDTDKey = @"http://www.imn.htwk-leipzig.de/~lhauswal/DBS/CRNH0203-2013-CO_Dinosaur_2_E.dtd";
NSString *CSVParserXSDKey = @"CRNH0203-2013-CO_Dinosaur_2_E.xsd";
NSString *CSVParserWBANNumberKey = @"wbanno";
NSString *CSVParserLongitudeKey = @"longitude";
NSString *CSVParserLatitudeKey = @"latitude";
NSString *CSVParserDataSetKey = @"set";
NSString *CSVParserUTCDateKey = @"utc_d";
NSString *CSVParserUTCTimeKey = @"utc_t";
NSString *CSVParserDataLoggerVersionNumberKey = @"dl_vn";
NSString *CSVParserTemperatureSetKey = @"temp";
NSString *CSVParserAverageTemperatureKey = @"avg";
NSString *CSVParserAverageTemperatureDuringEntireHourKey = @"hr";
NSString *CSVParserMaximumTemperatureKey = @"max";
NSString *CSVParserMinimumTemperatureKey = @"min";
NSString *CSVParserSolarRadiationSetKey = @"solar";
NSString *CSVParserSolarRadiationFlagKey = @"flag";
NSString *CSVParserAverageSolarRadiationKey = @"avg";
NSString *CSVParserMaximumSolarRadiationKey = @"max";
NSString *CSVParserMinimumSolarRadiationKey = @"min";
NSString *CSVParserSurfaceTemperatureSetKey = @"sur";
NSString *CSVParserSurfaceTemperatureTypeKey = @"type";
NSString *CSVParserSurfaceTemperatureFlagKey = @"flag";
NSString *CSVParserAverageSurfaceTemperatureKey = @"avg";
NSString *CSVParserMaximumSurfaceTemperatureKey = @"max";
NSString *CSVParserMinimumSurfaceTemperatureKey = @"min";
NSString *CSVParserRHAverageKey = @"rh";
NSString *CSVParserRHAverageFlagKey = @"flag";
NSString *CSVParserSoilSetKey = @"soil";
NSString *CSVParserSoilMoisture50cmKey = @"m_50";
NSString *CSVParserSoilMoisture100cmKey = @"m_100";
NSString *CSVParserSoilTemperature5cmKey = @"t_5";
NSString *CSVParserSoilTemperature10cmKey = @"t_10";
NSString *CSVParserSoilTemperature20cmKey = @"t_20";
NSString *CSVParserSoilTemperature50cmKey = @"t_50";
NSString *CSVParserSoilTemperature100cmKey = @"t_100";

enum : NSUInteger {
    CSVParserWBANNumberIndex = 0,
    CSVParserUTCDateIndex = 1,
    CSVParserUTCTimeIndex = 2,
    CSVParserDataLoggerVersionNumberIndex = 3,
    CSVParserLongitudeIndex = 4,
    CSVParserLatitudeIndex = 5,
    CSVParserAverageTemperatureIndex = 6,
    CSVParserAverageTemperatureDuringEntireHourIndex = 7,
    CSVParserMaximumTemperatureIndex = 8,
    CSVParserMinimumTemperatureIndex = 9,
    CSVParserAverageSolarRadiationIndex = 10,
    CSVParserAverageSolarRadiationFlagIndex = 11,
    CSVParserMaximumSolarRadiationIndex = 12,
    CSVParserMaximumSolarRadiationFlagIndex = 13,
    CSVParserMinimumSolarRadiationIndex = 14,
    CSVParserMinimumSolarRadiationFlagIndex = 15,
    CSVParserSurfaceTemperatureTypeIndex = 16,
    CSVParserAverageSurfaceTemperatureIndex = 17,
    CSVParserAverageSurfaceTemperatureFlagIndex = 18,
    CSVParserMaximumSurfaceTemperatureIndex = 19,
    CSVParserMaximumSurfaceTemperatureFlagIndex = 20,
    CSVParserMinimumSurfaceTemperatureIndex = 21,
    CSVParserMinimumSurfaceTemperatureFlagIndex = 22,
    CSVParserRHAverageIndex = 23,
    CSVParserRHAverageFlagIndex = 24,
    CSVParserSoilMoisture50cmIndex = 25,
    CSVParserSoilMoisture100cmIndex = 26,
    CSVParserSoilTemperature5cmIndex = 27,
    CSVParserSoilTemperature10cmIndex = 28,
    CSVParserSoilTemperature20cmIndex = 29,
    CSVParserSoilTemperature50cmIndex = 30,
    CSVParserSoilTemperature100cmIndex = 31
};

@interface CSVParser ()

@end

@implementation CSVParser

/*!
 @abstract Returns an NSXMLDocument parsed from the CSV file located at the given URL.
 */
- (NSXMLDocument *)XMLDocumentFromFileAtURL:(NSURL *)sourceFile
{
    if (![NSFileManager.defaultManager fileExistsAtPath: sourceFile.path])
        return nil;

    // Read file
    NSData *fileContents = [NSFileManager.defaultManager contentsAtPath: [sourceFile path]];
    NSString *input = [[NSString alloc] initWithData:fileContents encoding:NSUTF8StringEncoding];

    // Split into array of lines
    NSArray *lines = [[input stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsSeparatedByCharactersInSet: NSCharacterSet.newlineCharacterSet];

    if (lines.count != 8760 && lines.count != 8784)
        return nil;

    // Parse info
    NSMutableArray *updateInfos = NSMutableArray.new;
    for (NSString *line in lines) {
        [updateInfos addObject: [CSVParser splitLine: line]];
    }

    // Initialize XML document
    NSXMLElement *stationElement = [[NSXMLElement alloc] initWithName: CSVParserXMLRootKey];
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithRootElement: stationElement];
    xmlDocument.version = @"1.0";
    xmlDocument.characterEncoding = @"UTF-8";

    NSXMLDTD *xmlDTD = NSXMLDTD.new;
    xmlDTD.name = CSVParserXMLRootKey;
    xmlDTD.systemID = CSVParserDTDKey;
    xmlDocument.DTD = xmlDTD;

    [stationElement addAttribute:[NSXMLElement attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
    [stationElement addAttribute:[NSXMLElement attributeWithName:@"xsi:noNamespaceSchemaLocation" stringValue:CSVParserXSDKey]];

    // Add basic info
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserWBANNumberKey stringValue:updateInfos[0][CSVParserWBANNumberIndex]]];
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserLongitudeKey stringValue:updateInfos[0][CSVParserLongitudeIndex]]];
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserLatitudeKey stringValue:updateInfos[0][CSVParserLatitudeIndex]]];

    // Add update info
    for (NSArray *updateInfo in updateInfos) {

        NSXMLElement *setElement = [[NSXMLElement alloc] initWithName: CSVParserDataSetKey];

        [setElement addChild: [[NSXMLElement alloc] initWithName:CSVParserUTCDateKey stringValue:updateInfo[CSVParserUTCDateIndex]]];
        [setElement addChild: [[NSXMLElement alloc] initWithName:CSVParserUTCTimeKey stringValue:updateInfo[CSVParserUTCTimeIndex]]];
        [setElement addChild: [[NSXMLElement alloc] initWithName:CSVParserDataLoggerVersionNumberKey stringValue:updateInfo[CSVParserDataLoggerVersionNumberIndex]]];

        // Temperature element
        NSXMLElement *tempElement = [[NSXMLElement alloc] initWithName: CSVParserTemperatureSetKey];
        [tempElement addChild: [[NSXMLElement alloc] initWithName:CSVParserAverageTemperatureKey stringValue:updateInfo[CSVParserAverageTemperatureIndex]]];
        [tempElement addChild: [[NSXMLElement alloc] initWithName:CSVParserAverageTemperatureDuringEntireHourKey stringValue:updateInfo[CSVParserAverageTemperatureDuringEntireHourIndex]]];
        [tempElement addChild: [[NSXMLElement alloc] initWithName:CSVParserMaximumTemperatureKey stringValue:updateInfo[CSVParserMaximumTemperatureIndex]]];
        [tempElement addChild: [[NSXMLElement alloc] initWithName:CSVParserMinimumTemperatureKey stringValue:updateInfo[CSVParserMinimumTemperatureIndex]]];
        [setElement addChild: tempElement];

        // Solar radiation element
        NSXMLElement *solarElement = [[NSXMLElement alloc] initWithName: CSVParserSolarRadiationSetKey];
        [CSVParser addSubElementWithName:CSVParserAverageSolarRadiationKey Value:updateInfo[CSVParserAverageSolarRadiationIndex] Attribute:CSVParserSolarRadiationFlagKey AttributeValue:updateInfo[CSVParserAverageSolarRadiationFlagIndex] toParentElement:solarElement];
        [CSVParser addSubElementWithName:CSVParserMaximumSolarRadiationKey Value:updateInfo[CSVParserMaximumSolarRadiationIndex] Attribute:CSVParserSolarRadiationFlagKey AttributeValue:updateInfo[CSVParserMaximumSolarRadiationFlagIndex] toParentElement:solarElement];
        [CSVParser addSubElementWithName:CSVParserMinimumSolarRadiationKey Value:updateInfo[CSVParserMinimumSolarRadiationIndex] Attribute:CSVParserSolarRadiationFlagKey AttributeValue:updateInfo[CSVParserMinimumSolarRadiationFlagIndex] toParentElement:solarElement];
        [setElement addChild: solarElement];

        // Surface temperature element
        NSXMLElement *surElement = [[NSXMLElement alloc] initWithName: CSVParserSurfaceTemperatureSetKey];
        NSXMLElement *surAttribute = [NSXMLElement attributeWithName:CSVParserSurfaceTemperatureTypeKey stringValue:updateInfo[CSVParserSurfaceTemperatureTypeIndex]];
        [surElement addAttribute:surAttribute];
        [CSVParser addSubElementWithName:CSVParserAverageSurfaceTemperatureKey Value:updateInfo[CSVParserAverageSurfaceTemperatureIndex] Attribute:CSVParserSurfaceTemperatureFlagKey AttributeValue:updateInfo[CSVParserAverageSurfaceTemperatureFlagIndex] toParentElement:surElement];
        [CSVParser addSubElementWithName:CSVParserMaximumSurfaceTemperatureKey Value:updateInfo[CSVParserMaximumSurfaceTemperatureIndex] Attribute:CSVParserSurfaceTemperatureFlagKey AttributeValue:updateInfo[CSVParserMaximumSurfaceTemperatureFlagIndex] toParentElement:surElement];
        [CSVParser addSubElementWithName:CSVParserMinimumSurfaceTemperatureKey Value:updateInfo[CSVParserMinimumSurfaceTemperatureIndex] Attribute:CSVParserSurfaceTemperatureFlagKey AttributeValue:updateInfo[CSVParserMinimumSurfaceTemperatureFlagIndex] toParentElement:surElement];
        [setElement addChild: surElement];

        // RH-HR-AVG
        NSXMLElement *rhElement = [[NSXMLElement alloc] initWithName:CSVParserRHAverageKey stringValue:updateInfo[CSVParserRHAverageIndex]];
        NSXMLElement *rhAttribute = [NSXMLElement attributeWithName:CSVParserRHAverageFlagKey stringValue:updateInfo[CSVParserRHAverageFlagIndex]];
        [rhElement addAttribute: rhAttribute];
        [setElement addChild: rhElement];

        // Soil element
        NSXMLElement *soilElement = [[NSXMLElement alloc] initWithName:CSVParserSoilSetKey];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilMoisture50cmKey stringValue:updateInfo[CSVParserSoilMoisture50cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilMoisture100cmKey stringValue:updateInfo[CSVParserSoilMoisture100cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilTemperature5cmKey stringValue:updateInfo[CSVParserSoilTemperature5cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilTemperature10cmKey stringValue:updateInfo[CSVParserSoilTemperature10cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilTemperature20cmKey stringValue:updateInfo[CSVParserSoilTemperature20cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilTemperature50cmKey stringValue:updateInfo[CSVParserSoilTemperature50cmIndex]]];
        [soilElement addChild: [[NSXMLElement alloc] initWithName:CSVParserSoilTemperature100cmKey stringValue:updateInfo[CSVParserSoilTemperature100cmIndex]]];
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

    // Remove redundant and erroneous data
    [updateInfos removeObjectAtIndex:30];   // Soil moisture 20cm
    [updateInfos removeObjectAtIndex:29];   // Soil moisture 10cm
    [updateInfos removeObjectAtIndex:28];   // Soil moisture 5cm
    [updateInfos removeObjectAtIndex:12];   // Precipitation
    [updateInfos removeObjectAtIndex:4];    // Local time
    [updateInfos removeObjectAtIndex:3];    // Local date
    return updateInfos;
}

+ (NSXMLElement *)addSubElementWithName:(NSString *)name Value:(NSString *)value Attribute:(NSString *)attr AttributeValue:(NSString *)attrValue toParentElement:(NSXMLElement *)parent
{
    NSXMLElement *child = [[NSXMLElement alloc] initWithName:name stringValue:value];
    NSXMLElement *attribute = [NSXMLElement attributeWithName:attr stringValue:attrValue];
    [child addAttribute: attribute];
    [parent addChild: child];
    return parent;
}

@end
