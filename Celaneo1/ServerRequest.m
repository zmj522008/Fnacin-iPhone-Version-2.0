//
//  ServerRequest.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerRequest.h"
#import "Celaneo1AppDelegate.h"

#import "ASIDownloadCache.h"

#define SERVER @"http://91.121.68.190:88/"

@implementation ServerRequest

@synthesize asiRequest;
@synthesize delegate;
@synthesize articles;
@synthesize thematiques;
@synthesize rubriques;
@synthesize magasins;
@synthesize article;
@synthesize magasin;
@synthesize category;
@synthesize erreur;
@synthesize erreurDescription;
@synthesize commentaire;
@synthesize commentaires;
@synthesize limitStart;
@synthesize limitEnd;

#pragma mark Request constructors
- (id) initWithMethod:(NSString*)method
{
    [super init];
    if (self != nil) {
        self.asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[SERVER stringByAppendingString:method]]];
        asiRequest.delegate = self;
        NSString* sessionId = [Celaneo1AppDelegate getSingleton].sessionId;
        if (sessionId != nil) {
            [asiRequest setPostValue:sessionId forKey:@"session_id"];
        }
        self.limitEnd = -1;
        self.limitStart = -1;
    }
    return self;
}

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password
{
    [self initWithMethod:@"authentification"];
    if (self != nil) {
        [asiRequest setPostValue:email forKey:@"Email"];
        [asiRequest setPostValue:password forKey:@"Password"];
        [asiRequest setPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"Version"];
    }
    return self;
}

- (id) initArticle
{
    [self initWithMethod:@"article"];
    if (self != nil) {
        // TODO pagination
    }
    return self;
}

- (id) initGetThematiques
{
    [self initWithMethod:@"thematique"];
    return self;
}

- (id) initGetRubriques
{
    [self initWithMethod:@"rubrique"];
    return self;  
}

- (id) initGetMagasins
{
    [self initWithMethod:@"magasin"];
    return self;  
}

- (id) initSendTokenId
{
    [self initWithMethod:@"push"];
    return self;  
}

- (id) initSetFavoris:(BOOL)favoris withArticleId:(int)articleId {
    [self initWithMethod:@"setfavoris"];
    if (self != nil) {
        [asiRequest setPostValue:favoris ? @"1" : @"0" forKey:@"type"];
        [self setParameter:@"article_id" withIntValue:articleId];
    }
    return self;
}

- (void) setParameter:(NSString*) name withIntValue:(int)value
{
    [asiRequest setPostValue:[NSString stringWithFormat:@"%d", value] forKey:name];   
}

- (void) setParameter:(NSString*) name withValue:(NSString*)value
{
    [asiRequest setPostValue:value forKey:name];   
}

#pragma mark configuration

- (void) enableCacheWithForced:(BOOL)forced
{
    ASIDownloadCache* cache = [ASIDownloadCache sharedCache];
    [cache addIgnoredPostKey:@"session_id"]; // TODO This could be moved to sth called once per session
    
    [asiRequest setDownloadCache:cache];
    [asiRequest setCachePolicy:forced ? ASIDontLoadCachePolicy : ASIDoNotReadFromCacheCachePolicy];
    [asiRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
}

- (void) resetCache
{
    [[ASIDownloadCache sharedCache] removeCachedDataForRequest:asiRequest];
}

#pragma mark ASIFormDataRequest delegate handling
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching binary data
    NSData *responseData = [request responseData];

    if (responseData == nil) {
        [self requestFailed:request];
    } else {
//        NSLog(@"%@\n%@", request.url, request.responseString);
        
        NSXMLParser* parser = [[NSXMLParser alloc] initWithData:responseData];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        parser.delegate = self;
        [parser parse];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
 
    if (error.domain == NetworkRequestErrorDomain && error.code == ASIRequestCancelledErrorType) {
        NSLog(@"%@ cancelled", self);
    } else {
        NSLog(@"serverRequest error :%@", error);
        [delegate serverRequest:self didFailWithError:error];
    }
}

#pragma mark Generic XML Parsing

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
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (erreur == nil && fnac && [[Celaneo1AppDelegate getSingleton].sessionId length] > 0) {
        [self dump];
        [delegate serverRequest:self didSucceedWithObject:nil];
    } else {
        [delegate serverRequest:self didFailWithError:erreur];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate serverRequest:self didFailWithError:parseError];
}

-(void)     parser: (NSXMLParser*) parser 
   foundCharacters: (NSString*) string 
{    
    if( string && [string length] > 0 )
    {
        if( !currentTextString )
        {
            currentTextString = [[NSMutableString alloc] initWithCapacity:4];
        }
        [currentTextString appendString:string];
    }
}

-(void)    parser: (NSXMLParser*) parser
  didStartElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
       attributes: (NSDictionary*) attributeDict
{
    if( currentTextString )
    {
        [currentTextString release];
        currentTextString = nil;
    }
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementStart_%@:", elementName] );
    if( [self respondsToSelector:sel] )
    {
        [self performSelector:sel withObject: attributeDict];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@", elementName] );
    if( [self respondsToSelector:sel] )
    {
        [self performSelector:sel];
    } else {
        SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@:", elementName] );

        if( [self respondsToSelector:sel] )
        {
            [self performSelector:sel withObject: [currentTextString stringByTrimmingCharactersInSet:
                                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
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
    self.erreur = nil;
    self.erreurDescription = nil;
    
    fnac = NO;
    authentificated = NO;
}

#pragma mark Application XML Parsing - authentification

- (void) handleElementStart_fnac:(NSDictionary*)dic
{
    fnac = YES;
}

- (void) handleElementEnd_session_id:(NSString*)sessionId
{
    [Celaneo1AppDelegate getSingleton].sessionId = sessionId;
    authentificated = sessionId != nil;
}

- (void) handleElementEnd_nb_articles_page:(NSString*)nArticles
{
    [Celaneo1AppDelegate getSingleton].articlesPerPage = [nArticles intValue];
}

- (void) handleElementEnd_dirigeant:(NSString*)dirigeant
{
    [Celaneo1AppDelegate getSingleton].dirigeant = [dirigeant intValue] == 1;
}

#pragma mark Application XML Parsing - error

- (void) handleElementEnd_code:(NSString*)value
{
    erreurCode = [value intValue];
}

- (void) handleElementEnd_message:(NSString*)value
{
    erreurDescription = value;
}

- (void) handleElementEnd_reauthentification:(NSString*)value
{
    if ([value intValue] == 1) {
        [Celaneo1AppDelegate getSingleton].sessionId = nil;
    }
}

- (void) handleElementEnd_erreur
{
    erreur = [NSError errorWithDomain:@"FNAC" code:erreurCode userInfo:
              [NSDictionary dictionaryWithObject:erreurDescription forKey:NSLocalizedDescriptionKey]];
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

        if (NO) {
        [articles addObject:article]; // DEBUG
        [articles addObject:article];
        [articles addObject:article];
        [articles addObject:article];
        [articles addObject:article];
        [articles addObject:article];
        }
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
    self.article.nb_jaime = [value intValue];
}

- (void) handleElementEnd_nb_commentaires:(NSString*)value
{
    self.article.nb_commentaires = [value intValue];
}

- (void) handleElementEnd_titre:(NSString*)value
{
    self.article.titre = value;
}

- (void) handleElementStart_type:(NSDictionary*) attributes
{
    self.article.type = [[attributes objectForKey:@"id"] intValue];
}

- (void) handleElementEnd_date_affichee:(NSString*)value
{
    self.article.dateAffichee = value;
}

- (void) handleElementEnd_url_media:(NSString*)value
{
    self.article.urlMedia = value;
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


#pragma mark lifecycle
- (void) start
{
    if (limitStart >= 0) {
        [self setParameter:@"limit_start" withIntValue:limitStart];
    }
    if (limitEnd >= 0) {
        [self setParameter:@"limit_end" withIntValue:limitEnd];
    }

    [asiRequest startAsynchronous];
}

- (void) cancel
{
    [asiRequest clearDelegatesAndCancel];
}

- (void) dealloc
{
    [self cancel];
    [asiRequest release];
    
    [articles release];
    [thematiques release];
    [rubriques release];
    [magasins release];
    
    [article release];
    [magasin release];
    
    [commentaire release];
    [commentaires release];
    [super dealloc];
}
@end
