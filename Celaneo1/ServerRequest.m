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

#define SERVER @"http://webservice.fnacin.com/"

//
// ServerRequest handles server request:
// - creation with parameters
// - preparation of asi http requests
// - application level parsing

// For each request you should create a new object

@implementation ServerRequest

@synthesize asiRequest;
@synthesize delegate;
@synthesize erreur;

@synthesize limitStart;
@synthesize limitEnd;

@synthesize parser;

#pragma mark Request constructors
- (id) initWithMethod:(NSString*)method
{
    [super init];
    if (self != nil) {
        self.asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[SERVER stringByAppendingString:method]]];
        self.asiRequest.numberOfTimesToRetryOnTimeout = 3;
        
        asiRequest.delegate = self;
        NSString* sessionId = [Celaneo1AppDelegate getSingleton].sessionId;
        if (sessionId != nil) {
            [asiRequest setPostValue:sessionId forKey:@"session_id"];
        }
        self.limitEnd = -1;
        self.limitStart = -1;
        self.parser = [[[ArticleParser alloc] init] autorelease];
    }
    return self;
}

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password
{
    [self initWithMethod:@"authentification"];
    if (self != nil) {
        [asiRequest setPostValue:email forKey:@"email"];
        [asiRequest setPostValue:password forKey:@"password"];
        [asiRequest setPostValue:[NSString stringWithFormat:@"I%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forKey:@"version"];
    }
    return self;
}

- (id) initPasswordWithEmail:(NSString*)email
{
    [self initWithMethod:@"password"];
    if (self != nil) {
        [asiRequest setPostValue:email forKey:@"email"];
    }
    return self;
}

- (id) initArticle
{
    [self initWithMethod:@"article"];
    [self setParameter:@"materiel" withValue:@"iphone"];
    if (self != nil) {
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

- (id) initSendTokenId:(NSString*)tokenId
{
    [self initWithMethod:@"push"];
    NSLog(@"Sending token id: %@", tokenId);
    [self setParameter:@"token_id" withValue:tokenId];
    return self;  
}

- (id) initSetFavoris:(BOOL)favoris withArticleId:(int)articleId
{
    [self initWithMethod:@"setfavoris"];
    if (self != nil) {
        [asiRequest setPostValue:favoris ? @"1" : @"0" forKey:@"type"];
        [self setParameter:@"article_id" withIntValue:articleId];
    }
    return self;
}

- (id) initJaimeWithArticleId:(int)articleId
{
    [self initWithMethod:@"setjaime"];
    if (self != nil) {
        [self setParameter:@"article_id" withIntValue:articleId];
    }
    return self;
}


- (id) initSendCommentaire:(NSString *)text withArticleId:(int)articleId
{
    [self initWithMethod:@"setcommentaire"];
    if (self != nil) {
        [self setParameter:@"article_id" withIntValue:articleId];
        [self setParameter:@"commentaire" withValue:text];
    }
    return self;
}

- (id) initSetPreferences:(NSIndexSet*)indexSet forType:(int)type
{
    [self initWithMethod:@"setpreference"];
    static NSString* preferenceName[] = { @"thematique", @"rubrique", @"magasin" };

    static NSString* preferenceKey[] = { @"thematique_ids", @"rubrique_ids", @"magasin_ids" };
    [self setParameter:@"type" withValue:preferenceName[type]];
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
    [self setParameter:preferenceKey[type] withValue:indexString];
    return self;
}

- (id) initGetPreferencesForType:(int)type
{
    static NSString* preferenceName[] = { @"thematique", @"rubriques", @"magasins" };

    [self initWithMethod:@"getpreference"];
    [self setParameter:@"element" withValue:preferenceName[type]];

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
        NSLog(@"%@\n%@", request.url, request.responseString);
        
        NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:responseData];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
        xmlParser.delegate = self;
        [xmlParser parse];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // Never store errors!!!
    [[ASIDownloadCache sharedCache] removeCachedDataForRequest:request];
    
    if (error.domain == NetworkRequestErrorDomain && error.code == ASIRequestCancelledErrorType) {
        NSLog(@"%@ cancelled", self);
    } else {
        NSLog(@"serverRequest error :%@", error);
        [delegate serverRequest:self didFailWithError:error];
    }
}

#pragma mark Generic XML Parsing

- (void)parserDidEndDocument:(NSXMLParser *)xmlParser
{
    NSError* parsedError = [parser endDocument];
    if (erreur == nil && parsedError == nil) {
        [delegate serverRequest:self didSucceedWithObject:nil];        
    } else {
        // Never store errors!!!

        [[ASIDownloadCache sharedCache] removeCachedDataForRequest:asiRequest];

        [delegate serverRequest:self didFailWithError:erreur ? erreur : parsedError];
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

-(void)    parser: (NSXMLParser*) xmlParser
  didStartElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
       attributes: (NSDictionary*) attributeDict
{
    if (currentTextString) 
    {
        [currentTextString release];
        currentTextString = nil;
    }
    SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementStart_%@:", elementName] );
    if( [parser respondsToSelector:sel] )
    {
        [parser performSelector:sel withObject: attributeDict];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"handleElementEnd_%@", elementName]);
    if ([parser respondsToSelector:sel]) {
        [parser performSelector:sel];
    } else {
        SEL sel = NSSelectorFromString( [NSString stringWithFormat:@"handleElementEnd_%@:", elementName] );

        if( [parser respondsToSelector:sel] )
        {
            [parser performSelector:sel withObject: [currentTextString stringByTrimmingCharactersInSet:
                                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
}

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
    [parser release];
    [asiRequest release];
    [super dealloc];
}
@end
