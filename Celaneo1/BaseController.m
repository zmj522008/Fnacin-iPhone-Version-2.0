//
//  BaseController.m
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

#pragma mark UIViewController
- (void) viewWillAppear:(BOOL)animated
{
    [self doOfflineRequest];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [imageLoadingQueue cancelAllOperations];
}

- (void) refresh {
    [self.offlineRequest cancel];
    [self.onlineRequest cancel];
    [self doOfflineRequest];
}

#pragma mark server handling

- (void) doOfflineRequest
{
    ServerRequest* request = [self createListRequest];
    NSLog(@"offline Request %@", request);
    if (request) {
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
        self.onlineRequest = request;
        onlineRequest.delegate = self;
        [onlineRequest enableCacheWithForced:NO];
        [onlineRequest start];
    }
}

- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error
{
    if (request == offlineRequest) {
        [self doOnlineRequest:YES];
        return;
    }
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];

    NSString* title;
    NSString* message = [error localizedDescription];
    if ([error.domain compare:@"FNAC"] == 0) {
        title = @"Erreur";
    } else {
        title = @"Communication";
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
        delegate.window.rootViewController = delegate.loginController;
    }
}

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    [self updateList:request];
    if (request == offlineRequest) {
        [self doOnlineRequest:NO];
        return;
    } else if (request == onlineRequest) {
        Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
        delegate.offline = NO;
    }
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request;
{
}

- (ServerRequest*) createListRequest
{
    return nil;
}

#pragma mark life cycle

- (void)viewDidLoad {   
    [super viewDidLoad];
    
    imageLoadingQueue = [[NSOperationQueue alloc] init];
}

- (void) dealloc
{
    [super dealloc];
    
    [offlineRequest release];
    [onlineRequest release];
    [imageLoadingQueue release];
}
@end
