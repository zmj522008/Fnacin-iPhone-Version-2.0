//
//  Personne.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Personne.h"


@implementation Personne
@synthesize sId;

@synthesize nom;
@synthesize prenom;
@synthesize telephone;
@synthesize phoneDigits;

- (int)compare:(Personne*)p
{
    int r = [nom localizedCaseInsensitiveCompare:p.nom];
    if (r == 0) {
        [prenom localizedCaseInsensitiveCompare:p.prenom];
    }
    return r;
}

- (void)dump
{
    NSLog(@"P: %@ %@,T:%@", nom, prenom, telephone);
}

- (NSString*) phoneDigits
{
    return phoneDigits;
}

- (void)dealloc
{
    [nom release];
    [prenom release];
    [telephone release];
    [phoneDigits release];
    
    [super dealloc];
}
@end
