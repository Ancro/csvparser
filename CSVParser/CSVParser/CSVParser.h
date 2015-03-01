//
//  CSVParser.h
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVParser : NSObject;

- (NSXMLDocument *)XMLDocumentFromFileAtURL:(NSURL *)sourceFile;

@end
