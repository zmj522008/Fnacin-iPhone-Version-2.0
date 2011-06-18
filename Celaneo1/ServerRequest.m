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

@synthesize parser;

#pragma mark constructor
- (id) initWithUrl:(NSString*)url
{
    [super init];
    self.asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    self.asiRequest.numberOfTimesToRetryOnTimeout = 3;
    asiRequest.delegate = self;
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
    [parser serverRequestSetDefaultParameters:self];

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
