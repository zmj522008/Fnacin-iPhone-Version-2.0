//
//  AppListController.h
//  Celaneo1
//
//  Created by Camille Benhamou on 03/10/12.
//
//

#import <UIKit/UIKit.h>

@interface AppListController : UIViewController
{
    NSArray *_dataToShow;
    NSArray *_iconArray;
    NSArray *_linkArray;
    IBOutlet UITableView* table;

}

@property (nonatomic, retain) IBOutlet UITableView *table;
@end