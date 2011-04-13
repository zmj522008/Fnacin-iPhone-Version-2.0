//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleCellController.h"
#import "ASIDownloadCache.h"

@implementation ArticleCellController

@synthesize article;
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
@synthesize delegate;
@synthesize imageLoadingQueue;
@synthesize imageRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [article release];
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
    [imageLoadingQueue release];
    [imageRequest cancel];
    [imageRequest release];
    delegate = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{   
    self.rubrique = nil;
    self.thematique = nil;
    self.titre = nil;
    self.date = nil;
    self.accroche = nil;
    self.vignette = nil;
    self.mediaButton = nil;
    self.jaimeIcon = nil;
    self.jaimeText = nil;
    self.reactionsIcon = nil;
    self.reactionsText = nil;
    self.favorisButton = nil;
    self.detailAccessory = nil;
    
    [imageRequest cancel];
    self.imageRequest = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) update
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
    
    [self.accroche loadHTMLString:article.accroche baseURL:nil];
    [self.accroche loadHTMLString:article.contenu baseURL:nil]; // DEBUG

    self.imageRequest = [article startImageRequestWithWidth:vignette.bounds.size.width 
                                            withHeight:vignette.bounds.size.height toDelegate:self];
    
    jaimeText.text = [NSString stringWithFormat:@"j aime (%d)", article.nb_jaime];
    BOOL showCommentaires = article.nb_commentaires > 0;
    reactionsText.hidden = !showCommentaires;
    reactionsIcon.hidden = !showCommentaires;
    if (showCommentaires) {
        reactionsText.text = [NSString stringWithFormat:@"Réactions (%d)", article.nb_commentaires];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request == imageRequest) {
        self.vignette.image = [UIImage imageWithData:request.responseData];
        self.imageRequest = nil;
    }
}

#pragma mark actions

- (IBAction) mediaClick
{
    [delegate article:article playMediaUrl:article.urlMedia withType:article.type];
}

- (IBAction) contentClick
{
    [delegate articleShowContent:article];
}

- (IBAction) rubriqueClick
{
    [delegate articleShowRubrique:article.rubriqueId];
}

- (IBAction) thematiqueClick
{
    [delegate articleShowThematique:article.thematiqueId];
}

- (IBAction) favorisClick
{
    [delegate article:article makeFavoris:!article.favoris];
}

@end
