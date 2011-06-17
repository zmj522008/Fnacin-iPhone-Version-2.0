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

@protocol ApplicationParser <NSObject>

- (NSError*) endDocument;

@end

@interface ServerRequest : NSObject <ASIHTTPRequestDelegate, NSXMLParserDelegate> {
    ASIFormDataRequest* asiRequest;
    id<ServerRequestDelegate> delegate;

    NSError* erreur;
   
    NSMutableString* currentTextString;

    int limitStart;
    int limitEnd;
    
    id<ApplicationParser> parser;
}

@property (nonatomic, retain) ASIFormDataRequest* asiRequest;
@property (nonatomic, retain) id<ServerRequestDelegate> delegate;
@property (nonatomic, retain) NSError *erreur;

@property (nonatomic, assign) int limitStart;
@property (nonatomic, assign) int limitEnd;

@property (nonatomic, retain) id<ApplicationParser> parser;

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password;
- (id) initArticle;

- (id) initGetThematiques;
- (id) initGetRubriques;
- (id) initGetPreferencesForType:(int)type;
- (id) initGetMagasins;
- (id) initSendTokenId:(NSString*)tokenId;
- (id) initSetFavoris:(BOOL)favoris withArticleId:(int)articleId;
- (id) initSetPreferences:(NSIndexSet*)indexSet forType:(int)type;
- (id) initSendCommentaire:(NSString*)text withArticleId:(int)articleId;
- (id) initJaimeWithArticleId:(int)articleId;
- (id) initPasswordWithEmail:(NSString*)email;

- (void) setParameter:(NSString*) name withValue:(NSString*)value;
- (void) setParameter:(NSString*) name withIntValue:(int)value;

// Calling this method turns on cache use.
// If forced is true, only cached data is fetched, when false, data is stored in cache
- (void) enableCacheWithForced:(BOOL)forced;
- (void) resetCache;

- (void) start;

- (void) cancel;
@end
