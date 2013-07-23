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
@synthesize commentToggle;
@synthesize commentCount;
@synthesize commentText;
@synthesize commentSend;
@synthesize commentCancel;
@synthesize commentaireRequest;
@synthesize favorisRequest;
@synthesize jaimeRequest;
@synthesize activityIndicator;
@synthesize toolbar;
@synthesize fnaccomCell;

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
    [commentToggle release];
    [commentCount release];
    [commentText release];
    [commentSend release];
    [commentCancel release];
    [commentaireRequest cancel];
    commentaireRequest.delegate = nil;
    [commentaireRequest release];
    [favorisRequest cancel];
    favorisRequest.delegate = nil;
    [favorisRequest release];
    [jaimeRequest cancel];
    jaimeRequest.delegate = nil;
    [jaimeRequest release];
    [activityIndicator release];
    [toolbar release];
    [fnaccomCell release];
    
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
    
    [content.scrollView setScrollEnabled:YES];
   
    [[[content subviews] lastObject] setScrollEnabled:YES];
    
    detailCellHeight = detailCell.bounds.size.height + (article.type != ARTICLE_TYPE_TEXT ? mediaButton.bounds.size.height + 2 : 0);
    postCommentaireCellHeight = self.commentCount.frame.size.height + self.commentCount.frame.origin.y + 5;
    contentCellHeight = self.contentCell.bounds.size.height;
    
// Comment border radius magic
    [commentText.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [commentText.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [commentText.layer setBorderWidth: 1.0];
    [commentText.layer setCornerRadius:8.0f];
    [commentText.layer setMasksToBounds:YES];

    activityIndicator.frame = CGRectMake((toolbar.bounds.size.width - 20) / 2, 
                                         (toolbar.bounds.size.height - 20) / 2, 20, 20);
    
   UIImage* buttonBack = [[UIImage imageNamed:@"btn.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    [commentSend setBackgroundImage:buttonBack forState:UIControlStateNormal];
    [commentToggle setBackgroundImage:buttonBack forState:UIControlStateNormal];
    [commentCancel setBackgroundImage:buttonBack forState:UIControlStateNormal];
   
    //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"actions.png"] /*initWithTitle:@"icon AC"*/ style:UIBarButtonItemStyleDone target:self action:@selector(push:) ] autorelease];
    
   UIButton *bt=[UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(0, 0, 60, 30)];
    [bt setImage:[UIImage imageNamed:@"actions.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem=leftButton;
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
    self.commentToggle = nil;
    self.commentCount = nil;
    self.commentText = nil;
    self.commentSend = nil;  
    self.commentCancel = nil;
    self.activityIndicator = nil;
    self.toolbar = nil;
    self.fnaccomCell = nil;
    
    [commentaireRequest cancel];
    [jaimeRequest cancel];
    [favorisRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
    self.content.dataDetectorTypes=UIDataDetectorTypeAll;

}
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *requestUrl = [[request URL] retain];
    if (([[requestUrl scheme] isEqualToString:@"http"] || [[requestUrl scheme] isEqualToString:@"https"] || [[requestUrl scheme] isEqualToString:@"mailto"]) && (navigationType==UIWebViewNavigationTypeLinkClicked)) {
        NSURL *newURL = [[NSURL alloc] initWithString: [[[request URL] absoluteString] stringByReplacingOccurrencesOfString: @"allo:" withString: @"tel:"]];
        [requestUrl release];
        return ! [[UIApplication sharedApplication] openURL: [newURL autorelease]];
    }
    [requestUrl release];
    return YES;
}
 /*-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
   if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        [self updateContent2];
       [self.table reloadData];
    }else [self updateContent];
}*/

-(void)viewDidLayoutSubviews{
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(currentOrientation)||UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ){
            [self updateContentLandscape];
        NSLog(@"Landscape view now");
        
    }else if(UIDeviceOrientationIsPortrait(currentOrientation)||UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        [self updateContent];
        NSLog(@"Portrait View now");
    }
    [self.table reloadData];
}

- (NSString *)pageName
{
    return [@"INTRAFNAC - ARTICLE - " stringByAppendingString:article.titre];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[GANTracker sharedTracker] trackEvent:@"INTRAFNAC" action:@"ARTICLE" label:article.titre value:nil withError:nil];

    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    commentText.text = nil;
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
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (ServerRequest*) createListRequest
{
    ServerRequest* request = [[ArticleParser alloc] getRequestArticle];

    [request setParameter:@"id" withIntValue:article.articleId];
    [request setParameter:@"commentaire" withIntValue:1];

    return request;
}

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;
{
    for (Article* a in parsed.articles) {
        if (a.articleId == article.articleId) {
            self.article = a;
            [self update];
            break;
        }
    }
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
//    cell.frame = CGRectMake(0, 0, cell.frame.size.width, [CommentaireCell heightForCommentaire:com]);
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ArticleDetailSection_Details:
            return detailCell;
        case ArticleDetailSection_Content:
            return contentCell;
        case ArticleDetailSection_FnacCom:
            return fnaccomCell;
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
        case ArticleDetailSection_FnacCom:
            return article.urlFnacCom.length > 0 ? fnaccomCell.bounds.size.height : 0;
        case ArticleDetailSection_PostComment:
            return 0; // No Comment 08/01/2012
//            return postCommentaireCellHeight;
        case ArticleDetailSection_Comments:
            return 0;
//            return [CommentaireCell heightForCommentaire:[article.commentaires objectAtIndex:indexPath.row]];
    }
    return 0;
}

#pragma mark update view with server content
- (void) updateDetail
{
    self.titre.text = article.titre;
    self.date.text = article.dateAffichee;

    int x = self.rubrique.frame.origin.x;
    //NSLog(@"%d",x);
    
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
    
    self.fnaccomCell.hidden = article.urlFnacCom.length <= 0;
}

- (void) updateContent
{
    CGRect screenFrame=[[UIScreen mainScreen] applicationFrame];
     UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(currentOrientation)||UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.content.frame = CGRectMake(self.content.frame.origin.x,0, screenFrame.size.height, 1);
    }else if(UIDeviceOrientationIsPortrait(currentOrientation)||UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        self.content.frame = CGRectMake(self.content.frame.origin.x, 0, screenFrame.size.width, 1);

    }
    NSMutableString* contentString = [NSMutableString stringWithCapacity:100];
    [contentString appendString:@"<style>body { margin: 8px; padding: 0; font: 12px helvetica; }</style>"];
    if (article.accroche) {
        [contentString appendString:article.accroche];
    }
    if (article.contenu) {
        [contentString appendString:article.contenu];
    }
    [self.content loadHTMLString:contentString baseURL:nil];
    self.content.delegate = self;
}
- (void) updateContentLandscape
{
    CGRect screen=[[UIScreen mainScreen] applicationFrame];
    self.content.frame = CGRectMake(self.content.frame.origin.x, 0, screen.size.height, 1);
    //self.content.frame = CGRectMake(self.content.frame.origin.x, 0, screen.size.height, 1);
    NSMutableString* contentString = [NSMutableString stringWithCapacity:100];
    [contentString appendString:@"<style>body { margin: 8px; padding: 0; font: 12px helvetica; }</style>"];
    if (article.accroche) {
        [contentString appendString:article.accroche];
    }
    if (article.contenu) {
        [contentString appendString:article.contenu];
    }
    [self.content loadHTMLString:contentString baseURL:nil];
    self.content.delegate = self;
}

- (void) updateToolbar
{
    jaime.title = [NSString stringWithFormat:@"(%d)", article.nb_jaime];
    commentaire.title = [NSString stringWithFormat:@"Réactions (%d)", article.nb_commentaires];
    if (!article.favoris) {
        favoris.title = @"Ajout préférés";
    } else {
        favoris.title = @"(Préférés)";
    }
}

- (void) update
{
    [self updateDetail];
    [self updateContent];
    [self updateToolbar];
    BOOL hasCommentaires = article.commentaires.count > 0;
    hasCommentaires = NO; // No comments 08/01/2012
    commentCount.hidden = !hasCommentaires;
    if (hasCommentaires) {
        commentCount.text = [NSString stringWithFormat:@"(%d commentaires actuellement)", article.commentaires.count];
    }
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
#ifdef DEBUG
        if ([request.responseData length]) {
            NSLog(@"image empty: %@", [request.url absoluteURL]);
        }
#endif
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
    [label release];
#endif
#ifdef DEBUG
    NSLog(@"image %@ error: %@", [request.url absoluteString],[request.error localizedDescription]);
#endif
    
    self.imageRequest = nil;
}

#pragma mark cell actions

- (IBAction) mediaClick
{
    if (article.type != ARTICLE_TYPE_TEXT) {
        NSString* nibName = @"MediaPlayer";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = [nibName stringByAppendingString:@"~iPad"];
        }
        
        MediaPlayer* mediaPlayer = [[MediaPlayer alloc] initWithNibName:nibName bundle:nil];
        mediaPlayer.article = article;
        
        [self.navigationController pushViewController:mediaPlayer animated:YES];
    }
}

- (IBAction)fnaccomClick
{
    NSLog(@"Opening fnaccom link: %@", article.urlFnacCom);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.urlFnacCom]];
}

- (IBAction)push:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle: @""
                                  delegate:self
                                  cancelButtonTitle:@"Retour"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"J'aime", @"Ajouter à mes préférés", nil];
    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"ilike.png"] forState:UIControlStateNormal];
     [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"Jpreferes_off.png"] forState:UIControlStateNormal];
    [actionSheet showInView:self.view];
      [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"bouton 1");
            [self.jaimeRequest cancel];
            self.jaimeRequest = [[ArticleParser alloc] getRequestJaimeWithArticleId:article.articleId];
            jaimeRequest.delegate = self;
            [jaimeRequest start];
            [toolbar addSubview:activityIndicator];
            break;
        case 1:
            NSLog(@"bouton 2");
            if (!article.favoris) {
                [self.favorisRequest cancel];
                self.favorisRequest = [[ArticleParser alloc] getRequestSetFavoris:YES withArticleId:article.articleId];
                favorisRequest.delegate = self;
                [favorisRequest start];
                
                [toolbar addSubview:activityIndicator];
            } else {
                UIAlertView *feedback = [[UIAlertView alloc] initWithTitle:@"Article"
                                                                   message:@"Cet article est déjà dans vos dossiers."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [feedback show];
                [feedback release];
                
            }
            break;
        default:
            break;
       }
}

#pragma mark toolbar actions
- (IBAction) jaimeClick
{     self.jaimeRequest = [[ArticleParser alloc] getRequestJaimeWithArticleId:article.articleId];
    jaimeRequest.delegate = self;
    [jaimeRequest start];
    [toolbar addSubview:activityIndicator];
}

- (IBAction) commentaireClick
{
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArticleDetailSection_PostComment] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction) favorisClick
{
    if (!article.favoris) {
        [self.favorisRequest cancel];
        self.favorisRequest = [[ArticleParser alloc] getRequestSetFavoris:YES withArticleId:article.articleId];
        favorisRequest.delegate = self;
        [favorisRequest start];
        
        [toolbar addSubview:activityIndicator];
    } else {
        UIAlertView *feedback = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                           message:@"Cet article est déjà dans vos dossiers." 
                                                          delegate:nil 
                                                 cancelButtonTitle:@"OK" 
                                                 otherButtonTitles:nil];
        [feedback show];
        [feedback release];

    }
}

- (void) commentaireViewChange:(BOOL)visible
{
    if (visible) {
        self.commentText.hidden = NO;
        self.commentSend.hidden = NO;
        self.commentCancel.hidden = NO;
        self.commentCount.hidden = YES;
        self.commentToggle.hidden = YES;
        postCommentaireCellHeight = self.commentText.frame.size.height + self.commentText.frame.origin.y + 5;
        [self.commentText becomeFirstResponder];
    } else {
        self.commentText.hidden = YES;
        self.commentSend.hidden = YES;
        self.commentToggle.hidden = NO;
        self.commentCancel.hidden = YES;
        BOOL hasCommentaires = article.commentaires.count > 0;
        commentCount.hidden = !hasCommentaires;
        postCommentaireCellHeight = self.commentCount.frame.size.height + self.commentCount.frame.origin.y + 15;
        [self.commentText resignFirstResponder];
    }
    [table beginUpdates];
    [table endUpdates];
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArticleDetailSection_PostComment] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction) toggleCommentaireView
{
    [self commentaireViewChange:self.commentText.hidden];
}

#pragma mark commentaire actions
- (IBAction) submitCommentaire
{
    [self.commentaireRequest cancel];
    self.commentaireRequest = [[ArticleParser alloc] getRequestSendCommentaire:commentText.text withArticleId:article.articleId];
    commentaireRequest.delegate = self;
    [commentaireRequest start];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([commentText.text length] > 0) {
        // Keyboard button click
//        [self submitCommentaire];
    }
}

#pragma mark indicator

- (void) hideIndicatorIfNecessary
{
    if (favorisRequest == nil && jaimeRequest == nil) {
        [activityIndicator removeFromSuperview];
    }
}
#pragma mark Handle server Response

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    ArticleParser* parsed = (ArticleParser*) result;
    
    NSString* message;
    if (favorisRequest == request) {
        article.favoris = YES;
        [self updateToolbar];
        self.favorisRequest = nil;
        message = @"Article ajouté à vos préférés.";
    } else if (jaimeRequest == request) {
        if (parsed.nb_jaime > article.nb_jaime) {
            article.nb_jaime = parsed.nb_jaime;
        }
        [self updateToolbar];
        self.jaimeRequest = nil;
        message = @"Article marqué.";
    } else if (commentaireRequest == request) {
        if (parsed.nb_commentaire > article.nb_commentaires) {
            article.nb_commentaires = parsed.nb_commentaire;
        }
        [self updateToolbar];
        self.commentaireRequest = nil;
        message = @"Commentaire envoyé.";
        [self commentaireViewChange:NO];
        self.commentText.text = nil;
        self.resetCache = YES;
        [self refresh];
    } else {
        [super serverRequest:request didSucceedWithObject:result];
        return;
    }
    UIAlertView *feedback = [[UIAlertView alloc] initWithTitle:@"Article" 
                                                       message:message 
                                                      delegate:nil 
                                             cancelButtonTitle:@"OK" 
                                             otherButtonTitles:nil];
    [feedback show];
    [feedback release];

    [self hideIndicatorIfNecessary];
}

- (void)serverRequest:(ServerRequest *)request didFailWithError:(NSError *)error
{
    if (favorisRequest == request) {
        self.favorisRequest = nil;
    } else if (jaimeRequest == request) {
        self.jaimeRequest = nil;
    } else if (commentaireRequest == request) {
        self.commentaireRequest = nil;
    }
    [self hideIndicatorIfNecessary];
    [super serverRequest:request didFailWithError:error];
}

@end
