//
//  Cateogry.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Category.h"


@implementation Category
@synthesize categoryId;
@synthesize name;
@synthesize prefere;

- (void) dealloc
{
    [name release];
    
    [super dealloc];
}

- (void) dump
{
    NSLog(@"category %d \'%@\'", categoryId, name);
}

- (int) compare:(Category*)other
{
    return [name compare:other.name options:NSCaseInsensitiveSearch];
}

@end
