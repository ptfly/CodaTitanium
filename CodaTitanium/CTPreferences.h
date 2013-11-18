//
//  Preferences.h
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTPreferences : NSWindowController <NSWindowDelegate>
{    
    IBOutlet NSPopUpButton *defaultDevice;
    IBOutlet NSPopUpButton *defaultTitaniumSDK;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton *defaultDevice;
@property (nonatomic, retain) IBOutlet NSPopUpButton *defaultTitaniumSDK;

-(IBAction)updateDefaultDevice:(id)sender;
-(IBAction)updateDefaultTitaniumSDK:(id)sender;

@end
