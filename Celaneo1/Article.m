//
//  Article.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import "Commentaire.h"
#import "ASIDownloadCache.h"

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
@synthesize commentaires;
@synthesize nb_jaime;
@synthesize nb_commentaires;
@synthesize hash;

+ (Article*) articleWithId:(int)articleId
{
    Article* a = [[Article alloc] init];
    a.articleId = articleId;
    return a;
}

- (void) dump
{
    NSLog(@"Article: %d\nthem %d '%@'\nrubri %d '%@'\ntype %d\ntitre '%@'\ndate %@\nurlMedia '%@'\naccroche '%@'\nurlImage '%@'\nfavoris %d\njaime %d\n commentaires %d\nhash '%@'",
          articleId, thematiqueId, thematique, rubriqueId, rubrique, type, dateAffichee, urlMedia, accroche, contenu, urlImage, favoris, nb_jaime, nb_commentaires, hash);
    for(Commentaire* c in commentaires) {
        [c dump];
    }
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
    [commentaires release];
    [hash release];
    
    [super dealloc];
}

- (ASIHTTPRequest *)startImageRequestWithWidth:(int)width withHeight:(int)height toDelegate:(id<ASIHTTPRequestDelegate>)delegate
{
    ASIHTTPRequest* imageRequest;
    
    NSString* urlString = [self.urlImage stringByAppendingFormat:@"&max_width=%d&max_height=%d", 
                           width, height];
    urlString = @"http://i.imgur.com/VUCyt.jpg"; // DEBUG
    imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    imageRequest.downloadCache = [ASIDownloadCache sharedCache];
    imageRequest.delegate = self;
    [imageRequest start];
    
    return imageRequest;
}

@end
