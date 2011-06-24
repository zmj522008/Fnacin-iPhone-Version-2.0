//
//  AnnuaireSync.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnuaireSync.h"
#import "Celaneo1AppDelegate.h"
#import "ASIDownloadCache.h"

#define SERVER @"http://webservice.fnacin.com/"

@implementation AnnuaireSync
@synthesize parser;
@synthesize list;
@synthesize personne;
@synthesize dateMaj;

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
        SaxMethodParser* saxParser = [[[SaxMethodParser alloc] init] autorelease];
        request.xmlParserDelegate = saxParser;
        saxParser.serverRequest = request;
        saxParser.parser = self;
        self.parser = saxParser;
    }
    
    ASIDownloadCache* cache = [ASIDownloadCache sharedCache];
    [cache addIgnoredPostKey:@"session_id"]; // TODO This could be moved to sth called once per session
}

- (void) doSync
{
    [self createRequest];
    
    [self.parser.serverRequest start];
}

- (NSError *)endDocument
{
    return nil;
}

#pragma mark parse server results
- (void) handleElementStart_fnac:(NSDictionary*)dic
{
    
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
    self.dateMaj = d;
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
}

- (void) handleElementEnd_tel_fixe:(NSString*)s
{
    self.personne.telephone = s;
}

- (void) handleElementEnd_prenom:(NSString*)s
{
    self.personne.prenom = s;
}

- (void) handleElementEnd_nom:(NSString*)s
{
    self.personne.nom = s;
}

- (void) handleElementEnd_personne:(NSString*)d
{
    switch (mode) {
        case MethodAdd:
            
    }
}



@end
