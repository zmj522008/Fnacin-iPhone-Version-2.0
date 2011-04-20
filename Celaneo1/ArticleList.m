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

#define TAG_ITEM_A_LA_UNE 101
#define TAG_ITEM_PREFERE 102
#define TAG_ITEM_PODCAST 103
#define TAG_ITEM_RUBRIQUES 104
#define TAG_ITEM_DOSSIERS 105

@implementation ArticleList
@synthesize articles;
@synthesize table;
@synthesize favoris;
@synthesize prefere;
@synthesize podcast;
@synthesize rubriqueId;
@synthesize thematiqueId;
@synthesize magasinId;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    int tag = self.navigationController.tabBarItem.tag | self.tabBarItem.tag;
    switch (tag) {
        case TAG_ITEM_A_LA_UNE:
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
        case TAG_ITEM_DOSSIERS:
            favoris = YES;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Editer" action:@selector(showDelete)]];
             break;
        default:
            break;
    }
    self.articles = [NSMutableArray arrayWithCapacity:20];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.table = nil;
}


- (void)dealloc
{
    [table release];
    [articles release];
    [super dealloc];
}


- (NSString*) pageName
{
    int tag = self.navigationController.tabBarItem.tag | self.tabBarItem.tag;
    switch (tag) {
        case TAG_ITEM_A_LA_UNE:
            return @"/a_la_une";
            break;
        case TAG_ITEM_PREFERE:
            return @"/prefere/list";
            break;
        case TAG_ITEM_PODCAST:
            return @"/podcast";
            break;
        case TAG_ITEM_RUBRIQUES:
            return @"/rubriques/list";
            break;
        case TAG_ITEM_DOSSIERS:
            return @"/dossiers";
            break;
        default:
            break;
    }
    return @"/autre2";
}

- (void) refresh {
    [articles removeAllObjects];
    [table reloadData];
    [super refresh];
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

- (void) updateList:(ServerRequest*)request onlineContent:(BOOL)onlineContent
{
    int requestCount = request.articles.count;
    if (requestCount > 0 && requestCount >= articles.count - request.limitStart) {
        [table beginUpdates];
        
        NSMutableArray* reloadRows = [NSMutableArray arrayWithCapacity:requestCount];
        for (int i = 0; i < requestCount && i < articles.count - request.limitStart; i++) {
            if (![[request.articles objectAtIndex:i] isEqual:[articles objectAtIndex:i + request.limitStart]]) {
                [reloadRows addObject:[NSIndexPath indexPathForRow:i + request.limitStart inSection:0]];
            }
        }
        [table reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
        NSMutableArray* insertRows = [NSMutableArray arrayWithCapacity:requestCount];
        for (int i = articles.count - request.limitStart; i < requestCount; i++) {
            [insertRows addObject:[NSIndexPath indexPathForRow:i + request.limitStart inSection:0]];            
        }
        [table insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationNone];
        
        [articles removeObjectsInRange:NSMakeRange(request.limitStart, articles.count - request.limitStart)];
        [articles addObjectsFromArray:request.articles];
        [table endUpdates];
    } else {
        [table reloadData];
    }
    
    
    hasMore = [articles count] < request.articleCount;
    
    if (onlineContent) {
        if (prefere && articles.count == 0 && ![Celaneo1AppDelegate getSingleton].prefereEditDone) {
            [self.navigationController pushViewController:
                [[PrefereEditController alloc] initWithNibName:@"PrefereEdit" bundle:nil] animated:NO];
        }
    }
}

- (ServerRequest*) doCreateListRequestWithStartingIndex:(int)startIndex
{
    ServerRequest* request = [[ServerRequest alloc] initArticle];
    
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
    int articlesPerPage = [Celaneo1AppDelegate getSingleton].articlesPerPage;
    if (articlesPerPage == 0) {
        articlesPerPage = 13;
    }
    request.limitStart = startIndex;
    request.limitEnd = startIndex + articlesPerPage;

    // Disable caching for pagination
    if (resetCache || startIndex > 0) {
        [request resetCache];
        resetCache = NO;
    }
    return request;
}

- (ServerRequest*) createListRequest
{
    return [self doCreateListRequestWithStartingIndex:0];
}
#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellId = @"ArticleCell";
        
        ArticleCell *cell = (ArticleCell*) [tableView dequeueReusableCellWithIdentifier:CellId];
        
        if (cell == nil) {
            cell = (ArticleCell*) [self loadCellFromNib:CellId];
            NSAssert2([CellId compare:cell.reuseIdentifier] == 0, @"Cell has invalid identifier, actual: %@, expected: %@", cell.reuseIdentifier, CellId);
        }
        [cell updateWithArticle:[articles objectAtIndex:indexPath.row] usingImageLoadingQueue:self.imageLoadingQueue];
        return cell;
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
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? articles.count : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return hasMore ? 2 : 1;
}

#pragma mark table view delegate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? table.rowHeight : 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        ServerRequest* request = [self doCreateListRequestWithStartingIndex:articles.count];
        self.onlineRequest = request;
        onlineRequest.delegate = self;
        [onlineRequest start];
    }
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ServerRequest* changeRequest = 
            [[ServerRequest alloc] initSetFavoris:NO withArticleId:[[articles objectAtIndex:indexPath.row] articleId]];
        [changeRequest start];
        
        // Update article list: remove item
        self.resetCache = YES;
        [self refresh];
        
        [articles removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark article cell actions

- (ArticleCell*) articleCell:(id)sender
{
    UIView* v = sender;
    while (v != nil) {
        v = v.superview;
        if ([v isKindOfClass:[ArticleCell class]]) {
            return (ArticleCell*) v;
        }
    }
    return nil;
}

- (Article*) articleFromSender:(id)sender
{
    return [articles objectAtIndex:[table indexPathForCell:[self articleCell:sender]].row];
}

- (IBAction) cellMediaClick:(id)sender
{
    Article* article = [self articleFromSender:sender];
    if (article.type == ARTICLE_TYPE_TEXT) {
        [self cellContentClick:sender];
    } else {
        MediaPlayer* mediaPlayer = [[MediaPlayer alloc] initWithNibName:@"MediaPlayer" bundle:nil];
        mediaPlayer.article = article;
        
        [self.navigationController pushViewController:mediaPlayer animated:YES];   
    }
}

- (IBAction) cellContentClick:(id)sender
{
    ArticleDetail* detail = [[ArticleDetail alloc] initWithNibName:@"ArticleDetail" bundle:nil];
    detail.article = [self articleFromSender:sender];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

- (IBAction) cellRubriqueClick:(id)sender
{
    self.tabBarController.selectedIndex = 3;
    UINavigationController* rubriqueNavigationController = (UINavigationController*) self.tabBarController.selectedViewController;
    ArticleList* articleListController;
    int rId = [self articleFromSender:sender].rubriqueId;
    if ([rubriqueNavigationController.topViewController isKindOfClass:[ArticleList class]]) {
        articleListController = (ArticleList*) rubriqueNavigationController.topViewController;
        articleListController.rubriqueId = rId;
        [articleListController refresh];
    } else {
        articleListController = [[ArticleList alloc] initWithNibName:@"ArticleList" bundle:nil];
        articleListController.rubriqueId = rId;
        [rubriqueNavigationController pushViewController:articleListController animated:YES];
    }
}
- (IBAction) cellThematiqueClick:(id)sender
{
    ArticleList* articleListController = [[ArticleList alloc] initWithNibName:@"ArticleList" bundle:nil];
    articleListController.thematiqueId = [self articleFromSender:sender].thematiqueId;
    articleListController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:articleListController animated:YES];
   
}
- (IBAction) cellFavorisClick:(id)sender
{
    
}

@end
