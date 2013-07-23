//
//  BaseController.m
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"
#import "BaseController.h"

#import "Celaneo1AppDelegate.h"
#import "AnnuaireDB.h"

// Base Controller for all controllers

// Responsibilities:

// Handle offline(cache) / online requests and requesting on viewWillAppear
// ImageLoadingQueue to serialize image loading
// Google Analytics
// Appearance: nav buttons, nav bar
// utility method to cell list cell

@interface BaseController()

- (void) doOfflineRequest;
- (void) doOnlineRequest:(BOOL)forced;
@end

@implementation BaseController
@synthesize offlineRequest;
@synthesize onlineRequest;
@synthesize imageLoadingQueue;
@synthesize resetCache;

#pragma mark UIViewController

- (void) updateLeftBarNavigationButton
{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self navButton:NAVBUTTON_ARROW_LEFT withTitle:@"Retour" action:@selector(back)]];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString* pageName = [@"/" stringByAppendingString:[self pageName]];
    //NSLog(@"GA: %@", pageName);
    [[GANTracker sharedTracker] trackPageview:pageName withError:nil];
    [self refresh];
    [self updateLeftBarNavigationButton];
    errorShown = NO;
    active = YES;

    UINavigationBar *navBar = [[self navigationController] navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"nav.png"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
   }

-(void)viewWillLayoutSubviews{
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"nav.png"];
    UIImage *backgroundImageLandscape = [UIImage imageNamed:@"navbar_landscape.png"];
   
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsLandscape(currentOrientation)||UIDeviceOrientationIsLandscape(currentInterfaceOrientation)) {
        [navBar setBackgroundImage:backgroundImageLandscape forBarMetrics:UIBarMetricsLandscapePhone];
     
    }else if (UIDeviceOrientationIsPortrait(currentOrientation)||UIDeviceOrientationIsPortrait(currentInterfaceOrientation)){
     [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }

}

- (void) viewWillDisappear:(BOOL)animated
{
    active = NO;
    [super viewWillDisappear:animated];
    [imageLoadingQueue cancelAllOperations];
}

- (void) refresh {
   // [self.offlineRequest cancel];
   // [self.onlineRequest cancel];
    //self.offlineRequest = nil;
    //self.onlineRequest = nil;
    if (!self.resetCache) {
        [self doOfflineRequest];
    } else {
       [self doOnlineRequest:NO];

    }
}

#pragma mark server handling

- (void) doOfflineRequest
{
    NSLog(@"doOffLineRequest:::::::::");

    ServerRequest* request = [self createListRequest];
    if (request) {
        NSLog(@"request:::::::::%@",request);
        [self.offlineRequest cancel];

        self.offlineRequest = request;
        offlineRequest.delegate = self;
        NSLog(@"offline request %@",request);
        [offlineRequest enableCacheWithForced:NO];
        [offlineRequest start];
        
    }
}

- (void) doOnlineRequest:(BOOL)forced
{
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];

    NSLog(@"online Request %d %d", delegate.offline, forced);

    ServerRequest* request = [self createListRequest];
    if (request && (!delegate.offline || forced)) {
        [self.onlineRequest cancel];

        self.onlineRequest = request;
        onlineRequest.delegate = self;
        [onlineRequest enableCacheWithForced:NO];
        [onlineRequest start];
    }
}

- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error
{
//    if (request == onlineRequest) // DEBUG!
//    {
//        [self updateList:request onlineContent:YES];
//        return;
//    }
    if (request == offlineRequest) {
        [self doOnlineRequest:YES];
        return;
    }
    
    if (errorShown || !active) {
        return;
    }
    errorShown = YES;
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];

    NSString* title;
    NSString* message = [error localizedDescription];
    if ([error.domain compare:@"FNAC"] == 0) {
        title = @"Erreur";
        errorShown = NO;
    } else {
        title = @"Communication";
        message = @"La communication a été interrompue veuillez réessayer ultérieurement.";
//        message = [message stringByAppendingString:@" - l'application restera en mode hors ligne jusqu'au prochain lancement"];
        delegate.offline = YES;
    }
    if (message == nil) {
        message = @"Erreur de communication..";
    }
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    
    // And we check for the need to reauthenticate
    if (delegate.sessionId.length <= 0) {
#ifdef DEBUG
        NSLog(@"Debug, no reauth!");
#else
        delegate.window.rootViewController = delegate.loginController;
#endif
    }
}

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    ArticleParser* parser = (ArticleParser*) result;
    resetCache = NO;
    [self updateList:request parser:parser onlineContent:request == onlineRequest];
    if (request == offlineRequest) {
        [self doOnlineRequest:NO];
        return;
    } else if (request == onlineRequest) {
        Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
        delegate.offline = NO;
        
        [[GANTracker sharedTracker] dispatch];
    }
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;
{
        // code here to update view content with request result
        // method called twice: once for offline, another time for online
}

- (ServerRequest*) createListRequest
{
    NSLog(@"createListRequest----in BaseController");
        // code here to create a request to update the view content. or nil for no request
    return nil;
}

- (NSString*) pageName
{
        // page name in Google Analytics
    return @"INTRAFNAC";
}

#pragma mark create nice looking navigation buttons

- (UIButton*) navButton:(int) type withTitle:(NSString*) title action:(SEL)action
{
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:14.0];
    int width = [title sizeWithFont:font].width + 20;
    UIButton* navButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)] autorelease];

    
    UIImage* btnImage;
    switch (type) {
        case NAVBUTTON_ARROW_LEFT:
            btnImage = [UIImage imageNamed:@"btn_left.png"];
            btnImage = [btnImage stretchableImageWithLeftCapWidth:13 topCapHeight:5];
            [navButton setTitle:[NSString stringWithFormat:@"  %@", title] forState:UIControlStateNormal];
            break;
        case NAVBUTTON_PLAIN:
        default:
            btnImage = [UIImage imageNamed:@"btn.png"];
            btnImage = [btnImage stretchableImageWithLeftCapWidth:10 topCapHeight:5];
            [navButton setTitle:title forState:UIControlStateNormal];
            break;
    }
    [navButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [navButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    navButton.titleLabel.font = font;
    return navButton;
}

#pragma mark life cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {   
    [super viewDidLoad];
    //resetCache=YES;

    imageLoadingQueue = [[NSOperationQueue alloc] init];
    self.navigationItem.titleView = [[UIView alloc] init];
    self.navigationItem.hidesBackButton = NO;
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{
    [super dealloc];
    
    [offlineRequest release];
    [onlineRequest release];
    [imageLoadingQueue release];
}

#pragma mark utility method for table views

- (UITableViewCell *)loadCellFromNib:(NSString *)nibName
{
    NSString* platformizedName = nibName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        platformizedName = [nibName stringByAppendingString:@"~iPad"];
    }
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:platformizedName 
                                                 owner:self options:nil];
    
    for(id obj in nib)
    {
        if( [obj isKindOfClass:[UITableViewCell class]] ) {
            return (UITableViewCell*)obj;
        }
    }
    return nil;
}


- (void) goToTabBar
{
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];

    if (!delegate.annuaireDb.synchronized) {
        delegate.annuaireDb.synchronized = YES;
        [[[AnnuaireSync alloc] init] startSync];
    }
    
    delegate.window.rootViewController = delegate.tabBarController;
    
}
@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
    const int portaitWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 768 : 320;
    UIImage *img	= [UIImage imageNamed:@"nav_nologo.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    if (portaitWidth == self.frame.size.width) {
        UIImage *logo	= [UIImage imageNamed:@"nav.png"];
        [logo drawInRect:CGRectMake((self.frame.size.width - 320) / 2, 0,320, self.frame.size.height)];
    }

    self.tintColor = [UIColor colorWithRed:200/256.0 green:200/256.0 blue:200/256.0 alpha:0];
 
    for (UIView* view in self.subviews) {
//        view.hidden = YES;
    }
//    self.topItem.leftBarButtonItem;
    
}
@end
