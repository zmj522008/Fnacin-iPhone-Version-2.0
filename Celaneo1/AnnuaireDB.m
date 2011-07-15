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

#pragma mark debug
#ifdef DEBUG
- (void) createObjects
{
    NSArray* prenoms = [NSArray arrayWithObjects:@"ABE", @"ABEL", @"ABRAHAM", @"ABRAM", @"ADALBERTO", @"ADAM", @"ADAN", @"ADOLFO", @"ALDOLPH", @"AlDRIAN", @"AGUSTIN", @"AHMAD", @"AHMED", @"AL", @"ALAN", @"ALBERT", @"ALBERTO", @"ALDEN", @"ALDO", @"ALEC", @"ALEJANDRO", @"ALEX", @"ALEXANDER", @"ALEXIS", @"ALFONSO", @"ALFONZO", @"ALFRED", @"ALFREDO", @"ALI", @"ALLAN", @"ALLEN", @"ALONSO", @"ALONZO", @"ALPHONSE", @"ALPHONSO", @"ALTON", @"ALVA", @"ALVARO", @"ALVIN", @"AMADO", @"AMBROSE", @"AMOS", @"ANDERSON", @"ANDRE", @"ANDREA", @"ANDREAS", @"ANDRES", @"ANDREW", @"ANDY", @"ANGEL", @"ANGELO", @"ANIBAL", @"ANTHONY", @"ANTIONE", @"ANTOINE", @"ANTON", @"ANTONE", @"ANTONIA", @"ANTONIO", @"ANTONY", @"ANTWAN", @"ARCHIE", @"ARDEN", @"ARIEL", @"ARLEN", @"ARLIE", @"ARMAND", @"ARMANDO", @"ARNOLD", @"ARNOLDO", @"ARNULFO", @"ARON", @"ARRON", @"ART", @"ARTHUR", @"ARTURO", @"ASA", @"ASHLEY", @"AUBREY", @"AUGUST", @"AUGUSTINE", @"AUGUSTUS", @"AURELIO", @"AUSTIN", @"AVERY", @"BARNEY", @"BARRETT", @"BARRY", @"BART", @"BARTON", @"BASIL", @"BEAU", @"BEN", @"BENEDICT", @"BENITO", @"BENJAMIN", @"BENNETT", @"BENNIE", @"BENNY", @"BENTON", @"BERNARD", @"BERNARDO", @"BERNIE", @"BERRY", @"BERT", @"BERTRAM", @"BILL", @"BILLIE", @"BILLY", @"BLAINE", @"BLAIR", @"BLAKE", @"BO", @"BOB", @"BOBBIE", @"BOBBY", @"BOOKER", @"BORIS", @"BOYCE", @"BOYD", @"BRAD", @"BRADFORD", @"BRADLEY", @"BRADLY", @"BRADY", @"BRAIN", @"BRANDEN", @"BRANDON", @"BRANT", @"BRENDAN", @"BRENDON", @"BRENT", @"BRENTON", @"BRET", @"BRETT", @"BRIAN", @"BRICE", @"BRITT", @"BROCK", @"BRODERICK", @"BROOKS", @"BRUCE", @"BRUNO", @"BRYAN", @"BRYANT", @"BRYCE", @"BRYON", @"BUCK", @"BUD", @"BUDDY", @"BUFORD", @"BURL", @"BURT", @"BURTON", @"BUSTER", @"BYRON", @"CALEB", @"CALVIN", @"CAMERON", @"CAREY", @"CARL", @"CARLO", @"CARLOS", @"CARLTON", @"CARMELO", @"CARMEN", @"CARMINE", @"CAROL", @"CARROL", @"CARROLL", @"CARSON", @"CARTER", @"CARY", @"CASEY", @"CECIL", @"CEDRIC", @"CEDRICK", @"CESAR", @"CHAD", @"CHADWICK", @"CHANCE", @"CHANG", @"CHARLES", @"CHARLEY", @"CHARLIE", @"CHAS", @"CHASE", @"CHAUNCEY", @"CHESTER", @"CHET", @"CHI", @"CHONG", @"CHRIS", @"CHRISTIAN", @"CHRISTOPER", @"CHRISTOPHER", @"CHUCK", @"CHUNG", @"CLAIR", @"CLARENCE", @"CLARK", @"CLAUD", @"CLAUDE", @"CLAUDIO", @"CLAY", @"CLAYTON", @"CLEMENT", @"CLEMENTE", @"CLEO", @"CLETUS", @"CLEVELAND", @"CLIFF", @"CLIFFORD", @"CLIFTON", @"CLINT", @"CLINTON", @"CLYDE", @"CODY", @"COLBY", @"COLE", @"COLEMAN", @"COLIN", @"COLLIN", @"COLTON", @"COLUMBUS", @"CONNIE", @"CONRAD", @"CORDELL", @"COREY", @"CORNELIUS", @"CORNELL", @"CORTEZ", @"CORY", @"COURTNEY", @"COY", @"CRAIG", @"CRISTOBAL", @"CRISTOPHER", @"CRUZ", @"CURT", @"CURTIS", @"CYRIL", @"CYRUS", @"DALE", @"DALLAS", @"DALTON", @"DAMIAN", @"DAMIEN", @"DAMION", @"DAMON", @"DAN", @"DANA", @"DANE", @"DANIAL", @"DANIEL", @"DANILO", @"DANNIE", @"DANNY", @"DANTE", @"DARELL", @"DAREN", @"DARIN", @"DARIO", @"DARIUS", @"DARNELL", @"DARON", @"DARREL", @"DARRELL", @"DARREN", @"DARRICK", @"DARRIN", @"DARRON", @"DARRYL", @"DARWIN", @"DARYL", @"DAVE", @"DAVID", @"DAVIS", @"DEAN", @"DEANDRE", @"DEANGELO", @"DEE", @"DEL", @"DELBERT", @"DELMAR", @"DELMER", @"DEMARCUS", @"DEMETRIUS", @"DENIS", @"DENNIS", @"DENNY", @"DENVER", @"DEON", @"DEREK", @"DERICK", @"DERRICK", @"DESHAWN", @"DESMOND", @"DEVIN", @"DEVON", @"DEWAYNE", @"DEWEY", @"DEWITT", @"DEXTER", @"DICK", @"DIEGO", @"DILLON", @"DINO", @"DION", @"DIRK", @"DOMENIC", @"DOMINGO", @"DOMINIC", @"DOMINICK", @"DOMINIQUE", @"DON", @"DONALD", @"DONG", @"DONN", @"DONNELL", @"DONNIE", @"DONNY", @"DONOVAN", @"DONTE", @"DORIAN", @"DORSEY", @"DOUG", @"DOUGLAS", @"DOUGLASS", @"DOYLE", @"DREW", @"DUANE", @"DUDLEY", @"DUNCAN", @"DUSTIN", @"DUSTY", @"DWAIN", @"DWAYNE", @"DWIGHT", @"DYLAN", @"EARL", @"EARLE", @"EARNEST", @"ED", @"EDDIE", @"EDDY", @"EDGAR", @"EDGARDO", @"EDISON", @"EDMOND", @"EDMUND", @"EDMUNDO", @"EDUARDO", @"EDWARD", @"EDWARDO", @"EDWIN", @"EFRAIN", @"EFREN", @"ELBERT", @"ELDEN", @"ELDON", @"ELDRIDGE", @"ELI", @"ELIAS", @"ELIJAH", @"ELISEO", @"ELISHA", @"ELLIOT", @"ELLIOTT", @"ELLIS", @"ELLSWORTH", @"ELMER", @"ELMO", @"ELOY", @"ELROY", @"ELTON", @"ELVIN", @"ELVIS", @"ELWOOD", @"EMANUEL", @"EMERSON", @"EMERY", @"EMIL", @"EMILE", @"EMILIO", @"EMMANUEL", @"EMMETT", @"EMMITT", @"EMORY", @"ENOCH", @"ENRIQUE", @"ERASMO", @"ERIC", @"ERICH", @"ERICK", @"ERIK", @"ERIN", @"ERNEST", @"ERNESTO", @"ERNIE", @"ERROL", @"ERVIN", @"ERWIN", @"ESTEBAN", @"ETHAN", @"EUGENE", @"EUGENIO", @"EUSEBIO", @"EVAN", @"EVERETT", @"EVERETTE", @"EZEKIEL", @"EZEQUIEL", @"EZRA", @"FABIAN", @"FAUSTINO", @"FAUSTO", @"FEDERICO", @"FELIPE", @"FELIX", @"FELTON", @"FERDINAND", @"FERMIN", @"FERNANDO", @"FIDEL", @"FILIBERTO", @"FLETCHER", @"FLORENCIO", @"FLORENTINO", @"FLOYD", @"FOREST", @"FORREST", @"FOSTER", @"FRANCES", @"FRANCESCO", @"FRANCIS", @"FRANCISCO", @"FRANK", @"FRANKIE", @"FRANKLIN", @"FRANKLYN", @"FRED", @"FREDDIE", @"FREDDY", @"FREDERIC", @"FREDERICK", @"FREDRIC", @"FREDRICK", @"FREEMAN", @"FRITZ", @"GABRIEL", @"GAIL", @"GALE", @"GALEN", @"GARFIELD", @"GARLAND", @"GARRET", @"GARRETT", @"GARRY", @"GARTH", @"GARY", @"GASTON", @"GAVIN", @"GAYLE", @"GAYLORD", @"GENARO", @"GENE", @"GEOFFREY", @"GEORGE", @"GERALD", @"GERALDO", @"GERARD", @"GERARDO", @"GERMAN", @"GERRY", @"GIL", @"GILBERT", @"GILBERTO", @"GINO", @"GIOVANNI", @"GIUSEPPE", @"GLEN", @"GLENN", @"GONZALO", @"GORDON", @"GRADY", @"GRAHAM", @"GRAIG", @"GRANT", @"GRANVILLE", @"GREG", @"GREGG", @"GREGORIO", @"GREGORY", @"GROVER", @"GUADALUPE", @"GUILLERMO", @"GUS", @"GUSTAVO", @"GUY", @"HAI", @"HAL", @"HANK", @"HANS", @"HARLAN", @"HARLAND", @"HARLEY", @"HAROLD", @"HARRIS", @"HARRISON", @"HARRY", @"HARVEY", @"HASSAN", @"HAYDEN", @"HAYWOOD", @"HEATH", @"HECTOR", @"HENRY", @"HERB", @"HERBERT", @"HERIBERTO", @"HERMAN", @"HERSCHEL", @"HERSHEL", @"HILARIO", @"HILTON", @"HIPOLITO", @"HIRAM", @"HOBERT", @"HOLLIS", @"HOMER", @"HONG", @"HORACE", @"HORACIO", @"HOSEA", @"HOUSTON", @"HOWARD", @"HOYT", @"HUBERT", @"HUEY", @"HUGH", @"HUGO", @"HUMBERTO", @"HUNG", @"HUNTER", @"HYMAN", @"IAN", @"IGNACIO", @"IKE", @"IRA", @"IRVIN", @"IRVING", @"IRWIN", @"ISAAC", @"ISAIAH", @"ISAIAS", @"ISIAH", @"ISIDRO", @"ISMAEL", @"ISRAEL", @"ISREAL", @"ISSAC", @"IVAN", @"IVORY", @"JACINTO", @"JACK", @"JACKIE", @"JACKSON", @"JACOB", @"JACQUES", @"JAE", @"JAIME", @"JAKE", @"JAMAAL", @"JAMAL", @"JAMAR", @"JAME", @"JAMEL", @"JAMES", @"JAMEY", @"JAMIE", @"JAMISON", @"JAN", @"JARED", @"JAROD", @"JARRED", @"JARRETT", @"JARROD", @"JARVIS", @"JASON", @"JASPER", @"JAVIER", @"JAY", @"JAYSON", @"JC", @"JEAN", @"JED", @"JEFF", @"JEFFEREY", @"JEFFERSON", @"JEFFERY", @"JEFFREY", @"JEFFRY", @"JERALD", @"JERAMY", @"JERE", @"JEREMIAH", @"JEREMY", @"JERMAINE", @"JEROLD", @"JEROME", @"JEROMY", @"JERRELL", @"JERROD", @"JERROLD", @"JERRY", @"JESS", @"JESSE", @"JESSIE", @"JESUS", @"JEWEL", @"JEWELL", @"JIM", @"JIMMIE", @"JIMMY", @"JOAN", @"JOAQUIN", @"JODY", @"JOE", @"JOEL", @"JOESPH", @"JOEY", @"JOHN", @"JOHNATHAN", @"JOHNATHON", @"JOHNIE", @"JOHNNIE", @"JOHNNY", @"JOHNSON", @"JON", @"JONAH", @"JONAS", @"JONATHAN", @"JONATHON", @"JORDAN", @"JORDON", @"JORGE", @"JOSE", @"JOSEF", @"JOSEPH", @"JOSH", @"JOSHUA", @"JOSIAH", @"JOSPEH", @"JOSUE", @"JUAN", @"JUDE", @"JUDSON", @"JULES", @"JULIAN", @"JULIO", @"JULIUS", @"JUNIOR", @"JUSTIN", @"KAREEM", @"KARL", @"KASEY", @"KEENAN", @"KEITH", @"KELLEY", @"KELLY", @"KELVIN", @"KEN", @"KENDALL", @"KENDRICK", @"KENETH", @"KENNETH", @"KENNITH", @"KENNY", @"KENT", @"KENTON", @"KERMIT", @"KERRY", @"KEVEN", @"KEVIN", @"KIETH", @"KIM", @"KING", @"KIP", @"KIRBY", @"KIRK", @"KOREY", @"KORY", @"KRAIG", @"KRIS", @"KRISTOFER", @"KRISTOPHER", @"KURT", @"KURTIS", @"KYLE", @"LACY", @"LAMAR", @"LAMONT", @"LANCE", @"LANDON", @"LANE", @"LANNY", @"LARRY", @"LAUREN", @"LAURENCE", @"LAVERN", @"LAVERNE", @"LAWERENCE", @"LAWRENCE", @"LAZARO", @"LEANDRO", @"LEE", @"LEIF", @"LEIGH", @"LELAND", @"LEMUEL", @"LEN", @"LENARD", @"LENNY", @"LEO", @"LEON", @"LEONARD", @"LEONARDO", @"LEONEL", @"LEOPOLDO", @"LEROY", @"LES", @"LESLEY", @"LESLIE", @"LESTER", @"LEVI", @"LEWIS", @"LINCOLN", @"LINDSAY", @"LINDSEY", @"LINO", @"LINWOOD", @"LIONEL", @"LLOYD", @"LOGAN", @"LON", @"LONG", @"LONNIE", @"LONNY", @"LOREN", @"LORENZO", @"LOU", @"LOUIE", @"LOUIS", @"LOWELL", @"LOYD", @"LUCAS", @"LUCIANO", @"LUCIEN", @"LUCIO", @"LUCIUS", @"LUIGI", @"LUIS", @"LUKE", @"LUPE", @"LUTHER", @"LYLE", @"LYMAN", @"LYNDON", @"LYNN", @"LYNWOOD", @"MAC", @"MACK", @"MAJOR", @"MALCOLM", @"MALCOM", @"MALIK", @"MAN", @"MANUAL", @"MANUEL", @"MARC", @"MARCEL", @"MARCELINO", @"MARCELLUS", @"MARCELO", @"MARCO", @"MARCOS", @"MARCUS", @"MARGARITO", @"MARIA", @"MARIANO", @"MARIO", @"MARION", @"MARK", @"MARKUS", @"MARLIN", @"MARLON", @"MARQUIS", @"MARSHALL", @"MARTIN", @"MARTY", @"MARVIN", @"MARY", @"MASON", @"MATHEW", @"MATT", @"MATTHEW", @"MAURICE", @"MAURICIO", @"MAURO", @"MAX", @"MAXIMO", @"MAXWELL", @"MAYNARD", @"MCKINLEY", @"MEL", @"MELVIN", @"MERLE", @"MERLIN", @"MERRILL", @"MERVIN", @"MICAH", @"MICHAEL", @"MICHAL", @"MICHALE", @"MICHEAL", @"MICHEL", @"MICKEY", @"MIGUEL", @"MIKE", @"MIKEL", @"MILAN", @"MILES", @"MILFORD", @"MILLARD", @"MILO", @"MILTON", @"MINH", @"MIQUEL", @"MITCH", @"MITCHEL", @"MITCHELL", @"MODESTO", @"MOHAMED", @"MOHAMMAD", @"MOHAMMED", @"MOISES", @"MONROE", @"MONTE", @"MONTY", @"MORGAN", @"MORRIS", @"MORTON", @"MOSE", @"MOSES", @"MOSHE", @"MURRAY", @"MYLES", @"MYRON", @"NAPOLEON", @"NATHAN", @"NATHANAEL", @"NATHANIAL", @"NATHANIEL", @"NEAL", @"NED", @"NEIL", @"NELSON", @"NESTOR", @"NEVILLE", @"NEWTON", @"NICHOLAS", @"NICK", @"NICKOLAS", @"NICKY", @"NICOLAS", @"NIGEL", @"NOAH", @"NOBLE", @"NOE", @"NOEL", @"NOLAN", @"NORBERT", @"NORBERTO", @"NORMAN", @"NORMAND", @"NORRIS", @"NUMBERS", @"OCTAVIO", @"ODELL", @"ODIS", @"OLEN", @"OLIN", @"OLIVER", @"OLLIE", @"OMAR", @"OMER", @"OREN", @"ORLANDO", @"ORVAL", @"ORVILLE", @"OSCAR", @"OSVALDO", @"OSWALDO", @"OTHA", @"OTIS", @"OTTO", @"OWEN", @"PABLO", @"PALMER", @"PARIS", @"PARKER", @"PASQUALE", @"PAT", @"PATRICIA", @"PATRICK", @"PAUL", @"PEDRO", @"PERCY", @"PERRY", @"PETE", @"PETER", @"PHIL", @"PHILIP", @"PHILLIP", @"PIERRE", @"PORFIRIO", @"PORTER", @"PRESTON", @"PRINCE", @"QUENTIN", @"QUINCY", @"QUINN", @"QUINTIN", @"QUINTON", @"RAFAEL", @"RALEIGH", @"RALPH", @"RAMIRO", @"RAMON", @"RANDAL", @"RANDALL", @"RANDELL", @"RANDOLPH", @"RANDY", @"RAPHAEL", @"RASHAD", @"RAUL", @"RAY", @"RAYFORD", @"RAYMON", @"RAYMOND", @"RAYMUNDO", @"REED", @"REFUGIO", @"REGGIE", @"REGINALD", @"REID", @"REINALDO", @"RENALDO", @"RENATO", @"RENE", @"REUBEN", @"REX", @"REY", @"REYES", @"REYNALDO", @"RHETT", @"RICARDO", @"RICH", @"RICHARD", @"RICHIE", @"RICK", @"RICKEY", @"RICKIE", @"RICKY", @"RICO", @"RIGOBERTO", @"RILEY", @"ROB", @"ROBBIE", @"ROBBY", @"ROBERT", @"ROBERTO", @"ROBIN", @"ROBT", @"ROCCO", @"ROCKY", @"ROD", @"RODERICK", @"RODGER", @"RODNEY", @"RODOLFO", @"RODRICK", @"RODRIGO", @"ROGELIO", @"ROGER", @"ROLAND", @"ROLANDO", @"ROLF", @"ROLLAND", @"ROMAN", @"ROMEO", @"RON", @"RONALD", @"RONNIE", @"RONNY", @"ROOSEVELT", @"RORY", @"ROSARIO", @"ROSCOE", @"ROSENDO", @"ROSS", @"ROY", @"ROYAL", @"ROYCE", @"RUBEN", @"RUBIN", @"RUDOLF", @"RUDOLPH", @"RUDY", @"RUEBEN", @"RUFUS", @"RUPERT", @"RUSS", @"RUSSEL", @"RUSSELL", @"RUSTY", @"RYAN", @"SAL", @"SALVADOR", @"SALVATORE", @"SAM", @"SAMMIE", @"SAMMY", @"SAMUAL", @"SAMUEL", @"SANDY", @"SANFORD", @"SANG", @"SANTIAGO", @"SANTO", @"SANTOS", @"SAUL", @"SCOT", @"SCOTT", @"SCOTTIE", @"SCOTTY", @"SEAN", @"SEBASTIAN", @"SERGIO", @"SETH", @"SEYMOUR", @"SHAD", @"SHANE", @"SHANNON", @"SHAUN", @"SHAWN", @"SHAYNE", @"SHELBY", @"SHELDON", @"SHELTON", @"SHERMAN", @"SHERWOOD", @"SHIRLEY", @"SHON", @"SID", @"SIDNEY", @"SILAS", @"SIMON", @"SOL", @"SOLOMON", @"SON", @"SONNY", @"SPENCER", @"STACEY", @"STACY", @"STAN", @"STANFORD", @"STANLEY", @"STANTON", @"STEFAN", @"STEPHAN", @"STEPHEN", @"STERLING", @"STEVE", @"STEVEN", @"STEVIE", @"STEWART", @"STUART", @"SUNG", @"SYDNEY", @"SYLVESTER", @"TAD", @"TANNER", @"TAYLOR", @"TED", @"TEDDY", @"TEODORO", @"TERENCE", @"TERRANCE", @"TERRELL", @"TERRENCE", @"TERRY", @"THAD", @"THADDEUS", @"THANH", @"THEO", @"THEODORE", @"THERON", @"THOMAS", @"THURMAN", @"TIM", @"TIMMY", @"TIMOTHY", @"TITUS", @"TOBIAS", @"TOBY", @"TOD", @"TODD", @"TOM", @"TOMAS", @"TOMMIE", @"TOMMY", @"TONEY", @"TONY", @"TORY", @"TRACEY", @"TRACY", @"TRAVIS", @"TRENT", @"TRENTON", @"TREVOR", @"TREY", @"TRINIDAD", @"TRISTAN", @"TROY", @"TRUMAN", @"TUAN", @"TY", @"TYLER", @"TYREE", @"TYRELL", @"TYRON", @"TYRONE", @"TYSON", @"ULYSSES", @"VAL", @"VALENTIN", @"VALENTINE", @"VAN", @"VANCE", @"VAUGHN", @"VERN", @"VERNON", @"VICENTE", @"VICTOR", @"VINCE", @"VINCENT", @"VINCENZO", @"VIRGIL", @"VIRGILIO", @"VITO", @"VON", @"WADE", @"WALDO", @"WALKER", @"WALLACE", @"WALLY", @"WALTER", @"WALTON", @"WARD", @"WARNER", @"WARREN", @"WAYLON", @"WAYNE", @"WELDON", @"WENDELL", @"WERNER", @"WES", @"WESLEY", @"WESTON", @"WHITNEY", @"WILBER", @"WILBERT", @"WILBUR", @"WILBURN", @"WILEY", @"WILFORD", @"WILFRED", @"WILFREDO", @"WILL", @"WILLARD", @"WILLIAM", @"WILLIAMS", @"WILLIAN", @"WILLIE", @"WILLIS", @"WILLY", @"WILMER", @"WILSON", @"WILTON", @"WINFORD", @"WINFRED", @"WINSTON", @"WM", @"WOODROW", @"WYATT", @"XAVIER", @"YONG", @"YOUNG", @"ZACHARIAH", @"ZACHARY", @"ZACHERY", @"ZACK", @"ZACKARY", @"ZANE", nil];
    
    for (int i = 0; i < 10000; i++) {
        Personne* p = [[Personne alloc] init];
        int idx = rand() % prenoms.count;
        NSMutableString* str = [NSMutableString stringWithCapacity:1];
        [str appendString:[prenoms objectAtIndex:idx]];
        [str appendString:@" "];
        p.prenom = [NSString stringWithString:str];
        
        idx = rand() % prenoms.count;
        str = [NSMutableString stringWithCapacity:1];
        [str appendString:[prenoms objectAtIndex:idx]];
        [str appendString:@"nn"];
        p.nom = [NSString stringWithString:str];
        
        str = [NSMutableString stringWithCapacity:1];
        NSMutableString* str2 = [NSMutableString stringWithCapacity:1];
        for (int j = 0; j < 10; j++) {
            if (j > 0 && (j & 1) == 0) {
                [str appendString:@" "];
            }
            [str appendFormat:@"%01d", rand() % 10];
            [str2 appendFormat:@"%01d", rand() % 10];
        }
        p.telephone_fixe = [NSString stringWithString:str];
        p.phoneDigits = [NSString stringWithString:str2];
        
        p.sId = 100000 + i;
        [self add:p];
        [p release];
    }
}
#endif

#pragma mark dealloc

- (void)dealloc
{
    sqlite3_close(database);
    database = nil;
    
    [super dealloc];
}

@end
