//
//  CSVParser_Tests.m
//  CSVParser Tests
//
//  Created by Lucas Hauswald on 02.03.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "MasterViewController.h"
#import "CSVParser.h"

@interface CSVParser_Tests : XCTestCase

@end

@implementation CSVParser_Tests

- (void)testXMLDocumentWithCorrectData
{
	NSXMLDocument *validDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[[NSBundle bundleForClass: self.class] URLForResource:@"validFile" withExtension:@"xml"] options:NSXMLInvalidKind error:NULL];

	NSXMLDocument *xmlDocument = [CSVParser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"validFile" withExtension:@"txt"]];

	XCTAssertNotNil(xmlDocument);
	XCTAssertEqualObjects(validDocument.XMLString, xmlDocument.XMLString);
}

- (void)testXMLDocumentWithIncompleteData
{
	NSXMLDocument *xmlDocument = [CSVParser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"incompleteFile" withExtension:@"txt"]];

	XCTAssertNil(xmlDocument);
}

- (void)testXMLDocumentWithTooMuchData
{
	NSXMLDocument *xmlDocument = [CSVParser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"wrongFile" withExtension:@"txt"]];
	
	XCTAssertNil(xmlDocument);
}

@end
