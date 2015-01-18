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

- (IBAction)chooseSourceFile:(id)sender {
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        [sourceFileLabel setStringValue:[[openPanel URL] lastPathComponent]];
    }];
}

@end
