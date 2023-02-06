//
//  LQKeyChain.m
//  Liquid
//
//  Created by Miguel M. Almeida on 13/05/15.
//  Copyright (c) 2015 Liquid. All rights reserved.
//

#import "Keychain.h"
#import "KeychainItem.h"
#import "Defaults.h"

@implementation Keychain

+ (BOOL)setValue:(NSString *)value forKey:(NSString *)key allowUpdate:(BOOL)allowUpdate {
    KeychainItem *item = [[KeychainItem alloc] initWithKey:key andValue:value namespace:[Keychain liquidNameSpace]];
    if (allowUpdate || ![item exists]) {
        NSLog(@"Saved value '%@' in Keychain for key '%@'.", value, key);
        return [item save] == noErr;
    }
    return NO;
}

+ (NSString *)valueForKey:(NSString *)key {
    KeychainItem *item = [[KeychainItem alloc] initWithKey:key namespace:[Keychain liquidNameSpace]];
    NSLog(@"Retrieved value '%@' from Keychain for key '%@'.", item.value, item.key);
    return item.value;
}

+ (NSString *)liquidNameSpace {
    return [NSString stringWithFormat:@"%@.keychain", kBundle];
}

@end
