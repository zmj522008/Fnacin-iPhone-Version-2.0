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
@synthesize favorisButton;
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
    [favorisButton release];
    [imageLoadingQueue release];
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
    self.favorisButton = nil;

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
    [self.rubrique setTitle:article.rubrique forState:UIControlStateNormal];
    [self.thematique setTitle:article.thematique forState:UIControlStateNormal];
    self.titre.text = article.titre;
    self.date.text = article.dateAffichee;
    [self.accroche loadHTMLString:article.accroche baseURL:nil];

    NSString* urlString = [article.urlImage stringByAppendingFormat:@"&max_width=%d&max_height=%d", 
                           self.vignette.bounds.size.width, self.vignette.bounds.size.height];
    urlString = @"http://i.imgur.com/VUCyt.jpg";
    imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    imageRequest.downloadCache = [ASIDownloadCache sharedCache];
    imageRequest.delegate = self;
    [imageRequest start];
    jaimeText.text = [NSString stringWithFormat:@"j aime (%d)", article.articleId];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request == imageRequest) {
        self.vignette.image = [UIImage imageWithData:request.responseData];
        imageRequest = nil;
    }
}

#pragma mark actions

- (IBAction) mediaClick
{
    [delegate articlePlayMediaUrl:article.urlMedia withType:article.type];
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
