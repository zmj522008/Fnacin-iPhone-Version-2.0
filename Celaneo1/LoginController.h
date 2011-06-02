//
//  LoginPageController.h
//  Celaneo1
//
//  Created by Sebastien Chauvin on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"

#import "BaseController.h"

enum {
    LoginAuthMode,
    LoginForgMode,
    LoginSentMode
};

@interface LoginController : BaseController <UIAlertViewDelegate> {
    IBOutlet UITextField* email;
    IBOutlet UITextField* password;
    IBOutlet UIButton* debugButton;
    IBOutlet UIView* emailLabel;
    IBOutlet UIView* passwordLabel;
    IBOutlet UIView* passwordRecoveryLabel;

    IBOutlet UIView*   entryBackground;

    /** 3 screens:
     * auth: auth screen email+pwd
     * forg: forgotten pwd screen pwd
     * sent: screen after forgotten pwd sent
     */
    IBOutlet UIButton* authSubmitButton;
    IBOutlet UIButton* authForgottenPasswordButton;
    IBOutlet UIButton* forgSubmitButton;
    IBOutlet UIButton* forgCancelButton;
    IBOutlet UIButton* sentCancelButton;
    
    ServerRequest* request;
    
    IBOutlet UIActivityIndicatorView* activity;
    
    int mode;
}

@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *debugButton;
@property (nonatomic, retain) ServerRequest* request;

@property (nonatomic, retain) IBOutlet UIView *emailLabel;
@property (nonatomic, retain) IBOutlet UIView *passwordLabel;
@property (nonatomic, retain) IBOutlet UIView *passwordRecoveryLabel;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activity;

@property (nonatomic, retain) IBOutlet UIView *entryBackground;
@property (nonatomic, retain) IBOutlet UIButton *authSubmitButton;
@property (nonatomic, retain) IBOutlet UIButton *authForgottenPasswordButton;
@property (nonatomic, retain) IBOutlet UIButton *forgSubmitButton;
@property (nonatomic, retain) IBOutlet UIButton *forgCancelButton;
@property (nonatomic, retain) IBOutlet UIButton *sentCancelButton;


- (IBAction) authSubmit;
- (IBAction) authForgottenPassword;
- (IBAction) forgSubmit;
- (IBAction) forgCancel;
- (IBAction) sentCancel;

- (IBAction) passwordReturn;
- (IBAction) emailReturn;
- (IBAction) onChange;

- (IBAction) debugBypassLog;

- (void) switchToMode:(int) m;

@end
