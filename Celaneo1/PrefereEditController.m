//
//  SecondViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GANTracker.h"

#import "PrefereEditController.h"
#import "ServerRequest.h"
#import "ArticleList.h"
#import "Celaneo1AppDelegate.h"

@implementation PrefereEditController
@synthesize rubriques;
@synthesize selectedRubriques;
@synthesize table;
@synthesize prefereUpdateRequest;

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

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.table = nil;
    [prefereUpdateRequest cancel];
    self.prefereUpdateRequest = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    resetCache = YES;

    [super viewWillAppear:animated];
}

- (NSString *)pageName
{
    return @"/prefere/edit";
}

- (void) updateDoneButton
{
    if (selectedRubriques.count != 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:[self navButton:NAVBUTTON_PLAIN withTitle:@"Ok" action:@selector(doneButton)]];
        self.navigationItem.hidesBackButton = YES;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    selectedRubriques = [[NSMutableIndexSet alloc] init];
    self.navigationItem.hidesBackButton = YES;
    [self updateDoneButton];
}

- (void)dealloc
{
    [rubriques release];
    [selectedRubriques release];
    [table release];
    [prefereUpdateRequest cancel];
    [prefereUpdateRequest release];
    [super dealloc];
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request parser:(ArticleParser*)parsed onlineContent:(BOOL)onlineContent;
{    
    self.rubriques = parsed.rubriques;
    for (Category* cat in self.rubriques) {
        if (cat.prefere) {
            [selectedRubriques addIndex:cat.categoryId];
        } else {
            [selectedRubriques removeIndex:cat.categoryId];
        }
    }
    [table reloadData];
}

- (ServerRequest*) createListRequest
{
    return [[ArticleParser alloc] getRequestGetPreferencesForType:TYPE_RUBRIQUE];
}

#pragma mark navigation actions
- (void) doneButton
{
    if ([selectedRubriques count] == 0) {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Préféré" 
                                                            message:@"Veuillez sélectionner au moins une rubrique"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [errorView show];
        [errorView release];
    } else {
        [Celaneo1AppDelegate getSingleton].prefereEditDone = YES;

        ServerRequest* serverRequest = [[ArticleParser alloc] getRequestSetPreferences:selectedRubriques forType:TYPE_RUBRIQUE];
        serverRequest.delegate = self;
        [self.prefereUpdateRequest cancel];
        self.prefereUpdateRequest.delegate = nil;
        self.prefereUpdateRequest = serverRequest;
        [serverRequest start];
    }
}

- (void) serverRequest:(ServerRequest*)request didSucceedWithObject:(id)result
{
    if (request == prefereUpdateRequest) {
        self.prefereUpdateRequest = nil;
        ArticleList* articleList = (ArticleList*) [self.navigationController.viewControllers objectAtIndex:0];
        articleList.resetCache = YES;
        [articleList refresh];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [super serverRequest:request didSucceedWithObject:result];
    }
}

#pragma mark table view datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"PrefereEditCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    Category* rubrique  = [rubriques objectAtIndex:indexPath.row];

    cell.textLabel.text = rubrique.name;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];

    UIView* checkView = [[UIImageView alloc] initWithImage:
                          [UIImage imageNamed:
                           [selectedRubriques containsIndex:rubrique.categoryId] 
                                    ? @"checkbox_checked.png"
                                             : @"checkbox_unchecked.png"]];
    cell.accessoryView = checkView;
    [checkView release];
    cell.editing = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rubriques.count;
}

#pragma mark table view delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category* rubrique  = [rubriques objectAtIndex:indexPath.row];
    if ([selectedRubriques containsIndex:rubrique.categoryId]) {
        [selectedRubriques removeIndex:rubrique.categoryId];
    } else {
        [selectedRubriques addIndex:rubrique.categoryId];
    }
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self updateDoneButton];
}

@end
