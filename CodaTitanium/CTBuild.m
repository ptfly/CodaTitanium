//
//  CTBuild.m
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "CTBuild.h"

@implementation CTBuild
@synthesize project, command, field, logControl, runButton, stopButton, clearButton;

-(id)initWithProject:(NSString *)path
{
    self = [super initWithWindowNibName:@"CTBuild"];
    
    if(self){
        self.project = path;
    }
    
    return self;
}

-(void)windowDidLoad
{
    [field setMaxSize:CGSizeMake(FLT_MAX, FLT_MAX)];
    [field setHorizontallyResizable:YES];
    [[field textContainer] setWidthTracksTextView:NO];
    [[field textContainer] setContainerSize:CGSizeMake(FLT_MAX, FLT_MAX)];
    
    NSString *log = [[NSUserDefaults standardUserDefaults] stringForKey:@"CTLogLevel"];
    
    for(uint i=0; i<[logControl segmentCount]; i++){
        if([log isEqualToString:[[logControl labelForSegment:i] lowercaseString]]){
            [logControl setSelectedSegment:i];
        }
    }
    
    [stopButton setEnabled:NO];
    [stopButton setEnabled:NO];
    [clearButton setEnabled:NO];
}

-(void)windowWillClose:(NSNotification *)notification
{
    if(task && [task isRunning]){
        [task terminate];
    }
}

-(IBAction)runTask:(id)sender
{
    // just in case
    [self stopTask:sender];
    [self buildWithParams:command];
}

-(IBAction)stopTask:(id)sender
{
    if(task && [task isRunning]){
        [task terminate];
    }
    
    [stopButton setEnabled:NO];
    [runButton setEnabled:YES];
}

-(IBAction)setLogLevel:(id)sender
{
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSString *selected = [[control labelForSegment:[control selectedSegment]] lowercaseString];
    
    [[NSUserDefaults standardUserDefaults] setObject:selected forKey:@"CTLogLevel"];
}

-(IBAction)clearLog:(id)sender
{
    [clearButton setEnabled:NO];
    [field setString:@""];
}

-(void)printLog:(NSString *)str
{
    [field setEditable:YES];
    [field insertText:[NSString stringWithFormat:@"%@", str]];
    [field setEditable:NO];
}

-(void)buildWithParams:(NSString *)params
{
    [self showWindow:self];
    [self clearLog:nil];
    
    if([project isEqualToString:@""]){
        [self printLog:@"[ERROR] : Invalid Project Path"];
        return;
    }
    else {
        [self printLog:[NSString stringWithFormat:@"[PROJECT] : %@\n\n", project]];
    }
    
    self.command = params;
    
    NSArray *arguments = [command componentsSeparatedByString:@":"];
    
    if([arguments count] < 2){
        [self printLog:[NSString stringWithFormat:@"[ERROR] : Invalid arguments - %@", arguments]];
        return;
    }
    
    NSString *titanium      = [[NSUserDefaults standardUserDefaults] stringForKey:@"CTExecPath"];
    NSString *sdkVersion    = [[NSUserDefaults standardUserDefaults] stringForKey:@"CTSDKVersion"];
    NSString *logLevel      = [[NSUserDefaults standardUserDefaults] stringForKey:@"CTLogLevel"];
    NSString *platform      = [arguments objectAtIndex:0];
    NSString *target        = [arguments objectAtIndex:1];
    NSString *device        = @"";
    
    if([arguments count] > 2){
         device = [NSString stringWithFormat:@"--device-family %@", [arguments objectAtIndex:2]];
    }
    
    NSString *cli = [NSString stringWithFormat: @"%@titanium build --platform %@ --target %@ --project-dir '%@' --sdk %@ --log-level %@ --no-colors %@", titanium, platform, target, project, sdkVersion, logLevel, device];
    
    [self execute:cli];
}

-(void)execute:(NSString *)string
{
    NSString *shell = [self setupShellEnvironment];
    
    if([shell isEqualToString:@""]){
        [self printLog:@"[ERROR] : User shell unavailable... operation oborted!"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        task = [[NSTask alloc] init];
        [task setLaunchPath:shell];
        [task setArguments:[NSArray arrayWithObjects:@"-c", string, nil]];

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
        
        [runButton setEnabled:NO];
        [stopButton setEnabled:YES];
    });
}

-(void)outData:(NSNotification *)notification
{
    [clearButton setEnabled:YES];
    
    NSFileHandle *handle = (NSFileHandle *) [notification object];
    NSData *data = [handle availableData];
    
    if([data length]){
        NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self printLog:line];
    }
    
    [handle waitForDataInBackgroundAndNotify];
}

-(void)errData: (NSNotification *) notification
{
    [clearButton setEnabled:YES];
    
    NSFileHandle *handle = (NSFileHandle *) [notification object];
    NSData *data = [handle availableData];
    
    if([data length]){
        NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self printLog:[NSString stringWithFormat:@"%@", line]];
    }
    
    [handle waitForDataInBackgroundAndNotify];
}

-(void)terminated: (NSNotification *)notification
{
    [clearButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString *)setupShellEnvironment
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
