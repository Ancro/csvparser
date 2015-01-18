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
        
        fileContents = [fileManager contentsAtPath:[sourceFile path]];
        NSString *output = [[NSString alloc] initWithData:fileContents encoding:NSUTF8StringEncoding];
        NSLog(@"%@", output);
    }
}

@end
