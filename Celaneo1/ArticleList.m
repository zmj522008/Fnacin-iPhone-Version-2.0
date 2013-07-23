//
//  FirstViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleList.h"
#import "Celaneo1AppDelegate.h"
#import "MediaPlayer.h"
#import "PrefereEditController.h"
#import "ArticleDetail.h"
#import "GANTracker.h"
#import "RubriqueListController.h"
#import "ArticleCell.h"


#define TAG_ITEM_A_LA_UNE 101
#define TAG_ITEM_RUBRIQUES 102
#define TAG_ITEM_PODCAST 103
#define TAG_ITEM_PREFERE 104
#define TAG_ITEM_DOSSIERS 105

#define FIRST_ROW_IPAD 350
#define LOAD_MORE_HEIGHT 60

#define BASE_ACCROCHE_WIDTH 180
#define TITRE_WIDTH 302

#define kNewArticles @"newArticles"

// Handle all article lists

@implementation ArticleList
{
    PullToRefreshView *pull;
}
@synthesize articles;
@synthesize table;
@synthesize favoris;
@synthesize prefere;
@synthesize podcast;
@synthesize rubriqueId;
@synthesize thematiqueId;
@synthesize magasinId;
@synthesize loadAlert;
@synthesize loadIndocator;

@synthesize prefDictionary = _prefDictionary;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskLandscapeLeft;

    }else{
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.articles = [[NSMutableArray arrayWithCapacity:20] retain];

    // Return the token Id from Celaneo1AppDelegate
   NSData* ttId = [[Celaneo1AppDelegate getSingleton] tokenId];
    if (ttId!=NULL) {
        //Change the format of TokenID from data to string
        NSString* tt = [ttId description];
        //Delete the espace and special caracters
        tt = [tt stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"] ];
        tt = [tt stringByReplacingOccurrencesOfString:@" " withString:@""];
        //Envoyer the token Id to the DB
        ServerRequest* request = [[ArticleParser alloc] getRequestSendTokenId:tt];
        [request start];
    }
    /*else{
       UIAlertView *notifAlert= [[UIAlertView alloc] initWithTitle:@"Erreur"
                                              message:@"Notification désactivé"
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
        [notifAlert show];
    }*/
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self navButton:NAVBUTTON_ARROW_LEFT withTitle:@"Retour" action:@selector(back)]];
    }
   
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.table];
    [pull setDelegate:self];
    [self.table addSubview:pull];

}

- (void)viewDidAppear:(BOOL)animated {
   // [super refresh];
     
        //[loadAlert dismissWithClickedButtonIndex:0 animated:YES];


 }
-(void) positionArticle{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:@"content_row"] != nil && test == TRUE)
    {
        int rowToHighlight = [[userDefaults valueForKey:@"content_row"] intValue];
        
        NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:rowToHighlight inSection:0];
        @try
        {
            
            [table scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:NO];
            NSLog(@"PAS premier passage");
            if (favoris) {
                //[self refresh];
                //  [self cancelLoading];
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"premier passage");
            
        }
        test = FALSE;
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    //[self startLoading];
   // [articles removeAllObjects];
    //[super refresh];
    tag = self.navigationController.tabBarItem.tag | self.tabBarItem.tag;
    switch (tag) {
        case TAG_ITEM_A_LA_UNE:
            [self switchToDetail];
                break;
        case TAG_ITEM_PREFERE:
            prefere = YES;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Editer" action:@selector(editPrefere)]];
            
            
            break;
        case TAG_ITEM_PODCAST:
            podcast = YES;
            break;
        case TAG_ITEM_RUBRIQUES:

            break;
        case 0: // Work around for tabBarItem.tag not set properly ...
        case TAG_ITEM_DOSSIERS:            
            favoris = YES;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Editer" action:@selector(showDelete)]];
             break;
        default:
            break;
    }
    
    hasMore = NO;
    if (favoris) {
       // [self refresh];
        //[self cancelLoading];
    }

    //[super viewWillAppear:animated];
    [self positionArticle];
}


- (void) switchToDetail
{
   // [super refresh];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Thématiques" action:@selector(switchToList)]];
    UIImage* backImag= [UIImage imageNamed:@"btn_left.png"];
    self.navigationItem.leftBarButtonItem.image = backImag;
}

- (void) switchToList
{
    RubriqueListController *rubriqueListController = [[RubriqueListController alloc] initWithNibName:nil bundle:nil];

    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = nil;
   
  //  self.view.frame = CGRectMake(0, 200, 100,200);
    //[self.view addSubview:rubriqueListController.view];
    [self.navigationController pushViewController:rubriqueListController animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.table = nil;
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view Will Disappear");
    table.editing = NO;
   
}

- (void)dealloc
{
    [table release];
    [articles release];
    [super dealloc];
}


- (NSString*) pageName
{
     tag = self.navigationController.tabBarItem.tag | self.tabBarItem.tag;
    switch (tag) {
        case TAG_ITEM_A_LA_UNE:
            return @"INTRAFNAC - HOME";
            break;
        case TAG_ITEM_PREFERE:
            return @"INTRAFNAC - PREFERE";
            break;
        case TAG_ITEM_PODCAST:
            return @"INTRAFNAC - PODCAST";
            break;
        case TAG_ITEM_RUBRIQUES:
            return @"INTRAFNAC - THEMATIQUE";
            break;
        case 0: // Work around for tabBarItem.tag not set properly ...
        case TAG_ITEM_DOSSIERS:
            return @"INTRAFNAC - DOSSIERS";
            break;
        default:
            break;
    }
    return @"/autre2";
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    NSLog(@"pullToRefreshViewShouldRefresh---%@",view);
    [self reloadTableData];
}

- (void) refresh {
    NSLog(@"refresh--fonction-----");

    hasMore = NO;
   // [articles removeAllObjects];
    [table reloadData];
    NSData* ttId = [[Celaneo1AppDelegate getSingleton] tokenId];
    NSLog(@"TokenId in article:%@",ttId);
    if (ttId!=NULL) {
        NSString* tt = [ttId description];
        tt = [tt stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"] ];
        tt = [tt stringByReplacingOccurrencesOfString:@" " withString:@""];
        ServerRequest* request = [[ArticleParser alloc] getRequestSendTokenId:tt];
        [request start];
    }
   
    [super refresh];

}

-(void) reloadTableData
{
    NSLog(@"reload TableData--fonction-----");

    // call to reload your data
    [self refresh];
   [pull finishedLoading];
}

#pragma  mark tab bar button actions
- (void) showDelete
{
    [table setEditing:!table.editing animated:YES];
}

- (void) editPrefere
{
    [self.navigationController pushViewController:
     [[PrefereEditController alloc] initWithNibName:@"PrefereEdit" bundle:nil] animated:YES];    
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent
{
    NSLog(@"tableView:--onlineContent----");

    int requestCount = parsed.articles.count;
    if (requestCount > 0 && requestCount >= articles.count - parsed.limitStart) {
        
        if (tag == TAG_ITEM_A_LA_UNE && newArticles > 0)
        {
      //  [self readDataFromFile];
      //  newArticles = [[self.prefDictionary objectForKey:kNewArticles] intValue];
           // NSLog(@"notif Avant : %i", notif);
            //NSLog(@"parsed.articles.count : %i", parsed.articles.count);
            //NSLog(@"newArticles : %i", newArticles);
        notif = notif + parsed.articles.count - newArticles;
           // NSLog(@"notif Apres: %i", notif);
            

        [UIApplication sharedApplication].applicationIconBadgeNumber=notif;
        fldBadgeNumber.text = [NSString stringWithFormat:@"%i", [UIApplication sharedApplication].applicationIconBadgeNumber];
        }
        if (articles.count > 0) {
            [table beginUpdates];
            
            NSMutableArray* reloadRows = [NSMutableArray arrayWithCapacity:requestCount];
            for (int i = 0; i < requestCount && i < articles.count - parsed.limitStart; i++) {
                if (![[parsed.articles objectAtIndex:i] isEqual:[articles objectAtIndex:i + parsed.limitStart]]) {
                    [reloadRows addObject:[NSIndexPath indexPathForRow:i + parsed.limitStart inSection:0]];
                }
            }
            [table reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
            NSMutableArray* insertRows = [NSMutableArray arrayWithCapacity:requestCount];
            for (int i = articles.count - parsed.limitStart; i < requestCount; i++) {
                [insertRows addObject:[NSIndexPath indexPathForRow:i + parsed.limitStart inSection:0]];            
            }
            [table insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationNone];
            
            [articles removeObjectsInRange:NSMakeRange(parsed.limitStart, articles.count - parsed.limitStart)];
            [articles addObjectsFromArray:parsed.articles];
            [table endUpdates];
        } else {
            [articles addObjectsFromArray:parsed.articles];
            [table reloadData];
        }
    } else {
        /*
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        fldBadgeNumber.text = [NSString stringWithFormat:@"%i", [UIApplication sharedApplication].applicationIconBadgeNumber];
         */
        [table reloadData];
    }
    
    bool oldHasMore = hasMore;
    hasMore = [articles count] < parsed.articleCount;
    if (oldHasMore ^ hasMore) {
        [table reloadData];
    }
    if (onlineContent) {
        if (prefere && articles.count == 0 && ![Celaneo1AppDelegate getSingleton].prefereEditDone) {
            [self.navigationController pushViewController:
                [[PrefereEditController alloc] initWithNibName:@"PrefereEdit" bundle:nil] animated:NO];
        }
    }
}

- (ServerRequest*) doCreateListRequestWithStartingIndex:(int)startIndex
{
    NSLog(@"tableView:--doCreateListRequestWithStartingIndex----");

    ArticleParser* parser = [[[ArticleParser alloc] init] autorelease];
    ServerRequest* request = [parser getRequestArticle];
    NSLog(@"ArticleRequest:----:%@",request);
    if (favoris) {
        [request setParameter:@"favoris" withValue:@"1"];
    }
    if (prefere) {
        [request setParameter:@"prefere" withValue:@"1"];
    }
    if (podcast) {
        [request setParameter:@"podcast" withValue:@"1"];
    }
    if (thematiqueId > 0) {
        [request setParameter:@"thematique_id" withIntValue:thematiqueId];
    }
    if (rubriqueId > 0) {
        [request setParameter:@"rubrique_id" withIntValue:rubriqueId];
    }
    if (magasinId > 0) {
        [request setParameter:@"magasin_id" withIntValue:magasinId];
    }
    /*
     int articlesPerPage = [Celaneo1AppDelegate getSingleton].articlesPerPage;
    if (articlesPerPage == 0) {
        articlesPerPage = 13;
    }
    parser.limitStart = startIndex;
    parser.limitEnd = startIndex + articlesPerPage;    
    [request setParameter:@"limit_start" withIntValue:parser.limitStart];
    [request setParameter:@"limit_end" withIntValue:parser.limitEnd];
   
    // Disable caching for pagination
    if (resetCache || startIndex > 0) {
        NSLog(@"hahahhahahahahahha");
        [request resetCache];
    }
      */
    return request;
}

- (ServerRequest*) createListRequest
{
    NSLog(@"creat List Request In articleList");
    return [self doCreateListRequestWithStartingIndex:0];
}
#pragma mark table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (indexPath.section == 0) {
        if (articles.count==0) {
            NSLog(@"holy shit------");
        }
        if (favoris && articles.count == 0) {
            static NSString *CellId = @"InfoCell";

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            }
            cell.textLabel.text = @"Ajoutez des articles dans vos dossiers en cliquant \"Ajout Préférés\" sur une page Article.";
            cell.textLabel.font = [UIFont fontWithName:nil size:13];
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        } else {
            NSString *CellId = @"ArticleCell";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
                && indexPath.row == 0) {
                CellId = @"ArticleCellLarge";

            }
            ArticleCell *cell = (ArticleCell*) [tableView dequeueReusableCellWithIdentifier:CellId];

            if (cell == nil) {
                cell = (ArticleCell*) [self loadCellFromNib:CellId];
                NSAssert2([CellId compare:cell.reuseIdentifier] == 0, @"Cell has invalid identifier, actual: %@, expected: %@", cell.reuseIdentifier, CellId);
            }
            
            if (UIDeviceOrientationIsPortrait(currentDeviceOrientation)||UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) ){
                [cell updateWithArticle:[articles objectAtIndex:indexPath.row] usingImageLoadingQueue:self.imageLoadingQueue];
               
            }else if(UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)){
               [cell updateWithArticleLandscape:[articles objectAtIndex:indexPath.row] usingImageLoadingQueue:self.imageLoadingQueue];
                           }
            
            cell.delegate = self;

            return cell;
        }
    } else {
        static NSString *CellId = @"MoreCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }
        cell.textLabel.opaque = NO;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = @"Voir les articles plus anciens";
        cell.textLabel.font = [UIFont fontWithName:nil size:14];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more.jpg"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        cell.accessoryView = activity;
        [activity release];

        return cell;
    }
}

-(void)viewDidLayoutSubviews{
    
    UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIDeviceOrientationIsPortrait(currentDeviceOrientation)||UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) ){
        
        [self refresh];
        
    }else if(UIDeviceOrientationIsLandscape(currentDeviceOrientation)||UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)){
        
        [self refresh];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tableView:--numberOfRowsInSection----");
    NSLog(@"section----:%d",section);
    if (section == 0) {
        if (favoris && articles.count == 0) {
            return 0;
        }
        newArticles = articles.count;
        NSLog(@"newArticles : %i articles", newArticles);
        //[self cancelLoading];
        return articles.count;
    } else {
        return 1;
    }
}
-(void) startLoading{
    loadAlert= [[UIAlertView alloc] initWithTitle:@"Chargement..."
                                          message:nil
                                         delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:nil];
    [loadAlert show];
    
    loadIndocator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadIndocator.center = CGPointMake(loadAlert.bounds.size.width / 2, loadAlert.bounds.size.height - 50);
    [loadIndocator startAnimating];
    [loadAlert addSubview:loadIndocator];
}
-(void) cancelLoading{
    [loadAlert dismissWithClickedButtonIndex:0 animated:YES];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return hasMore ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return LOAD_MORE_HEIGHT;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
        && indexPath.row == 0) {

        return FIRST_ROW_IPAD;
    } else {
        return tableView.rowHeight;
    }
}

#pragma mark table view delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:---didSelectRowAtIndexPath---");
    if (indexPath.section == 1) {
       [(UIActivityIndicatorView*) [tableView cellForRowAtIndexPath:indexPath].accessoryView startAnimating];
        ServerRequest* request = [self doCreateListRequestWithStartingIndex:articles.count];
        self.onlineRequest = request;
        onlineRequest.delegate = self;
        [onlineRequest start];
       
    }

    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:---accessoryButtonTappedForRowWithIndexPath---");

}
#pragma mark article cell actions

- (ArticleCell*) articleCell:(id)sender
{
    UIView* v = sender;
    while (v != nil) {
        if ([v isKindOfClass:[ArticleCell class]]) {
            return (ArticleCell*) v;
        }
        v = v.superview;
    }
    return nil;
}

- (Article*) articleFromSender:(id)sender
{
    return [articles objectAtIndex:[table indexPathForCell:[self articleCell:sender]].row];
}



- (IBAction) cellMediaClick:(id)sender
{
    if (table.editing) {
        [self cellDeleteClick:sender];
    } else {
        Article* article = [self articleFromSender:sender];
        if (article.type == ARTICLE_TYPE_TEXT) {
            [self cellContentClick:sender];
        } else {
            NSString* nibName = @"MediaPlayer";
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                nibName = [nibName stringByAppendingString:@"~iPad"];
            }

            MediaPlayer* mediaPlayer = [[MediaPlayer alloc] initWithNibName:nibName bundle:nil];
            mediaPlayer.article = article;
            
            [self.navigationController pushViewController:mediaPlayer animated:YES];   
        }
    }
}

- (IBAction) cellContentClick:(id)sender
{
    NSLog(@"cellContentClicked--:%@",sender);
    if (table.editing) {
        [self cellDeleteClick:sender];
    } else {
        NSIndexPath *selectedRowPath = [[table indexPathsForVisibleRows] objectAtIndex:0];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:selectedRowPath.row forKey:@"content_row"];
        test = TRUE;

        NSString* nibName = @"ArticleDetail";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = [nibName stringByAppendingString:@"~iPad"];
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        fldBadgeNumber.text = [NSString stringWithFormat:@"%i", [UIApplication sharedApplication].applicationIconBadgeNumber];
        notif = 0;
        ArticleDetail* detail = [[ArticleDetail alloc] initWithNibName:nibName bundle:nil];
        detail.article = [self articleFromSender:sender];
        //detail.hidesBottomBarWhenPushed = YES;
       [self.navigationController pushViewController:detail animated:YES];
    }
}

- (IBAction) cellRubriqueClick:(id)sender
{
    if (table.editing) {
        [self cellDeleteClick:sender];
    } else {
        self.tabBarController.selectedIndex = 3;
        UINavigationController* rubriqueNavigationController = (UINavigationController*) self.tabBarController.selectedViewController;
        ArticleList* articleListController;
        int rId = [self articleFromSender:sender].rubriqueId;
        if ([rubriqueNavigationController.topViewController isKindOfClass:[ArticleList class]]) {
            articleListController = (ArticleList*) rubriqueNavigationController.topViewController;
            articleListController.rubriqueId = rId;
            [articleListController refresh];
        } else {
            NSString* nibName = @"ArticleList";
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                nibName = [nibName stringByAppendingString:@"~iPad"];
            }

            articleListController = [[ArticleList alloc] initWithNibName:nibName bundle:nil];
            articleListController.rubriqueId = rId;
            [rubriqueNavigationController pushViewController:articleListController animated:YES];
        }
    }
}

- (IBAction) cellThematiqueClick:(id)sender
{
    if (table.editing) {
        [self cellDeleteClick:sender];
    } else {
        NSString* nibName = @"ArticleList";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = [nibName stringByAppendingString:@"~iPad"];
        }
        
        ArticleList* articleListController = [[ArticleList alloc] initWithNibName:nibName bundle:nil];
        articleListController.thematiqueId = [self articleFromSender:sender].thematiqueId;
        articleListController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:articleListController animated:YES];
    }   
}

- (IBAction) cellFavorisClick:(id)sender
{
    
}


- (IBAction)cellDeleteClick:(id)sender
{
    int row = [table indexPathForCell:[self articleCell:sender]].row;
    ServerRequest* changeRequest =
    [[ArticleParser alloc] getRequestSetFavoris:NO withArticleId:[[articles objectAtIndex:row] articleId]];
    [changeRequest start];
    
    // Immediate feedback
    if ([articles count] > row) {
        [articles removeObjectAtIndex:row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    // Update article list: remove item
    self.resetCache = YES;
    [self refresh];
}


- (BOOL)readDataFromFile
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"preferences.plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization    propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!dictionary) {
        // Il y a eu une erreur, errorDesc est alloué
        NSLog(@"erreur : %@",errorDesc);
        // retourner NO éventuellement selon l'implémentation désirée
    }
    
    self.prefDictionary = [NSMutableDictionary dictionaryWithDictionary:[dictionary objectForKey:@"prefDictionary"]];
    return YES;
}

- (BOOL)writeDataToFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"preferences.plist"];
    
    NSString *errorDesc = nil;
    NSMutableDictionary *prefDict;
    // on remplace par les valeurs que l'on a modifiées
    prefDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObject:self.prefDictionary] forKeys:[NSArray arrayWithObject:@"prefDictionary"]];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:prefDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
    if (plistData) {
        BOOL returned = [plistData writeToFile:plistPath atomically:YES];
        return returned;
    }
    else {
        return NO;
    }
    return NO;
}


@end
