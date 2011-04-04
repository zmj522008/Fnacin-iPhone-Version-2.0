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

@interface ServerRequest : NSObject <ASIHTTPRequestDelegate, NSXMLParserDelegate> {
    ASIFormDataRequest* asiRequest;
    id<ServerRequestDelegate> delegate;
}

@property (nonatomic, retain) ASIFormDataRequest* asiRequest;
@property (nonatomic, retain) id<ServerRequestDelegate> delegate;

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password;
/*
- (id) initGetThematiques;
- (id) initGetRubriques;
- (id) initGetMagasins;
- (id) initSendTokenId;
*/
- (void) start;

- (void) cancel;
@end
