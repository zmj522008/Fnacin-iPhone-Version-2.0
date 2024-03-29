//
//  BaseController.h
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIViewController.h>

#import "ServerRequest.h"
#import "ArticleParser.h"

#import "AnnuaireSync.h"

#define NAVBUTTON_ARROW_LEFT 0
#define NAVBUTTON_PLAIN 1

@interface BaseController : UIViewController <ServerRequestDelegate> {
    ServerRequest* offlineRequest;
    ServerRequest* onlineRequest;
    NSOperationQueue* imageLoadingQueue;

    BOOL resetCache;
    BOOL errorShown;
    BOOL active;
}

@property (nonatomic, retain) ServerRequest *offlineRequest;
@property (nonatomic, retain) ServerRequest *onlineRequest;
@property (nonatomic, readonly) NSOperationQueue *imageLoadingQueue;

@property (nonatomic, assign, getter=isResetCache) BOOL resetCache;

- (void) refresh;

- (ServerRequest*) createListRequest;
- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;

- (UITableViewCell *)loadCellFromNib:(NSString *)nibName;

- (NSString*) pageName;

- (UIButton*) navButton:(int) type withTitle:(NSString*) title action:(SEL)action;

- (void) goToTabBar;
- (void) updateLeftBarNavigationButton;
@end
