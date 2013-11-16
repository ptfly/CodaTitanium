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
    IBOutlet NSTextView *field;
    NSTask *task;
}

@property (nonatomic, retain) IBOutlet NSTextView *field;

-(void)run:(NSString *)command onPath:(NSString *)path;

@end
