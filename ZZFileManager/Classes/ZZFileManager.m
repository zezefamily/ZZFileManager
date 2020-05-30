//
//  ZZFileManager.m
//  TestDemo
//
//  Created by wenmei on 2020/5/30.
//  Copyright © 2020 wenmei. All rights reserved.
//

#import "ZZFileManager.h"
#define FileManager     [NSFileManager defaultManager]
static BOOL enableLog = NO;

@implementation ZZFileManager

+ (id)defalutFileManager {
    static dispatch_once_t onceToken;
    static ZZFileManager* shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[ZZFileManager alloc]init];
    });
    return shareInstance;
}

//日志输出

- (void)enableLog:(BOOL)enable {
    enableLog = enable;
}

+ (void)DYLog:(id)object {
    if (enableLog) {
        NSLog(@"%@",object);
    }
}



//处理路径
+ (NSString *)absolutePath:(NSString *)path {
    NSString* defaultDir = [self absoluteDirectoryForPath:path];
    //系统目录可以找到
    if (defaultDir != nil) {
        return path;
    }
    else{
        //默认拼接到 document里面
        return [self documentDirPathWithPath:path];
    }
}

+ (NSString *)absoluteDirectoryForPath:(NSString *)path {
    if ([path isEqualToString:@"/"]) {
        return nil;
    }
    
    NSMutableArray *directories = [self absoluteDirectories];
    for (NSString* directory in directories) {
        NSRange tempRange = [path rangeOfString:directory];
        if (tempRange.location == 0) {
            return directory;
        }
    }
    return nil;
}

+(NSMutableArray *)absoluteDirectories{
    static NSMutableArray *directories = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        directories = [NSMutableArray arrayWithObjects:
                       [self applicationSupportDirPath],
                       [self cachesDirPath],
                       [self documentDirPath],
                       [self libraryDirPath],
                       [self mainBundleDirPath],
                       [self temporaryDirPath],
                       nil];
        
        [directories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return (((NSString *)obj1).length > ((NSString *)obj2).length) ? 0 : 1;
            
        }];
    });
    
    return directories;
}

+ (void)assertDirectory:(NSString *)dirPath {
    NSAssert(dirPath != nil, @"path can't be nil");
    NSAssert(![dirPath isEqualToString:@""], @"path can't be empty string.");
    NSString* pathSuffix = [dirPath substringFromIndex:(dirPath.length - 1)];
    NSLog(@"pathSuffix:%@",pathSuffix);
    NSAssert(![pathSuffix isEqualToString:@"/"], @"path format is wrong");
}

+ (void)assertFilePath:(NSString*)filePath {
    NSAssert(filePath != nil, @"path can't be nil");
    NSAssert(![filePath isEqualToString:@""], @"path can't be empty string.");
}


//system absolute directory

+ (NSString *)documentDirPath {
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir = [dirPaths objectAtIndex:0];
    return docDir;
}

+ (NSString *)cachesDirPath {
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* docDir = [dirPaths objectAtIndex:0];
    return docDir;
}

+ (NSString *)mainBundleDirPath {
    return [NSBundle mainBundle].resourcePath;
}

+ (NSString *)libraryDirPath {
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* docDir = [dirPaths objectAtIndex:0];
    return docDir;
}

+ (NSString *)applicationSupportDirPath {
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* docDir = [dirPaths objectAtIndex:0];
    return docDir;
}

+ (NSString *)temporaryDirPath {
    return NSTemporaryDirectory();
}

// relative  directory

+ (NSString *)documentDirPathWithPath:(NSString *)path {
    return [[self documentDirPath] stringByAppendingPathComponent:path];
}

+ (NSString *)cachesDirPathWithPath:(NSString *)path {
    return [[self cachesDirPath] stringByAppendingPathComponent:path];
}

+ (NSString *)mainBundleDirPathWithPath:(NSString *)path {
    return [[self mainBundleDirPath] stringByAppendingPathComponent:path];
}

+ (NSString *)libraryDirPathWithPath:(NSString *)path {
    return [[self libraryDirPath] stringByAppendingPathComponent:path];
}

+ (NSString *)applicationSupportDirPathWithPath:(NSString *)path {
    return [[self applicationSupportDirPath] stringByAppendingPathComponent:path];
}

+ (NSString *)temporaryDirPathWithPath:(NSString *)path {
    return [[self temporaryDirPath] stringByAppendingPathComponent:path];
}

+(NSString *)pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if([nameExtension isEqualToString:@""])
    {
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    
    return [self mainBundleDirPathWithPath:name];
}

// create file

+ (BOOL)createFileWithPath:(NSString *)path {
    return [self createFileWithPath:path content:nil];
}

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content {
    return [self createFileWithPath:path content:content overwrite:NO attributes:nil error:nil];
}

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite {
    return [self createFileWithPath:path content:content overwrite:overwrite attributes:nil error:nil];
}

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite attributes:(NSDictionary*)attributes {
    return [self createFileWithPath:path content:content overwrite:overwrite attributes:attributes error:nil];
}

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite attributes:(NSDictionary *)attributes error:(NSError **)error {
    [self assertFilePath:path];
    if (![self fileExistsAtPath:path]) {
        if([FileManager createFileAtPath:path contents:nil attributes:attributes]) {
            if (content != nil) {
                BOOL writed = [self writeContent:content path:path error:error];
                return writed && ([self NoError:error]);
            }
            else{
                return YES;
            }
        }
        else{
            [ZZFileManager DYLog:@"创建文件异常，请检查文件路径"];
            return NO;
        }
    }
    else{
        if (overwrite) {
            if ([self removeFileWithPath:path error:error]) {
                BOOL created = [FileManager createFileAtPath:path contents:nil attributes:attributes];
                if (created) {
                    if (content != nil) {
                        BOOL writed = [self writeContent:content path:path error:error];
                        return (writed && [self NoError:error]);
                    }
                    else{
                        return YES;
                    }
                }
                else{
                    [ZZFileManager DYLog:@"创建文件异常，请检查文件路径"];
                    return NO;
                }
            }
            else{
                [ZZFileManager DYLog:@"创建文件异常，请检查文件路径"];
                return NO;
            }
        }
        else{
            [ZZFileManager DYLog:@"创建文件成功"];
            return YES;
        }
    }
}

//create directory

//根据文件路径创建目录

+(BOOL)createDirectoriesForFileWithPath:(NSString *)path{
    return [self createDirectoriesForFileWithPath:path error:nil];
}


+(BOOL)createDirectoriesForFileWithPath:(NSString *)path error:(NSError **)error{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if([pathLastChar isEqualToString:@"/"])
    {
        return NO;
    }
    
    return [self createDirectoryWithDirPath:[[self absolutePath:path] stringByDeletingLastPathComponent]];
}

//根据目录路径直接创建

+ (BOOL)createDirectoryWithDirPath:(NSString *)path {
    return [self createDirectoryWithDirPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)createDirectoryWithDirPath:(NSString *)path attributes:(NSDictionary*)attributes {
    return [self createDirectoryWithDirPath:path withIntermediateDirectories:YES attributes:attributes error:nil];
}

+ (BOOL)createDirectoryWithDirPath:(NSString *)path attributes:(NSDictionary*)attributes error:(NSError **)error {
    return [self createDirectoryWithDirPath:path withIntermediateDirectories:YES attributes:attributes error:error];
}

+ (BOOL)createDirectoryWithDirPath:(NSString *)path withIntermediateDirectories:(BOOL)IntermediateDirectories attributes:(NSDictionary*)attributes error:(NSError **)error {
    [self assertDirectory:path];
    BOOL isDirectory = NO;
    BOOL isExit = [self fileExistsAtPath:path isDirectory:&isDirectory];
    if (isExit) {
        if(isDirectory){
            [ZZFileManager DYLog:@"directory already exitst"];
            return YES;
        }
        else{
            [ZZFileManager DYLog:@"path format is wrong"];
            return NO;
        }
    }
    else{
        return [FileManager createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:IntermediateDirectories attributes:attributes error:error];
    }
}

//attribute for file

+ (NSDictionary *)attributesOfFileWithPath:(NSString *)path {
    return [self attributesOfFileWithPath:path error:nil];
}

+ (NSDictionary *)attributesOfFileWithPath:(NSString *)path error:(NSError **)error {
    return [FileManager attributesOfItemAtPath:path error:error];
}

+ (id)attributeOfFileWithPath:(NSString *)path forKey:(NSString *)key {
    return [self attributeOfFileWithPath:path forKey:key error:nil];
}

+ (id)attributeOfFileWithPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error {
    return [[FileManager attributesOfItemAtPath:path error:error] objectForKey:key];
}

//list files at dir path

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path {
    return [self filesInDirectoryWithPath:path deep:NO];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path deep:(BOOL)deep {
    NSArray* itemArr = [self itemsInDirectoryWithPath:path deep:deep];
    return [itemArr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString* subPath = (NSString*)evaluatedObject;
        return [self isFileItemWithPath:subPath];
    }]];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withExtension:(NSString *)extension{
    return [self filesInDirectoryWithPath:path withExtension:extension deep:NO];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep{
    NSArray* subPaths = [self filesInDirectoryWithPath:path deep:deep];
    return [subPaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString* subPath = (NSString *)evaluatedObject;
        NSString* pathExtension = [[subPath pathExtension] lowercaseString];
        return [pathExtension isEqualToString:extension];
    }]];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withSuffix:(NSString *)suffix {
    return [self filesInDirectoryWithPath:path withSuffix:suffix deep:NO];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep {
    NSArray* subPaths = [self filesInDirectoryWithPath:path deep:deep];
    return [subPaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString* subPath = (NSString *)evaluatedObject;
        NSString* fileName = [subPath lastPathComponent];
        NSString* fileNameWithoutExtension = [fileName stringByDeletingPathExtension];
        return ([fileNameWithoutExtension hasSuffix:suffix] || [fileNameWithoutExtension isEqualToString:suffix]);
    }]];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withPrefix:(NSString *)prefix{
    return [self filesInDirectoryWithPath:path withPrefix:prefix deep:NO];
}

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep {
    NSArray* subPaths = [self filesInDirectoryWithPath:path deep:deep];
    return [subPaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString* subPath = (NSString *)evaluatedObject;
        subPath = [subPath lastPathComponent];
        return ([subPath isEqualToString:prefix] || [subPath hasPrefix:prefix]);
    }]];
}

//deep 标志 是否递归便利所有的子目录
+ (NSArray*)itemsInDirectoryWithPath:(NSString*)path deep:(BOOL)deep {
    NSString* absolutePath = [self absolutePath:path];
    NSArray* relativeSubPaths = (deep == YES) ? [FileManager subpathsOfDirectoryAtPath:absolutePath error:nil] : [FileManager contentsOfDirectoryAtPath:absolutePath error:nil];
    NSMutableArray *absoluteSubPaths = [NSMutableArray array];
    for (NSString *relativeSubPath in relativeSubPaths) {
        NSString *absoluteSubPath = [absolutePath stringByAppendingPathComponent:relativeSubPath];
        [absoluteSubPaths addObject:absoluteSubPath];
    }
    return absoluteSubPaths;
}

//remove item at pth

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path {
    return [self removeFilesInDirectoryWithPath:path error:nil];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path error:(NSError **)error {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path] error:error];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path extension:(NSString *)extension{
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withExtension:extension] error:nil];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path extension:(NSString *)extension error:(NSError **)error {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withExtension:extension] error:error];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path prefix:(NSString *)prefix {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withPrefix:prefix] error:nil];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path prefix:(NSString *)prefix error:(NSError **)error {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withPrefix:prefix] error:error];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path suffix:(NSString *)suffix {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withSuffix:suffix] error:nil];
}

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path suffix:(NSString *)suffix  error:(NSError **)error {
    return [self removeItemsWithPaths:[self filesInDirectoryWithPath:path withSuffix:suffix] error:error];
}

+ (BOOL)removeFilesWithPaths:(NSArray *)paths {
    return [self removeFilesWithPaths:paths error:nil];
}
+ (BOOL)removeFilesWithPaths:(NSArray *)paths error:(NSError **)error {
    return [self removeItemsWithPaths:paths error:error];
}

+ (BOOL)removeItemsInDirectoryWithPath:(NSString *)path {
    return [self removeItemsInDirectoryWithPath:path error:nil];
}

+ (BOOL)removeItemsInDirectoryWithPath:(NSString *)path error:(NSError **)error {
    return [self removeItemsWithPaths:[self itemsInDirectoryWithPath:path deep:NO] error:error];
}

+ (BOOL)removeItemsWithPaths:(NSArray *)paths {
    return [self removeItemsWithPaths:paths error:nil];
}

+ (BOOL)removeItemsWithPaths:(NSArray *)paths error:(NSError **)error {
    BOOL success = YES;
    for (NSString* path in paths) {
        if([self removeItemWithPath:path error:error]){
            success = YES;
        }
        else{
            success = NO;
        }
    }
    return success;
}

+ (BOOL)removeFileWithPath:(NSString *)path {
    return [self removeItemWithPath:path];
}

+ (BOOL)removeFileWithPath:(NSString *)path error:(NSError **)error {
    return [self removeItemWithPath:path error:error];
}

+ (BOOL)removeDirectoryWithPath:(NSString *)path {
    return [self removeDirectoryWithPath:path error:nil];
}

+ (BOOL)removeDirectoryWithPath:(NSString *)path error:(NSError **)error {
    return [self removeItemWithPath:path error:error];
}

+ (BOOL)removeItemWithPath:(NSString *)path {
    return [self removeItemWithPath:path error:nil];
}

+ (BOOL)removeItemWithPath:(NSString *)path error:(NSError **)error {
    return [FileManager removeItemAtPath:[self absolutePath:path] error:error];
}

//copy file

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath {
    return [self copyFileFromPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error {
    return [self copyFileFromPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self copyFileFromPath:path toPath:toPath overwrite:overwrite error:nil];
}

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error {
    if (![self fileExistsAtPath:toPath] || (overwrite && [self removeItemWithPath:toPath error:error] && [self NoError:error])) {
        if ([self createDirectoriesForFileWithPath:toPath error:error]) {
            BOOL copied = [FileManager copyItemAtPath:path toPath:toPath error:error];
            return (copied && [self NoError:error]);
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}

//move file
+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath {
    return [self moveFileFromPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self moveFileFromPath:path toPath:toPath overwrite:overwrite error:nil];
}

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error {
    return [self moveFileFromPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error {
    if (![self fileExistsAtPath:toPath] || (overwrite && [self removeItemWithPath:toPath error:error] && [self NoError:error])) {
        return ([self createDirectoriesForFileWithPath:toPath error:error] && [FileManager moveItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error]);
    }
    else{
        return NO;
    }
}

#pragma mark - Private Method

+ (BOOL)isFileItemWithPath:(NSString *)path {
    return ([self attributeOfFileWithPath:path forKey:NSFileType] == NSFileTypeRegular);
}

+ (BOOL)isFileItemWithPath:(NSString *)path error:(NSError **)error {
    return ([self attributeOfFileWithPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+ (BOOL)isDirectoryWithPath:(NSString *)path {
    return ([self attributeOfFileWithPath:path forKey:NSFileType] == NSFileTypeDirectory);
}

+ (BOOL)isDirectoryWithPath:(NSString *)path error:(NSError **)error {
    return ([self attributeOfFileWithPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    return [FileManager fileExistsAtPath:path];
}

+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    return [FileManager fileExistsAtPath:path isDirectory:isDirectory];
}

+ (BOOL)NoError:(NSError **)error {
    return ((error == nil) || (*error == nil));
}

+ (BOOL)isReadableItemWithPath:(NSString *)path {
    return [FileManager isReadableFileAtPath:[self absolutePath:path]];
}

+ (BOOL)isWritableItemWithPath:(NSString *)path {
    return [FileManager isWritableFileAtPath:[self absolutePath:path]];
}


+ (BOOL)clearCachesDirectory {
    return [self removeFilesInDirectoryWithPath:[self cachesDirPath]];
}

+ (BOOL)clearTemporaryDirectory {
    return [self removeFilesInDirectoryWithPath:[self temporaryDirPath]];
}


+ (BOOL)writeContent:(NSObject *)content path:(NSString *)path {
    return [self writeContent:content path:path error:nil];
}

+ (BOOL)writeContent:(NSObject *)content path:(NSString *)path error:(NSError **)error{
    if (content == nil) {
        return NO;
    }
    
    NSString* absolutePath = [self absolutePath:path];
    if ([content isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSArray class]]){
        [(NSArray*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableDictionary class]]){
        [(NSMutableDictionary*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSDictionary class]]){
        [(NSDictionary*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableData class]]){
        [(NSMutableData*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSData class]]){
        [(NSData*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSJSONSerialization class]]){
        [(NSDictionary*)content writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableString class]]){
        [(NSMutableString*)content writeToFile:absolutePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else if([content isKindOfClass:[NSString class]]){
        [(NSString*)content writeToFile:absolutePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else if([content conformsToProtocol:@protocol(NSCoding)]){
        [NSKeyedArchiver archiveRootObject:content toFile:absolutePath];
    }
    else{
        return NO;
    }
    return YES;
}

+ (void)writeContentToEnd:(NSData *)content path:(NSString *)path {
    return [self writeContentToEnd:content path:path error:nil];
}

+ (void)writeContentToEnd:(NSData *)content path:(NSString *)path error:(NSError **)error {
    if (content == nil) {
        return;
    }
    
    NSString* absolutePath = [self absolutePath:path];
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:absolutePath];
    [fileHandle seekToEndOfFile];
    
    [fileHandle writeData:content];
    
    [fileHandle closeFile];
}

//从头部插入内容
+ (void)writeContentFromStart:(NSData *)content path:(NSString *)path {
    [self writeContentFromStart:content path:path error:nil];
}

+ (void)writeContentFromStart:(NSData *)content path:(NSString *)path error:(NSError **)error {
    if (content == nil) {
        return;
    }
    
    NSString* absolutePath = [self absolutePath:path];
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:absolutePath];
    [fileHandle seekToFileOffset:0];
    
    [fileHandle writeData:content];
    
    [fileHandle closeFile];
}

//read

+ (NSString *)readContentWithPath:(NSString *)path {
    return [self readContentWithPath:path error:nil];
}

+ (NSString *)readContentWithPath:(NSString *)path error:(NSError **)error{
    return [self readContentAsStringWithPath:path error:error];
}

+ (NSString *)readContentAsStringWithPath:(NSString *)path {
    return [self readContentAsStringWithPath:path error:nil];
}

+ (NSString *)readContentAsStringWithPath:(NSString *)path error:(NSError **)error{
    return [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:error];
}

+ (NSArray *)readContentAsNSArrayWithPath:(NSString *)path {
    return [NSArray arrayWithContentsOfFile:[self absolutePath:path]];
}

+ (NSMutableArray *)readContentAsNSMutableArrayWithPath:(NSString *)path {
    return [NSMutableArray arrayWithContentsOfFile:[self absolutePath:path]];
}

+ (NSDictionary *)readContentAsNSDictionaryWithPath:(NSString *)path {
    return [NSDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}

+ (NSMutableDictionary *)readContentAsNSMutableDictionaryWithPath:(NSString *)path {
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}

+ (NSData *)readContentAsNSDataWithPath:(NSString *)path {
    return [NSData dataWithContentsOfFile:[self absolutePath:path]];
}

+ (NSData *)readContentAsNSDataWithPath:(NSString *)path error:(NSError **)error {
    return [NSData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMappedIfSafe error:error];
}

+ (NSMutableData *)readContentAsNSMutableDataWithPath:(NSString *)path {
    return [NSMutableData dataWithContentsOfFile:[self absolutePath:path]];
}

+ (NSMutableData *)readContentAsNSMutableDataWithPath:(NSString *)path error:(NSError **)error {
    return [NSMutableData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMappedIfSafe error:error];
}

+ (NSObject *)readContentAsCustomModelWithPath:(NSString *)path {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self absolutePath:path]];
}

+(NSJSONSerialization *)readContentAsJSONWithPath:(NSString *)path
{
    return [self readContentAsJSONWithPath:path error:nil];
}

+(NSJSONSerialization *)readContentAsJSONWithPath:(NSString *)path error:(NSError **)error{
    NSData *data = [self readContentAsNSDataWithPath:path error:error];
    
    if([self NoError:error])
    {
        
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        
        if([NSJSONSerialization isValidJSONObject:json])
        {
            return json;
        }
    }
    return nil;
}

//size for file

+ (NSNumber *)sizeForFileWithPath:(NSString *)path {
    return [self sizeForFileWithPath:path error:nil];
}

+ (NSNumber *)sizeForFileWithPath:(NSString *)path error:(NSError **)error {
    if ([self isFileItemWithPath:path error:error]) {
        if ([self NoError:error]) {
            return [self sizeForItemWithPath:path error:error];
        }
    }
    return nil;
}

+ (NSNumber *)sizeForItemWithPath:(NSString *)path {
    return [self sizeForItemWithPath:path error:nil];
}

+ (NSNumber *)sizeForItemWithPath:(NSString *)path error:(NSError **)error {
    return (NSNumber*)[self attributeOfFileWithPath:path forKey:NSFileSize error:error];
}

//size for directory

+ (NSNumber *)sizeForDirectoryWithPath:(NSString *)path {
    return [self sizeForDirectoryWithPath:path error:nil];
}

+ (NSNumber *)sizeForDirectoryWithPath:(NSString *)path error:(NSError **)error {
    if([self isDirectoryWithPath:path error:error])
    {
        if([self NoError:error])
        {
            NSNumber *size = [self sizeForItemWithPath:path error:error];
            double sizeValue = [size doubleValue];
            
            if([self NoError:error])
            {
                NSArray *subpaths = [self itemsInDirectoryWithPath:path deep:YES];
                NSUInteger subpathsCount = [subpaths count];
                
                for(NSUInteger i = 0; i < subpathsCount; i++)
                {
                    NSString *subpath = [subpaths objectAtIndex:i];
                    NSNumber *subpathSize = [self sizeForItemWithPath:subpath error:error];
                    
                    if([self NoError:error])
                    {
                        sizeValue += [subpathSize doubleValue];
                    }
                    else {
                        return nil;
                    }
                }
                
                return [NSNumber numberWithDouble:sizeValue];
            }
        }
    }
    
    return nil;
}



//size format    1024 * 1024 bytes = 1024kb = 1MB
+ (NSString *)sizeFormatted:(NSNumber *)size {
    double convertedValue = [size doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];
    
    while(convertedValue > 1024){
        convertedValue /= 1024;
        
        multiplyFactor++;
    }
    
    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");
    
    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}

+ (NSString *)sizeFormattedForDirectoryWithPath:(NSString *)path {
    return [self sizeFormattedForDirectoryWithPath:path error:nil];
}

+ (NSString *)sizeFormattedForDirectoryWithPath:(NSString *)path error:(NSError **)error {
    NSNumber *size = [self sizeForDirectoryWithPath:path error:error];
    if (size != nil && [self NoError: error]) {
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedForFileWithPath:(NSString *)path {
    return [self sizeFormattedForFileWithPath:path error:nil];
}

+ (NSString *)sizeFormattedForFileWithPath:(NSString *)path error:(NSError **)error {
    NSNumber *size = [self sizeForFileWithPath:path error:error];
    if (size != nil && [self NoError: error]) {
        return [self sizeFormatted:size];
    }
    return nil;
}


+(BOOL)renameFileWithPath:(NSString *)path withName:(NSString *)name{
    return [self renameFileWithPath:path withName:name error:nil];
}


+(BOOL)renameFileWithPath:(NSString *)path withName:(NSString *)name error:(NSError **)error{
    NSRange indexOfSlash = [name rangeOfString:@"/"];
    
    if(indexOfSlash.location < name.length)
    {
        return NO;
    }
    
    return [self moveFileFromPath:path toPath:[[[self absolutePath:path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:name] error:error];
}

@end
