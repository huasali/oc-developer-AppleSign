//
//  GNAppleSignManager.h
//  gnsmart
//
//  Created by Huasali on 2020/11/18.
//  Copyright © 2020 GN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol GNAppleLogDelegate <NSObject>
- (void)didLog:(NSString *)message;
@end

@interface GNAppleSignManager : NSObject

@property(nonatomic, weak) id <GNAppleLogDelegate>delegate;

+ (GNAppleSignManager *)manager;
- (void)didAppleButton;
- (void)checkLoginStausApplication:(UIApplication *)application;


@end

NS_ASSUME_NONNULL_END
