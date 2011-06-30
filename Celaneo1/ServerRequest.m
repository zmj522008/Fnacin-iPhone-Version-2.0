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

@synthesize xmlParserDelegate;
@synthesize result;

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
#ifdef DEBUG
        if (responseData.length < 1000) {
            NSLog(@"%@\n%@", request.url, request.responseString);
        }
#endif
        NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:responseData];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
        xmlParser.delegate = xmlParserDelegate;
        [xmlParser parse];
        
        if (erreur == nil) {
            [delegate serverRequest:self didSucceedWithObject:result];        
        } else {
            [self requestFailed:request];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *requestError = [request error];
    // Never store errors!!!
    [[ASIDownloadCache sharedCache] removeCachedDataForRequest:request];
    
    if (requestError.domain == NetworkRequestErrorDomain && requestError.code == ASIRequestCancelledErrorType) {
        NSLog(@"%@ cancelled", self);
    } else {
        NSLog(@"serverRequest error :%@, app error: %@", requestError, erreur);
        if (requestError) {
            [delegate serverRequest:self didFailWithError:requestError];
        } else {
            [delegate serverRequest:self didFailWithError:erreur];
        }
    }
}


#pragma mark lifecycle
- (void) start
{
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
    [erreur release];
    [xmlParserDelegate release];
    [result release];
    
    [super dealloc];
}
@end
