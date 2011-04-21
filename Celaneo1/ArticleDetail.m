//
//  ArticleDetail.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"

#import "ArticleDetail.h"
#import "MediaPlayer.h"
#import "CommentaireCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArticleDetail
@synthesize article;
@synthesize table;
@synthesize jaime;
@synthesize commentaire;
@synthesize favoris;
@synthesize detailCell;
@synthesize contentCell;
@synthesize postCommentCell;
@synthesize rubrique;
@synthesize thematique;
@synthesize titre;
@synthesize vignette;
@synthesize mediaButton;
@synthesize imageRequest;
@synthesize content;
@synthesize commentPrompt;
@synthesize commentText;
@synthesize commentSend;
@synthesize commentaireRequest;
@synthesize favorisRequest;
@synthesize jaimeRequest;

- (void)dealloc
{
    [article release];
    [table release];
    [jaime release];
    [commentaire release];
    [favoris release];
    [detailCell release];
    [contentCell release];
    [postCommentCell release];
    [rubrique release];
    [thematique release];
    [titre release];
    [vignette release];
    [mediaButton release];
    [imageRequest release];
    [content release];
    [commentPrompt release];
    [commentText release];
    [commentSend release];
    [commentaireRequest cancel];
    commentaireRequest.delegate = nil;
    [commentaireRequest release];
    [favorisRequest cancel];
    favorisRequest.delegate = nil;
    [favorisRequest release];
    [jaimeRequest cancel];
    jaimeRequest.delegate = nil;
    [jaimeRequest release];
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
    
    detailCellHeight = detailCell.bounds.size.height + (article.type != ARTICLE_TYPE_TEXT ? mediaButton.bounds.size.height + 2 : 0);
    postCommentaireCellHeight = self.commentPrompt.frame.size.height + self.commentPrompt.frame.origin.y + 5;
    contentCellHeight = self.contentCell.bounds.size.height;
    
// Comment border radius magic
    [commentText.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [commentText.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [commentText.layer setBorderWidth: 1.0];
    [commentText.layer setCornerRadius:8.0f];
    [commentText.layer setMasksToBounds:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.table = nil;
    self.jaime = nil;
    self.commentaire = nil;
    self.favoris = nil;
    self.detailCell = nil;
    self.contentCell = nil;
    self.postCommentCell = nil;
    self.rubrique = nil;
    self.thematique = nil;
    self.titre = nil;
    self.vignette = nil;
    self.mediaButton = nil;
    self.content = nil;
    self.commentPrompt = nil;
    self.commentText = nil;
    self.commentSend = nil;
    [commentaireRequest cancel];
    [jaimeRequest cancel];
    [favorisRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (NSString *)pageName
{
    return @"/article/detail";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ArticleDetailSection_count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == ArticleDetailSection_Comments ? [article.commentaires count] : 1;
}

- (UITableViewCell *)commentaireCell:(int) row
{
    static NSString *CellId = @"CommentaireCell";
    
    CommentaireCell *cell = (CommentaireCell*) [table dequeueReusableCellWithIdentifier:CellId];
    
    if (cell == nil) {
        cell = (CommentaireCell*) [self loadCellFromNib:CellId];
        NSAssert2([CellId compare:cell.reuseIdentifier] == 0, @"Cell has invalid identifier, actual: %@, expected: %@", cell.reuseIdentifier, CellId);
    }
    Commentaire* com = [article.commentaires objectAtIndex:row];
    [cell updateWithCommentaire:com];
    cell.frame = CGRectMake(0, 0, cell.frame.size.width, [CommentaireCell heightForCommentaire:com]);
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ArticleDetailSection_Details:
            return detailCell;
        case ArticleDetailSection_Content:
            return contentCell;
        case ArticleDetailSection_PostComment:
            return postCommentCell;
        case ArticleDetailSection_Comments:
            return [self commentaireCell:indexPath.row];
    }
    return nil;
}


#pragma mark -
#pragma mark Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
	keyboardIsShowing = YES;
	[self resizeViewControllerToFitScreen];
}

- (void)keyboardWillHide:(NSNotification *)note {
	keyboardIsShowing = NO;
	keyboardBounds = CGRectMake(0, 0, 0, 0);
	[self resizeViewControllerToFitScreen];
}

- (void)resizeViewControllerToFitScreen {
	// Needs adjustment for portrait orientation!
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	CGRect frame = self.table.frame;
	frame.size.height = applicationFrame.size.height - 80;
    
	if (keyboardIsShowing)
		frame.size.height -= keyboardBounds.size.height - 40;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	self.table.frame = frame;
    if (keyboardIsShowing) {
        [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArticleDetailSection_PostComment] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
	[UIView commitAnimations];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ArticleDetailSection_Details:
            return detailCellHeight;
        case ArticleDetailSection_Content:
            return contentCellHeight;
        case ArticleDetailSection_PostComment:
            return postCommentaireCellHeight;
        case ArticleDetailSection_Comments:
            return [CommentaireCell heightForCommentaire:[article.commentaires objectAtIndex:indexPath.row]];
    }
    return 0;
}

#pragma mark update view with server content
- (void) updateDetail
{
    self.titre.text = article.titre;
    
    int x = 5;
    
    CGSize rubriqueSize = [article.rubrique sizeWithFont:self.rubrique.titleLabel.font];
    rubriqueSize.width += 10;
    rubriqueSize.height = self.rubrique.frame.size.height;
    self.rubrique.frame = CGRectMake(x, rubrique.frame.origin.y, rubriqueSize.width, rubriqueSize.height);
    self.rubrique.bounds = CGRectMake(0, 0, rubriqueSize.width, rubriqueSize.height);
    x += rubriqueSize.width;
    [self.rubrique setTitle:article.rubrique forState:UIControlStateNormal];
    
    
    x += 5; // margin
    
    CGSize thematiqueSize = [article.thematique sizeWithFont:self.thematique.titleLabel.font];
    thematiqueSize.width += 5;
    thematiqueSize.height = self.thematique.frame.size.height;
    self.thematique.frame = CGRectMake(x, thematique.frame.origin.y, thematiqueSize.width, thematiqueSize.height);
    [self.thematique setTitle:article.thematique forState:UIControlStateNormal];
    
    self.vignette.hidden = NO;
    
    self.imageRequest.delegate = nil;
    [self.imageRequest cancel];
    self.imageRequest = [article createImageRequestForViewSize:self.vignette.bounds.size];
    
    self.vignette.image = [UIImage imageNamed:@"loading_detail.jpg"];
    self.imageRequest.delegate = self;
    [self.imageRequest start];
    
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

- (void) updateContent
{
    self.content.frame = CGRectMake(0, 0, self.content.frame.size.width, 1);
    [self.content loadHTMLString:[@"<style>body { margin: 8px; padding: 0; font: 12px helvetica; }</style>" stringByAppendingString:article.contenu] baseURL:nil];
    self.content.delegate = self;
}

- (void) updateToolbar
{
    jaime.title = [NSString stringWithFormat:@"J'aime (%d)", article.nb_jaime];
    commentaire.title = [NSString stringWithFormat:@"Réactions (%d)", article.nb_commentaires];
    if (!article.favoris) {
        favoris.title = @"Ajout Dossier";
    } else {
        favoris.title = @"(Dossiers)";
    }
}

- (void) update
{
#ifdef DEBUG
    article.nb_commentaires = 2;
    Commentaire* com1 = [[Commentaire alloc] init];
    com1.date = @"date1";
    com1.prenom = @"prenom";
    com1.contenu = @"Fnac Billetterie : concerts, festivals, théâtre, expositions, sports, parcs... plus de 50 000 événements par an.";
    Commentaire* com2 = [[Commentaire alloc] init];
    com2.date = @"date2";
    com2.prenom = @"prenom";
    com2.contenu = @"Fnac Billetterie : concerts, festivals, théâtre, expositions, sports, parcs... plus de 50 000 événements par an.";

    article.commentaires = [NSArray arrayWithObjects:com1, com2, nil];
#endif
    [self updateDetail];
    [self updateContent];
    [self updateToolbar];
    [self.table reloadData];
}

#pragma mark web view layout

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView == content) {
        [content sizeToFit];
        contentCellHeight = content.bounds.size.height;
        [table reloadData];
    }
}

#pragma mark image loading delegates

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request == imageRequest) {
        self.vignette.image = [UIImage imageWithData:request.responseData];
        if ([request.responseData length]) {
            NSLog(@"image empty: %@", [request.url absoluteURL]);
        }
#ifdef DEBUG_IMAGE
        UILabel* label = [[UILabel alloc] initWithFrame:self.vignette.bounds];
        [self.vignette addSubview:label];
        label.text = [NSString stringWithFormat:@"[%d]:%d", request.responseStatusCode,
                      [request.responseData length]];
        [label release];
#endif
        
        self.imageRequest = nil;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.vignette.hidden = NO;
    self.vignette.image = [UIImage imageNamed:@"loading_detail.jpg"];
#ifdef DEBUG_IMAGE
    UILabel* label = [[UILabel alloc] initWithFrame:self.vignette.bounds];
    [self.vignette addSubview:label];
    label.text = [request.error localizedDescription];
    NSLog(@"image %@ error: %@", [request.url absoluteString],[request.error localizedDescription]);
    [label release];
#endif
    
    self.imageRequest = nil;
}

#pragma mark cell actions

- (IBAction) mediaClick
{
    if (article.type != ARTICLE_TYPE_TEXT) {
        MediaPlayer* mediaPlayer = [[MediaPlayer alloc] initWithNibName:@"MediaPlayer" bundle:nil];
        mediaPlayer.article = article;
        
        [self.navigationController pushViewController:mediaPlayer animated:YES];   
    }
}

#pragma mark toolbar actions
- (IBAction) jaimeClick
{
    self.jaimeRequest = [[ServerRequest alloc] initJaimeWithArticleId:article.articleId];
    jaimeRequest.delegate = self;
    [jaimeRequest start];
}

- (IBAction) commentaireClick
{
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArticleDetailSection_PostComment] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction) favorisClick
{
    self.favorisRequest = [[ServerRequest alloc] initSetFavoris:YES withArticleId:article.articleId];
    favorisRequest.delegate = self;
    [favorisRequest start];
    
}

- (IBAction) toggleCommentaireView
{
    if (self.commentText.hidden) {
        self.commentText.hidden = NO;
        self.commentSend.hidden = NO;
        postCommentaireCellHeight = self.commentText.frame.size.height + self.commentText.frame.origin.y + 5;
    } else {
        self.commentText.hidden = YES;
        self.commentSend.hidden = YES;
        postCommentaireCellHeight = self.commentPrompt.frame.size.height + self.commentPrompt.frame.origin.y + 15;
    }
    [table beginUpdates];
    [table endUpdates];
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArticleDetailSection_PostComment] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark commentaire actions
- (IBAction) submitCommentaire
{
    self.commentaireRequest = [[ServerRequest alloc] initSendCommentaire:commentText.text withArticleId:article.articleId];
    commentaireRequest.delegate = self;
    [commentaireRequest start];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Keyboard button click
    [self submitCommentaire];
}

#pragma mark Handle server Response

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    if (favorisRequest == request) {
        NSLog(@"favoris");
        
        
//        UIGraphicsBeginImageContext(self.view.frame.size);
//        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
//        UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
//        imageView.alpha = 0.5f;
//        imageView.backgroundColor = [UIColor greenColor];
//        [self.view addSubview:imageView];

        //TODO Possibly apply gray bg during request
        UIView* gray = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
        gray.backgroundColor = [UIColor grayColor];
        gray.alpha = 0.5f;
        [self.view addSubview:gray];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
        [gray removeFromSuperview];

        [UIView setAnimationDelay:1.0];
        [UIView commitAnimations];
        
        article.favoris = YES;
        [self updateToolbar];
    } else if (jaimeRequest == request) {
        if (request.nb_jaime > article.nb_jaime) {
            article.nb_jaime = request.nb_jaime;
        }
        [self updateToolbar];
    } else if (commentaireRequest == request) {
        if (request.nb_commentaire > article.nb_commentaires) {
            article.nb_commentaires = request.nb_commentaire;
        }
        [self updateToolbar];
    } else {
        [super serverRequest:request didSucceedWithObject:result];
    }
}


@end
