//
//  Shop.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Magasin.h"

@implementation Magasin

- (id) init
{
    [super init];
    self.validAttributes = [NSArray arrayWithObjects:@"nom", @"adresse", @"code_postal", @"pays", @"region", @"ville", @"latitude", @"longitude", @"fax", @"telephone", @"email", @"billeterie", @"ouverture", @"ouverture_exceptionnelle", @"url_fnaccom", nil];
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake([[self latitude] floatValue], [[self longitude] floatValue]);
}

- (NSString *)title
{
    return [self nom];
}

- (NSString *)subtitle
{
    return [self ouverture];
}

@end
