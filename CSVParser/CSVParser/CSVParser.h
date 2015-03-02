//
//  CSVParser.h
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVParser : NSObject

/*!
 @abstract Returns an NSXMLDocument parsed from the CSV file located at the given URL.
 */
+ (NSXMLDocument *)XMLDocumentFromFileAtURL:(NSURL *)sourceFile;

@end
