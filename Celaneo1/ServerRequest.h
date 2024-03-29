//
//  ServerRequest.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@class ServerRequest;

@protocol ServerRequestDelegate <NSObject>

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result;
- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error;

@end

@interface ServerRequest : NSObject <ASIHTTPRequestDelegate> {
    ASIFormDataRequest* asiRequest;
    id<ServerRequestDelegate> delegate;

    id result;
    NSError* erreur;
    id<NSXMLParserDelegate> xmlParserDelegate;
}

@property (nonatomic, retain) ASIFormDataRequest* asiRequest;
@property (nonatomic, retain) id<ServerRequestDelegate> delegate;

@property (nonatomic, retain) NSError *erreur;
@property (nonatomic, retain) id<NSXMLParserDelegate> xmlParserDelegate;

@property (nonatomic, retain) id result;

- (id) initWithUrl:(NSString*)url;

- (void) setParameter:(NSString*) name withValue:(NSString*)value;
- (void) setParameter:(NSString*) name withIntValue:(int)value;

// Calling this method turns on cache use.
// If forced is true, only cached data is fetched, when false, data is stored in cache
- (void) enableCacheWithForced:(BOOL)forced;
- (void) resetCache;

- (void) start;
- (void) startSynchronous;

- (void) cancel;
@end
