//
//  CodaTitanium.h
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CTConfig.h"
#import "CTBuild.h"
#import "CTPreferences.h"
#import "CodaPluginsController.h"

@class CTBuild, CTPreferences, CodaPlugInsController;

@interface CTDelegate : NSObject <CodaPlugIn>
{
    CTBuild *build;
    CTPreferences *pref;
    CodaPlugInsController *controller;
    
    NSBundle *oldBundle;
    NSObject <CodaPlugInBundle> *newBundle;
}

@end
