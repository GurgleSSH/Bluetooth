//
//  LSBluetoothHelper.m
//  LSBluetooth
//
//  Created by liushuai on 16/5/3.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#import "LSBluetoothMicro.h"

#import "LSBluetoothHelper.h"
#import "LSBluetoothInfo.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const SavedBluetoothUUID = @"LSSavedBluetoothUUID";

@interface LSBluetoothHelper ()

@property (nonatomic, strong) NSMutableArray *arrForBLE;

@end


@implementation LSBluetoothHelper

#pragma mark - init
+ (instancetype)sharedBluetoothHelper {
    static LSBluetoothHelper *bluetoothHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothHelper = [[LSBluetoothHelper alloc] init];
    });
    return bluetoothHelper;
}

#pragma mark - override getter
- (NSMutableArray *)arrForBLE {
    if (!_arrForBLE) {
        _arrForBLE = [NSMutableArray array];
    }
    return _arrForBLE;
}

#pragma mark - methods
/**
 *  @brief 将搜索到的设备信息缓存入数组
 *
 *  @param discoveredBluetoothInfo 搜索到的蓝牙外围设备信息
 *
 *  @return 缓存成功否
 */
- (BOOL)cacheBluetooth:(LSBluetoothInfo *) discoveredBluetoothInfo {
    for (LSBluetoothInfo *info in self.arrForBLE) {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBluetoothInfo.discoveredPeripheral.identifier.UUIDString]) {
            return NO;
        }
    }
    [self.arrForBLE addObject:discoveredBluetoothInfo];
    DELEGATE_RESPONDS_WITH(updatePeripheralList:, self.arrForBLE);
    return YES;
}

/**
 *  @brief 清理缓存的设备信息
 */
- (void)cleanBluetoothCacheInfo {
    [self.arrForBLE removeAllObjects];
}

/**
 *  @brief 从本地配置文件中读取已经配对的蓝牙外围设备uuid
 *
 *  @return 返回数组，数组首元素为CBUUID类型的uuid，当从未配对时返回nil。
 */
- (NSArray<CBUUID *> *)getSavedBluetoothUUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuidStr = [userDefaults stringForKey:SavedBluetoothUUID];
    if (STRING_IS_NOT_NULL(uuidStr)) {
        CBUUID *uuid = [CBUUID UUIDWithString:uuidStr];
        return @[uuid];
    } else {
        return nil;
    }
}

/**
 *  @brief 记忆设备，用于记住已经连接的设备
 *
 *  @param discoveredPeripheral 搜索到的蓝牙外围设备信息
 */
- (void)saveBluetooth:(CBPeripheral *) discoveredPeripheral {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuidStr = discoveredPeripheral.identifier.UUIDString;
    [userDefaults setObject:uuidStr forKey:SavedBluetoothUUID];
}

@end
