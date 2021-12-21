//
//  GNAppleSignManager.m
//  gnsmart
//
//  Created by Huasali on 2020/11/18.
//  Copyright © 2020 GN. All rights reserved.
//

#import "GNAppleSignManager.h"
#import <AuthenticationServices/AuthenticationServices.h>


@interface GNAppleSignManager()<ASAuthorizationControllerDelegate>{

}
@end

@implementation GNAppleSignManager

static  id _instance = nil;
+ (GNAppleSignManager *)manager{
  return [self shareManager];
}
+ (instancetype)shareManager{
  if (_instance == nil) {
    _instance = [[self alloc] init];
  }
  return _instance;
}
+ (id)allocWithZone:(NSZone *)zone{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [super allocWithZone:zone];
  });
  return _instance;
}

#pragma mark --- appid登录
- (void)didAppleButton {
    if (@available(iOS 13.0, *)) {
        // 基于用户AppleID的授权，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 创建新的AppleID授权请求
        ASAuthorizationAppleIDRequest *request = [provider createRequest];
        // 在用户授权期间请求的联系信息
        request.requestedScopes = @[ASAuthorizationScopeEmail, ASAuthorizationScopeFullName];
        // 由 ASAuthorizationAppleIDProvider 创建的授权请求来管理 授权请求控制器
        ASAuthorizationController *authController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        authController.delegate = self;
        [authController performRequests];
    }
    
}

#pragma mark - ASAuthorizationControllerDelegate

/// Apple登录授权出错
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSLog(@"[Apple]Apple登录_错误信息: %@", error.localizedDescription);
    
    NSInteger code = error.code;
    if (code == ASAuthorizationErrorUnknown) { // 授权请求未知错误
        NSLog(@"[Apple]Apple登录_授权请求未知错误");
    } else if (code == ASAuthorizationErrorCanceled) { // 授权请求取消了
        NSLog(@"[Apple]Apple登录_授权请求取消了");
    } else if (code == ASAuthorizationErrorInvalidResponse) { // 授权请求响应无效
        NSLog(@"[Apple]Apple登录_授权请求响应无效");
    } else if (code == ASAuthorizationErrorNotHandled) { // 授权请求未能处理
        NSLog(@"[Apple]Apple登录_授权请求未能处理");
    } else if (code == ASAuthorizationErrorFailed) { // 授权请求失败
        NSLog(@"[Apple]Apple登录_授权请求失败");
    }
}

/// Apple登录授权成功
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    Class credentialClass = [authorization.credential class];
    if (credentialClass == [ASAuthorizationAppleIDCredential class]) {
        // 用户登录使用的是: ASAuthorizationAppleIDCredential,授权成功后可以取到苹果返回的全部数据,然后再与后台交互
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        
        NSString *userID = credential.user;
//        NSString *state = credential.state;
//        NSArray<ASAuthorizationScope> *authorizedScopes = credential.authorizedScopes;
        // refresh_token
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
        // access_token
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        NSString *email = credential.email;
        NSPersonNameComponents *fullName = credential.fullName;
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        
        NSLog(@"[Apple]Apple登录_1_user: %@", userID);
        NSLog(@"[Apple]Apple登录_4_authorizationCode: %@", authorizationCode);
        NSLog(@"[Apple]Apple登录_5_identityToken: %@", identityToken);
        NSLog(@"[Apple]Apple登录_6_email: %@", email);
        NSLog(@"[Apple]Apple登录_7_fullName.givenName: %@", fullName.givenName);
        NSLog(@"[Apple]Apple登录_7_fullName.familyName: %@", fullName.familyName);
        NSLog(@"[Apple]Apple登录_8_realUserStatus: %ld", realUserStatus);
        [self didLog:[NSString stringWithFormat:@"userID : %@",userID]];
        [self didLog:[NSString stringWithFormat:@"authorizationCode : %@",authorizationCode]];
        [self didLog:[NSString stringWithFormat:@"identityToken : %@",identityToken]];
        //这里我只用到了userID，email，[NSString stringWithFormat:@"%@%@", fullName.familyName, fullName.givenName]
        [[NSUserDefaults standardUserDefaults] setValue:userID forKey:@"appleUserID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
       //接下来就调用自己服务器接口
    } else if (credentialClass == [ASPasswordCredential class]) {
        // 用户登录使用的是: 现有密码凭证
        ASPasswordCredential *credential = (ASPasswordCredential *)authorization.credential;
        NSString *user = credential.user; // 密码凭证对象的用户标识(用户的唯一标识)
        NSString *password = credential.password;
        NSLog(@"[Apple]Apple登录_现有密码凭证: %@, %@", user, password);
    }
}

- (void)checkLoginStausApplication:(UIApplication *)application{
  if (@available(iOS 13.0, *)) {
//          [appleInstance appleLoad];
             NSString *appleUserID = [[NSUserDefaults standardUserDefaults] valueForKey:@"appleUserID"];
             NSLog(@"[Apple]Apple登录_本地存储的AppleUserID: %@", appleUserID);
             if (!appleUserID) {//为空
                 return;
             }
                if (appleUserID.length == 0) {
                        return;;
                    }

             ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
             [appleIDProvider getCredentialStateForUserID:appleUserID completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                 switch (credentialState) {
                     case ASAuthorizationAppleIDProviderCredentialAuthorized:
                         // Apple ID credential is valid
                         NSLog(@"[Apple]Apple登录_Apple ID credential is Authorized:");
                         break;
                         
                     case ASAuthorizationAppleIDProviderCredentialRevoked:
                         // Apple ID Credential revoked, handle unlink
                         NSLog(@"[Apple]Apple登录_Apple ID Credential revoked");
//                         [self unbindApple];  //跟自己服务器解绑
                         break;
                         
                     case ASAuthorizationAppleIDProviderCredentialNotFound:
                         // Apple ID Credential not found, show login UI
                         NSLog(@"[Apple]Apple登录_Apple ID Credential not found,");
                         break;
                         
                     case ASAuthorizationAppleIDProviderCredentialTransferred:
                         NSLog(@"[Apple]Apple登录_Apple ID Credential transferred");
                         break;
                 }
             }];
          }
}
- (void)didLog:(NSString *)message{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didLog:)]) {
        [self.delegate didLog:message];
    }
}

@end
