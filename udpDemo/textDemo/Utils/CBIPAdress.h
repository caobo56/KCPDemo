//
//  CBIPAdress.h
//  CB_UDP_KCP_Test
//
//  Created by caobo56 on 2018/1/24.
//  Copyright © 2018年 caobo56. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface CBIPAdress : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;


@end
