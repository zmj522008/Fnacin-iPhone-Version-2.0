//
//  annuaireDetail.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Personne.h"

@interface annuaireDetail : UITableViewController {
    Personne* personne;
}
@property (nonatomic, retain) Personne* personne;

@end
