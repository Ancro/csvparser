//
//  MasterViewController.h
//  CSVParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSVParser.h"

@interface MasterViewController : NSViewController;

- (IBAction)selectSourceFile:(id)sender;

- (IBAction)generateXML:(id)sender;

@end
