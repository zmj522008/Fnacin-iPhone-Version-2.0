//
//  ArticleCell.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleCellController.h"


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
// todo async load    self.vignette
    jaimeText.text = [NSString stringWithFormat:@"j aime (%d)", article.articleId];
}

@end
