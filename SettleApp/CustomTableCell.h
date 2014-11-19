//
//  CustomTableCell.h
//  KivaLoan
//
//  Created by Simon on 5/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userSurname;

@property (weak, nonatomic) IBOutlet UILabel *userAmount;
@end
