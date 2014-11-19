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

@interface ViewController ()
{
    HomeModel *_homeModel;
    NSArray *_feedItems;
}
@end

@implementation ViewController


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
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    
    // Set this view controller object as the delegate for the home model object
    _homeModel.delegate = self;
    
    // Call the download items method of the home model object
    [_homeModel downloadItems];
    
    
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
    User *item = _feedItems[indexPath.row];
    // Get references to labels of cell
   
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", item.name, item.surname];
    myCell.textLabel.text = fullName;
    
    return myCell;
}

// Dismiss keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


// Insert to Database function
- (IBAction)insert:(id)sender
{
    // create string contains url address for php file, the file name is phpFile.php, it receives parameter :name
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?username=%@&email=%@&name=%@&surname=%@&password=%@",_txtUsername.text, _txtEmail.text, _txtName.text, _txtSurname.text, _txtPassword.text];
    
    // to execute php code
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", strResult);
}


// Login/Register User
- (IBAction)loginAction:(id)sender{
    if ([_userNameTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"Please Fill all the field" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    // i will use a code from connect to DB tutorial
    NSString *strURL = [NSString stringWithFormat:@"http://demo.lundgrendesign.se/settleapp/db.php?userName=%@&password=%@",_userNameTextField.text, _passwordTextField.text];
    
    // to execute php code
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding:NSUTF8StringEncoding];
    
    if ([strResult isEqualToString:@"1"])
    {
        // i need to get the control for main navigation controller
        //    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        
        // create object from app main view to push it
        //    appMainView = [[AppMainView alloc] initWithNibName:@"AppMainView" bundle:nil];
        //   [UINavigationController pushViewController:SettleApp animated:YES];
    }else
    {
        // invalid information
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"Invalide Information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

// If Empty table

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (1==1) {
        
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
        
        self.listTableView.backgroundView = messageLabel;
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
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

@end
