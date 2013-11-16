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
		controller = inController;
        
        [controller registerActionWithTitle:@"Build Current Project:" target:self selector:nil];
        
        [controller registerActionWithTitle:@"iPad Simulator" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:@"ipad" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"iPhone Simulator" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:@"iphone" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Android Emulator" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:@"android" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Browser" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:@"mobileweb-b" keyEquivalent:nil pluginName:nil];
        [controller registerActionWithTitle:@"Mobile Web Preview in Emulator" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:@"mobileweb-e" keyEquivalent:nil pluginName:nil];
        
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
        build = [[CTBuild alloc] initWithWindowNibName:@"CTBuild"];
        [build showWindow:self];
        [build run:[sender representedObject] onPath:[tv siteLocalPath]];
    }
}

-(void)preferences:(id)sender
{
    pref = [[CTPreferences alloc] initWithWindowNibName:@"CTPreferences"];
    [pref showWindow:self];
}



@end
