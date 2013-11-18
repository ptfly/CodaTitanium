//
//  Preferences.m
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "CTConfig.h"
#import "CTPreferences.h"

@interface CTPreferences ()

@end

@implementation CTPreferences
@synthesize defaultDevice, defaultTitaniumSDK;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if(self){

    }
    return self;
}

- (void)windowDidLoad
{
    NSDictionary *devices = [CTConfig devicesList];
    NSString *current = [devices objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"CTDefaultTarget"]];
    
    [defaultDevice removeAllItems];
    [defaultDevice addItemsWithTitles:[devices allValues]];
    [defaultDevice selectItemWithTitle:current];
    
    [super windowDidLoad];
}

-(IBAction)updateDefaultDevice:(id)sender
{
    NSString *command = [[[CTConfig devicesList] allKeysForObject:[sender titleOfSelectedItem]] lastObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:command forKey:@"CTDefaultTarget"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)updateDefaultTitaniumSDK:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[[sender titleOfSelectedItem] lowercaseString] forKey:@"CTSDKVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
