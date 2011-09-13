//
//  Prepage.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface Prepage : BaseController <UIWebViewDelegate> {
    IBOutlet UIWebView* content;
    IBOutlet UIButton* continuer;
    IBOutlet UINavigationItem* item;
    
    NSString* prepageContent;
    BOOL ferme;
}
@property (nonatomic, retain) IBOutlet UIWebView *content;
@property (nonatomic, retain) IBOutlet UIButton *continuer;
@property (nonatomic, retain) NSString *prepageContent;
@property (nonatomic, assign, getter=isFerme) BOOL ferme;
@property (nonatomic, retain) IBOutlet UINavigationItem *item;

- (IBAction) continuerClick;

@end
