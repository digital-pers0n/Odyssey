//
//  ODGoTo.m
//  Odyssey
//
//  Created by Terminator on 11/28/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "ODGoTo.h"

#define ID_KEY @"Identifier"
#define NAME_KEY @"Name"
#define URL_KEY @"URLTemplate"
#define DEFAULTS_KEY @"DefaultSearchEngineID"

@interface ODGoTo ()
{
   IBOutlet NSTextField *_addressField;
    IBOutlet NSPopUpButton *_searchEngineButton;
    IBOutlet NSBox *_view;
    NSString *_searchURL;
}

-(IBAction)okPressed:(id)sender;
-(IBAction)cancelPressed:(id)sender;

@end

@implementation ODGoTo

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self _setUpSearchEngine];
    _view.fillColor = [NSColor whiteColor];
    _view.borderColor = [NSColor lightGrayColor];
    _view.cornerRadius = 4;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)close
{
    
}

-(NSString *)windowNibName
{
    return @"ODGoTo";
}

-(NSString *)editRequest:(NSString *)rule
{
    

    {
        BOOL(^checkString)(id, id) = ^(NSString *arg0, NSString *arg1) {
            NSRange range = [arg0 rangeOfString:arg1 options:NSCaseInsensitiveSearch];
            if (range.length) {
                return YES;
            }
            return NO;
        };
        
        NSWindow *window = self.window;
        self.cancel = NO;
        
        if (rule) {
            _addressField.stringValue = rule;
        } 
        
        //NSRect rect = [[NSApp mainWindow] frame];
       
        [NSApp beginSheet:window modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        [NSApp runModalForWindow:window];
        // sheet is up here...
        
        [NSApp endSheet:window];
        [self.window orderOut:self];
        
        rule = _addressField.stringValue;
        
//        if (!checkString(rule, @"http") && !checkString(rule, @"file")) {
//            rule = [NSString stringWithFormat:@"http://%@", rule];
//            if (![NSURL URLWithString:rule]) {
//                            rule = [rule stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                            rule = [_searchURL stringByReplacingOccurrencesOfString:@"{searchTerms}" withString:rule];
//            }
//        }

      
        if (checkString(rule, @".")) {
            if (!checkString(rule, @"http") && !checkString(rule, @"file")) {
                rule = [NSString stringWithFormat:@"http://%@", rule];
               
            } 
            
        } else {
            rule = [rule stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //NSString *searchReq = @"https://www.google.com/search?client=safari&rls=en&q={searchTerms}&ie=UTF-8&oe=UTF-8";
            rule = [_searchURL stringByReplacingOccurrencesOfString:@"{searchTerms}" withString:rule];
        
        }
        
        return rule;
        
    }
}

#pragma mark - Actions

-(void)okPressed:(id)sender
{
    [NSApp stopModal];
}

-(void)cancelPressed:(id)sender
{
    self.cancel = YES;
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
