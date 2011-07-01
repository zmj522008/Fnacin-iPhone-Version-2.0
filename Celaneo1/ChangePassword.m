//
//  ChangePassword.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangePassword.h"


@implementation ChangePassword
@synthesize password1;
@synthesize password2;
@synthesize warning;
@synthesize submit;
@synthesize activity;
@synthesize request;

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
    [super dealloc];
    [password1 release];
    [password2 release];
    [warning release];
    [submit release];
    [activity release];
    [request release];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.password1 = nil;
    self.password2 = nil;
    self.warning = nil;
    self.submit = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    password1.text = @"";
    password2.text = @"";
    [self textChange:password1];
}

#pragma mark server request

- (void)doSubmit
{
    [self.request cancel];
    self.request = [[ArticleParser alloc] getSetPassword:password1.text];
    request.delegate = self;
    [request start];
    
    [activity startAnimating];
}

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Mot de passe" 
                                                        message:@"Votre mot de passe a bien été changé."
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    [activity stopAnimating];
}

#pragma mark handle ui interaction

- (void) textChange:(id)sender
{
    NSString* t1 = password1.text;
    NSString* t2 = password2.text;
    
    BOOL valid = t1.length >= 4 && [t1 compare:t2] == 0;
    NSString* w = nil;
    if (t1.length > 0) {
        if (t1.length < 4) {
            w = @"Le mot de passe doit faire plus de 4 caractères";
        } else if (t2.length > 0 && [t1 compare:t2] != 0) {
            w = @"Vous n'avez pas saisi le même mot de passe";
        }
    }
    warning.hidden = w == nil;
    warning.text= w;
    if (valid) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Changer" action:@selector(doSubmit)]];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) password1Return
{
    [password2 becomeFirstResponder];
}
@end
