//
//  PlayerPing.m
//  IJKMediaPlayer
//
//  Created by JSHT on 17/3/10.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import "PlayerPing.h"
#import "SimplePing.h"

@interface PlayerPing ()<SimplePingDelegate>
@property(nonatomic,strong)SimplePing *simplePing;
@property(nonatomic,strong)NSTimer *timerCount;
@property(nonatomic,assign)int sendTimer;
@property(nonatomic,assign)int receiveTimer;
@property(nonatomic,assign)int receiveCount;
@property(nonatomic,assign)int countNum;
@property(nonatomic,strong)NSMutableArray * countArray;
@end

static PlayerPing *playerPing;
@implementation PlayerPing

+(PlayerPing*)buildPlayerPing:(NSString *)ipAddress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerPing = [[PlayerPing alloc]initWithIp:ipAddress];
    });
    return playerPing;
}

-(instancetype)initWithIp:(NSString*)ipText
{
    self = [super init];
    if (self) {
        self.simplePing = [[SimplePing alloc]initWithHostName:ipText];
    }
    return self;
}

-(void)startPing:(BOOL)iPv4Bool andiPv6:(BOOL)iPv6Bool
{
    if (iPv4Bool && !iPv6Bool)
        self.simplePing.addressStyle = SimplePingAddressStyleICMPv4;
    else
        self.simplePing.addressStyle = SimplePingAddressStyleICMPv6;
    self.simplePing.delegate = self;
    [self.simplePing start];
    self.pingBool = YES;
}

-(void)stop
{
    [self.simplePing stop];
    [self.timerCount invalidate];
    self.timerCount = nil;
    //self.pingBool = NO;
}

-(void)sendPing
{
    [self.simplePing sendPingWithData:nil];
}

-(int)getNowDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSArray * dateArr = [date componentsSeparatedByString:@" "];
    NSString * timerStr = [dateArr objectAtIndex:1];
    NSArray * timerArr = [timerStr componentsSeparatedByString:@":"];
    int minuteNum = [[timerArr objectAtIndex:1]intValue] * 60 * 1000;
    int secondNum = [[timerArr objectAtIndex:2]intValue] * 1000;
    int millisecondNum = [[timerArr objectAtIndex:3]intValue];
    int allNum = minuteNum + secondNum + millisecondNum;
    return allNum;
}

-(void)timerEvent
{
    [self sendPing];
}

#pragma SimplePingDelegate
-(void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    NSLog(@"simplePing did start with address!!!\n");
    [self sendPing];
    self.timerCount = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
}

-(void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"simplePing did fail with error!!!\n");
}

-(void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NSLog(@"simplePing did send packet length = %ld , sequenceNumber = %d\n",(unsigned long)packet.length,sequenceNumber);
    self.sendTimer = [self getNowDate];
}

-(void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSLog(@"simplePing did send fail to send packet!!!!!!!!!!!!!!\n");
}

-(void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    if (self.receiveCount == 50) {
        NSLog(@"monitor is over--monitor is over--monitor is over!!!\n");
        [self networkAnalyse];
    }else{
        self.receiveCount++;
        self.receiveTimer = [self getNowDate] - self.sendTimer;
        NSLog(@"------------------------%d-----------------------\n",self.receiveTimer);
        NSNumber * number = [NSNumber numberWithInt:self.receiveTimer];
        if (!self.countArray) {
            self.countArray = [NSMutableArray array];
        }
        [self.countArray addObject:number];
    }
}

-(void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    NSLog(@"did receive unexpected packet length = %ld\n",(unsigned long)packet.length);
}

//网络测试
-(void)networkAnalyse
{
    
    NSLog(@"--countArray--%@--countArray--",self.countArray);
    
    int terribleCount = 0;
    int firstCount = 0;
    for (int i = 0; i < 10; i++) {
        NSNumber * netNum = [self.countArray objectAtIndex:i];
        if ([netNum intValue] > 40) {
            firstCount++;
        }
        if (firstCount > 5) {
            terribleCount++;
        }
    }
    
    int secondCount = 0;
    for (int j = 10; j < 20; j++) {
        NSNumber * netNumSec = [self.countArray objectAtIndex:j];
        if ([netNumSec intValue] > 40) {
            secondCount++;
        }
        if (secondCount > 5) {
            terribleCount++;
        }
    }
    
    int thirdCount = 0;
    for (int k = 20; k < 30; k++) {
        NSNumber * netNumThir = [self.countArray objectAtIndex:k];
        if ([netNumThir intValue] > 40) {
            thirdCount++;
        }
        if (thirdCount > 5) {
            terribleCount++;
        }
    }
    
    int fourCount = 0;
    for (int l = 30; l < 40; l++) {
        NSNumber * netNumFour = [self.countArray objectAtIndex:l];
        if ([netNumFour intValue] > 40) {
            fourCount++;
        }
        if (fourCount > 5) {
            terribleCount++;
        }
    }
    
    int fiveCount = 0;
    for (int m = 40; m < 50; m++) {
        NSNumber * netNumFive = [self.countArray objectAtIndex:m];
        if ([netNumFive intValue] > 40) {
            fiveCount++;
        }
    }
    
    NSLog(@"--fiveCount-fiveCount--%d--fiveCount-fiveCount--%d--terribleCount",fiveCount,terribleCount);
    
    if ((fiveCount > 5 && terribleCount >= 2)||(fiveCount < 5 && terribleCount >3)) {
        NSLog(@"网络不好，建议切换到点播收看\n");
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkChangeToTerrible)]) {
            [self.delegate networkChangeToTerrible];
        }
    }else{
        self.pingBool = NO;
    }
    [self stop];
}

@end
