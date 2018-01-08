//
//  ODAddressField.m
//  Odyssey
//
//  Created by Terminator on 4/13/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODAddressField.h"
#import "ODDelegate.h"

#define ID_KEY @"Identifier"
#define NAME_KEY @"Name"
#define URL_KEY @"URLTemplate"
#define DEFAULTS_KEY @"DefaultSearchEngineID"

@interface ODAddressField (){
    
    IBOutlet NSTextField *_addressField;
    IBOutlet NSPopUpButton *_searchEngineButton;
    IBOutlet NSBox *_backgroundView;
    
    NSString *_searchURL;
    NSString *_address;
    BOOL _cancelled;
    
}

-(IBAction)okPressed:(id)sender;
-(IBAction)cancelPressed:(id)sender;

@end

@implementation ODAddressField

-(void)awakeFromNib
{
    [self _setUpSearchEngine];
    _backgroundView.fillColor = [NSColor whiteColor];
    _backgroundView.borderColor = [NSColor lightGrayColor];
    _backgroundView.cornerRadius = 4;
}

-(NSString *)nibName
{
    return [self className];
}

-(void)editString:(NSString *)rule withReply:(void (^)(NSString *))respond
{
    {
        BOOL(^checkString)(id, id) = ^(NSString *arg0, NSString *arg1) {
            NSRange range = [arg0 rangeOfString:arg1 options:NSCaseInsensitiveSearch];
            if (range.length) {
                return YES;
            }
            return NO;
        };
        
        _cancelled = YES;
        
        NSView *view = self.view;
        
        if (rule) {
            
            _addressField.stringValue = rule;
        } 
//        
//        NSRect viewFrame = view.frame;
//        NSInteger styleMask = NSTitledWindowMask | NSTexturedBackgroundWindowMask | NSUtilityWindowMask;
//        NSPanel *window = [[NSPanel alloc] initWithContentRect:viewFrame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
//        [window setBackgroundColor:[NSColor blackColor]];
//        //[window setFrame:view.frame display:NO animate:NO];
//        NSRect frame = [[NSApp mainWindow] frame];
//        NSPoint point =  NSMakePoint(NSMinX(frame) + ((NSWidth(frame) - NSWidth(viewFrame)) / 2),
//                                     NSMinY(frame) + ((NSHeight(frame) - NSHeight(viewFrame)) / 2));
//        [window setFrameOrigin:point];
//        [window.contentView addSubview:view];
        NSPanel *window = [(ODDelegate *)[NSApp delegate] modalDialogWithView:view];
        [window setInitialFirstResponder:_addressField];
        [window makeKeyAndOrderFront:nil];
        
        
        //[NSApp beginSheet:window modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
        [NSApp runModalForWindow:window];
    
        // sheet is up here...
        
        [NSApp endSheet:window];
        [window orderOut:self];
        
        if (_cancelled) {
            
            rule = nil;
            
        } else {
            
            rule = _addressField.stringValue;
            
            if (checkString(rule, @".")) {
                
                if (!checkString(rule, @"http") && !checkString(rule, @"file")) {
                    
                    rule = [NSString stringWithFormat:@"http://%@", rule];
                    
                } 
                
            } else {
                
                rule = [rule stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                rule = [_searchURL stringByReplacingOccurrencesOfString:@"{searchTerms}" withString:rule];
                
            }
            
            
        }
        
        respond(rule);
        
        
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

-(void)okPressed:(id)sender
{
    _cancelled = NO;
    [NSApp stopModal];
}

-(void)cancelPressed:(id)sender
{
    _cancelled = YES;
    [NSApp stopModal];
    
}

-(void)setSearchURL:(NSMenuItem *)sender
{
    //[_searchEngineButton selectItem:sender];
    NSDictionary *data = sender.representedObject;
    _searchURL = data[URL_KEY];
    for (NSMenuItem *item in _searchEngineButton.menu.itemArray) {
        [item setState:NSOffState];
    }
    [sender setState:NSOnState];
    [[NSUserDefaults standardUserDefaults] setObject:data[ID_KEY] forKey:DEFAULTS_KEY];
}

#pragma mark - Private

-(void)_setUpSearchEngine
{
    
    NSString *engineID = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY];
    NSArray *data = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SearchEngines" ofType: @"plist"]];
    if (data) {
        for (NSDictionary *dict in data) {
            NSMenuItem *item = [[NSMenuItem alloc ] initWithTitle:dict[NAME_KEY] action:@selector(setSearchURL:) keyEquivalent:@""];
            item.target = self;
            item.representedObject = dict;
            [_searchEngineButton.menu addItem:item];
            
            if ([dict[ID_KEY] isEqualToString:engineID]) {
                [self setSearchURL:item];
            }
            
        }
    }
    
    if (!_searchURL) {
        NSMenuItem *item = [_searchEngineButton.menu itemAtIndex:1];
        [self setSearchURL:item];
    }
    
}

@end
