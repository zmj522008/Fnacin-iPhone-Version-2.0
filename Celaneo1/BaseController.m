//
//  BaseController.m
//  
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseController.h"


@implementation BaseController

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    [self goToTabBar];
}
@end
