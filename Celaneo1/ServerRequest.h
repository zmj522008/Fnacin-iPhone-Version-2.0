//
//  ServerRequest.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Article.h"
#import "Magasin.h"
#import "Category.h"
#import "Commentaire.h"

@class ServerRequest;

@protocol ServerRequestDelegate <NSObject>

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result;
- (void) serverRequest:(ServerRequest*)request didFailWithError:(NSError*)error;

@end

@interface ServerRequest : NSObject <ASIHTTPRequestDelegate, NSXMLParserDelegate> {
    ASIFormDataRequest* asiRequest;
    id<ServerRequestDelegate> delegate;
    
    NSMutableString* currentTextString;
    Article* article;
    Magasin* magasin;
    Category* category;
    Commentaire* commentaire;
    
    BOOL authentificated;
    BOOL fnac;
    
    int currentId;
    
    NSMutableArray* articles;
    NSMutableArray* thematiques;
    NSMutableArray* rubriques;
    NSMutableArray* magasins;
    
    NSMutableArray* commentaires;
    
    NSString* erreurDescription;
    int erreurCode;
    NSError* erreur;
}

@property (nonatomic, retain) ASIFormDataRequest* asiRequest;
@property (nonatomic, retain) id<ServerRequestDelegate> delegate;
@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, retain) NSArray *thematiques;
@property (nonatomic, retain) NSArray *rubriques;
@property (nonatomic, retain) NSArray *magasins;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) Magasin *magasin;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSError *erreur;
@property (nonatomic, retain) NSString *erreurDescription;
@property (nonatomic, retain) Commentaire *commentaire;
@property (nonatomic, retain) NSMutableArray *commentaires;

- (id) initAuthentificateWithEmail:(NSString*)email withPassword:(NSString*)password;
- (id) initListALaUne;
- (id) initListPodcast;

- (id) initGetThematiques;
- (id) initGetRubriques;
- (id) initGetMagasins;
- (id) initSendTokenId;

- (void) enableCacheWithForced:(BOOL)cache;

- (void) start;

- (void) cancel;
@end
