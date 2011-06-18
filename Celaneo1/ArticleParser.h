//
//  ArticleParser.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerRequest.h"

#import "BaseParser.h"

#import "Article.h"
#import "Magasin.h"
#import "Category.h"
#import "Commentaire.h"

#define TYPE_THEMATIQUE 0
#define TYPE_RUBRIQUE 1
#define TYPE_MAGASIN 2

@interface ArticleParser : BaseParser <ApplicationParser> {
    Article* article;
    Magasin* magasin;
    Category* category;
    Commentaire* commentaire;
    
    BOOL dirigeant;
    
    int currentId;
    int articleCount;
    
    int nb_jaime;
    int nb_commentaire;
    
    NSMutableArray* articles;
    NSMutableArray* thematiques;
    NSMutableArray* rubriques;
    NSMutableArray* magasins;
    
    NSMutableArray* commentaires;
    
    NSString* prepageContent;
    BOOL prepageFerme;
}
@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, retain) NSArray *thematiques;
@property (nonatomic, retain) NSArray *rubriques;
@property (nonatomic, retain) NSArray *magasins;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) Magasin *magasin;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSMutableArray *commentaires;
@property (nonatomic, assign) int articleCount;
@property (nonatomic, assign) int nb_jaime;
@property (nonatomic, retain) Commentaire *commentaire;
@property (nonatomic, assign) int nb_commentaire;
@property (nonatomic, assign) BOOL dirigeant;
@property (nonatomic, retain) NSString *prepageContent;
@property (nonatomic, assign, getter=isPrepageFerme) BOOL prepageFerme;

@end
