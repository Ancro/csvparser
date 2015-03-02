//
//  MasterViewController.m
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () {
    IBOutlet NSTextField *_sourceFileLabel;
    NSOpenPanel *_openPanel;
    NSURL *_sourceFile;

    CSVParser *parser;
}

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _openPanel = NSOpenPanel.openPanel;

    _openPanel.canChooseFiles = YES;
    _openPanel.canChooseDirectories = NO;
    _openPanel.allowsMultipleSelection = NO;
    _openPanel.allowedFileTypes = [NSArray arrayWithObject:@"txt"];
}

- (IBAction)selectSourceFile:(id)sender
{
    [_openPanel beginWithCompletionHandler:^(NSInteger result) {
        _sourceFile = _openPanel.URL;
        _sourceFileLabel.stringValue = _sourceFile.lastPathComponent;
    }];
}

- (IBAction)generateXML:(id)sender
{
    parser = [CSVParser new];
    NSXMLDocument *xmlDocument = [parser XMLDocumentFromFileAtURL: _sourceFile];

    if (!xmlDocument) {
        _sourceFileLabel.stringValue = @"File format incompatible";
        return;
    }

    // Save XML
    NSString *xml = [xmlDocument XMLStringWithOptions:NSXMLNodePrettyPrint];
    NSData *xmlFileData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *xmlURL = [[_sourceFile URLByDeletingPathExtension] URLByAppendingPathExtension:@"xml"];
    [xmlFileData writeToURL:xmlURL atomically:NO];
}

@end
