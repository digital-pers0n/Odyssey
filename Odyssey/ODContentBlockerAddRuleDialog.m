//
//  ODContentBlockerAddRuleDialog.m
//  Odyssey
//
//  Created by Terminator on 11/25/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODContentBlockerAddRuleDialog.h"

@interface ODContentBlockerAddRuleDialog ()
{
    IBOutlet NSTextField *_textField;
    NSString *_rule;
}

-(IBAction)okButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

@end

@implementation ODContentBlockerAddRuleDialog

-(NSString *)windowNibName
{
    return @"ODContentBlockerAddRuleDialog";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(NSString *)editRule:(NSString *)rule
{
    NSWindow *window = self.window;
    self.cancel = NO;
    
    if (rule) {
        _textField.stringValue = rule;
    } 
    
    [NSApp beginSheet:window modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:window];
    // sheet is up here...
    
    [NSApp endSheet:window];
    [self.window orderOut:self];
    
    rule = _textField.stringValue;
    
    if (rule.length == 0) {
        rule = nil;
    }
    
    return rule;
    
}

-(void)okButtonClicked:(id)sender
{
    [NSApp stopModal]; 
}

-(void)cancelButtonClicked:(id)sender
{
    self.cancel = YES;
    [NSApp stopModal];
}

@end
