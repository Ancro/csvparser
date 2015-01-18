//
//  MasterViewController.h
//  XMLParser
//
//  Created by Lucas Hauswald on 18.01.15.
//  Copyright (c) 2015 Lucas Hauswald. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MasterViewController : NSViewController {
    
    IBOutlet NSTextField *sourceFileLabel;
    NSOpenPanel *openPanel;
    
}

- (IBAction)chooseSourceFile:(id)sender;

@end
