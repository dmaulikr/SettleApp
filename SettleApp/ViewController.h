//
//  ViewController.h
//  SettleApp
//
//  Created by Tobias Lundgren on 2014-09-08.
//  Copyright (c) 2014 Tobias Lundgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HomeModelProtocol>

@property (weak, nonatomic) IBOutlet UITableView *listTableView;


// Register
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtSurname;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmpassword;

// create ibaction for insert button:
- (IBAction)registerUser:(id)sender;



// Login
- (IBAction)loginAction:(id)sender;
@property (nonatomic, retain) NSArray *arrayLogin;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
//-(IBAction) nextPressed: (id) sender;
//@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;

// Add debt
@property (weak, nonatomic) IBOutlet UITextField *debtUsername;
@property (weak, nonatomic) IBOutlet UITextField *debtDebt;
- (IBAction)createDebt:(id)sender;




@end
