//
//  Personne.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Personne : NSObject {
    NSString* nom;
    NSString* prenom;
    NSString* telephone;
}
@property (nonatomic, retain) NSString *nom;
@property (nonatomic, retain) NSString *prenom;
@property (nonatomic, retain) NSString *telephone;

@end
