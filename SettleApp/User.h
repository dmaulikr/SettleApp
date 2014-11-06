//
//  User.m
//  SettleApp
//
//  Created by Tobias Lundgren on 2014-11-06.
//  Copyright (c) 2014 Tobias Lundgren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (atomic) NSInteger *ID;
@property (nonatomic, strong) NSString *Username;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Surname;
@property (nonatomic, strong) NSString *Email;
@property (nonatomic, strong) NSString *Password;

@end