//
//  LSBluetoothInfo.h
//  LSBluetooth
//
//  Created by liushuai on 16/5/3.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface LSBluetoothInfo : NSObject

@property (nonatomic, strong) CBPeripheral *discoveredPeripheral; //搜索到的周边设备
@property (nonatomic, strong) NSNumber *rssi; //搜索到的周边设备信号强度


@end
