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
        
        NSMutableArray *separatedLineArray = [NSMutableArray array];
        
        for (NSString *line in contentArray) {
            [separatedLineArray addObject:[line substringWithRange:NSMakeRange(0, 5)]];
            NSLog(@"%@", [separatedLineArray componentsJoinedByString:@", "]);
        }
    }
}

@end
