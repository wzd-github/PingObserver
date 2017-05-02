//
//  PlayerPing.h
//  IJKMediaPlayer
//
//  Created by JSHT on 17/3/10.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol pingDelegate <NSObject>

-(void)networkChangeToTerrible;
-(void)networkChangeToFine;

@end

@interface PlayerPing : NSObject
@property(nonatomic,assign)BOOL pingBool;
@property(nonatomic,assign)BOOL remindBool;
@property(nonatomic,weak)id <pingDelegate> delegate;
+(PlayerPing*)buildPlayerPing:(NSString *)ipAddress;
-(void)startPing:(BOOL)iPv4Bool andiPv6:(BOOL)iPv6Bool;
-(void)stop;
@end
