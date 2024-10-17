//
//  FileDataSource.m
//  demo
//
//  Created by tbolp on 2023/3/30.
//

#import "FileDataSource.h"
#include <fstream>

@implementation FileDataSource{
    NSString* _path;
    std::ifstream _file;
    bool _empty;
}

- (instancetype)init:(NSString *)path{
    self = [super init];
    if(self){
        _path = path;
        _empty = false;
    }
    return self;
}

- (bool)empty { 
    return _empty;
}

- (nonnull NSData *)read:(int)ms error:(NSError *__autoreleasing  _Nullable * _Nullable)error { 
    int len = ms * 16 *2;
    NSMutableData* data = [NSMutableData dataWithCapacity:len];
    data.length = len;
    _file.read((char*)data.mutableBytes, len);
    _empty = !(bool)_file;
    return data;
}

- (NSError *)start {
    _file.open([_path UTF8String], std::ios::binary);
    if (_file.is_open()) {
        return nil;
    }else {
        return [[NSError alloc] initWithDomain:@"Open File Failed" code:-1 userInfo:nil];
    }
}

- (NSError *)stop {
    _file.close();
    return nil;
}

@end
