//
//  Commentaire.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Commentaire.h"


@implementation Commentaire
@synthesize commentaireId;
@synthesize prenom;
@synthesize date;
@synthesize contenu;

+ (Commentaire*) commentaireWithId:(int)commentaireId
{
    Commentaire* c = [[Commentaire alloc] init];
    c.commentaireId = commentaireId;
    return c;
}

- (void) dealloc
{
    [super dealloc];
    
    [prenom release];
    [date release];
    [contenu release];
}
@end
