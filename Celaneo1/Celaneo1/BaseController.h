//
//  BaseController.h
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIViewController.h>
#import "ServerRequest.h"

@interface BaseController : UIViewController {

}

- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error;

@end
