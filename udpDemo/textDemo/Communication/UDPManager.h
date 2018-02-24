//
//  UDPManager.h
//  textDemo
//
//  Created by caobo56 on 2018/2/24.
//  Copyright © 2018年 dahua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncUdpSocket.h>

@protocol UDPManagerDelegate <NSObject>

-(void)udpManagerdidReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;

@end

@interface UDPManager : NSObject

+(instancetype)shareUDPManagerWithPort:(int)port;

@property(nonatomic,weak) id<UDPManagerDelegate> delegate;

- (void)sendData:(NSData *)data
          toHost:(NSString *)host
            port:(uint16_t)port
     withTimeout:(NSTimeInterval)timeout
             tag:(long)tag;
@end
