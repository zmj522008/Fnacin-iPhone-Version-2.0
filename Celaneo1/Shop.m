//
//  Shop.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Shop.h"


@implementation Shop

- (id) init
{
    [super init];
    self.validAttributes = [NSArray arrayWithObjects:@"name", @"description", nil];
    return self;
}
@end
