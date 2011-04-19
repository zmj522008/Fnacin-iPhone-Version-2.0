//
//  ArticleCell.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Commentaire.h"
#import "ASIHTTPRequest.h"

@interface CommentaireCell : UITableViewCell <ASIHTTPRequestDelegate, UIWebViewDelegate> {
    IBOutlet UILabel* date;
    IBOutlet UILabel* prenom;
    IBOutlet UITextView* text;
}
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *prenom;
@property (nonatomic, retain) IBOutlet UITextView *text;

- (void) updateWithCommentaire:(Commentaire*) commentaire;
+ (float) heightForCommentaire:(Commentaire*) commentaire;
@end
