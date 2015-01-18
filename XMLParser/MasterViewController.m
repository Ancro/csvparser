//
//  MasterViewController.m
//  XMLParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
}

- (IBAction)selectSourceFile:(id)sender {
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        sourceFile = [openPanel URL];
        [sourceFileLabel setStringValue:[sourceFile lastPathComponent]];
    }];
}

- (IBAction)generateXML:(id)sender {
    // TODO: Tell XMLParser to parse 'sourceFile'.
    
    parser = [[XMLParser alloc] init];
    NSLog(@"Sending filename to parser.");
    [parser generateXMLFileFrom:sourceFile];
}

@end
