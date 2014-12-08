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
//#import "AppMainView.h"
#import "CustomTableCell.h"
#import "Loan.h"

#ifndef USER_CLASS
#import "users.h"
#include <memory>
#include <iostream>
#include <string>
#include <sstream>
#include <math.h>
#include <cctype>
#endif

static NSString *usernameSelf;
shared_ptr<Contact> string_to_contact(const std::string info, const double debt, unsigned char depth = 0);

@interface ViewController ()
{
    HomeModel *_homeModel;
    NSArray *_feedItems;
    NSArray *_cellItem;
    // NSMutableArray *tableArray;
    // IBOutlet UIView *contactView;
    
    // IBOutlet UITableView *contactTableView;
    
}
@property (nonatomic) NSString *usernameSelf;
@property (nonatomic) std::shared_ptr<Self> SelfPtr;
@property (nonatomic) UIRefreshControl *refreshControl;
@end

@implementation ViewController
@synthesize data;
//@synthesize data2;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Instantiate NSMutableArray
    data = [[NSMutableArray alloc] initWithArray:_feedItems];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(uglyReload) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:self.refreshControl];
    
    _feedItems = [[NSArray alloc] init];
    
    [self createSelf];
    
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

- (void) uglyReload {
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
    
    self.SelfPtr->refresh();
    totalDebts.text = [[NSString alloc] initWithFormat:@"%.0fkr", self.SelfPtr->total()]; // 0 decimals
    
    
    [self fillArray];
    // As this block of code is run in a background thread, we need to ensure the GUI
    // update is executed in the main thread
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

}




- (void) fillArray
{
    std::shared_ptr<vector<shared_ptr<User> > > fillVector = self.SelfPtr->get_debts();
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    
    if (self.SelfPtr) {
        
        
        if (fillVector->size() != 0) {
            NSString *name, *surname;
            NSNumber *debt;
            
            for (auto & cont : *fillVector) {
                std::shared_ptr<Contact> cnt = std::dynamic_pointer_cast<Contact>(cont);
                 Loan *contacts = [[Loan alloc] init];
                if (cnt) {
                   
                    name = [NSString stringWithUTF8String:cnt->name().c_str()];
                    surname = [NSString stringWithUTF8String:cnt->surname().c_str()];;
                    debt = [NSNumber numberWithDouble:cnt->debt()];
                    NSString *fullName = [NSString stringWithFormat:@"%@ %@", name, surname];
                    contacts.fullname = fullName;
                    contacts.amount = debt;
                    
                    NSLog(@"Lägger till Cell i tableArray: %@", fullName);
                    [tableArray addObject: contacts];
                }
                
                std::shared_ptr<Not_Complete> nc = std::dynamic_pointer_cast<Not_Complete>(cont);
                if (nc) {
                    name = [NSString stringWithUTF8String:nc->name().c_str()];
                    surname = [NSString stringWithUTF8String:nc->surname().c_str()];;
                    debt = [NSNumber numberWithDouble:nc->debt()];
                    NSString *fullName = [NSString stringWithFormat:@"%@ %@", name, surname];
                    contacts.fullname = fullName;
                    contacts.amount = debt;
                   
                    [tableArray addObject: contacts];
                }
            }
            // Sets array with Contact to tableView
            _feedItems = tableArray;
            data = [[NSMutableArray alloc] initWithArray:_feedItems];
            
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
        
        self.SelfPtr->refresh();
        totalDebts.text = [[NSString alloc] initWithFormat:@"%.0f", self.SelfPtr->total()]; // 0 decimals
        
        
        [self fillArray];
    
        }else {

        return;
    }
    
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, HH:mm"];
        NSString *title = [NSString stringWithFormat:@"Senast uppdaterad: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (data) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of feed items (initially 0)
    //return _feedItems.count;
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve cell
    static NSString *cellIdentifier = @"ContactCell"; // static?
    CustomTableCell *myCell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    
    if (myCell == nil){
        myCell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Loan *contacts = [data objectAtIndex:indexPath.row];
    myCell.cellName.text = contacts.fullname;
    myCell.cellTotal.text = [NSString stringWithFormat:@"%@kr", [contacts.amount stringValue]];
    
    NSLog(@"%@", contacts.amount);
    if ([contacts.amount doubleValue] > 0)
        myCell.cellTotal.textColor = [UIColor colorWithRed:(57.0/255.0) green:(169.0/255.0) blue:(136.0/255.0) alpha:1];
    else if ([contacts.amount doubleValue] < 0)
        myCell.cellTotal.textColor = [UIColor colorWithRed:(231.0/255.0) green:(79.0/255.0) blue:(43.0/255.0) alpha:1];
    else myCell.cellTotal.textColor = [UIColor grayColor];
    
    
    //myCell.textLabel.text = [data objectAtIndex:indexPath.row];
    
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
    Self _self = *self.SelfPtr; // set self
    
    std::shared_ptr<vector<shared_ptr<User> > > debtVec = _self.get_debts();
    std::string usernamestd ([_debtUsername.text UTF8String]);
    double userDebtstd  = ([_debtDebt.text doubleValue]);
    
    BOOL existing = false;
    
    for (auto & debt : *debtVec) {
        std::shared_ptr<Contact> cnt = std::dynamic_pointer_cast<Contact>(debt);
        
        if (cnt) {
            if (cnt->username() == usernamestd) {
                
                NSLog(@"Användare finns: ");
                _self.change_debt(usernamestd,userDebtstd);
                existing = true;
            }
        }
        
        
        std::shared_ptr<Not_Complete> nc = std::dynamic_pointer_cast<Not_Complete>(debt);
        
        if (nc) {
                if (nc->username() == usernamestd) {
                    NSLog(@"Användare finns: ");
                _self.change_debt(usernamestd,userDebtstd);
                existing = true;
            }
        }

        
        
    }
    
    if (!existing) {
        NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyName&id=%@", _debtUsername.text];
        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
        std::string strResultstd ([strResult UTF8String]);
        
       
        
        if (strResultstd == "") { // User doesn't exist
             NSLog(@"Hur ser strResultstd ut: %@", _debtUsername.text);
            std::stringstream ss (usernamestd);
            std::string namenc;
            std::string surnamenc;
            ss >> namenc >> surnamenc;
            shared_ptr<Not_Complete> noCnt = std::make_shared<Not_Complete> (namenc, surnamenc, 0);
            if(!noCnt){
                NSLog(@"Här är den satt");
            }
            _self.push_back(noCnt);
            _self.change_debt(noCnt->username(), userDebtstd);
            
        }else{
            
            NSLog(@"HÄR ÄR DET FETT HORIGT BREE: %@", strResult);
            
            std::shared_ptr<Contact> debtCont = (string_to_contact(strResultstd, 0));
            
            
            NSString *str2 = [NSString stringWithCString:debtCont->username().c_str()
                                                encoding:NSUTF8StringEncoding];
            NSLog(@"debtCont: %@", str2);
            
            std::shared_ptr<Contact> selfCont = (make_shared<Contact>(_self.username(), _self.name(),  _self.surname(), _self.Id(), 0));
            
            debtCont->push_back(selfCont);
            _self.push_back(debtCont);
            _self.change_debt(debtCont->username(), userDebtstd);
        }
    }
    
    std::shared_ptr<vector<shared_ptr<User> > > debtUpd = _self.get_debts();
    NSString *userns = [NSString stringWithCString:_self.username().c_str()
                                          encoding:NSUTF8StringEncoding];
    
    
    NSString *selfdebt = [NSString stringWithCString:_self.debts_to_str().c_str()
                                            encoding:NSUTF8StringEncoding];
    
    
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?debtUsername=%@&debtStr=%@", userns, selfdebt];
    [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    NSLog(@"Vi uppdaterar oss själva (SELF) :P %@ STRURL: %@", selfdebt, strURL);
    
    for (auto & u : *debtUpd) {
        std::shared_ptr<Contact> upd = std::dynamic_pointer_cast<Contact>(u);
        if (upd) {
            NSString *usernamens = [NSString stringWithCString:upd->username().c_str()
                                                      encoding:NSUTF8StringEncoding];
            NSString *debtns = [NSString stringWithCString:upd->debts_to_str().c_str()
                                                  encoding:NSUTF8StringEncoding];
            
            NSLog(@"Uppdatera vän: %@", debtns);
            NSString *strURL2 = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?debtUsername=%@&debtStr=%@", usernamens, debtns];
            [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL2]];
            
            
        }
    }
    
    _self.refresh();
    totalDebts.text = [[NSString alloc] initWithFormat:@"%.0f", _self.total()]; // 0 decimals
}


- (void) loginAction:(id)sender {
    if ([userNameTextField.text isEqualToString:@""] || [passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fel vid inloggning" message:@"Vänligen fyll i alla fält" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fel vid inloggning" message:@"Felaktigt användarnamn eller lösenord." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
        NSLog(@"SS.PEEK :%d ", (char)ss.peek());
        ss >> std::ws;
        if (std::isalpha((char)ss.peek())) {
           
            std::string namenc;
            std::string surnamenc = "";
            std::getline(ss,namenc,',');
           //if(ss.peek() == ',')
               ss >> std::ws;
              NSLog(@"SS.PEEK :%d ", (char)ss.peek());
            while(true){
                
                ss>>c;
                if(c != ','){
                    surnamenc+=c;
                }else{
                    break;
                }
                
            }
                
                
            
            //std::getline(ss,surname,',');
             
            NSString *surnameNS = [NSString stringWithCString:surnamenc.c_str()
                                                                         encoding:NSUTF8StringEncoding];
            NSLog(@"surnamme: %@", surnameNS);
            if(ss.peek() == ',')
                ss >> c; 
            ss >> contDebt >> c;
            std::shared_ptr<Not_Complete> nc = make_shared<Not_Complete>(namenc, surnamenc, contDebt);
            _self->push_back(nc);
            
        }else{
            ss >> contId >> c >> contDebt >> c;
            
            NSString *strFromInt = [NSString stringWithFormat:@"%d", contId];
            NSLog (@"StrFromInt: %@", strFromInt);
            NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?i=getUserbyID&id=%@",strFromInt];
            NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            NSString *userResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
            std::string userResultstd ([userResult UTF8String]);
            
            NSLog (@"userREsult: %@", userResult);
            
            std::shared_ptr<Contact> ContPtr = string_to_contact(userResultstd, contDebt, 0);
            _self->push_back(ContPtr);
            
        }
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
    
    
    NSString *usrCont  = [NSString stringWithCString:surname.c_str()
                                            encoding:NSUTF8StringEncoding];
    
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
            if(isalpha(ss.peek())) {
                int contId {};
                double contDebt {};
                char c;
                ss >> std::ws;
                if (std::isalpha((char)ss.peek())) {
                    
                    std::string namenc;
                    std::string surnamenc = "";
                    std::getline(ss,namenc,',');
                    //if(ss.peek() == ',')
                    ss >> std::ws;
                    NSLog(@"SS.PEEK :%d ", (char)ss.peek());
                    while(true){
                        
                        ss>>c;
                        if(c != ','){
                            surnamenc+=c;
                        }else{
                            break;
                        }
                        
                    }
                   
                    if(ss.peek() == ',')
                        ss >> c; 
                    ss >> contDebt >> c;
                }
            }else{
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
    }
    return cont;
}

@end
