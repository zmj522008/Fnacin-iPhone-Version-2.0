//
//  Celaneo1AppDelegate.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"

@class AnnuaireDB;
@class AnnuaireModel;

@interface Celaneo1AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationBarDelegate, UINavigationControllerDelegate> {
    IBOutlet LoginController* loginController;
    
    NSString* sessionId;
    BOOL dirigeant;
    int articlesPerPage;
    
    BOOL offline;
    BOOL prefereEditDone;
    
    IBOutlet UINavigationController* rubriquesNavigation;
    
    AnnuaireDB* annuaireDb;
    AnnuaireModel* annuaireModel;
}

@property (nonatomic, retain) AnnuaireModel* annuaireModel;

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, assign, getter=isDirigeant) BOOL dirigeant;
@property (nonatomic, assign) int articlesPerPage;

@property (nonatomic, assign, getter=isOffline) BOOL offline;
@property (nonatomic, assign, getter=isPrefereEditDone) BOOL prefereEditDone;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LoginController *loginController;
@property (nonatomic, retain) IBOutlet UINavigationController *rubriquesNavigation;

@property (nonatomic, retain) AnnuaireDB* annuaireDb;

+ (Celaneo1AppDelegate*) getSingleton;

@end
