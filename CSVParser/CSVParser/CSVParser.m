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
        
        // Build XML
        NSString *xml = [CSVParser buildXMLTreeWithBasicInfo:basicInfo updateInfo:updateInfoCollection];
        NSData *xmlFileData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        
        // Save XML
        NSMutableArray *urlArray = [[sourceFile pathComponents] mutableCopy];
        [urlArray replaceObjectAtIndex:([urlArray count] - 1) withObject:[NSString stringWithFormat:@"%@%@", [urlArray lastObject], @".xml"]];
        [fileManager createFileAtPath:[urlArray componentsJoinedByString:@"/"] contents:xmlFileData attributes:nil];
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

+ (NSString *)buildXMLTreeWithBasicInfo:(NSArray *)basicInfo updateInfo:(NSArray *)updateInfoCollection {
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    // Standard header
    [xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"http://www.imn.htwk-leipzig.de/~lhauswal/DBS/CRNH0203-2013-CO_Dinosaur_2_E.xsl\"?>\n<!DOCTYPE station SYSTEM \"http://www.imn.htwk-leipzig.de/~lhauswal/DBS/CRNH0203-2013-CO_Dinosaur_2_E.dtd\">\n<!--\n- Documentation for arbitrary element names\n- =========================================\n- <utc_d>         -> UTC_Date\n- <utc_t>         -> UTC_Time\n- <dl_vn>         -> CRX_VN\n- <temp><avg>     -> T_CALC\n- <temp><hr>      -> T_HR_AVG\n- <temp><max>     -> T_MAX\n- <temp><min>     -> T_MIN\n- <solar><avg>    -> SOLARAD\n- <solar><max>    -> SOLARAD_MAX\n- <solar><min>    -> SOLARAD_MIN\n- <sur [@type]>   -> SUR_TEMP_TYPE\n- <sur><avg>      -> SUR_TEMP\n- <sur><max>      -> SUR_TEMP_MAX\n- <sur><min>    	 -> SUR_TEMP_MIN\n- <rh>         	 -> RH_HR_AVG\n- <soil><m_*> 	 -> SOIL_MOISTURE_*\n- <soil><t_*>     -> SOIL_TEMP_*\n-->\n<station xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"CRNH0203-2013-CO_Dinosaur_2_E.xsd\">\n\t<wbanno>\n\t\t"];
    
    // Station info
    [xml appendString:[basicInfo objectAtIndex:0]];
    [xml appendString:@"\n\t</wbanno>\n\t<longitude>\n\t\t"];
    [xml appendString:[basicInfo objectAtIndex:1]];
    [xml appendString:@"\n\t</longitude>\n\t<latitude>\n\t\t"];
    [xml appendString:[basicInfo objectAtIndex:2]];
    [xml appendString:@"\n\t</latitude>\n"];
    
    // Update info
    for (NSArray *updateInfo in updateInfoCollection) {
        [xml appendString:@"\t<set>\n\t\t<utc_d>\n\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:0]];
        [xml appendString:@"\n\t\t</utc_d>\n\t\t<utc_t>\n\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:1]];
        [xml appendString:@"\n\t\t</utc_t>\n\t\t<dl_vn>\n\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:2]];
        [xml appendString:@"\n\t\t</dl_vn>\n\t\t<temp>\n\t\t\t<avg>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:3]];
        [xml appendString:@"\n\t\t\t</avg>\n\t\t\t<hr>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:4]];
        [xml appendString:@"\n\t\t\t</hr>\n\t\t\t<max>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:5]];
        [xml appendString:@"\n\t\t\t</max>\n\t\t\t<min>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:6]];
        [xml appendString:@"\n\t\t\t</min>\n\t\t</temp>\n\t\t<solar>\n\t\t\t<avg flag=\""];
        [xml appendString:[updateInfo objectAtIndex:8]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:7]];
        [xml appendString:@"\n\t\t\t</avg>\n\t\t\t<max flag=\""];
        [xml appendString:[updateInfo objectAtIndex:10]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:9]];
        [xml appendString:@"\n\t\t\t</max>\n\t\t\t<min flag=\""];
        [xml appendString:[updateInfo objectAtIndex:12]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:11]];
        [xml appendString:@"\n\t\t\t</min>\n\t\t</solar>\n\t\t<sur type=\""];
        [xml appendString:[updateInfo objectAtIndex:13]];
        [xml appendString:@"\">\n\t\t\t<avg flag=\""];
        [xml appendString:[updateInfo objectAtIndex:15]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:14]];
        [xml appendString:@"\n\t\t\t</avg>\n\t\t\t<max flag=\""];
        [xml appendString:[updateInfo objectAtIndex:17]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:16]];
        [xml appendString:@"\n\t\t\t</max>\n\t\t\t<min flag=\""];
        [xml appendString:[updateInfo objectAtIndex:19]];
        [xml appendString:@"\">\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:18]];
        [xml appendString:@"\n\t\t\t</min>\n\t\t</sur>\n\t\t<rh flag=\""];
        [xml appendString:[updateInfo objectAtIndex:21]];
        [xml appendString:@"\">\n\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:20]];
        [xml appendString:@"\n\t\t</rh>\n\t\t<soil>\n\t\t\t<m_50>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:22]];
        [xml appendString:@"\n\t\t\t</m_50>\n\t\t\t<m_100>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:23]];
        [xml appendString:@"\n\t\t\t</m_100>\n\t\t\t<t_5>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:24]];
        [xml appendString:@"\n\t\t\t</t_5>\n\t\t\t<t_10>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:25]];
        [xml appendString:@"\n\t\t\t</t_10>\n\t\t\t<t_20>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:26]];
        [xml appendString:@"\n\t\t\t</t_20>\n\t\t\t<t_50>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:27]];
        [xml appendString:@"\n\t\t\t</t_50>\n\t\t\t<t_100>\n\t\t\t\t"];
        [xml appendString:[updateInfo objectAtIndex:28]];
        [xml appendString:@"\n\t\t\t</t_100>\n\t\t</soil>\n\t</set>\n"];
    }
    
    [xml appendString:@"</station>\n"];
    
    return xml;
}

@end
