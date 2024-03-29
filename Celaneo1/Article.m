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
@synthesize urlFnacCom;

+ (Article*) articleWithId:(int)articleId
{
    Article* a = [[Article alloc] init];
    a.articleId = articleId;
    return a;
}

- (void) dump
{
    NSLog(@"Article: %d\nthem %d '%@'\nrubri %d '%@'\ntype %d\ntitre '%@'\ndate %@\nurlMedia '%@'\naccroche '%@'\ncontenu '%@'\nurlImage '%@'\nfavoris %d\njaime %d\n commentaires %d\nfnaccom %@\nhash '%@'",
          articleId, thematiqueId, thematique, rubriqueId, rubrique, type, titre, dateAffichee, urlMedia, accroche, contenu, urlImage, favoris, nb_jaime, nb_commentaires, urlFnacCom, hash);
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
    [urlFnacCom release];
    
    [super dealloc];
}

- (ASIHTTPRequest*)createImageRequestForViewSize:(CGSize)size
{
    float scale = UIScreen.mainScreen.scale;
    int width = size.width * scale;
    int height = size.height * scale;
    
    ASIHTTPRequest* imageRequest;
    
    NSString* urlString = self.urlImage;
    urlString = [urlString stringByAppendingFormat:@"/%d/%d", width, height];
    
    imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    imageRequest.downloadCache = [ASIDownloadCache sharedCache];
    imageRequest.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy;
    [imageRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    
    //NSLog(@"Cache: %@", [imageRequest.downloadCache pathToCachedResponseDataForRequest:imageRequest]);

    return imageRequest;
}

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        Article* a = (Article*) object;
        return articleId == a.articleId && [hash compare:a.hash] == 0;
    } else {
        return NO;
    }
}
@end
