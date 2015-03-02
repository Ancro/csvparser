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

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testXMLDocumentWithCorrectData
{
	NSXMLDocument *validDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[[NSBundle bundleForClass: self.class] URLForResource:@"validFile" withExtension:@"xml"] options:NSXMLInvalidKind error:NULL];

	CSVParser *parser = [CSVParser new];
	NSXMLDocument *xmlDocument = [parser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"validFile" withExtension:@"txt"]];

	XCTAssertNotNil(xmlDocument);
	XCTAssertEqualObjects(validDocument.XMLString, xmlDocument.XMLString);
}

- (void)testXMLDocumentWithIncompleteData
{
	CSVParser *parser = [CSVParser new];
	NSXMLDocument *xmlDocument = [parser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"incompleteFile" withExtension:@"txt"]];

	XCTAssertNil(xmlDocument);
}

- (void)testXMLDocumentWithTooMuchData
{
	CSVParser *parser = [CSVParser new];
	NSXMLDocument *xmlDocument = [parser XMLDocumentFromFileAtURL: [[NSBundle bundleForClass: self.class] URLForResource:@"wrongFile" withExtension:@"txt"]];
	
	XCTAssertNil(xmlDocument);
}

- (void)testPerformanceExample
{
	// This is an example of a performance test case.
	[self measureBlock:^{
		// Put the code you want to measure the time of here.
	}];
}

@end
