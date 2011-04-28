//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentaireCell.h"

#undef DEBUG_IMAGE

#define MARGIN_TEXT 20
#define CELL_EXTRA 100

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
    CGSize boundingSize = CGSizeMake(280, CGFLOAT_MAX);

    int h = [commentaire.contenu sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap].height;

    text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, 
               text.frame.size.width, h + MARGIN_TEXT );
    self.frame = CGRectMake(0, 0,
                            self.frame.size.width, h + CELL_EXTRA + MARGIN_TEXT);
}


- (void) prepareForReuse {
}

+ (float)heightForCommentaire:(Commentaire *)commentaire
{
    return [commentaire.contenu sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] forWidth:280 lineBreakMode:UILineBreakModeWordWrap].height + CELL_EXTRA + MARGIN_TEXT;
}
@end
