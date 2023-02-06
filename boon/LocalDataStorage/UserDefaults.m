//
//  LQUserDefaults.m
//  Liquid
//
//  Created by Miguel M. Almeida on 17/05/15.
//  Copyright (c) 2015 Liquid. All rights reserved.
//

#import "UserDefaults.h"
#import "Defaults.h"

@implementation UserDefaults

+ (BOOL)setObject:(id)object forKey:(NSString *)key allowUpdate:(BOOL)allowUpdate {
    if (!allowUpdate && [[NSUserDefaults standardUserDefaults] objectForKey:[UserDefaults phrontPrefixedKey:key]]) {
        return NO;
    }
    NSLog(@"Setting NSUserDefaults key '%@' with object '%@'", key, object);
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:[UserDefaults phrontPrefixedKey:key]];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[UserDefaults phrontPrefixedKey:key]];
}

+ (void)removeObjectForKey:(NSString *)key {
    NSLog(@"Removing NSUserDefaults key '%@'", key);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[UserDefaults phrontPrefixedKey:key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)phrontPrefixedKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@.%@", kBundle, key];
}

@end
