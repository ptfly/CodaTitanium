//
//  CTDelegate.m
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "CTDelegate.h"

@interface CTDelegate ()
-(id)initWithController:(CodaPlugInsController *)inController;
@end

@class CodaPlugInsController;

@implementation CTDelegate

//2.0 and lower
-(id)initWithPlugInController:(CodaPlugInsController *)aController bundle:(NSBundle*)aBundle
{
    oldBundle = aBundle;
    return [self initWithController:aController];
}

//2.0.1 and higher
-(id)initWithPlugInController:(CodaPlugInsController *)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
    newBundle = plugInBundle;
    return [self initWithController:aController];
}

-(id)initWithController:(CodaPlugInsController *)inController
{
	if((self = [super init]) != nil)
	{
        // Defaul configuration
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"/usr/local/bin/",       @"CTExecPath",
                                      @"ios:simulator:iphone",  @"CTDefaultTarget",
                                      @"trace",                 @"CTLogLevel",
                                      @"latest",                @"CTSDKVersion",
                                      @"NO",                    @"CTBuildOnly",
                                      @"NO",                    @"CTForceRebuild",
                                  nil];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
        NSString *CTDefaultTarget = [[NSUserDefaults standardUserDefaults] stringForKey:@"CTDefaultTarget"];

        // Init
		controller = inController;
        
        NSString *newGroup = @"New...";
        [controller registerActionWithTitle:@"iPad Simulator" underSubmenuWithTitle:newGroup target:self selector:@selector(build:) representedObject:@"ios:simulator:ipad" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"iPhone Simulator" underSubmenuWithTitle:newGroup target:self selector:@selector(build:) representedObject:@"ios:simulator:iphone" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Android Emulator" underSubmenuWithTitle:newGroup target:self selector:@selector(build:) representedObject:@"android:emulator" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Browser" underSubmenuWithTitle:newGroup target:self selector:@selector(build:) representedObject:@"mobileweb:browser" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Emulator" underSubmenuWithTitle:newGroup target:self selector:@selector(build:) representedObject:@"mobileweb:emulator" keyEquivalent:nil pluginName:nil];
        
        [controller registerActionWithTitle:@"—" target:self selector:nil];
        
        [controller registerActionWithTitle:@"Build & Run" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:CTDefaultTarget keyEquivalent:@"cmd+b" pluginName:nil];
        
        NSString *buildGroup = @"Build & Run...";
        [controller registerActionWithTitle:@"iPad Simulator" underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:@"ios:simulator:ipad" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"iPhone Simulator" underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:@"ios:simulator:iphone" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Android Emulator" underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:@"android:emulator" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Browser" underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:@"mobileweb:browser" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Emulator" underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:@"mobileweb:emulator" keyEquivalent:nil pluginName:nil];
        
        [controller registerActionWithTitle:@"—" target:self selector:nil];
        [controller registerActionWithTitle:@"Preferences..." target:self selector:@selector(preferences:)];
    }
    
	return self;
}

-(NSString *)name
{
	return @"Titanium";
}

-(void)build:(id)sender
{
    CodaTextView *tv = [controller focusedTextView:self];
    
    if(tv)
    {
        if(!build){
            build = [[CTBuild alloc] initWithProject:[tv siteLocalPath]];
        }
        
        [build buildWithParams:[sender representedObject]];
    }
}

-(void)preferences:(id)sender
{
    if(!pref){
        pref = [[CTPreferences alloc] initWithWindowNibName:@"CTPreferences"];
    }
    
    [pref showWindow:self];
}

@end
