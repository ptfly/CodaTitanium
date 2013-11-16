//
//  CTBuild.h
//  CodaTitanium
//
//  Created by Plamen Todorov on 15.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTBuild : NSWindowController <NSWindowDelegate>
{
    NSString *command;
    NSString *project;
    
    IBOutlet NSTextView *field;
    
    IBOutlet NSToolbarItem *runButton;
    IBOutlet NSToolbarItem *stopButton;
    IBOutlet NSToolbarItem *clearButton;
    IBOutlet NSSegmentedControl *logControl;
    
    NSTask *task;
}

@property (nonatomic, retain) NSString *project;
@property (nonatomic, retain) NSString *command;
@property (nonatomic, retain) IBOutlet NSTextView *field;
@property (nonatomic, retain) IBOutlet NSToolbarItem *runButton;
@property (nonatomic, retain) IBOutlet NSToolbarItem *stopButton;
@property (nonatomic, retain) IBOutlet NSToolbarItem *clearButton;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *logControl;

-(IBAction)runTask:(id)sender;
-(IBAction)stopTask:(id)sender;
-(IBAction)setLogLevel:(id)sender;
-(IBAction)clearLog:(id)sender;

-(id)initWithProject:(NSString *)path;
-(void)buildWithParams:(NSString *)params;

@end
