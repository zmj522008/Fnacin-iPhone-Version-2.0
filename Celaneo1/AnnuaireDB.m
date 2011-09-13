//
//  AnnuaireDB.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnuaireDB.h"

#import "Personne.h"

@interface AnnuaireDB()
- (void) createIfNotExist;
@end

@implementation AnnuaireDB
@synthesize synchronized;

+ (NSString*) databasePath
{
    // On récupère le chemin
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"annuaire.db"];
}

- (BOOL) openDB
{
    int r = sqlite3_open([[AnnuaireDB databasePath] UTF8String], &database);
    if (r != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"DB Error: %d", r);
        database = nil;
        return NO;
    } else {
        return YES;
    }
}

- (id) initWithDBName:(NSString*)dbName
{
    [super init];
    
    if ([self openDB]) {
        [self createIfNotExist];
        return self;
    } else {
        return nil;
    }
}

- (void) resetDB
{
    if (database) {
        sqlite3_close(database);
        database = nil;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[AnnuaireDB databasePath] error:nil];   

    if ([self openDB]) {
        [self createIfNotExist];
    }
    
}

- (void) createIfNotExist
{
    sqlite3_exec(database,
                 "CREATE TABLE IF NOT EXISTS Personnes (ID INTEGER PRIMARY KEY,\
                 civilite TEXT,\
                 nom TEXT,\
                 prenom TEXT,\
                 telephone_fixe TEXT,\
                 telephone_interne TEXT,\
                 telephone_mobile TEXT,\
                 telephone_fax TEXT,\
                 email TEXT,\
                 num_bureau TEXT,\
                 fonction TEXT,\
                 site TEXT,\
                 adresse TEXT,\
                 codepostal TEXT,\
                 ville TEXT,\
                 commentaire TEXT,\
                 site_nom TEXT,\
                 site_pays TEXT,\
                 site_region TEXT,\
                 phoneDigits TEXT)",

                 NULL, NULL, NULL);
    sqlite3_exec(database,
                 "CREATE TABLE IF NOT EXISTS Dates (ID INTEGER PRIMARY KEY, DATE TEXT)",
                 NULL, NULL, NULL);
    NSLog(@"Error: %s", sqlite3_errmsg(database));
}

#define SET(field, col) { char* str = (char*) sqlite3_column_text(statement, col); NSString* v = strcmp(str, "(null)") == 0 ? nil : [[NSString alloc] initWithUTF8String:str]; p.field = v; [v release]; }

- (NSArray*) getPersonnesShort
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, "SELECT * FROM Personnes ORDER BY nom ASC", -1, &statement, nil);
    
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:1];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        Personne* p = [[Personne alloc] init];
        p.sId = sqlite3_column_int(statement, 0);
        SET(civilite, 1);
        SET(nom, 2);
        SET(prenom, 3);
        SET(telephone_fixe, 4);
        SET(telephone_interne, 5);
        SET(telephone_mobile, 6);
        SET(telephone_fax, 7);
        SET(phoneDigits, 18);

        [list addObject:p];
        [p release];
    }
    
    sqlite3_finalize(statement);
    
    return list;
}

- (Personne*) getPersonneFull:(int)serverId
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [[NSString stringWithFormat:@"SELECT * FROM Personnes WHERE ID == %d", serverId] UTF8String], -1, &statement, nil);
    
    Personne* p;
    if (sqlite3_step(statement) == SQLITE_ROW) {
        p = [[[Personne alloc] init] autorelease];
        p.sId = sqlite3_column_int(statement, 0);
        SET(civilite, 1);
        SET(nom, 2);
        SET(prenom, 3);
        SET(telephone_fixe, 4);
        SET(telephone_interne, 5);
        SET(telephone_mobile, 6);
        SET(telephone_fax, 7);
        SET(email, 8);
        SET(num_bureau, 9);
        SET(fonction, 10);
        SET(site, 11);
        SET(adresse, 12);
        SET(codepostal, 13);
        SET(ville, 14);
        SET(commentaire, 15);
        SET(site_nom, 16);
        SET(site_pays, 17);
        SET(site_region, 18);
        SET(phoneDigits, 19);
    } else {
        p = nil;
    }
#ifdef DEBUG
    [p test];
#endif
    sqlite3_finalize(statement);
    
    return p;
}

- (NSString*) getDataDate
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, "SELECT DATE FROM Dates WHERE id == 0", -1, &statement, nil);
    int r;
    if ((r = sqlite3_step(statement)) == SQLITE_ROW) {
        char* result = (char*) sqlite3_column_text(statement, 0);
        if (result != NULL) {
            NSString* date = [NSString stringWithUTF8String: result];
            sqlite3_finalize(statement);
            
            return date;
        }
    }
    NSLog(@"Error in getDataDate: %d %s", r, sqlite3_errmsg(database));
    return nil;
}

- (void) setDataDate:(NSString*) date
{
    int r = sqlite3_exec(database,
                 [[@"INSERT OR REPLACE INTO Dates (ID, DATE) VALUES (0, " stringByAppendingFormat:@"'%@' )", date] UTF8String],
                 NULL, NULL, NULL);
    if (r != SQLITE_OK) {
        NSLog(@"Error in setDataDate: %d %s", r, sqlite3_errmsg(database));
    }
}

- (void) startTransaction
{
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
}

- (void) endTransaction
{
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, NULL);    
}

- (int) getPersonneCount
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, "SELECT COUNT(*) FROM Personnes", -1, &statement, nil);
    int r;
    if ((r = sqlite3_step(statement)) == SQLITE_ROW) {
        int count = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
        return count;
    } else {
        NSLog(@"Error in getPersonneCount: %d %s", r, sqlite3_errmsg(database));

        return -1;
    }
}

#define C(s) (s.length ? [s stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"")
- (int)add:(Personne*)p
{
    [p genPhoneDigits];
    NSString* queryString = [NSString stringWithFormat:@"REPLACE INTO Personnes (ID,\
                             civilite,\
                             nom,\
                             prenom,\
                             telephone_fixe,\
                             telephone_interne,\
                             telephone_mobile,\
                             telephone_fax,\
                             email,\
                             num_bureau,\
                             fonction,\
                             site,\
                             adresse,\
                             codepostal,\
                             ville,\
                             commentaire,\
                             site_nom,\
                             site_pays,\
                             site_region,\
                             phoneDigits)\
                             VALUES (%d, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                             p.sId, 
                             C(p.civilite),
                             C(p.nom),
                             C(p.prenom),
                             C(p.telephone_fixe),
                             C(p.telephone_interne),
                             C(p.telephone_mobile),
                             C(p.telephone_fax),
                             C(p.email),
                             C(p.num_bureau),
                             C(p.fonction),
                             C(p.site),
                             C(p.adresse),
                             C(p.codepostal),
                             C(p.ville),
                             C(p.commentaire),
                             C(p.site_nom),
                             C(p.site_pays),
                             C(p.site_region),
                             C(p.phoneDigits)
                             ];
    int r = sqlite3_exec(database,
                 [queryString UTF8String],
                 NULL, NULL, NULL);
    if (r != SQLITE_OK) {
        NSLog(@"Error in add: %d %s", r, sqlite3_errmsg(database));
    }
    return r;
}


- (int)update:(Personne*)p
{
    return [self add:p];
}


- (int)remove:(int)sId
{
    int r = sqlite3_exec(database,
                 [[NSString stringWithFormat:@"DELETE FROM Personnes WHERE ID = %d", sId] UTF8String],
                 NULL, NULL, NULL);
    if (r != SQLITE_OK) {
        NSLog(@"Error in remove: %d %s", r, sqlite3_errmsg(database));
    }
    return r;
}

- (void)removeAll
{
    int r = sqlite3_exec(database, "DELETE FROM Personnes", NULL, NULL, NULL);
    if (r != SQLITE_OK) {
        NSLog(@"Error in setDataDate: %d %s", r, sqlite3_errmsg(database));
    }

}

#pragma mark dealloc

- (void)dealloc
{
    sqlite3_close(database);
    database = nil;
    
    [super dealloc];
}

@end
