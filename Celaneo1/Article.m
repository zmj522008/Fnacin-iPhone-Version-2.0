//
//  Article.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Article.h"


@implementation Article
@synthesize articleId;
@synthesize thematiqueId;
@synthesize rubriqueId;
@synthesize thematique;
@synthesize rubrique;
@synthesize type;
@synthesize titre;
@synthesize dateAffichee;
@synthesize urlMedia;
@synthesize accroche;
@synthesize contenu;
@synthesize urlImage;
@synthesize favoris;

+ (Article*) articleWithId:(int)articleId
{
    Article* a = [[Article alloc] init];
    a.articleId = articleId;
    return a;
}

- (void) dealloc
{
    [thematique release];
    [rubrique release];
    [titre release];
    [dateAffichee release];
    [urlMedia release];
    [accroche release];
    [contenu release];
    [urlImage release];
    
    [super dealloc];
}
@end
