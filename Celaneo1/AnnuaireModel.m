//
//  AnnuaireModel.m
//  Celaneo1
//
//  Created by Sebastien Chauvin on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnuaireModel.h"

#import "AnnuaireDB.h"
#import "Celaneo1AppDelegate.h"

#import "CollateAndSearch.h"
#import "Personne.h"

@interface AnnuaireModel()
- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector;
@property (nonatomic, retain) NSArray* filteredData;
@end

@implementation AnnuaireModel

@synthesize filteredData;
@synthesize filtered;
@synthesize indexShown;

- (id) init
{
    return self;
} 

- (void) fetchData
{
    @synchronized(self) {
        NSLog(@"Updating Model...");
        AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
        
        data = [[self partitionObjects:[db getPersonnesShort] collationStringSelector:@selector(nom)] retain];
        NSLog(@"Done Updating Model...");
    }
}

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector

{
    CollateAndSearch *collation = [CollateAndSearch currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"RubriqueCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
    }
    NSArray* dataSource;
    if (filtered) {
        dataSource = filteredData;
    } else {
        dataSource = [data objectAtIndex:indexPath.section];
    }
    Personne* p = [dataSource objectAtIndex:indexPath.row];
    if (filtered) {
        // TODO...
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    if (phoneShown) {
        cell.textLabel.text = p.phoneDigits;
        cell.detailTextLabel.text = [p.prenom stringByAppendingFormat:@" %@", p.nom];
    } else {
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = [p.prenom stringByAppendingFormat:@" %@", p.nom];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (filtered) {
        return [filteredData count];
    } else {
        return [[data objectAtIndex:section] count];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (filtered) {
        return 1;
    } else {
        return [[[CollateAndSearch currentCollation] sectionTitles] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (filtered) {
        return nil;
    } else {
        return [[[CollateAndSearch currentCollation] sectionTitles] objectAtIndex:section];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!indexShown) {
        return nil;
    } else {
        return [[CollateAndSearch currentCollation] sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (filtered) {
        return NSNotFound;
    } else {
        NSInteger section = [[CollateAndSearch currentCollation] sectionForSectionIndexTitleAtIndex:index];
        if(section == NSNotFound) { 
            [tableView setContentOffset:CGPointMake(0,0)];
        }
        return section;
    }
}

- (void) filterStartingWith:(NSArray*)source to:(NSMutableArray*)result with:(NSString*)searchTerm
{
    for (Personne* p in source) {
        if ([p.nom hasPrefix:searchTerm] || [p.prenom hasPrefix:searchTerm]) {
            [result addObject:p];
        }
    }
}

- (void) filterContainsAfterFirstChar:(NSArray*)source to:(NSMutableArray*)result with:(NSString*)searchTerm
{
    for (Personne* p in source) {
        if ([[p.nom substringFromIndex:1] rangeOfString:searchTerm].location != NSNotFound
            || [[p.prenom substringFromIndex:1] rangeOfString:searchTerm].location != NSNotFound) {
            [result addObject:p];
        }
    }
}


- (void) filterTelephone:(NSArray*)source to:(NSMutableArray*)result with:(NSString*)searchTerm
{
    for (Personne* p in source) {
        if ([p.phoneDigits rangeOfString:searchTerm].location != NSNotFound) {
            [result addObject:p];
        }
    }
}

- (void) setFilter:(NSString*)f
{
    NSString* searchTerm = [f uppercaseString];
    if (f == nil || f.length == 0) {
        self.filteredData = nil;
        phoneShown = NO;
    } else {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 +()"];
        BOOL phoneSearch = ([searchTerm rangeOfCharacterFromSet:numberCharSet].length > 0);
        phoneShown = phoneSearch;

        NSMutableArray* result = [NSMutableArray arrayWithCapacity:1];
        if (1 || filter == nil || [searchTerm rangeOfString:filter].location == NSNotFound) {
            if (phoneShown) {
                for (NSArray* array in data) {
                    [self filterTelephone:array to:result with:searchTerm];
                }
            } else {
                for (NSArray* array in data) {
                    [self filterStartingWith:array to:result with:searchTerm];
                }
                for (NSArray* array in data) {
                    [self filterContainsAfterFirstChar:array to:result with:searchTerm];
                }
            }
        } else {
            if (phoneShown) {
                [self filterTelephone:filteredData to:result with:searchTerm];
            } else {
                [self filterStartingWith:filteredData to:result with:searchTerm];
                [self filterContainsAfterFirstChar:filteredData to:result with:searchTerm];
            }
        }
        self.filteredData = result;
    }
    [filter release];
    filter = [searchTerm retain];
}

- (void) dealloc
{
    [filter release];
    [super dealloc];
}
@end
