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
    CSVParserLongitudeIndex = 1,
    CSVParserLatitudeIndex = 2,
    CSVParserUTCDateIndex = 0,
    CSVParserUTCTimeIndex = 1,
    CSVParserDataLoggerVersionNumberIndex = 2,
    CSVParserAverageTemperatureIndex = 3,
    CSVParserAverageTemperatureDuringEntireHourIndex = 4,
    CSVParserMaximumTemperatureIndex = 5,
    CSVParserMinimumTemperatureIndex = 6,
    CSVParserAverageSolarRadiationIndex = 7,
    CSVParserAverageSolarRadiationFlagIndex = 8,
    CSVParserMaximumSolarRadiationIndex = 9,
    CSVParserMaximumSolarRadiationFlagIndex = 10,
    CSVParserMinimumSolarRadiationIndex = 11,
    CSVParserMinimumSolarRadiationFlagIndex = 12,
    CSVParserSurfaceTemperatureTypeIndex = 13,
    CSVParserAverageSurfaceTemperatureIndex = 14,
    CSVParserAverageSurfaceTemperatureFlagIndex = 15,
    CSVParserMaximumSurfaceTemperatureIndex = 16,
    CSVParserMaximumSurfaceTemperatureFlagIndex = 17,
    CSVParserMinimumSurfaceTemperatureIndex = 18,
    CSVParserMinimumSurfaceTemperatureFlagIndex = 19,
    CSVParserRHAverageIndex = 20,
    CSVParserRHAverageFlagIndex = 21,
    CSVParserSoilMoisture50cmIndex = 22,
    CSVParserSoilMoisture100cmIndex = 23,
    CSVParserSoilTemperature5cmIndex = 24,
    CSVParserSoilTemperature10cmIndex = 25,
    CSVParserSoilTemperature20cmIndex = 26,
    CSVParserSoilTemperature50cmIndex = 27,
    CSVParserSoilTemperature100cmIndex = 28
};

@interface CSVParser ()

@end

@implementation CSVParser

- (NSXMLDocument *)XMLDocumentFromFileAtURL:(NSURL *)sourceFile
{
    if (![NSFileManager.defaultManager fileExistsAtPath: sourceFile.path])
        return nil;
    
    // Read file
    NSData *fileContents = [NSFileManager.defaultManager contentsAtPath: [sourceFile path]];
    NSString *input = [[NSString alloc] initWithData:fileContents encoding:NSUTF8StringEncoding];
    
    // Split string at line-breaks, make array
    NSUInteger length = input.length;
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *contentArray = NSMutableArray.new;
    NSRange currentRange;
    
    while (paraEnd < length) {
        [input getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [contentArray addObject:[input substringWithRange: currentRange]];
    }
    
    // Parse basic info
    NSArray *basicInfo = [CSVParser parseBasicInfoFromFirstLine: contentArray[0]];
    
    // Parse update info
    NSMutableArray *updateInfos = NSMutableArray.new;
    for (NSString *line in contentArray) {
        [updateInfos addObject:[CSVParser separateLine: line]];
    }

    // Initialize XML document and add basic info
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
    
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserWBANNumberKey stringValue:basicInfo[0]]];
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserLongitudeKey stringValue:basicInfo[1]]];
    [stationElement addChild: [[NSXMLElement alloc] initWithName:CSVParserLatitudeKey stringValue:basicInfo[2]]];
    
    // Add update info
    for (NSArray *updateInfo in updateInfos) {
        
        NSXMLElement *setElement = [[NSXMLElement alloc] initWithName: CSVParserDataSetKey];
        
        [setElement addChild:[[NSXMLElement alloc] initWithName:CSVParserUTCDateKey stringValue:updateInfo[CSVParserUTCDateIndex]]];
        [setElement addChild:[[NSXMLElement alloc] initWithName:CSVParserUTCTimeKey stringValue:updateInfo[CSVParserUTCTimeIndex]]];
        [setElement addChild:[[NSXMLElement alloc] initWithName:CSVParserDataLoggerVersionNumberKey stringValue:updateInfo[CSVParserDataLoggerVersionNumberIndex]]];
        
        // Temperature element
        NSXMLElement *tempElement = [[NSXMLElement alloc] initWithName: CSVParserTemperatureSetKey];
        [tempElement addChild:[[NSXMLElement alloc] initWithName:CSVParserAverageTemperatureKey stringValue:updateInfo[CSVParserAverageTemperatureIndex]]];
        [tempElement addChild:[[NSXMLElement alloc] initWithName:CSVParserAverageTemperatureDuringEntireHourKey stringValue:updateInfo[CSVParserAverageTemperatureDuringEntireHourIndex]]];
        [tempElement addChild:[[NSXMLElement alloc] initWithName:CSVParserMaximumTemperatureKey stringValue:updateInfo[CSVParserMaximumTemperatureIndex]]];
        [tempElement addChild:[[NSXMLElement alloc] initWithName:CSVParserMinimumTemperatureKey stringValue:updateInfo[CSVParserMinimumTemperatureIndex]]];
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
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilMoisture50cmKey stringValue:updateInfo[CSVParserSoilMoisture50cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilMoisture100cmKey stringValue:updateInfo[CSVParserSoilMoisture100cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilTemperature5cmKey stringValue:updateInfo[CSVParserSoilTemperature5cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilTemperature10cmKey stringValue:updateInfo[CSVParserSoilTemperature10cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilTemperature20cmKey stringValue:updateInfo[CSVParserSoilTemperature20cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilTemperature50cmKey stringValue:updateInfo[CSVParserSoilTemperature50cmIndex]]];
        [soilElement addChild:[[NSXMLElement alloc] initWithName:CSVParserSoilTemperature100cmKey stringValue:updateInfo[CSVParserSoilTemperature100cmIndex]]];
        [setElement addChild: soilElement];
        
        [stationElement addChild: setElement];
    }

    return xmlDocument;
}

+ (NSArray *)parseBasicInfoFromFirstLine:(NSString *)firstLine
{
    NSString *wbanno, *longitude, *latitude;
    
    wbanno = [CSVParser trimSubstringOfLine:firstLine from:0 length:5];         // WBANNO
    longitude = [CSVParser trimSubstringOfLine:firstLine from:41 length:7];     // LONGITUDE
    latitude = [CSVParser trimSubstringOfLine:firstLine from:49 length:7];      // LATITUDE
    
    return @[wbanno, longitude, latitude];
}

+ (NSArray *)separateLine:(NSString *)line
{
    NSMutableArray *updateInfos = NSMutableArray.new;
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:6 length:8]];      // UTC_Date
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:15 length:4]];     // UTC_Time
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:34 length:6]];     // CRX_VN
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:57 length:7]];     // T_CALC
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:65 length:7]];     // T_HR_AVG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:73 length:7]];     // T_MAX
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:81 length:7]];     // T_MIN
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:97 length:6]];     // SOLARRAD
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:104 length:1]];    // SOLARRAD_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:106 length:6]];    // SOLARRAD_MAX
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:113 length:1]];    // SOLARRAD_MAX_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:115 length:6]];    // SOLARRAD_MIN
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:122 length:1]];    // SOLARRAD_MIN_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:124 length:1]];    // SUR_TEMP_TYPE
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:126 length:7]];    // SUR_TEMP
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:134 length:1]];    // SUR_TEMP_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:136 length:7]];    // SUR_TEMP_MAX
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:144 length:1]];    // SUR_TEMP_MAX_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:146 length:7]];    // SUR_TEMP_MIN
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:154 length:1]];    // SUR_TEMP_MIN_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:156 length:5]];    // RH_HR_AVG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:162 length:1]];    // RH_HR_AVG_FLAG
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:188 length:7]];    // SOIL_MOISTURE_50
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:196 length:7]];    // SOIL_MOISTURE_100
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:204 length:7]];    // SOIL_TEMP_5
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:212 length:7]];    // SOIL_TEMP_10
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:220 length:7]];    // SOIL_TEMP_20
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:228 length:7]];    // SOIL_TEMP_50
    [updateInfos addObject: [CSVParser trimSubstringOfLine:line from:236 length:7]];    // SOIL_TEMP_100
    return updateInfos;
}

+ (NSString *)trimSubstringOfLine:(NSString *)line from:(NSUInteger)start length:(NSUInteger)length
{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *substring = [[NSString alloc] initWithString: [line substringWithRange: NSMakeRange(start, length)]];
    return [substring stringByTrimmingCharactersInSet: characterSet];
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
