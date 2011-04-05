//
//  BaseController.m
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseController.h"

#import "Celaneo1AppDelegate.h"

@implementation BaseController

- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error
{
    NSString* title;
    if ([error.domain compare:@"FNAC"] == 0) {
        title = @"Erreur";
    } else {
        title = @"Communication";
    }
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorView show];
    [errorView release];
    
    // And we check for the need to reauthenticate
    Celaneo1AppDelegate* delegate = [Celaneo1AppDelegate getSingleton];
    if (delegate.sessionId.length <= 0) {
        delegate.window.rootViewController = delegate.loginController;
    }
}
@end
