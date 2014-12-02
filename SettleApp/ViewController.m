//
//  ViewController.m
//  SettleApp
//
//  Created by Tobias Lundgren on 2014-09-08.
//  Copyright (c) 2014 Tobias Lundgren. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "HomeModel.h"
#import "AppDelegate.h"
#import "AppMainView.h"

#ifndef USER_CLASS
#import "users.h"
#include <memory>
#include <iostream>
#include <string>
#include <sstream>
#endif

static NSString *usernameSelf;
shared_ptr<Contact> string_to_contact(const std::string info, const double debt, unsigned char depth = 0);

@interface ViewController ()
{
    HomeModel *_homeModel;
    NSArray *_feedItems;
    IBOutlet UIView *contactView;
    
    IBOutlet UITableView *contactTableView;
    
}
@property (nonatomic) NSString *usernameSelf;
@property (nonatomic) std::shared_ptr<Self> SelfPtr;
@end

@implementation ViewController
@synthesize arrayLogin;
@synthesize userNameTextField, passwordTextField;
@synthesize nextField;

- (IBAction)userNameTxt:(SOTextField *)sender{}
- (IBAction)passwordTxt:(SOTextField *)sender{}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if ([textField isKindOfClass:[SOTextField class]])
        
        dispatch_async(dispatch_get_current_queue(),
                       ^ { [[(SOTextField *)textField nextField] becomeFirstResponder]; });
    
    return YES;
}

- (void) fillArray
{
    std::shared_ptr<vector<shared_ptr<User> > > fillVector = self.SelfPtr->get_debts();
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    
    
    if (self.SelfPtr) {
        
        if (fillVector->size() != 0) {
            for (auto & cont : *fillVector) {
                // Create cell
                NSString *cellIdentifier = @"ContactCell";
                UITableViewCell *myCell = [self->contactTableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                // Get references to labels of cell
                NSString *fullName = [NSString stringWithFormat:@"%s %s", cont->name().c_str(), cont->surname().c_str()];
                myCell.textLabel.text = fullName;
                
                
                /* HUR FAN GÖR MAN
                 if ([tableArray isEqual:nil]) {
                 NSLog(@"Lägger till Cell i tableArray");
                 [tableArray addObject: myCell];
                 
                 } */
                
            }
            _feedItems = tableArray;
            NSLog(@"Sätter _feedItems");
        }
    }
}
- (void) createSelf
{
    if (!self.SelfPtr ) {
        std::shared_ptr<Self> SelfPtr;
        NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyName&id=%@",usernameSelf];
        
        NSLog(@"Användare: %@", usernameSelf);
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *userResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        
        std::string userResultstd ([userResult UTF8String]);
        if (userResultstd[0] != ' ') {
            self.SelfPtr = string_to_self(userResultstd);
            self.SelfPtr->refresh();
            
        } else {
            self.SelfPtr = make_shared<Self> ("", "", "", 0,"");
            return;
        }
        NSLog(@"Vi skapar en Self :P");
        
        self.SelfPtr->refresh();
        totalDebts.text = [[NSString alloc] initWithFormat:@"%.0f", self.SelfPtr->total()]; // 0 decimals
        
        
        [self fillArray];
    }else {
        return;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Initialize the refresh control.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.backgroundColor = [UIColor lightGrayColor];
    //refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.listTableView addSubview:refreshControl];
    
    // Use the HomeModel to view cells **
    
    // Set this view controller object as the delegate and data source for the table view
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    // Create array object and assign it to _feedItems variable
    _feedItems = [[NSArray alloc] init];
    
    [self createSelf];
    // Create new HomeModel object and assign it to _homeModel variable
    //_homeModel = [[HomeModel alloc] init];
    
    // Set this view controller object as the delegate for the home model object
    //_homeModel.delegate = self;
    
    // Call the download items method of the home model object
    //[_homeModel downloadItems];
    
    // Set the Navigation Logo Image**
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    // if you need to resize the image to fit the UIImageView frame
    logoImage.contentMode = UIViewContentModeScaleAspectFit;
    // no extension name needed for image_name
    [logoImage setImage:[UIImage imageNamed:@"SettleApp.png"]];
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, logoImage.frame.size.width, logoImage.frame.size.height)];
    [logoView addSubview:logoImage];
    self.navigationItem.titleView = logoView;
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)itemsDownloaded:(NSArray *)items
{
    // This delegate method will get called when the items are finished downloading
    
    // Set the downloaded items to the array
    _feedItems = items;
    
    // Reload the table view
    [self.listTableView reloadData];
}

#pragma mark Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of feed items (initially 0)
    return _feedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve cell
    NSString *cellIdentifier = @"BasicCell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Get the user to be shown
    Userc *item = _feedItems[indexPath.row];
    // Get references to labels of cell
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", item.name, item.surname];
    myCell.textLabel.text = fullName;
    
    return myCell;
}

// Dismiss keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// Insert to Database function ***************************

// Register user
- (IBAction)registerUser:(id)sender
{
    // create string contains url address for php file, the file name is phpFile.php, it receives parameter :name
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?username=%@&email=%@&name=%@&surname=%@&password=%@", _txtUsername.text, _txtEmail.text, _txtName.text, _txtSurname.text, _txtPassword.text];
    
    // to execute php code
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", strResult);
}

// Create Debt
- (IBAction)createDebt:(id)sender
{
    std::shared_ptr<vector<shared_ptr<User> > > debtVec = self.SelfPtr->get_debts();
    std::string usernamestd ([_debtUsername.text UTF8String]);
    double userDebtstd = ([_debtDebt.text doubleValue]);
    
    // double userDebtstd = ([[_debtDebt.text initWithFormat:@"%.0f@", _debtDebt.text] doubleValue]);

   //   totalDebts.text = [[NSString alloc] initWithFormat:@"%.0f", self.SelfPtr->total()]; // 0 decimals
    
    
    
   // [NSString stringWithFormat:@"%9.5f", x]
    
    
         BOOL existing = false;
    
    for (auto & debt : *debtVec) {
        std::shared_ptr<Contact> cnt = std::dynamic_pointer_cast<Contact>(debt);
        
        if (cnt) {
            NSString *str = [NSString stringWithCString:cnt->username().c_str()
                                               encoding:[NSString defaultCStringEncoding]];
            NSLog(@"ID: %@", str);
            
            if (cnt->username() == usernamestd) {
                
                NSLog(@"KUKEn: ");
                self.SelfPtr->change_debt(usernamestd,userDebtstd);
                existing = true;
            }
        }
        
    }
    
    if (!existing) {
        NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyName&id=%@", _debtUsername.text];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        std::string strResultstd ([strResult UTF8String]);
        
        std::shared_ptr<Contact> debtCont = (string_to_contact(strResultstd, 0));
        
        
        NSString *str2 = [NSString stringWithCString:debtCont->username().c_str()
                                           encoding:[NSString defaultCStringEncoding]];
        NSLog(@"debtCont: %@", str2);
        
        std::shared_ptr<Contact> selfCont = (make_shared<Contact>(self.SelfPtr->username(), self.SelfPtr->name(),  self.SelfPtr->surname(), self.SelfPtr->Id(), 0));
        
        debtCont->push_back(selfCont);
        self.SelfPtr->push_back(debtCont);
        self.SelfPtr->change_debt(debtCont->username(), userDebtstd);
    }
    
    std::shared_ptr<vector<shared_ptr<User> > > debtUpd = self.SelfPtr->get_update();
    NSString *userns = [NSString stringWithCString:self.SelfPtr->username().c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    NSString *selfdebt = [NSString stringWithCString:self.SelfPtr->debts_to_str().c_str()
                                            encoding:[NSString defaultCStringEncoding]];
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?debtUsername=%@&debtStr=%@", userns, selfdebt];
    [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    for (auto & u : *debtUpd) {
        std::shared_ptr<Contact> upd = std::dynamic_pointer_cast<Contact>(u);
        if (upd) {
            NSString *usernamens = [NSString stringWithCString:upd->username().c_str()
                                                      encoding:[NSString defaultCStringEncoding]];
            NSString *debtns = [NSString stringWithCString:upd->debts_to_str().c_str()
                                                  encoding:[NSString defaultCStringEncoding]];
            
            NSLog(@"Uppdatera vän: %@", debtns);
            NSString *strURL2 = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?debtUsername=%@&debtStr=%@", usernamens, debtns];
            [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL2]];
            
            
        }
    }
    
    self.SelfPtr->refresh();
    totalDebts.text = [[NSString alloc] initWithFormat:@"%.0f", self.SelfPtr->total()]; // 0 decimals
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    // End the refreshing
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    [self.listTableView reloadData]; // EGET SKIT FÖR ATT RELOADA
    
    [refreshControl endRefreshing];
}

- (void) loginAction:(id)sender {
    if ([userNameTextField.text isEqualToString:@""] || [passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"Vänligen fyll i alla fält" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?userName=%@&password=%@",userNameTextField.text, passwordTextField.text];
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    if ([strResult isEqualToString:@"1"] )
    {
        usernameSelf = userNameTextField.text;
        [self performSegueWithIdentifier:@"login" sender:self];
    }else{
        // invalid information
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"Felaktigt användarnamn eller lösenord." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.arrayLogin = nil;
    self.userNameTextField = nil;
    self.passwordTextField = nil;
}


std::shared_ptr<Self> string_to_self(const std::string info){
    std::stringstream ss;
    ss.str(info);
    std::string username{""};
    std::string name{""};
    std::string surname{""};
    int Id{0};
    std::string email{""};
    
    ss >> username >> name >> surname >> Id >> email;
    
    int nrContacts{};
    for (int i{}; i<info.size(); i++) {
        if (info[i] == ':')
            nrContacts++;
    }
    std::shared_ptr<Self> _self = make_shared<Self>(username,name,surname,Id,email);
    
    for(int i{}; i < nrContacts; i++) {
        int contId {};
        double contDebt {};
        char c;
        ss >> contId >> c >> contDebt >> c;
        
        NSString *strFromInt = [NSString stringWithFormat:@"%d",contId];
        NSLog (@"StrFromInt: %@", strFromInt);
        NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyID&id=%@",strFromInt];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *userResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        std::string userResultstd ([userResult UTF8String]);
        
        NSLog (@"userREsult: %@", userResult);
        
        std::shared_ptr<Contact> ContPtr = string_to_contact(userResultstd, contDebt, 0);
        _self->push_back(ContPtr);
    }
    return _self;
}

shared_ptr<Contact> string_to_contact(const std::string info, const double debt, unsigned char depth){
    std::stringstream ss;
    ss.str(info);
    std::string username{""};
    std::string name{""};
    std::string surname{""};
    int Id;
    ss >> username >> name >> surname >> Id;
    
    NSString *usrCont  = [NSString stringWithCString:username.c_str()
                                          encoding:[NSString defaultCStringEncoding]];
    
    NSLog(@"USERNAME CONTACT: %@", usrCont);
    
    std::shared_ptr<Contact> cont = make_shared<Contact>(username,name,surname,Id,debt);
    if (depth < 3) {
        int nrContacts{};
        for (int i{}; i<info.size(); i++) {
            if (info[i] == ':')
                nrContacts++;
        }
        for (int i{}; i<nrContacts; i++) {
            int contId {};
            double contDebt {};
            char c;
            ss >> contId >> c >> contDebt >> c;
            
            NSString *strFromInt = [NSString stringWithFormat:@"%d",contId];
            NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyID&id=%@",strFromInt];
            NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            NSString *userResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
            std::string userResultstd ([userResult UTF8String]);
            
            std::shared_ptr<Contact> ContPtr = string_to_contact(userResultstd, contDebt, ++depth);
            cont->push_back(ContPtr);
        }
    }
    return cont;
}

@end
