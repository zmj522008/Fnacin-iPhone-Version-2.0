//
//  BaseController.h
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIViewController.h>

#import "ServerRequest.h"

@interface BaseController : UIViewController <ServerRequestDelegate> {    
    ServerRequest* offlineRequest;
    ServerRequest* onlineRequest;
    NSOperationQueue* imageLoadingQueue;
}

@property (nonatomic, retain) ServerRequest *offlineRequest;
@property (nonatomic, retain) ServerRequest *onlineRequest;
@property (nonatomic, retain) NSOperationQueue *imageLoadingQueue;

- (ServerRequest*) createListRequest;
- (void) updateList:(ServerRequest*)request;
@end
