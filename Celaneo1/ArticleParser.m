//
//  ArticleParser.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleParser.h"
#import "Celaneo1AppDelegate.h"

#import "ServerRequest.h"
#import "ASIDownloadCache.h"

#define SERVER @"http://webservice.fnacin.com/"

@implementation ArticleParser
@synthesize fnac;
@synthesize articles;
@synthesize thematiques;
@synthesize rubriques;
@synthesize magasins;
@synthesize article;
@synthesize magasin;
@synthesize category;
@synthesize commentaire;
@synthesize commentaires;
@synthesize articleCount;
@synthesize nb_jaime;
@synthesize nb_commentaire;
@synthesize dirigeant;
@synthesize prepageContent;
@synthesize prepageFerme;

@synthesize limitStart, limitEnd;

#pragma mark Request constructors

- (id) getServerRequest:(NSString*)method
{
    NSString* url = [SERVER stringByAppendingString:method];
    ServerRequest* request = [[ServerRequest alloc] initWithUrl:url];
    if (request != nil) {
        NSString* sessionId = [Celaneo1AppDelegate getSingleton].sessionId;
        if (sessionId != nil) {
            [request setParameter:@"session_id" withValue:sessionId];
        }
        SaxMethodParser* saxParser = [[[SaxMethodParser alloc] init] autorelease];
        request.xmlParserDelegate = saxParser;
        saxParser.serverRequest = request;
        saxParser.parser = self;
    }
    
    ASIDownloadCache* cache = [ASIDownloadCache sharedCache];
    [cache addIgnoredPostKey:@"session_id"]; // TODO This could be moved to sth called once per session

    return request;
}

- (ServerRequest*) getRequestAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password
{
    ServerRequest* request = [self getServerRequest:@"authentification"];
    if (self != nil) {
        [request setParameter:@"email" withValue:email];
        [request setParameter:@"password" withValue:password];
        [request setParameter:@"version" withValue:[NSString stringWithFormat:@"I%@", 
                                                    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    }
    return request;
}

- (ServerRequest*) getRequestPasswordWithEmail:(NSString*)email
{
    ServerRequest* request = [self getServerRequest:@"password"];
    if (self != nil) {
        [request setParameter:@"email" withValue:email];
    }
    return request;
}

- (ServerRequest*) getRequestArticle
{
    ServerRequest* request = [self getServerRequest:@"article"];
    [request setParameter:@"materiel" withValue:@"iphone"];
    if (self != nil) {
    }
    return request;
}

- (ServerRequest*) getRequestGetThematiques
{
    ServerRequest* request = [self getServerRequest:@"thematique"];
    return request;
}

- (ServerRequest*) getRequestGetRubriques
{
    ServerRequest* request = [self getServerRequest:@"rubrique"];
    return request;  
}

- (ServerRequest*) getRequestGetMagasins
{
    ServerRequest* request = [self getServerRequest:@"magasin"];
    return request;  
}

- (ServerRequest*) getRequestSendTokenId:(NSString*)tokenId
{
    ServerRequest* request = [self getServerRequest:@"push"];
    NSLog(@"Sending token id: %@", tokenId);
    [request setParameter:@"token_id" withValue:tokenId];
    return request;  
}

- (ServerRequest*) getRequestSetFavoris:(BOOL)favoris withArticleId:(int)articleId
{
    ServerRequest* request = [self getServerRequest:@"setfavoris"];
        [request setParameter:@"type" withValue:favoris ? @"1" : @"0"];
        [request setParameter:@"article_id" withIntValue:articleId];
    return request;
}

- (ServerRequest*) getRequestJaimeWithArticleId:(int)articleId
{
    ServerRequest* request = [self getServerRequest:@"setjaime"];
        [request setParameter:@"article_id" withIntValue:articleId];
    return request;
}


- (ServerRequest*) getRequestSendCommentaire:(NSString *)text withArticleId:(int)articleId
{
    ServerRequest* request = [self getServerRequest:@"setcommentaire"];
        [request setParameter:@"article_id" withIntValue:articleId];
        [request setParameter:@"commentaire" withValue:text];
    return request;
}

- (ServerRequest*) getRequestSetPreferences:(NSIndexSet*)indexSet forType:(int)type
{
    ServerRequest* request = [self getServerRequest:@"setpreference"];
    static NSString* preferenceName[] = { @"thematique", @"rubrique", @"magasin" };
    
    static NSString* preferenceKey[] = { @"thematique_ids", @"rubrique_ids", @"magasin_ids" };
    [request setParameter:@"type" withValue:preferenceName[type]];
    NSMutableString* indexString = [NSMutableString stringWithCapacity:1];
    int count = indexSet.count;
    NSUInteger* indexes = (NSUInteger*) malloc(sizeof(NSUInteger) * count);
    [indexSet getIndexes:indexes maxCount:count inIndexRange:nil];
    for (int i = 0; i < count; i++) {
        [indexString appendFormat:@"%d", indexes[i]];
        if (i < count - 1) {
            [indexString appendString:@","];
        }
    }
    free(indexes);
    [request setParameter:preferenceKey[type] withValue:indexString];
    return request;
}

- (ServerRequest*) getRequestGetPreferencesForType:(int)type
{
    static NSString* preferenceName[] = { @"thematique", @"rubriques", @"magasins" };
    
    ServerRequest* request = [self getServerRequest:@"getpreference"];
    [request setParameter:@"element" withValue:preferenceName[type]];
    
    return request;
}

#pragma mark Application XML Parsing

- (void) resetParsing
{
    self.articles = nil;
    self.magasins = nil;
    self.rubriques = nil;
    self.thematiques = nil;
    
    self.article = nil;
    self.magasin = nil;
    
    self.prepageContent = nil;
    
    self.fnac = NO;
    [super resetParsing];
}

- (void) dump
{
    for (NSString* arg in [NSArray arrayWithObjects:@"rubriques", @"thematiques", @"articles", @"magasins", nil]) {
        NSArray* lst = [self performSelector:NSSelectorFromString(arg)];
        NSLog(@"%@ (%d):", arg, [lst count]);
        for (id<ModelObject> c in lst) {
            [c dump];
        }
    }
}

#pragma mark Application XML Parsing - authentification

- (void) handleElementStart_fnac:(NSDictionary*)dic
{
    fnac = YES;
}

- (void) handleElementEnd_session_id:(NSString*)sessionId
{
    [Celaneo1AppDelegate getSingleton].sessionId = sessionId;
}

- (void) handleElementEnd_nb_articles_page:(NSString*)nArticles
{
    [Celaneo1AppDelegate getSingleton].articlesPerPage = [nArticles intValue];
#ifdef DEBUG
    [Celaneo1AppDelegate getSingleton].articlesPerPage = 5;
#endif
}

- (void) handleElementEnd_nb_articles:(NSString*)nArticles
{
    self.articleCount = [nArticles intValue];
}

- (void) handleElementEnd_dirigeant:(NSString*)value
{
    dirigeant = [value intValue] == 1;
}


- (void) handleElementStart_pre_page:(NSDictionary*) attributes
{
    self.prepageFerme = [[attributes objectForKey:@"ferme"] intValue] == 1;
}

- (void) handleElementEnd_pre_page:(NSString*)value
{
    self.prepageContent = value;
}

#pragma mark Application XML Parsing - articles

- (void) handleElementStart_articles:(NSDictionary*) attributes
{
    self.articles = [NSMutableArray arrayWithCapacity:20];
}

- (void) handleElementStart_article:(NSDictionary*) attributes
{
    self.article = [Article articleWithId:[[attributes objectForKey:@"id"] intValue]];
}

- (void) handleElementStart_commentaires:(NSDictionary*) attributes
{
    self.commentaires = [NSMutableArray arrayWithCapacity:1];
}

- (void) handleElementEnd_commentaires
{
    self.article.commentaires = commentaires;
    self.commentaires = nil;
}

- (void) handleElementStart_commentaire:(NSDictionary*) attributes
{
    self.commentaire = [Commentaire commentaireWithId:[[attributes objectForKey:@"id"] intValue]];
}

- (void) handleElementEnd_commentaire
{
    [self.commentaires addObject:commentaire];
    self.commentaire = nil;
}

- (void) handleElementEnd_prenom:(NSString*)value
{
    self.commentaire.prenom = value;
}

- (void) handleElementEnd_date_depot:(NSString*)value
{
    self.commentaire.date = value;
}

- (void) handleElementEnd_article
{
    if (self.article != nil) {
        [articles addObject:article];
        
        self.article = nil;
    }
}

- (void) handleElementStart_thematique:(NSDictionary*) attributes
{
    if (self.article != nil) {
        self.article.thematiqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementEnd_thematique:(NSString*)value
{
    if (self.article != nil) {
        self.article.thematique = value;
    } else {	
        self.category.name = value;
        [thematiques addObject:category];
    }
}

- (void) handleElementStart_rubrique_libelle:(NSDictionary*) attributes
{
    // WORKAROUND
    
    if (self.article != nil) {
        self.article.rubriqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementStart_rubrique:(NSDictionary*) attributes
{
    if (self.article != nil) {
        self.article.rubriqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementEnd_rubrique_libelle:(NSString*)value
{
    // WORKAROUND
    
    if (self.article != nil) {
        self.article.rubrique = value;
    } else {
        self.category.name = value;
        [rubriques addObject:category];
    }
}

- (void) handleElementEnd_rubrique:(NSString*)value
{
    if (self.article != nil) {
        self.article.rubrique = value;
    } else {
        self.category.name = value;
        [rubriques addObject:category];
    }
}

- (void) handleElementEnd_nb_jaime:(NSString*)value
{
    nb_jaime = [value intValue];
    self.article.nb_jaime = [value intValue];
}

- (void) handleElementEnd_nb_commentaires:(NSString*)value
{
    nb_commentaire = [value intValue];
    self.article.nb_commentaires = [value intValue];
}

- (void) handleElementEnd_nb_commentaire:(NSString*)value
{
    nb_commentaire = [value intValue];
    self.article.nb_commentaires = [value intValue];
}


- (void) handleElementEnd_titre:(NSString*)value
{
    self.article.titre = value;
#ifdef DEBUG
    if (article.articleId & 1) {
        self.article.urlFnacCom = [NSString stringWithFormat:@"http://www.bing.com/search?q=%d", article.articleId];
    }
#endif
}

- (void) handleElementStart_type:(NSDictionary*) attributes
{
    self.article.type = [[attributes objectForKey:@"id"] intValue];
}

- (void) handleElementEnd_date_affichee:(NSString*)value
{
    self.article.dateAffichee = value;
}

- (void) handleElementEnd_date_modification:(NSString*)value
{
    self.article.hash = value;
}

- (void) handleElementEnd_url_media:(NSString*)value
{
    self.article.urlMedia = value;
}

- (void) handleElementEnd_url_fnaccom:(NSString*)value
{
    self.article.urlFnacCom = value;
}

- (void) handleElementEnd_accroche:(NSString*)value
{
    self.article.accroche = value;
}

- (void) handleElementEnd_contenu:(NSString*)value
{
    if (self.commentaire) {
        self.commentaire.contenu = value;
    } else {
        self.article.contenu = value;
    }
}

- (void) handleElementEnd_url_image:(NSString*)value
{
    self.article.urlImage = value;
}

- (void) handleElementEnd_favoris:(NSString*)value
{
    self.article.favoris = [value intValue] == 1;
}

#pragma mark Application XML Parsing - thematiques

- (void) handleElementStart_thematiques:(NSDictionary*) attributes
{
    self.thematiques = [NSMutableArray arrayWithCapacity:20];
}

// (void) handleElementStart_thematique:(NSDictionary*) attributes (see above)


// (void) handleElementEnd_thematique:(NSString*) value (see above)

#pragma mark Application XML Parsing - rubriques

- (void) handleElementStart_rubriques:(NSDictionary*) attributes
{
    self.rubriques = [NSMutableArray arrayWithCapacity:20];
}

// (void) handleElementStart_rubrique:(NSDictionary*) attributes (see above)

// (void) handleElementEnd_rubrique:(NSString*) value (see above)

- (void) handleElementEnd_prefere:(NSString*)value
{
    self.category.prefere = [value intValue] == 1;
}

- (NSError*) endDocument
{
    if (erreurCode == 0 && erreurDescription == nil && fnac) {
#ifdef DEBUG
        [self dump];
#endif
        return nil;
    } else {
        NSError* erreur = [NSError errorWithDomain:@"FNAC" code:erreurCode userInfo:
                           [NSDictionary dictionaryWithObject:erreurDescription forKey:NSLocalizedDescriptionKey]];
        
        return erreur;
    }
}

- (void) dealloc
{
    [articles release];
    [thematiques release];
    [rubriques release];
    [magasins release];
    
    [article release];
    [magasin release];
    
    [commentaire release];
    [commentaires release];
    [prepageContent release];
    [super dealloc];
}

@end
