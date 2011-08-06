//
//  AnnuaireSync.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerRequest.h"
#import "SaxMethodParser.h"

#import "Personne.h"

@interface AnnuaireSync : NSObject <ApplicationParser, ServerRequestDelegate> {
    enum {
        MethodAdd,
        MethodRemove,
        MethodUpdate
    } mode;
    SaxMethodParser* parser;
    
    NSMutableArray* list;
    Personne* personne;
    int nModif;
    int nTotal;
    BOOL dirty;
    
    NSString* endDate;
    NSAutoreleasePool* personPool;
}

@property (nonatomic, retain) SaxMethodParser *parser;
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) Personne *personne;
@property (nonatomic, retain) NSString* endDate;
@property (nonatomic, assign) NSAutoreleasePool* personPool;

- (void) startSync;
@end
