//
//  SecondViewController.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefereEditController.h"
#import "ServerRequest.h"
#import "ArticleList.h"

@implementation PrefereEditController
@synthesize rubriques;
@synthesize selectedRubriques;
@synthesize table;

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
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    selectedRubriques = [[NSMutableIndexSet alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
}

- (void)dealloc
{
    [rubriques release];
    [selectedRubriques release];
    [table release];
    [super dealloc];
}

#pragma mark BaseController overrides

- (void) updateList:(ServerRequest*)request
{
    self.rubriques = request.rubriques;
    
    [table reloadData];
}

- (ServerRequest*) createListRequest
{
    return [[ServerRequest alloc] initGetRubriques];
}

#pragma mark navigation actions
- (void) doneButton
{
    // TODO send preferences and wait!
    
    [self.navigationController popViewControllerAnimated:YES];
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
    cell.accessoryView = [[UIImageView alloc] initWithImage:
                          [UIImage imageNamed:
                           [selectedRubriques containsIndex:rubrique.categoryId] 
                                    ? @"checkbox_checked.png"
                                             : @"checkbox_unchecked.png"]];
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
}

@end
