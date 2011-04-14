//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleCell.h"
#import "ASIDownloadCache.h"

@implementation ArticleCell

@synthesize rubrique;
@synthesize thematique;
@synthesize titre;
@synthesize date;
@synthesize accroche;
@synthesize vignette;
@synthesize mediaButton;
@synthesize jaimeIcon;
@synthesize jaimeText;
@synthesize reactionsIcon;
@synthesize reactionsText;
@synthesize favorisButton;
@synthesize detailAccessory;
@synthesize imageRequest;

- (void)dealloc
{
    [rubrique release];
    [thematique release];
    [titre release];
    [date release];
    [accroche release];
    [vignette release];
    [mediaButton release];
    [jaimeIcon release];
    [jaimeText release];
    [reactionsIcon release];
    [reactionsText release];
    [favorisButton release];
    [imageRequest cancel];
    [imageRequest release];
    [super dealloc];
}

- (void) updateWithArticle:(Article*) article usingImageLoadingQueue:(NSOperationQueue*)imageLoadingQueue
{
    self.titre.text = article.titre;
    

    int x = 5;
    
    CGSize rubriqueSize = [article.rubrique sizeWithFont:self.rubrique.titleLabel.font];
    rubriqueSize.width += 5;
    rubriqueSize.height = self.rubrique.frame.size.height;
    self.rubrique.frame = CGRectMake(x, rubrique.frame.origin.y, rubriqueSize.width, rubriqueSize.height);
    self.rubrique.bounds = CGRectMake(0, 0, rubriqueSize.width, rubriqueSize.height);
    x += rubriqueSize.width;
    [self.rubrique setTitle:article.rubrique forState:UIControlStateNormal];
    

    x += 5; // margin
    
    CGSize thematiqueSize = [article.thematique sizeWithFont:self.thematique.titleLabel.font];
    thematiqueSize.width += 15;
    thematiqueSize.height = self.thematique.frame.size.height;
    self.thematique.frame = CGRectMake(x, thematique.frame.origin.y, thematiqueSize.width, thematiqueSize.height);
    [self.thematique setTitle:article.thematique forState:UIControlStateNormal];

    self.date.text = article.dateAffichee;
    
    [self.accroche loadHTMLString:[@"<style>body { margin: 0; padding: 0; font-size: 12px; }</style>" stringByAppendingString:article.accroche] baseURL:nil];

    if (self.vignette.image == nil) {
        self.vignette.image = [UIImage imageNamed:@"loading_list.jpg"];
    }
    self.imageRequest = [article createImageRequestWithWidth:vignette.bounds.size.width 
                                                 withHeight:vignette.bounds.size.height 
                                                 toDelegate:self];
    [imageLoadingQueue addOperation:self.imageRequest];
    
    jaimeText.text = [NSString stringWithFormat:@"J'aime (%d)", article.nb_jaime];
    BOOL showCommentaires = article.nb_commentaires > 0;
    reactionsText.hidden = !showCommentaires;
    reactionsIcon.hidden = !showCommentaires;
    if (showCommentaires) {
        reactionsText.text = [NSString stringWithFormat:@"Réactions (%d)", article.nb_commentaires];
    }
    
    switch (article.type) {
        case ARTICLE_TYPE_TEXT:
            mediaButton.hidden = YES;
            break;
        case ARTICLE_TYPE_VIDEO:
            mediaButton.hidden = NO;
            mediaButton.text = @"➜ Lire la vidéo";
            break;
        case ARTICLE_TYPE_AUDIO:
            mediaButton.hidden = NO;
            mediaButton.text = @"➜ Écouter";
            break;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request == imageRequest) {
        self.vignette.image = [UIImage imageWithData:request.responseData];
        self.imageRequest = nil;
    }
}

- (void) prepareForReuse {
    [self.imageRequest cancel];
    self.imageRequest = nil;
    self.vignette.image = nil;
}
@end
