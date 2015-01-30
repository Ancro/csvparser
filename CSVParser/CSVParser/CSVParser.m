//
//  CSVParser.m
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "CSVParser.h"

@implementation CSVParser

- (void)generateXMLFileFrom:(NSURL *)sourceFile {
    NSFileManager *fileManager;
    NSData *fileContents;
    
    NSLog(@"Filename received.");
    
    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[sourceFile path]]) {
        NSLog(@"File still exists.");
        
        // Read file
        fileContents = [fileManager contentsAtPath:[sourceFile path]];
        NSString *output = [[NSString alloc] initWithData:fileContents encoding:NSUTF8StringEncoding];
        
        // Split string at line-breaks, make array
        NSUInteger length = [output length];
        NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
        NSMutableArray *contentArray = [NSMutableArray array];
        NSRange currentRange;
        
        while (paraEnd < length) {
            [output getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
            currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
            [contentArray addObject:[output substringWithRange:currentRange]];
        }
        
        // Parse basic info
        NSArray *basicInfo = [CSVParser parseBasicInfoFromFirstLine:[contentArray objectAtIndex:0]];
        
        // Parse update info        
        NSMutableArray *updateInfoCollection = [NSMutableArray array];
        for (NSString *line in contentArray) {
            [updateInfoCollection addObject:[CSVParser separateLine:line]];
        }

        // Initialize XML document and add basic info
        NSXMLElement *stationElement = [[NSXMLElement alloc] initWithName:@"station"];
        xmlDocument = [[NSXMLDocument alloc] initWithRootElement:stationElement];
        [xmlDocument setVersion:@"1.0"];
        [xmlDocument setCharacterEncoding:@"UTF-8"];

        NSXMLDTD *xmlDTD = [[NSXMLDTD alloc] init];
        [xmlDTD setName:@"station"];
        [xmlDTD setSystemID:@"http://www.imn.htwk-leipzig.de/~lhauswal/DBS/CRNH0203-2013-CO_Dinosaur_2_E.dtd"];
        [xmlDocument setDTD:xmlDTD];
        
        [stationElement addAttribute:[NSXMLElement attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
        [stationElement addAttribute:[NSXMLElement attributeWithName:@"xsi:noNamespaceSchemaLocation" stringValue:@"CRNH0203-2013-CO_Dinosaur_2_E.xsd"]];

        [stationElement addChild:[[NSXMLElement alloc] initWithName:@"wbanno" stringValue:[basicInfo objectAtIndex:0]]];
        [stationElement addChild:[[NSXMLElement alloc] initWithName:@"longitude" stringValue:[basicInfo objectAtIndex:1]]];
        [stationElement addChild:[[NSXMLElement alloc] initWithName:@"latitude" stringValue:[basicInfo objectAtIndex:2]]];

        // Add update info
        for (NSArray *updateInfo in updateInfoCollection) {
            
            void (^addSubElements)(NSString *, NSString *, NSString *, NSString *, NSXMLElement *) = ^(NSString *name, NSString *value, NSString *attr, NSString *attrValue, NSXMLElement *parent) {
                NSXMLElement *child = [[NSXMLElement alloc] initWithName:name stringValue:value];
                NSXMLElement *attribute = [NSXMLElement attributeWithName:attr stringValue:attrValue];
                [child addAttribute:attribute];
                [parent addChild:child];
            };

            NSXMLElement *setElement = [[NSXMLElement alloc] initWithName:@"set"];

            [setElement addChild:[[NSXMLElement alloc] initWithName:@"utc_d" stringValue:[updateInfo objectAtIndex:0]]];
            [setElement addChild:[[NSXMLElement alloc] initWithName:@"utc_t" stringValue:[updateInfo objectAtIndex:1]]];
            [setElement addChild:[[NSXMLElement alloc] initWithName:@"dl_vn" stringValue:[updateInfo objectAtIndex:2]]];

            // Temperature element
            NSXMLElement *tempElement = [[NSXMLElement alloc] initWithName:@"temp"];
            [tempElement addChild:[[NSXMLElement alloc] initWithName:@"avg" stringValue:[updateInfo objectAtIndex:3]]];
            [tempElement addChild:[[NSXMLElement alloc] initWithName:@"hr" stringValue:[updateInfo objectAtIndex:4]]];
            [tempElement addChild:[[NSXMLElement alloc] initWithName:@"max" stringValue:[updateInfo objectAtIndex:5]]];
            [tempElement addChild:[[NSXMLElement alloc] initWithName:@"min" stringValue:[updateInfo objectAtIndex:6]]];
            [setElement addChild:tempElement];

            // Solar radiation element
            NSXMLElement *solarElement = [[NSXMLElement alloc] initWithName:@"solar"];
            addSubElements(@"avg", [updateInfo objectAtIndex:7], @"flag", [updateInfo objectAtIndex:8], solarElement);
            addSubElements(@"max", [updateInfo objectAtIndex:9], @"flag", [updateInfo objectAtIndex:10], solarElement);
            addSubElements(@"min", [updateInfo objectAtIndex:11], @"flag", [updateInfo objectAtIndex:12], solarElement);
            [setElement addChild:solarElement];

            // Surface temperature element
            NSXMLElement *surElement = [[NSXMLElement alloc] initWithName:@"sur"];
            NSXMLElement *surAttribute = [NSXMLElement attributeWithName:@"type" stringValue:[updateInfo objectAtIndex:13]];
            [surElement addAttribute:surAttribute];
            addSubElements(@"avg", [updateInfo objectAtIndex:14], @"flag", [updateInfo objectAtIndex:15], surElement);
            addSubElements(@"max", [updateInfo objectAtIndex:16], @"flag", [updateInfo objectAtIndex:17], surElement);
            addSubElements(@"min", [updateInfo objectAtIndex:18], @"flag", [updateInfo objectAtIndex:19], surElement);
            [setElement addChild:surElement];

            // RH-HR-AVG
            NSXMLElement *rhElement = [[NSXMLElement alloc] initWithName:@"rh" stringValue:[updateInfo objectAtIndex:20]];
            NSXMLElement *rhAttribute = [NSXMLElement attributeWithName:@"flag" stringValue:[updateInfo objectAtIndex:21]];
            [rhElement addAttribute:rhAttribute];
            [setElement addChild:rhElement];

            // Soil element
            NSXMLElement *soilElement = [[NSXMLElement alloc] initWithName:@"soil"];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"m_50" stringValue:[updateInfo objectAtIndex:22]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"m_100" stringValue:[updateInfo objectAtIndex:23]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"t_5" stringValue:[updateInfo objectAtIndex:24]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"t_10" stringValue:[updateInfo objectAtIndex:25]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"t_20" stringValue:[updateInfo objectAtIndex:26]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"t_50" stringValue:[updateInfo objectAtIndex:27]]];
            [soilElement addChild:[[NSXMLElement alloc] initWithName:@"t_100" stringValue:[updateInfo objectAtIndex:28]]];
            [setElement addChild:soilElement];

            [stationElement addChild:setElement];
        }
        
        // Optional explanation of element names
        [xmlDocument insertChild:[NSXMLNode commentWithStringValue:@"\n- Documentation for arbitrary element names\n- =========================================\n- <utc_d>         -> UTC_Date\n- <utc_t>         -> UTC_Time\n- <dl_vn>         -> CRX_VN\n- <temp><avg>     -> T_CALC\n- <temp><hr>      -> T_HR_AVG\n- <temp><max>     -> T_MAX\n- <temp><min>     -> T_MIN\n- <solar><avg>    -> SOLARAD\n- <solar><max>    -> SOLARAD_MAX\n- <solar><min>    -> SOLARAD_MIN\n- <sur [@type]>   -> SUR_TEMP_TYPE\n- <sur><avg>      -> SUR_TEMP\n- <sur><max>      -> SUR_TEMP_MAX\n- <sur><min>    	 -> SUR_TEMP_MIN\n- <rh>         	 -> RH_HR_AVG\n- <soil><m_*> 	 -> SOIL_MOISTURE_*\n- <soil><t_*>     -> SOIL_TEMP_*\n"] atIndex:0];

        // Save XML
        NSLog(@"Writing out XML file...");
        NSString *xml = [xmlDocument XMLStringWithOptions:NSXMLNodePrettyPrint];
        NSData *xmlFileData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        NSURL *xmlURL = [[sourceFile URLByDeletingPathExtension] URLByAppendingPathExtension:@"xml"];
        BOOL done = [xmlFileData writeToURL:xmlURL atomically:NO];
        if (done) {
            NSLog(@"Done.");
        }
    }
}

+ (NSArray *)parseBasicInfoFromFirstLine:(NSString *)firstLine {
    NSString *wbanno, *longitude, *latitude;
    
    wbanno = [CSVParser trimSubstringOfLine:firstLine from:0 length:5];         // WBANNO
    longitude = [CSVParser trimSubstringOfLine:firstLine from:41 length:7];     // LONGITUDE
    latitude = [CSVParser trimSubstringOfLine:firstLine from:49 length:7];      // LATITUDE
    
    return [NSArray arrayWithObjects:wbanno, longitude, latitude, nil];
}

+ (NSArray *)separateLine:(NSString *)line {
    NSString *updateInfo[29];
    updateInfo[0] = [CSVParser trimSubstringOfLine:line from:6 length:8];       // UTC_Date
    updateInfo[1] = [CSVParser trimSubstringOfLine:line from:15 length:4];      // UTC_Time
    updateInfo[2] = [CSVParser trimSubstringOfLine:line from:34 length:6];      // CRX_VN
    updateInfo[3] = [CSVParser trimSubstringOfLine:line from:57 length:7];      // T_CALC
    updateInfo[4] = [CSVParser trimSubstringOfLine:line from:65 length:7];      // T_HR_AVG
    updateInfo[5] = [CSVParser trimSubstringOfLine:line from:73 length:7];      // T_MAX
    updateInfo[6] = [CSVParser trimSubstringOfLine:line from:81 length:7];      // T_MIN
    updateInfo[7] = [CSVParser trimSubstringOfLine:line from:97 length:6];      // SOLARRAD
    updateInfo[8] = [CSVParser trimSubstringOfLine:line from:104 length:1];     // SOLARRAD_FLAG
    updateInfo[9] = [CSVParser trimSubstringOfLine:line from:106 length:6];     // SOLARRAD_MAX
    updateInfo[10] = [CSVParser trimSubstringOfLine:line from:113 length:1];    // SOLARRAD_MAX_FLAG
    updateInfo[11] = [CSVParser trimSubstringOfLine:line from:115 length:6];    // SOLARRAD_MIN
    updateInfo[12] = [CSVParser trimSubstringOfLine:line from:122 length:1];    // SOLARRAD_MIN_FLAG
    updateInfo[13] = [CSVParser trimSubstringOfLine:line from:124 length:1];    // SUR_TEMP_TYPE
    updateInfo[14] = [CSVParser trimSubstringOfLine:line from:126 length:7];    // SUR_TEMP
    updateInfo[15] = [CSVParser trimSubstringOfLine:line from:134 length:1];    // SUR_TEMP_FLAG
    updateInfo[16] = [CSVParser trimSubstringOfLine:line from:136 length:7];    // SUR_TEMP_MAX
    updateInfo[17] = [CSVParser trimSubstringOfLine:line from:144 length:1];    // SUR_TEMP_MAX_FLAG
    updateInfo[18] = [CSVParser trimSubstringOfLine:line from:146 length:7];    // SUR_TEMP_MIN
    updateInfo[19] = [CSVParser trimSubstringOfLine:line from:154 length:1];    // SUR_TEMP_MIN_FLAG
    updateInfo[20] = [CSVParser trimSubstringOfLine:line from:156 length:5];    // RH_HR_AVG
    updateInfo[21] = [CSVParser trimSubstringOfLine:line from:162 length:1];    // RH_HR_AVG_FLAG
    updateInfo[22] = [CSVParser trimSubstringOfLine:line from:188 length:7];    // SOIL_MOISTURE_50
    updateInfo[23] = [CSVParser trimSubstringOfLine:line from:196 length:7];    // SOIL_MOISTURE_100
    updateInfo[24] = [CSVParser trimSubstringOfLine:line from:204 length:7];    // SOIL_TEMP_5
    updateInfo[25] = [CSVParser trimSubstringOfLine:line from:212 length:7];    // SOIL_TEMP_10
    updateInfo[26] = [CSVParser trimSubstringOfLine:line from:220 length:7];    // SOIL_TEMP_20
    updateInfo[27] = [CSVParser trimSubstringOfLine:line from:228 length:7];    // SOIL_TEMP_50
    updateInfo[28] = [CSVParser trimSubstringOfLine:line from:236 length:7];    // SOIL_TEMP_100
    return [[NSArray alloc] initWithObjects:updateInfo count:29];
}

+ (NSString *)trimSubstringOfLine:(NSString *)line from:(NSUInteger)start length:(NSUInteger)length {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *substring = [[NSString alloc] initWithString:[line substringWithRange:NSMakeRange(start, length)]];
    return [substring stringByTrimmingCharactersInSet:characterSet];
}

@end
