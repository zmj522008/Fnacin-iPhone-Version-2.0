//
//  Prepage.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Prepage.h"


@implementation Prepage
@synthesize content;
@synthesize continuer;
@synthesize prepageContent;
@synthesize ferme;
@synthesize item;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [content release];
    [continuer release];
    [prepageContent release];
    [item release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    bool debug = NO;
#ifdef DEBUG
    debug = YES;
#endif
    if (ferme && !debug) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        NSLog(@"navItem: %@", self.navigationItem);
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:debug ? @"DBG Cont" : @"Continuer" action:@selector(continuerClick)]];
    }
    [self.content loadHTMLString:prepageContent baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.content = nil;
    self.continuer = nil;    
    self.item = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString*) pageName
{
    return @"/prepage";
}

- (IBAction) continuerClick
{
    [self goToTabBar];
}

@end
