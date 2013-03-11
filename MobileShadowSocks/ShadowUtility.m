//
//  ShadowUtility.m
//  MobileShadowSocks
//
//  Created by Linus Yang on 13-3-4.
//  Copyright (c) 2013 Linus Yang. All rights reserved.
//

#import "ShadowUtility.h"

@implementation ShadowUtility

- (id)initWithDaemonIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self && identifier) {
        _daemonIdentifier = [[NSString alloc] initWithString:identifier];
        _launcherPath = [[NSString alloc] initWithFormat:@"%@/launcher", [[NSBundle mainBundle] bundlePath]];
    }
    return self;
}

- (void)dealloc
{
    [_daemonIdentifier release];
    [_launcherPath release];
    [super dealloc];
}

- (BOOL)isRunning
{
    const char *args[] = {"launchctl", "list", 0};
    char *output = 0;
    BOOL result = NO;
    int exit_code = run_process(LAUNCH_CTL_PATH, args, 0, &output, 0);
    if (exit_code == 0 && output) {
        const char *daemon_id = [_daemonIdentifier cStringUsingEncoding:NSUTF8StringEncoding];
        if (strstr(output, daemon_id))
            result = YES;
        free(output);
    }
    return result;
}

- (BOOL)runLauncher:(BOOL)enabled withFirst:(NSString *)arg1 andSecond:(NSString *)arg2
{
    BOOL result = NO;
    if ([[NSFileManager defaultManager] isExecutableFileAtPath:_launcherPath]) {
        const char *execs = [_launcherPath cStringUsingEncoding:NSUTF8StringEncoding];
        const char *args[3];
        char *output = 0;
        args[0] = "launcher";
        args[1] = [(enabled ? arg1 : arg2) cStringUsingEncoding:NSUTF8StringEncoding];
        args[2] = 0;
        result = run_process(execs, args, 0, &output, 0) ? NO : YES;
        if (output)
            free(output);
    }
    return result;
}

- (BOOL)setProxy:(BOOL)isEnabled
{
    return [self runLauncher:isEnabled withFirst:@"-p" andSecond:@"-n"];
}

- (BOOL)startStopDaemon:(BOOL)start
{
    BOOL result = [self runLauncher:start withFirst:@"-r" andSecond:@"-s"];
    if (start != [self isRunning])
        result = NO;
    return result;
}

@end
