//
//  IServiceCall.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 07.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IServiceCall <NSObject>
-(BOOL)isSuccess;
-(NSString *)getServiceMethodName;
-(NSString *)getServiceName;
-(NSArray *)getArguments;
-(uint)getStatus;
-(NSException *)getException;
@optional
-(void)setStatus:(uint)status;
-(void)setException:(NSException *)exception;
@end
