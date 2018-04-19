//
//  ODContentFilterEditRule.m
//  Odyssey
//
//  Created by Terminator on 4/24/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODContentFilterEditRule.h"
#import "ODModalDialog.h"

@interface ODContentFilterEditRule ()
{
    IBOutlet NSTextView *_textView;
    BOOL _wasCancelled;
}


-(IBAction)okButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

@end

@implementation ODContentFilterEditRule

-(NSString *)nibName 
{
    return [self className];
}

- (void)editRule:(NSString *)rule withReply:(void (^)(NSString *))respond {
    NSView *view = self.view;

    _textView.string = rule;
    _wasCancelled = YES;

    NSPanel *window = [ODModalDialog modalDialogWithView:view];
    [window setInitialFirstResponder:_textView];
    [window makeKeyAndOrderFront:nil];
    
    [NSApp runModalForWindow:window];
    // sheet is up here...
    
    [NSApp endSheet:window];
    [window orderOut:self];
    
    if (!_wasCancelled) {
        rule = _textView.string;
    } else {
        rule = nil;
    }
    respond(rule);
}

-(void)okButtonClicked:(id)sender
{
    _wasCancelled = NO;
    [NSApp stopModal];
}

-(void)cancelButtonClicked:(id)sender
{
    _wasCancelled = YES;
    [NSApp stopModal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
