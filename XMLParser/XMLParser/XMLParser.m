//
//  XMLParser.m
//  XMLParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (void)generateXMLFileFrom:(NSURL *)sourceFile {
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
        NSArray *basicInfo = [XMLParser parseBasicInfoFromFristLine:[contentArray objectAtIndex:0]];
        NSLog(@"%@", [basicInfo componentsJoinedByString:@", "]);
        
        // Parse update info        
        NSMutableArray *updateInfoCollection = [NSMutableArray array];
        for (NSString *line in contentArray) {
            [updateInfoCollection addObject:[XMLParser separateLine:line]];
        }
        
        // Test for successful parsing in console
        for (int i = 0; i < [updateInfoCollection count]; i++) {
            for (int j = 0; j < [[updateInfoCollection objectAtIndex:i] count]; j++) {
                NSLog(@"%@", [[updateInfoCollection objectAtIndex:i] objectAtIndex:j]);
            }
        }
    }
}

+ (NSArray *)parseBasicInfoFromFristLine:(NSString *)firstLine {
    NSString *wbanno, *longitude, *latitude;
    
    wbanno = [[firstLine substringWithRange:NSMakeRange(0, 5)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];      // WBANNO
    longitude = [[firstLine substringWithRange:NSMakeRange(41, 7)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  // LONGITUDE
    latitude = [[firstLine substringWithRange:NSMakeRange(49, 7)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];   // LATITUDE
    
    return [NSArray arrayWithObjects:wbanno, longitude, latitude, nil];
}

+ (NSArray *)separateLine:(NSString *)line {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *updateInfo[29];
    updateInfo[0] = [[line substringWithRange:NSMakeRange(6, 8)] stringByTrimmingCharactersInSet:characterSet];     // UTC_Date
    updateInfo[1] = [[line substringWithRange:NSMakeRange(15, 4)] stringByTrimmingCharactersInSet:characterSet];    // UTC_Time
    updateInfo[2] = [[line substringWithRange:NSMakeRange(34, 6)] stringByTrimmingCharactersInSet:characterSet];    // CRX_VN
    updateInfo[3] = [[line substringWithRange:NSMakeRange(57, 7)] stringByTrimmingCharactersInSet:characterSet];    // T_CALC
    updateInfo[4] = [[line substringWithRange:NSMakeRange(65, 7)] stringByTrimmingCharactersInSet:characterSet];    // T_HR_AVG
    updateInfo[5] = [[line substringWithRange:NSMakeRange(73, 7)] stringByTrimmingCharactersInSet:characterSet];    // T_MAX
    updateInfo[6] = [[line substringWithRange:NSMakeRange(81, 7)] stringByTrimmingCharactersInSet:characterSet];    // T_MIN
    updateInfo[7] = [[line substringWithRange:NSMakeRange(97, 6)] stringByTrimmingCharactersInSet:characterSet];    // SOLARRAD
    updateInfo[8] = [[line substringWithRange:NSMakeRange(104, 1)] stringByTrimmingCharactersInSet:characterSet];   // SOLARRAD_FLAG
    updateInfo[9] = [[line substringWithRange:NSMakeRange(106, 6)] stringByTrimmingCharactersInSet:characterSet];   // SOLARRAD_MAX
    updateInfo[10] = [[line substringWithRange:NSMakeRange(113, 1)] stringByTrimmingCharactersInSet:characterSet];  // SOLARRAD_MAX_FLAG
    updateInfo[11] = [[line substringWithRange:NSMakeRange(115, 6)] stringByTrimmingCharactersInSet:characterSet];  // SOLARRAD_MIN
    updateInfo[12] = [[line substringWithRange:NSMakeRange(122, 1)] stringByTrimmingCharactersInSet:characterSet];  // SOLARRAD_MIN_FLAG
    updateInfo[13] = [[line substringWithRange:NSMakeRange(124, 1)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_TYPE
    updateInfo[14] = [[line substringWithRange:NSMakeRange(126, 7)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP
    updateInfo[15] = [[line substringWithRange:NSMakeRange(134, 1)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_FLAG
    updateInfo[16] = [[line substringWithRange:NSMakeRange(136, 7)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_MAX
    updateInfo[17] = [[line substringWithRange:NSMakeRange(144, 1)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_MAX_FLAG
    updateInfo[18] = [[line substringWithRange:NSMakeRange(146, 7)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_MIN
    updateInfo[19] = [[line substringWithRange:NSMakeRange(154, 1)] stringByTrimmingCharactersInSet:characterSet];  // SUR_TEMP_MIN_FLAG
    updateInfo[20] = [[line substringWithRange:NSMakeRange(156, 5)] stringByTrimmingCharactersInSet:characterSet];  // RH_HR_AVG
    updateInfo[21] = [[line substringWithRange:NSMakeRange(162, 1)] stringByTrimmingCharactersInSet:characterSet];  // RH_HR_AVG_FLAG
    updateInfo[22] = [[line substringWithRange:NSMakeRange(188, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_MOISTURE_50
    updateInfo[23] = [[line substringWithRange:NSMakeRange(196, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_MOISTURE_100
    updateInfo[24] = [[line substringWithRange:NSMakeRange(204, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_TEMP_5
    updateInfo[25] = [[line substringWithRange:NSMakeRange(212, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_TEMP_10
    updateInfo[26] = [[line substringWithRange:NSMakeRange(220, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_TEMP_20
    updateInfo[27] = [[line substringWithRange:NSMakeRange(228, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_TEMP_50
    updateInfo[28] = [[line substringWithRange:NSMakeRange(236, 7)] stringByTrimmingCharactersInSet:characterSet];  // SOIL_TEMP_100
    return [[NSArray alloc] initWithObjects:updateInfo count:29];
}

@end
