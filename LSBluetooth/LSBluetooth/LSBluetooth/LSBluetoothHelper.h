//
//  LSBluetoothHelper.h
//  LSBluetooth
//
//  Created by liushuai on 16/5/3.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class LSBluetoothInfo;

@protocol LSBluetoothHelperDelegate <NSObject>

- (void)updatePeripheralList:(NSArray *)arrForBLE;

@end

@interface LSBluetoothHelper : NSObject

@property (nonatomic, weak) id<LSBluetoothHelperDelegate> delegate;

+ (instancetype)sharedBluetoothHelper;

/**
 *  @brief 将搜索到的设备信息缓存入数组
 *
 *  @param discoveredBluetoothInfo 搜索到的蓝牙外围设备信息
 *
 *  @return 缓存成功否
 */
- (BOOL)cacheBluetooth:(LSBluetoothInfo *) discoveredBluetoothInfo;

/**
 *  @brief 清理缓存的设备信息
 */
- (void)cleanBluetoothCacheInfo;

/**
 *  @brief 从本地配置文件中读取已经配对的蓝牙外围设备uuid
 *
 *  @return 返回数组，数组首元素为CBUUID类型的uuid，当从未配对时返回nil。
 */
- (NSArray<CBUUID *> *)getSavedBluetoothUUID;

/**
 *  @brief 记忆设备，用于记住已经连接的设备
 *
 *  @param discoveredPeripheral 搜索到的蓝牙外围设备信息
 */
- (void)saveBluetooth:(CBPeripheral *) discoveredPeripheral;



@end
