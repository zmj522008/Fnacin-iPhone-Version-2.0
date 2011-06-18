//
//  ArticleParser.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleParser.h"
#import "Celaneo1AppDelegate.h"


@implementation ArticleParser
@synthesize articles;
@synthesize thematiques;
@synthesize rubriques;
@synthesize magasins;
@synthesize article;
@synthesize magasin;
@synthesize category;
@synthesize commentaire;
@synthesize commentaires;
@synthesize articleCount;
@synthesize nb_jaime;
@synthesize nb_commentaire;
@synthesize dirigeant;
@synthesize prepageContent;
@synthesize prepageFerme;

#pragma mark Application XML Parsing

- (void) resetParsing
{
    self.articles = nil;
    self.magasins = nil;
    self.rubriques = nil;
    self.thematiques = nil;
    
    self.article = nil;
    self.magasin = nil;
    
    self.prepageContent = nil;
    
    [super resetParsing];
}

- (void) dump
{
    for (NSString* arg in [NSArray arrayWithObjects:@"rubriques", @"thematiques", @"articles", @"magasins", nil]) {
        NSArray* lst = [self performSelector:NSSelectorFromString(arg)];
        NSLog(@"%@ (%d):", arg, [lst count]);
        for (id<ModelObject> c in lst) {
            [c dump];
        }
    }
}

#pragma mark Application XML Parsing - authentification
- (void) handleElementEnd_session_id:(NSString*)sessionId
{
    [Celaneo1AppDelegate getSingleton].sessionId = sessionId;
}

- (void) handleElementEnd_nb_articles_page:(NSString*)nArticles
{
    [Celaneo1AppDelegate getSingleton].articlesPerPage = [nArticles intValue];
#ifdef DEBUG
    [Celaneo1AppDelegate getSingleton].articlesPerPage = 5;
#endif
}

- (void) handleElementEnd_nb_articles:(NSString*)nArticles
{
    self.articleCount = [nArticles intValue];
}

- (void) handleElementEnd_dirigeant:(NSString*)value
{
    dirigeant = [value intValue] == 1;
}


- (void) handleElementStart_pre_page:(NSDictionary*) attributes
{
    self.prepageFerme = [[attributes objectForKey:@"ferme"] intValue] == 1;
}

- (void) handleElementEnd_pre_page:(NSString*)value
{
    self.prepageContent = value;
}

#pragma mark Application XML Parsing - articles

- (void) handleElementStart_articles:(NSDictionary*) attributes
{
    self.articles = [NSMutableArray arrayWithCapacity:20];
}

- (void) handleElementStart_article:(NSDictionary*) attributes
{
    self.article = [Article articleWithId:[[attributes objectForKey:@"id"] intValue]];
}

- (void) handleElementStart_commentaires:(NSDictionary*) attributes
{
    self.commentaires = [NSMutableArray arrayWithCapacity:1];
}

- (void) handleElementEnd_commentaires
{
    self.article.commentaires = commentaires;
    self.commentaires = nil;
}

- (void) handleElementStart_commentaire:(NSDictionary*) attributes
{
    self.commentaire = [Commentaire commentaireWithId:[[attributes objectForKey:@"id"] intValue]];
}

- (void) handleElementEnd_commentaire
{
    [self.commentaires addObject:commentaire];
    self.commentaire = nil;
}

- (void) handleElementEnd_prenom:(NSString*)value
{
    self.commentaire.prenom = value;
}

- (void) handleElementEnd_date_depot:(NSString*)value
{
    self.commentaire.date = value;
}

- (void) handleElementEnd_article
{
    if (self.article != nil) {
        [articles addObject:article];
        
        self.article = nil;
    }
}

- (void) handleElementStart_thematique:(NSDictionary*) attributes
{
    if (self.article != nil) {
        self.article.thematiqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementEnd_thematique:(NSString*)value
{
    if (self.article != nil) {
        self.article.thematique = value;
    } else {	
        self.category.name = value;
        [thematiques addObject:category];
    }
}

- (void) handleElementStart_rubrique_libelle:(NSDictionary*) attributes
{
    // WORKAROUND
    
    if (self.article != nil) {
        self.article.rubriqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementStart_rubrique:(NSDictionary*) attributes
{
    if (self.article != nil) {
        self.article.rubriqueId = [[attributes objectForKey:@"id"] intValue];
    } else {
        category = [[Category alloc] init];
        category.categoryId = [[attributes objectForKey:@"id"] intValue];
    }
}

- (void) handleElementEnd_rubrique_libelle:(NSString*)value
{
    // WORKAROUND
    
    if (self.article != nil) {
        self.article.rubrique = value;
    } else {
        self.category.name = value;
        [rubriques addObject:category];
    }
}

- (void) handleElementEnd_rubrique:(NSString*)value
{
    if (self.article != nil) {
        self.article.rubrique = value;
    } else {
        self.category.name = value;
        [rubriques addObject:category];
    }
}

- (void) handleElementEnd_nb_jaime:(NSString*)value
{
    nb_jaime = [value intValue];
    self.article.nb_jaime = [value intValue];
}

- (void) handleElementEnd_nb_commentaires:(NSString*)value
{
    nb_commentaire = [value intValue];
    self.article.nb_commentaires = [value intValue];
}

- (void) handleElementEnd_nb_commentaire:(NSString*)value
{
    nb_commentaire = [value intValue];
    self.article.nb_commentaires = [value intValue];
}


- (void) handleElementEnd_titre:(NSString*)value
{
    self.article.titre = value;
}

- (void) handleElementStart_type:(NSDictionary*) attributes
{
    self.article.type = [[attributes objectForKey:@"id"] intValue];
}

- (void) handleElementEnd_date_affichee:(NSString*)value
{
    self.article.dateAffichee = value;
}

- (void) handleElementEnd_date_modification:(NSString*)value
{
    self.article.hash = value;
}

- (void) handleElementEnd_url_media:(NSString*)value
{
    self.article.urlMedia = value;
}

- (void) handleElementEnd_accroche:(NSString*)value
{
    self.article.accroche = value;
}

- (void) handleElementEnd_contenu:(NSString*)value
{
    if (self.commentaire) {
        self.commentaire.contenu = value;
    } else {
        self.article.contenu = value;
    }
}

- (void) handleElementEnd_url_image:(NSString*)value
{
    self.article.urlImage = value;
}

- (void) handleElementEnd_favoris:(NSString*)value
{
    self.article.favoris = [value intValue] == 1;
}

#pragma mark Application XML Parsing - thematiques

- (void) handleElementStart_thematiques:(NSDictionary*) attributes
{
    self.thematiques = [NSMutableArray arrayWithCapacity:20];
}

// (void) handleElementStart_thematique:(NSDictionary*) attributes (see above)


// (void) handleElementEnd_thematique:(NSString*) value (see above)

#pragma mark Application XML Parsing - rubriques

- (void) handleElementStart_rubriques:(NSDictionary*) attributes
{
    self.rubriques = [NSMutableArray arrayWithCapacity:20];
}

// (void) handleElementStart_rubrique:(NSDictionary*) attributes (see above)

// (void) handleElementEnd_rubrique:(NSString*) value (see above)

- (void) handleElementEnd_prefere:(NSString*)value
{
    self.category.prefere = [value intValue] == 1;
}

- (NSError*) endDocument
{
    if (erreurCode == 0 && erreurDescription == nil && fnac && [[Celaneo1AppDelegate getSingleton].sessionId length] > 0) {
#ifdef DEBUG
        [self dump];
#endif
        return nil;
    } else {
        NSError* erreur = [NSError errorWithDomain:@"FNAC" code:erreurCode userInfo:
                           [NSDictionary dictionaryWithObject:erreurDescription forKey:NSLocalizedDescriptionKey]];
        
        return erreur;
    }
}

- (void) dealloc
{
    [articles release];
    [thematiques release];
    [rubriques release];
    [magasins release];
    
    [article release];
    [magasin release];
    
    [commentaire release];
    [commentaires release];
    [prepageContent release];
    [super dealloc];
}

@end
