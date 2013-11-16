//
//  CTBuild.m
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "CTBuild.h"

@implementation CTBuild
@synthesize field;

-(void)windowWillClose:(NSNotification *)notification
{
    if(task && [task isRunning]){
        [task terminate];
    }
}

-(void)print:(NSString *)str
{
    [field setEditable:YES];
    [field insertText:[NSString stringWithFormat:@"%@", str]];
    [field setTextColor:[NSColor whiteColor]];
    [field setEditable:NO];
}

-(void)run:(NSString *)command onPath:(NSString *)path;
{
    NSString *userShell = [self getUserShell];
    if([userShell isEqualToString:@""]){
        [self print:@"ERROR: Invalid User Shell... operation aborted!\n"];
        return;
    }
    
    [self print:[NSString stringWithFormat:@"Building project: %@\n\n",path]];
    [self setEnvironment:userShell];
    
    NSString *exec = [NSString stringWithFormat:@"/usr/local/bin/titanium build -p ios -T simulator -d '%@'", path];
    
    // Run the task
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        task = [[NSTask alloc] init];
        [task setLaunchPath:userShell];
        [task setArguments:[NSArray arrayWithObjects:@"-c", exec, nil]];
        
        NSPipe *pipe = [NSPipe pipe];
        NSPipe *errorPipe = [NSPipe pipe];
        
        [task setStandardOutput:pipe];
        [task setStandardError:errorPipe];
        
        NSFileHandle *outFile = [pipe fileHandleForReading];
        NSFileHandle *errFile = [errorPipe fileHandleForReading];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminated:)
                                                     name:NSTaskDidTerminateNotification
                                                   object:task];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(outData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:outFile];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(errData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:errFile];
        
        [outFile waitForDataInBackgroundAndNotify];
        [errFile waitForDataInBackgroundAndNotify];
        
        [task launch];
    });
}

-(void)outData:(NSNotification *)notification
{
    NSFileHandle *handle = (NSFileHandle *) [notification object];
    NSData *data = [handle availableData];
    
    if([data length]){
        NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self print:line];
    }
    
    [handle waitForDataInBackgroundAndNotify];
}

-(void)errData: (NSNotification *) notification
{
    NSFileHandle *handle = (NSFileHandle *) [notification object];
    NSData *data = [handle availableData];
    
    if([data length]){
        NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self print:[NSString stringWithFormat:@"ERROR: %@", line]];
    }
    
    [handle waitForDataInBackgroundAndNotify];
}

-(void)terminated: (NSNotification *)notification
{
    //NSTask *handle = (NSTask *) [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString *)getUserShell
{
    NSString *userShell = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
    
    BOOL isValidShell = NO;
    for(NSString *validShell in [[NSString stringWithContentsOfFile:@"/etc/shells" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]){
        if([[validShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:userShell]){
            isValidShell = YES;
            break;
        }
    }
    
    if(!isValidShell){
        return @"";
    }
    
    return userShell;
}

-(void)setEnvironment:(NSString *)userShell
{
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
    if(userPath.length > 0 && [userPath rangeOfString:@":"].length > 0 && [userPath rangeOfString:@"/usr/bin"].length > 0) {
        userPath = [NSString stringWithFormat:@"%@:/usr/local/bin/", userPath];
        setenv("PATH", [userPath fileSystemRepresentation], 1);
    }
}

@end
