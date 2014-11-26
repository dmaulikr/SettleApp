//
//  User.m
//  SettleApp
//
//  Created by Tobias Lundgren on 2014-11-06.
//  Copyright (c) 2014 Tobias Lundgren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Userc : NSObject

@property (nonatomic, assign) NSNumber *ide;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *debts;

@end