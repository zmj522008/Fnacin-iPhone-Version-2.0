//
//  Commentaire.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Commentaire : NSObject {
    int commentaireId;
    
    NSString* prenom;
    NSString* date;
    NSString* contenu;
}
@property (nonatomic, assign) int commentaireId;
@property (nonatomic, retain) NSString *prenom;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *contenu;

+ (Commentaire*) commentaireWithId:(int)commentaireId;

@end
