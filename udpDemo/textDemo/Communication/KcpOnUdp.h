//
//  KcpOnUdp.h
//  textDemo
//
//  Created by caobo56 on 2018/2/23.
//  Copyright © 2018年 caobo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KcpOnUdpDelegate <NSObject>

-(void)kcpOnUdpDidReciveMsg:(NSString *)str;

@end

@interface KcpOnUdp : NSObject

+(KcpOnUdp *)creatKcpOnUdpWithPort:(int)port;

+(KcpOnUdp *)creatKcpOnUdp;

@property(nonatomic,weak) id<KcpOnUdpDelegate> delegate;

-(void)sendMsg:(NSString *)msg toHost:(NSString *)ip toPort:(int)port;

@end
