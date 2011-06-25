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

- (void) doAddPhoneDigits:(NSString*) phone To:(NSMutableString*) target {
    for (int i = 0; i < phone.length; i++) {
        char c = (char) [phone characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            [target appendFormat:@"%c", c];
        }
    }
    [target appendString:@" "];
}

- (void) genPhoneDigits
{
    NSMutableString* digits = [NSMutableString stringWithCapacity:10];
    [self doAddPhoneDigits:telephone To:digits];
}

- (void)dump
{
    NSLog(@"P: %@ %@,T:%@", nom, prenom, telephone);
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
