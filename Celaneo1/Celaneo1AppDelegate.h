//
//  Celaneo1AppDelegate.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"

@interface Celaneo1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet LoginController* loginController;
    
    NSString* sessionId;
    BOOL dirigeant;
    int articlesPerPage;
    
    BOOL offline;
    BOOL prefereEditDone;
    
    IBOutlet UINavigationController* rubriquesNavigation;
}

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, assign, getter=isDirigeant) BOOL dirigeant;
@property (nonatomic, assign) int articlesPerPage;

@property (nonatomic, assign, getter=isOffline) BOOL offline;
@property (nonatomic, assign, getter=isPrefereEditDone) BOOL prefereEditDone;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LoginController *loginController;
@property (nonatomic, retain) IBOutlet UINavigationController *rubriquesNavigation;

+ (Celaneo1AppDelegate*) getSingleton;

@end
