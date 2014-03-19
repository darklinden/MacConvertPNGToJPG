//
//  main.m
//  ImgConverter
//
//  Created by DarkLinden on M/24/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

static void convertAllContentToJpg(NSString *stringFolderPath)
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    NSArray *arrayFiles = [mgr contentsOfDirectoryAtPath:stringFolderPath error:nil];
    for (NSString *stringFileName in arrayFiles) {
        BOOL boolIsDirectory = NO;
        NSString *stringFileFullPath = [stringFolderPath stringByAppendingPathComponent:stringFileName];
        BOOL boolFileExists = [mgr fileExistsAtPath:stringFileFullPath isDirectory:&boolIsDirectory];
        if (boolFileExists) {
            if (boolIsDirectory) {
                convertAllContentToJpg(stringFileFullPath);
            }
            else {
                if ([[[stringFileFullPath pathExtension] uppercaseString] isEqualToString:@"PNG"]) {
                    CFURLRef cfurl = (__bridge CFURLRef) [NSURL fileURLWithPath:stringFileFullPath];
                    CGImageSourceRef source = CGImageSourceCreateWithURL(cfurl, NULL);
                    
                    size_t count = CGImageSourceGetCount(source);
                    for (size_t i = 0; i < count; ++i) {
                        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
                        if (!cgImage) continue;
                        
                        CFMutableDataRef data = CFDataCreateMutable (kCFAllocatorDefault, 0);
                        
                        CGImageDestinationRef dataDest = CGImageDestinationCreateWithData (data, kUTTypeJPEG, 1, NULL);
                        
                        CGImageDestinationAddImage (dataDest, cgImage, NULL);
                        
                        CGImageDestinationFinalize (dataDest);
                        
                        NSString *stringDestinationPath = [[stringFileFullPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
                        const char *charFileDestinationPath = [stringDestinationPath UTF8String];
                        
                        const UInt8 *buffer = CFDataGetBytePtr(data);
                        long bufferLength = CFDataGetLength(data);
                        
                        FILE *file = fopen(charFileDestinationPath, "wb");
                        if (!file) {
                            printf("error opening file!");
                        }
                        
                        size_t len = fwrite(buffer, 1, bufferLength, file);
                        if (bufferLength == len) {
                            printf("ImgConverter: write jpg success [%s] \n", charFileDestinationPath);
                        }
                        else {
                            printf("ImgConverter: trying to write jpg failed [%s]. \n", charFileDestinationPath);
                        }
                        fclose(file);
                    }
                }
            }
        }
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSString *stringCurrentPath = [[NSBundle mainBundle] bundlePath];
        printf("ImgConverter: convert All png in path to jpg [%s]", stringCurrentPath.UTF8String);
        convertAllContentToJpg(stringCurrentPath);
    }
    return 0;
}

