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

@implementation Celaneo1AppDelegate

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize loginController;

@synthesize sessionId;
@synthesize dirigeant;
@synthesize articlesPerPage;

@synthesize offline;
@synthesize prefereEditDone;

@synthesize rubriquesNavigation;

@synthesize annuaireDb;
@synthesize annuaireModel;

//#define DEBUG_ANNUAIRE
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
    self.window.rootViewController = self.loginController;

#ifdef DEBUG_ANNUAIRE
    Annuaire* annuaire = [[Annuaire alloc] initWithNibName:@"Annuaire" bundle:nil];
    self.window.rootViewController = annuaire;
#endif

    [self.window makeKeyAndVisible];

    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-22831970-1"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:15];

    // Setup Annuaire
    self.annuaireModel = [[AnnuaireModel alloc] init];
    self.annuaireDb = [[AnnuaireDB alloc] initWithDBName:@"db"];
    
    NSThread* modelUpdateThread = [[NSThread alloc] initWithTarget:self selector:@selector(doAnnuaireUpdate) object:nil];
    [modelUpdateThread start];

    return YES;
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
    NSLog(@"Did register for remote notifications: %@", deviceToken);
    ServerRequest* request = [[ArticleParser alloc] getRequestSendTokenId:[deviceToken description]];
    [request start];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
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
