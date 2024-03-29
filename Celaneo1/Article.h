//
//  Article.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "ASIHTTPRequest.h"

#define ARTICLE_TYPE_TEXT 1
#define ARTICLE_TYPE_VIDEO 2
#define ARTICLE_TYPE_AUDIO 3

@interface Article : NSObject <ModelObject> {
    int articleId;
    
    int rubriqueId;
    int thematiqueId;
    
    NSString* thematique;
    NSString* rubrique;
    int type;
    NSString* titre;
    NSString* dateAffichee;
    NSString* urlMedia;
    NSString* accroche;
    NSString* contenu;
    NSString* urlImage;
    NSString* urlFnacCom;
    BOOL favoris;
    
    NSArray* commentaires;
    int nb_commentaires;
    int nb_jaime;
    NSString* hash;
}

@property (nonatomic, assign) int articleId;
@property (nonatomic, assign) int rubriqueId;
@property (nonatomic, assign) int thematiqueId;
@property (nonatomic, retain) NSString *thematique;
@property (nonatomic, retain) NSString *rubrique;
@property (nonatomic, assign) int type;

@property (nonatomic, retain) NSString *titre;
@property (nonatomic, retain) NSString *dateAffichee;
@property (nonatomic, retain) NSString *urlMedia;
@property (nonatomic, retain) NSString *accroche;
@property (nonatomic, retain) NSString *contenu;
@property (nonatomic, retain) NSString *urlImage;
@property (nonatomic, assign, getter=isFavoris) BOOL favoris;
@property (nonatomic, retain) NSArray *commentaires;
@property (nonatomic, assign) int nb_jaime;
@property (nonatomic, assign) int nb_commentaires;
@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *urlFnacCom;

+ (Article*) articleWithId:(int)id;

- (ASIHTTPRequest*)createImageRequestForViewSize:(CGSize)size;

- (BOOL) isEqual:(id)article;

@end
