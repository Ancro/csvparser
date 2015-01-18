//
//  XMLParser.h
//  XMLParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject {
    NSFileManager *fileManager;
    NSData *fileContents;
}

- (void)generateXMLFileFrom:(NSURL *)sourceFile;

@end
