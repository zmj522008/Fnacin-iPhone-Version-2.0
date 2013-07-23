//
//  Celaneo1AppDelegate.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Celaneo1AppDelegate.h"
#import "GANTracker.h"
#import "Annuaire.h"
#import "AnnuaireModel.h"
#import "PrefereEditController.h"
#import "ArticleList.h"
#import "SiteGroupController.h"


@implementation Celaneo1AppDelegate


// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static NSData* tokenId;
@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize loginController;

@synthesize sessionId;
@synthesize dirigeant;
@synthesize articlesPerPage;

@synthesize offline;
@synthesize prefereEditDone;

@synthesize rubriquesNavigation;
@synthesize navController;

@synthesize annuaireDb;
@synthesize annuaireModel;

@synthesize tokenId;

//#define DEBUG_ANNUAIRE
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
    self.window.rootViewController = self.loginController;
    self.tabBarController.moreNavigationController.delegate = self;    
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];

    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-22324743-4"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:15];

    // Setup Annuaire
    self.annuaireModel = [[AnnuaireModel alloc] init];
    self.annuaireDb = [[AnnuaireDB alloc] initWithDBName:@"db"];
    
    NSThread* modelUpdateThread = [[NSThread alloc] initWithTarget:self selector:@selector(doAnnuaireUpdate) object:nil];
    [modelUpdateThread start];
    
    
#ifdef DEBUG_ANNUAIRE
    Annuaire* annuaire = [[Annuaire alloc] initWithNibName:@"Annuaire" bundle:nil];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:annuaire];
#endif

    return YES;
}

+(void) setTokenId:(NSData*)toId{
 
     @synchronized(self){
    tokenId=toId;
     }
}
+(NSData*) tokenId{
    
    @synchronized(self){
    return tokenId;
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    UINavigationBar *morenavbar = navigationController.navigationBar;
    UINavigationItem *morenavitem = morenavbar.topItem;
    //We don't need Edit button in More screen.
    morenavitem.rightBarButtonItem = nil;
    morenavitem.title = nil;
    UIImage *backgroundImage = [UIImage imageNamed:@"nav.png"];
    NSLog(@"MoreNavItem-----:%@",morenavitem);
    [morenavbar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIDeviceOrientationIsLandscape(currentInterfaceOrientation)){
        UIImage *backgroundImageLandscape = [UIImage imageNamed:@"navbar_landscape.png"];
        [morenavbar setBackgroundImage:backgroundImageLandscape forBarMetrics:UIBarMetricsDefault];
    }
    
}

-(void) application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration{
    
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UINavigationBar *autreNavBar=self.tabBarController.moreNavigationController.navigationBar;
    NSLog(@"AutreNavItem:%@",autreNavBar);
 
    if (autreNavBar==NULL) {
        NSLog(@"Bar non trouve");
    }
    if (UIDeviceOrientationIsPortrait(newStatusBarOrientation)||UIDeviceOrientationIsPortrait(currentDeviceOrientation)) {
        UIImage *backgrdImage = [UIImage imageNamed:@"nav.png"];
        [autreNavBar setBackgroundImage:backgrdImage forBarMetrics:UIBarMetricsDefault];

    }else if (UIDeviceOrientationIsLandscape(newStatusBarOrientation)||UIDeviceOrientationIsLandscape(currentDeviceOrientation)){
        UIImage *backgrdImageLand = [UIImage imageNamed:@"navbar_landscape.png"];
        [autreNavBar setBackgroundImage:backgrdImageLand forBarMetrics:UIBarMetricsLandscapePhone];
    }

}
- (void) doAnnuaireUpdate
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    
    [annuaireModel fetchData];
    [pool release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
     /*
      ArticleList* articleListController = [[ArticleList alloc] initWithNibName:nil bundle:nil];;
 

    [articleListController refresh];

 
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*

     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Remote notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    self.tokenId =deviceToken;
    NSLog(@"Tokenid récupéré du serveur Apple:%@",deviceToken);
    
    if (self.tokenId==NULL) {
        NSLog(@"The TokenID is null, please check again");
    };
  

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications for the TokenID: %@", error);
    UIAlertView *notifAlert= [[UIAlertView alloc] initWithTitle:@"Attention"
                                                        message:@"Notification désactivée"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [notifAlert show];

}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"UserInfo:%@",userInfo);
    [[[ArticleList alloc] init] refresh];
}

- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];

    [_window release];
    [_tabBarController release];

    [sessionId release];
    [rubriquesNavigation release];
    
    [annuaireDb release];
    [annuaireModel release];
      [navController release];
    [super dealloc];
}

+ (Celaneo1AppDelegate*) getSingleton
{
    return (Celaneo1AppDelegate*) [UIApplication sharedApplication].delegate;
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/
@end
