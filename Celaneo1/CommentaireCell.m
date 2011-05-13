//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentaireCell.h"

#undef DEBUG_IMAGE

#define MARGIN_TEXT 3
#define CELL_EXTRA 70

@interface CommentaireCell ()
+ (float)heightForCommentaireText:(Commentaire *)commentaire;
@end 

@implementation CommentaireCell
@synthesize date;
@synthesize prenom;
@synthesize text;


- (void)dealloc
{
    
    [date release];
    [prenom release];
    [text release];    
    [super dealloc];
}

- (void) updateWithCommentaire:(Commentaire *)commentaire
{
    date.text = commentaire.date;
    prenom.text = commentaire.prenom;
    text.text = commentaire.contenu;

    int h = [CommentaireCell heightForCommentaireText:commentaire];
    text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, 
               text.frame.size.width, h + MARGIN_TEXT );
    text.contentInset = UIEdgeInsetsMake(-8,-8,0,0);

//    self.bounds = CGRectMake(0, 0,
//                            self.frame.size.width, h + CELL_EXTRA + MARGIN_TEXT);
}


- (void) prepareForReuse {
}

+ (float)heightForCommentaireText:(Commentaire *)commentaire
{    
    CGSize boundingSize = CGSizeMake(280, CGFLOAT_MAX);
    
    int h = [commentaire.contenu sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap].height;
    return h;
}

+ (float)heightForCommentaire:(Commentaire *)commentaire
{
    return [CommentaireCell heightForCommentaireText:commentaire] + CELL_EXTRA + MARGIN_TEXT;
}
@end
