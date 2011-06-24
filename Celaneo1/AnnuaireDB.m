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

- (id) initWithDBName:(NSString*)dbName
{
    [super init];
    
    // On récupère le chemin
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:dbName];
    
    int r = sqlite3_open([databasePath UTF8String], &database);
    if (r != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"DB Error: %d", r);
        return nil;
    }
    [self createIfNotExist];
    return self;
}

- (void) createIfNotExist
{
    sqlite3_exec(database,
                 "CREATE TABLE IF NOT EXISTS Personnes (ID INTEGER PRIMARY KEY, NOM TEXT, PRENOM TEXT, TELEPHONE TEXT)",
                 NULL, NULL, NULL);
    sqlite3_exec(database,
                 "CREATE TABLE IF NOT EXISTS Dates (ID INTEGER PRIMARY KEY, DATE TEXT)",
                 NULL, NULL, NULL);
    NSLog(@"Error: %s", sqlite3_errmsg(database));
}

- (NSArray*) getPersonnesShort
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [[NSString stringWithFormat:@"SELECT nom, prenom, telephone FROM Personnes"] UTF8String], -1, &statement, nil);
    
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:1];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        Personne* p = [[Personne alloc] init];
        p.nom = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
        p.prenom = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 1)];
        p.telephone = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 2)];
        [list addObject:p];
        [p release];
    }
    
    sqlite3_finalize(statement);
    
    return list;
}

- (Personne*) getPersonneFull:(int)serverId
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [[NSString stringWithFormat:@"SELECT nom, prenom, telephone FROM Personnes WHERE ID == %d", serverId] UTF8String], -1, &statement, nil);
    
    Personne* p;
    if (sqlite3_step(statement) == SQLITE_ROW) {
        p = [[Personne alloc] init];
        p.nom = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
        p.prenom = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 1)];
        p.telephone = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 2)];
    } else {
        p = nil;
    }
    
    sqlite3_finalize(statement);
    
    return p;
}

- (NSString*) getDataDate
{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, "SELECT DATE FROM Dates WHERE id == 0", -1, &statement, nil);
    
    NSString* date = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
    sqlite3_finalize(statement);
    
    return date;
}

- (void) setDataDate:(NSString*) date
{
    sqlite3_exec(database,
                 [[@"INSERT OR REPLACE INTO Dates (ID, DATE) VALUES (0, " stringByAppendingFormat:@"%s )", date] UTF8String],
                 NULL, NULL, NULL);
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
    
    int count = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return count;
}

- (void)add:(Personne*)p
{
    sqlite3_exec(database,
                 [[NSString stringWithFormat:@"INSERT INTO Personnes (ID, NOM, PRENOM, TELEPHONE) VALUES (%d, '%@', '%@', '%@')",
                   p.sId, p.nom, p.prenom, p.telephone] UTF8String],
                 NULL, NULL, NULL);
}


- (void)update:(Personne*)p
{
    sqlite3_exec(database,
                 [[NSString stringWithFormat:@"REPLACE INTO Personnes (ID, NOM, PRENOM, TELEPHONE) VALUES (%d, '%@', '%@', '%@')",
                   p.sId, p.nom, p.prenom, p.telephone] UTF8String],
                 NULL, NULL, NULL);
}


- (void)remove:(int)sId
{
    sqlite3_exec(database,
                 [[NSString stringWithFormat:@"DELETE FROM Personnes WHERE ID = %d", sId] UTF8String],
                 NULL, NULL, NULL);
}

- (void)dealloc
{
    sqlite3_close(database);
    database = nil;
    
    [super dealloc];
}

@end
