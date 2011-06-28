//
//  AnnuaireDB.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "/usr/include/sqlite3.h"

@class Personne;

@interface AnnuaireDB : NSObject {
    sqlite3* database;
    
    BOOL synchronized;
}
@property (assign) BOOL synchronized;

- (id) initWithDBName:(NSString*)dbName;

- (NSArray*) getPersonnesShort;
- (Personne*) getPersonneFull:(int) serverId;

- (NSString*) getDataDate;
- (void) setDataDate:(NSString*) date;

- (void) startTransaction;
- (void) endTransaction;

- (int) getPersonneCount;


- (int)add:(Personne*)p;
- (int)update:(Personne*)p;
- (int)remove:(int)sId;
- (void)removeAll;
@end
