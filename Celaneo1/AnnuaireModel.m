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
@property (nonatomic, retain) NSString* currentFilter;
@end

NSString *const AnnuaireModelDataStatusChange = @"AnnuaireModelDataStatusChange";

@implementation AnnuaireModel

@synthesize filteredData;
@synthesize filtered;
@synthesize indexShown;
@synthesize fetching;
@synthesize syncing;
@synthesize currentFilter;

- (id) init
{
    return self;
} 

- (void) doPostNotification:(id) notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];
}

- (void) postStatusChange
{
    [self performSelectorOnMainThread:@selector(doPostNotification:) withObject:AnnuaireModelDataStatusChange waitUntilDone:NO];
}

- (void) fetchData
{
    @synchronized(self) {
        fetching = YES;
        [self postStatusChange];
        
        NSLog(@"Updating Model...");
        AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
        
        NSArray* personnes = [db getPersonnesShort];
        [self performSelectorOnMainThread:@selector(updateData:) withObject:personnes waitUntilDone:YES];

        NSLog(@"Done Updating Model... (%d)", dataCount);
        fetching = NO;
        [self postStatusChange];
    }
}

- (void) updateData:(NSArray*)personnes
{
    data = [[self partitionObjects:personnes collationStringSelector:@selector(nom)] retain];
    dataCount = [personnes count];
}

- (void)setSyncing:(BOOL)s
{
    syncing = s;
    [self postStatusChange];
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

- (Personne*) personneAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* dataSource;
    if (filtered) {
        dataSource = filteredData;
    } else {
        dataSource = [data objectAtIndex:indexPath.section];
    }
    // In case of sync problem after a fetchData (should not happen)
    if (dataSource.count > indexPath.row) {
        Personne* p = [dataSource objectAtIndex:indexPath.row];
        return p;
    } else {
        NSLog(@"Arrgggg requesting invalid indexPath!");
        return nil;
    }
}

- (Personne*) detailPersonneAtIndexPath:(NSIndexPath*)indexPath
{
    Personne* p = [self personneAtIndexPath:indexPath];
    AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
    return [db getPersonneFull:p.sId];
}

- (UITableViewCell *)loadingCell
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    if (fetching) {
        cell.textLabel.text = @"Annuaire en cours d'optimisation";
        cell.detailTextLabel.text = @"Veuillez patienter quelques instants";
    } else if (syncing) {
        cell.textLabel.text = @"Annuaire en cours de chargement";
        cell.detailTextLabel.text = @"1 minute avec WIFI ou 5 minutes sans";
    } else {
        cell.textLabel.text = @"Erreur de communication";
        cell.detailTextLabel.text = @"Merci de redémarrer l'application";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataCount == 0) {
        return [self loadingCell];
    }
    static NSString *CellId = @"RubriqueCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
    }
    Personne* p = [self personneAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    if (phoneShown) {
        int idx = 0;
        cell.textLabel.text = p.telephone_fixe; // fallback
        for (NSString* s in [p.phoneDigits componentsSeparatedByString:@" "]) {
            if ([s rangeOfString:currentFilter].location != NSNotFound && p.telephones.count > idx) {
                cell.textLabel.text = [[p.telephones objectAtIndex:idx] phone];
                break;
            }
            idx++;
        }
        cell.detailTextLabel.text = [p.prenom stringByAppendingFormat:@" %@", p.nom];
    } else {
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = [p.prenom stringByAppendingFormat:@" %@", p.nom];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (filtered) {
        return [filteredData count];
    } else if (dataCount == 0) {
        return 1;
    } else {
        return [[data objectAtIndex:section] count];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (filtered) {
        return 1;
    } else if (dataCount == 0) {
        return 1;
    } else {
        return [[[CollateAndSearch currentCollation] sectionTitles] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (filtered) {
        int c = [filteredData count];
        if (c == 0) {
            return @"pas de résultat";
        } else if (c == 1) {
            return @"1 personne trouvée";
        } else {
            return [NSString stringWithFormat:@"%d personnes trouvées", c];
        }
    } else if (dataCount == 0) {
        return nil;
    } else {
        return [[[CollateAndSearch currentCollation] sectionTitles] objectAtIndex:section];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (dataCount > 0 && !filtered && section == [self numberOfSectionsInTableView:tableView] - 1) {
        if (syncing) {
            return [NSString stringWithFormat:@"Mise à jour en cours"];
        } else {
            AnnuaireDB* db = [Celaneo1AppDelegate getSingleton].annuaireDb;
            NSString* date = [db getDataDate];
            return [NSString stringWithFormat:@"Mise à jour: %@", date];
        }
    } else {
        return nil;
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

#pragma mark filter
- (void) filterStartingWith:(NSArray*)source to:(NSMutableArray*)result with:(NSString*)searchTerm
{
    for (Personne* p in source) {
        if ([[p.nom uppercaseString] hasPrefix:searchTerm] || [[p.prenom uppercaseString] hasPrefix:searchTerm]) {
            [result addObject:p];
        }
    }
}

- (void) filterContainsAfterFirstChar:(NSArray*)source to:(NSMutableArray*)result with:(NSString*)searchTerm
{
    for (Personne* p in source) {
        if ([[[p.nom uppercaseString] substringFromIndex:1] rangeOfString:searchTerm].location != NSNotFound
            || [[[p.prenom uppercaseString] substringFromIndex:1] rangeOfString:searchTerm].location != NSNotFound) {
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
        if (currentFilter.length == 0 || [searchTerm rangeOfString:currentFilter].location != 0) {
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
    self.currentFilter = searchTerm;
}

- (void) dealloc
{
    [currentFilter release];
    [super dealloc];
}
@end
