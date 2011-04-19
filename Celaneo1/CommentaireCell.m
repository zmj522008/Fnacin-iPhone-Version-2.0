//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentaireCell.h"
#import "ASIDownloadCache.h"

#undef DEBUG_IMAGE

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
}


- (void) prepareForReuse {
}

+ (float)heightForCommentaire:(Commentaire *)commentaire
{
    return [commentaire.contenu sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] forWidth:280 lineBreakMode:UILineBreakModeWordWrap].height + 100;
}
@end
