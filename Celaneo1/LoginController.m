//
//  LoginPageController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "Celaneo1AppDelegate.h"
#import "ASIHTTPRequest.h"

@implementation LoginController

@synthesize email;
@synthesize password;
@synthesize submitButton;
@synthesize debugButton;
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
    
    [email release];
    [password release];
    [request release];
    [submitButton release];
    [debugButton release];
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
    
    email.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginEmail"];
#ifdef DEBUG
    self.debugButton.hidden = NO;
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.email = nil;
    self.password = nil;
    self.submitButton = nil;
    self.debugButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (email.text.length == 0) {
        [email becomeFirstResponder];
    } else {
        [password becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) submit
{
    self.request = [[ServerRequest alloc] initAuthentificateWithEmail:email.text withPassword:password.text];
    request.delegate = self;
    [request start];
    
    [[NSUserDefaults standardUserDefaults] setObject:email.text forKey:@"loginEmail"];
}

- (void) goToTabBar
{
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
    delegate.window.rootViewController = delegate.tabBarController;    
}


- (NSString*) pageName
{
    return @"/login";
}

#pragma mark Handle server Response

- (void) serverRequest:(ServerRequest*)aRequest didSucceedWithObject:(id)result
{
    [self goToTabBar];

    [Celaneo1AppDelegate getSingleton].dirigeant = aRequest.dirigeant;
    if (aRequest.dirigeant) {
#if !TARGET_IPHONE_SIMULATOR
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert];
#endif
    }
}

#pragma mark Button actions
- (IBAction) recoverPassword
{
    NSString* launchUrl = @"http://www.google.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

- (IBAction) selectPassword
{
    [password becomeFirstResponder];
}

- (IBAction) debugBypassLog
{
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
    delegate.window.rootViewController = delegate.tabBarController;
}

- (BOOL) isValid
{
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx]; 

    return password.text.length > 0 && [emailTest evaluateWithObject:email.text];
}

- (void)validateButtons
{
    BOOL valid = [self isValid];
    submitButton.enabled = valid;
}

- (IBAction) onChange
{
    [self validateButtons];
}

@end
