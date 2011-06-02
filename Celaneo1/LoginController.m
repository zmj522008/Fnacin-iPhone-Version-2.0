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
#import "Prepage.h"

@implementation LoginController

@synthesize email;
@synthesize password;
@synthesize debugButton;
@synthesize request;
@synthesize emailLabel;
@synthesize passwordLabel;
@synthesize passwordRecoveryLabel;
@synthesize entryBackground;
@synthesize authSubmitButton;
@synthesize authForgottenPasswordButton;
@synthesize forgSubmitButton;
@synthesize forgCancelButton;
@synthesize sentCancelButton;
@synthesize activity;

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
    [debugButton release];
    [emailLabel release];
    [passwordLabel release];
    [passwordRecoveryLabel release];
    [entryBackground release];
    [authSubmitButton release];
    [authForgottenPasswordButton release];
    [forgSubmitButton release];
    [forgCancelButton release];
    [sentCancelButton release];
    [activity release];
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
    self.debugButton = nil;
    self.emailLabel = nil;
    self.passwordLabel = nil;
    self.passwordRecoveryLabel = nil;
    self.entryBackground = nil;
    self.authSubmitButton = nil;
    self.authForgottenPasswordButton = nil;
    self.forgSubmitButton = nil;
    self.forgCancelButton = nil;
    self.sentCancelButton = nil;
    self.activity = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (NSString*) pageName
{
    return @"/login";
}

#pragma mark Handle server Response

- (void) serverRequest:(ServerRequest*)aRequest didSucceedWithObject:(id)result
{
    if (mode == LoginForgMode) {
        [self switchToMode:LoginSentMode];
        return;
    }
    if (aRequest.prepageContent) {
        NSString* nibName = @"Prepage";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = [nibName stringByAppendingString:@"~iPad"];
        }
        Prepage* prepage = [[Prepage alloc] initWithNibName:nibName bundle:nil];
        prepage.ferme = aRequest.prepageFerme;
        prepage.prepageContent = aRequest.prepageContent;
        
        Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
        delegate.window.rootViewController = prepage;    
    } else {
        [self goToTabBar];
    }

    [Celaneo1AppDelegate getSingleton].dirigeant = aRequest.dirigeant;
    if (aRequest.dirigeant) {
#if !TARGET_IPHONE_SIMULATOR
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert];
#endif
    }
    [activity stopAnimating];
}

- (void) serverRequest:(ServerRequest*)aRequest didFailWithError:(NSError*)error
{
    if (error == nil && (
        mode == LoginForgMode || [Celaneo1AppDelegate getSingleton].sessionId.length > 0)) {
        [self serverRequest:aRequest didSucceedWithObject:self];
        return;
    }   
    NSString* message;
    NSString* title;

    if ([error.domain compare:@"FNAC"] == 0) {
        title = @"Erreur";
        message = [error localizedDescription];
    } else {
        title = @"Communication";
        message = @"La communication a été interrompue veuillez réessayer ultérieurement.";
        //        message = [message stringByAppendingString:@" - l'application restera en mode hors ligne jusqu'au prochain lancement"];
    }
    
    if (message == nil) {
        message = @"Erreur de communication..";
    }
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message 
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    [activity stopAnimating];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self switchToMode:LoginAuthMode];
}

#pragma mark Button actions
- (void) switchToMode:(int) m
{
    mode = m;
    switch (m) {
        case LoginAuthMode:
            entryBackground.hidden = NO;
            passwordRecoveryLabel.hidden = YES;
            passwordLabel.hidden = NO;
            password.hidden = NO;
            email.returnKeyType = UIReturnKeyNext;
            [password becomeFirstResponder];
            authForgottenPasswordButton.hidden = NO;
            authSubmitButton.hidden = NO;
            forgCancelButton.hidden = YES;
            forgSubmitButton.hidden = YES;
            sentCancelButton.hidden = YES;
            break;
     
        case LoginForgMode:
            entryBackground.hidden = NO;
            passwordRecoveryLabel.hidden = YES;
            passwordLabel.hidden = YES;
            password.hidden = YES;
            email.returnKeyType = UIReturnKeySend;
            [email becomeFirstResponder];
            authForgottenPasswordButton.hidden = YES;
            authSubmitButton.hidden = YES;
            forgCancelButton.hidden = NO;
            forgSubmitButton.hidden = NO;
            sentCancelButton.hidden = YES;
            break;
            
        case LoginSentMode:
            passwordRecoveryLabel.hidden = NO;
            entryBackground.hidden = YES;
            authForgottenPasswordButton.hidden = YES;
            authSubmitButton.hidden = YES;
            forgCancelButton.hidden = YES;
            forgSubmitButton.hidden = YES;
            sentCancelButton.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (IBAction) passwordReturn
{
    if (mode == LoginAuthMode) {
        [self authSubmit];
    }
}

- (IBAction) emailReturn
{
    if (mode == LoginAuthMode) {
        [password becomeFirstResponder];
    } else {
        [self forgSubmit];
    }
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
 //   BOOL valid = [self isValid];
//    self.authSubmitButton.enabled = valid;
//    self.forgSubmitButton.enabled = valid;
}

- (IBAction) onChange
{
    [self validateButtons];
}

- (IBAction) authSubmit
{
    [self.request cancel];
    self.request = [[ServerRequest alloc] initAuthentificateWithEmail:email.text withPassword:password.text];
    request.delegate = self;
    [request start];
    
    [[NSUserDefaults standardUserDefaults] setObject:email.text forKey:@"loginEmail"];
    [activity startAnimating];
}

- (IBAction) forgSubmit
{
    [self.request cancel];
    self.request = [[ServerRequest alloc] initPasswordWithEmail:email.text];
    request.delegate = self;
    [request start];
    
    [[NSUserDefaults standardUserDefaults] setObject:email.text forKey:@"loginEmail"]; 
    [activity startAnimating];
}

- (IBAction) authForgottenPassword
{
    [self switchToMode:LoginForgMode];
}

- (IBAction) forgCancel
{
    [self switchToMode:LoginAuthMode];
}

- (IBAction) sentCancel
{
    [self switchToMode:LoginAuthMode];    
}
@end
