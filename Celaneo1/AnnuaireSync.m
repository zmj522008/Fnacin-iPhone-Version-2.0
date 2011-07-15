//
//  AnnuaireSync.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnuaireSync.h"
#import "AnnuaireDB.h"
#import "AnnuaireModel.h"

#import "Celaneo1AppDelegate.h"
#import "ASIDownloadCache.h"

#define SERVER @"http://webservice.fnacin.com/"

@implementation AnnuaireSync
@synthesize parser;
@synthesize list;
@synthesize personne;

- (void) createRequest
{
    NSString* url = [SERVER stringByAppendingString:@"annuaire"];
    ServerRequest* request = [[ServerRequest alloc] initWithUrl:url];
    if (request != nil) {
        NSString* sessionId = [Celaneo1AppDelegate getSingleton].sessionId;
        if (sessionId != nil) {
            [request setParameter:@"session_id" withValue:sessionId];
        }
        [request setParameter:@"retour" withValue:@"data"];
        AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
        NSString* date = [db getDataDate];
        //        date = @"2011-06-13 18:13:07"; // Modif + suppression
        //        date = @"2011-06-13 19:13:07"; // Modif + suppression
        // 
        if (date != nil && date.length > 0) {
            [request setParameter:@"date_derniere_maj" withValue:date];
            
#ifdef DEBUG
//            [db createObjects];
//            [[Celaneo1AppDelegate getSingleton].annuaireModel fetchData];
#endif
        } else {
            // We need to clear up the data base in this case
            [db removeAll];
        }
        SaxMethodParser* saxParser = [[[SaxMethodParser alloc] init] autorelease];
        request.xmlParserDelegate = saxParser;
        request.delegate = self;
        request.asiRequest.numberOfTimesToRetryOnTimeout = 5;
        request.asiRequest.timeOutSeconds = 30;
        request.asiRequest.requestFinishedOnASIThread = YES;
        saxParser.serverRequest = request;
        saxParser.parser = self;
        self.parser = saxParser;
    }
    dirty = NO;
    ASIDownloadCache* cache = [ASIDownloadCache sharedCache];
    [cache addIgnoredPostKey:@"session_id"]; // TODO This could be moved to sth called once per session
}

- (void) startSync
{
    [Celaneo1AppDelegate getSingleton].annuaireModel.syncing = YES;
    [self createRequest];
    
    [self.parser.serverRequest start];
}

- (NSError *)endDocument
{
    return nil;
}

- (void)serverRequest:(ServerRequest *)request didFailWithError:(NSError *)error
{
    [Celaneo1AppDelegate getSingleton].annuaireModel.syncing = NO;
}

- (void)serverRequest:(ServerRequest *)request didSucceedWithObject:(id)result
{
    [Celaneo1AppDelegate getSingleton].annuaireModel.syncing = NO;
}

#pragma mark parse server results
- (void) handleElementStart_fnac:(NSDictionary*)dic
{
    AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
    [db startTransaction];
}

- (void) handleElementEnd_fnac
{
    AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
    [db endTransaction];
    int count = [db getPersonneCount];
    if (dirty || count != nTotal) {
        NSLog(@"Count: DB: %d nb_personnes_total: %d. Mark DB as dirty", count, nTotal);
        // Remove the modification date to restart the server
        [db setDataDate:@""];
    }
    if (nModif > 0) {
        [[Celaneo1AppDelegate getSingleton].annuaireModel fetchData];
    }
}

- (void) handleElementStart_ajout:(NSDictionary*)dic
{
    mode = MethodAdd;
}

- (void) handleElementStart_modification:(NSDictionary*)dic
{
    mode = MethodUpdate;
}

- (void) handleElementStart_suppression:(NSDictionary*)dic
{
    mode = MethodRemove;
}

- (void) handleElementEnd_date_maj:(NSString*)d
{
    AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
    [db setDataDate:d];
}

- (void) handleElementEnd_nb_personnes_a_modifier:(NSString*)n
{
    nModif = [n intValue];
}

- (void) handleElementEnd_nb_personnes_total:(NSString*)n
{
    nTotal = [n intValue];
}

- (void) handleElementStart_personne:(NSDictionary*)dic
{
    self.personne = [[Personne alloc] init];
    personne.sId = [[dic objectForKey:@"id"] intValue];
}


- (void) handleElementEnd_civilite:(NSString*)s
{
    self.personne.civilite = s;
}

- (void) handleElementEnd_prenom:(NSString*)s
{
    self.personne.prenom = s;
}

- (void) handleElementEnd_nom:(NSString*)s
{
    self.personne.nom = s;
}

- (void) handleElementEnd_tel_fixe:(NSString*)s
{
    self.personne.telephone_fixe = s;
}

- (void) handleElementEnd_tel_interne:(NSString*)s
{
    self.personne.telephone_interne = s;
}

- (void) handleElementEnd_tel_mobile:(NSString*)s
{
    self.personne.telephone_mobile = s;
}

- (void) handleElementEnd_fax:(NSString*)s
{
    self.personne.telephone_fax = s;
}

- (void) handleElementEnd_email:(NSString*)s
{
    self.personne.email = s;
}

- (void) handleElementEnd_num_bureau:(NSString*)s
{
    self.personne.num_bureau = s;
}

- (void) handleElementEnd_fonction:(NSString*)s
{
    self.personne.fonction = s;
}

- (void) handleElementEnd_site:(NSString*)s
{
    self.personne.site = s;
}

- (void) handleElementEnd_adresse:(NSString*)s
{
    self.personne.adresse = s;
}

- (void) handleElementEnd_ville:(NSString*)s
{
    self.personne.ville = s;
}

- (void) handleElementEnd_cp:(NSString*)s
{
    self.personne.codepostal = s;
}

- (void) handleElementEnd_commentaire:(NSString*)s
{
    self.personne.commentaire = s;
}

- (void) handleElementEnd_site_nom:(NSString*)s
{
    self.personne.site_nom = s;
}

- (void) handleElementEnd_site_pays:(NSString*)s
{
    self.personne.site_pays = s;
}

- (void) handleElementEnd_site_region:(NSString*)s
{
    self.personne.site_region = s;
}

- (void) handleElementEnd_personne:(NSString*)d
{
    AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
    int r;
    switch (mode) {
        case MethodAdd:
            [personne genPhoneDigits];
            r = [db add:personne];
            break;
        case MethodRemove:
            r = [db remove:personne.sId];
            break;
        case MethodUpdate:
            r = [db update:personne];
            break;
    }
    if (r != SQLITE_OK) {
        dirty = YES;
    }
}

@end
