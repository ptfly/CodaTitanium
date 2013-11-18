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
        
        [controller registerActionWithTitle:@"Build & Run" underSubmenuWithTitle:nil target:self selector:@selector(build:) representedObject:CTDefaultTarget keyEquivalent:@"cmd+b" pluginName:nil];
        
        NSString *buildGroup = @"Build & Run...";
        
        [[CTConfig devicesList] enumerateKeysAndObjectsUsingBlock:^(id value, id text, BOOL *stop) {
            [controller registerActionWithTitle:text underSubmenuWithTitle:buildGroup target:self selector:@selector(build:) representedObject:value keyEquivalent:nil pluginName:nil];
        }];
        
        [controller registerActionWithTitle:@"Preferences..." underSubmenuWithTitle:nil target:self selector:@selector(preferences:) representedObject:nil keyEquivalent:nil pluginName:@"Titanium"];
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
    
    [pref showWindow:[pref window]];
}


@end
