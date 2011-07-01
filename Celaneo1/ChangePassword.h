//
//  ChangePassword.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseController.h"

@interface ChangePassword : BaseController {
    IBOutlet UITextField* password1;
    IBOutlet UITextField* password2;
    IBOutlet UILabel* warning;
    IBOutlet UIButton* submit;
    IBOutlet UIActivityIndicatorView* activity;
    
    ServerRequest* request;
    
}
@property (nonatomic, retain) IBOutlet UITextField *password1;
@property (nonatomic, retain) IBOutlet UITextField *password2;
@property (nonatomic, retain) IBOutlet UILabel *warning;
@property (nonatomic, retain) IBOutlet UIButton *submit;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, retain) ServerRequest *request;

- (IBAction) textChange:(id) sender;
- (IBAction) password1Return;
@end
