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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GANTracker sharedTracker] trackPageview:[self pageName] withError:nil];
    [self refresh];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self navButton:NAVBUTTON_ARROW_LEFT withTitle:@"Retour" action:@selector(back)]];
    }
    errorShown = NO;
    active = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    active = NO;
    [super viewWillDisappear:animated];
    [imageLoadingQueue cancelAllOperations];
}

- (void) refresh {
    [self.offlineRequest cancel];
    [self.onlineRequest cancel];
    self.offlineRequest = nil;
    self.onlineRequest = nil;
    if (!self.resetCache) {
        [self doOfflineRequest];
    } else {
        [self doOnlineRequest:YES];
    }
}

#pragma mark server handling

- (void) doOfflineRequest
{
    ServerRequest* request = [self createListRequest];
    NSLog(@"offline Request %@", request);
    if (request) {
        [self.offlineRequest cancel];

        self.offlineRequest = request;
        offlineRequest.delegate = self;
        [offlineRequest enableCacheWithForced:YES];
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
        message = @"La communication avec le serveur a échoué veuillez réessayer ultérieurement.";
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
    resetCache = NO;

    [self updateList:request onlineContent:request == onlineRequest];
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

- (void) updateList:(ServerRequest*)request onlineContent:(BOOL)onlineContent;
{
    
}

- (ServerRequest*) createListRequest
{
    return nil;
}

- (UIButton*) navButton:(int) type withTitle:(NSString*) title action:(SEL)action
{
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:14.0];
    int width = [title sizeWithFont:font].width + 20;
    UIButton* navButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 30)] autorelease];

    
    UIImage* btnImage;
    switch (type) {
        case NAVBUTTON_ARROW_LEFT:
            btnImage = [UIImage imageNamed:@"btn_left.png"];
            btnImage = [btnImage stretchableImageWithLeftCapWidth:13 topCapHeight:2];
            [navButton setTitle:[NSString stringWithFormat:@"  %@", title] forState:UIControlStateNormal];
            break;
        case NAVBUTTON_PLAIN:
        default:
            btnImage = [UIImage imageNamed:@"btn.png"];
            btnImage = [btnImage stretchableImageWithLeftCapWidth:3 topCapHeight:2];
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

- (NSString*) pageName
{
    return @"/autre";
}

#pragma mark utility method for table views

- (UITableViewCell *)loadCellFromNib:(NSString *)nibName
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName 
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
    delegate.window.rootViewController = delegate.tabBarController;    
}
@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
    UIImage *img	= [UIImage imageNamed: 
                       self.frame.size.width != 320 ? @"nav_nologo.png" : @"nav.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.tintColor = [UIColor colorWithRed:200/256.0 green:200/256.0 blue:200/256.0 alpha:0];
 
    for (UIView* view in self.subviews) {
//        view.hidden = YES;
    }
//    self.topItem.leftBarButtonItem;
    
}
@end
