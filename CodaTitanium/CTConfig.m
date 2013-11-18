//
//  CTConfig.m
//  CodaTitanium
//
//  Created by Plamen Todorov on 18.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "CTConfig.h"

@implementation CTConfig

+(NSDictionary *)devicesList
{
    NSDictionary *list = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"iPhone Simulator", @"ios:simulator:iphone",
                @"iPad Simulator", @"ios:simulator:ipad",
                @"Android Emulator", @"android:emulator",
                @"Mobile Web - Browser", @"mobileweb:browser",
                @"Mobile Web - Emulator", @"mobileweb:emulator",
                nil];
    
    // TODO: order that shit
    return list;
}

+(NSString *)userShell
{
    BOOL isValidShell = NO;
    NSString *userShell = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
    
    for(NSString *validShell in [[NSString stringWithContentsOfFile:@"/etc/shells" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]){
        if([[validShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:userShell]){
            isValidShell = YES;
            break;
        }
    }
    
    if(!isValidShell){
        return @"";
    }
    
    NSTask *readPath = [[NSTask alloc] init];
    [readPath setLaunchPath:userShell];
    [readPath setArguments:[NSArray arrayWithObjects:@"-c", @"echo $PATH", nil]];
    
    NSPipe *outPipe = [NSPipe pipe];
    [readPath setStandardOutput:outPipe];
    
    [readPath launch];
    [readPath waitUntilExit];
    
    NSData *dataRead = [[outPipe fileHandleForReading] readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    NSString *userPath = [stringRead stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(userPath.length > 0 && [userPath rangeOfString:@":"].length > 0 && [userPath rangeOfString:@"/usr/bin"].length > 0)
    {
        userPath = [NSString stringWithFormat:@"%@:%@", userPath, [[NSUserDefaults standardUserDefaults] stringForKey:@"CTExecPath"]];
        setenv("PATH", [userPath fileSystemRepresentation], 1);
        
        return userShell;
    }
    
    return @"";
}

@end
