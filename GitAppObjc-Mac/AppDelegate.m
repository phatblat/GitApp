//
//  AppDelegate.m
//  GitAppObjc-Mac
//
//  Created by Ben Chatelain on 8/7/15.
//  Copyright (c) 2015 phatblat. All rights reserved.
//

#import "AppDelegate.h"

@import ObjectiveGit;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Set up certificates

    /*
     let CACertificateFile_DigiCert = "DigiCert High Assurance EV Root CA.pem"
     let certFilePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(CACertificateFile_DigiCert)
     LogVerbose("Loading certificate: \(certFilePath)")

     let file = (certFilePath as NSString).UTF8String
     let path: UnsafePointer<Int8> = nil

     let returnValue = _git_libgit2_opts(GIT_OPT_SET_SSL_CERT_LOCATIONS, getVaList([file, path])) // as int, Int8? CInt?
     if (returnValue != 0) {
     LogError("Error setting SSL certificate location")
     }
    */

    NSString *CACertificateFile_DigiCert = @"DigiCert High Assurance EV Root CA.pem";
    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:[CACertificateFile_DigiCert stringByDeletingPathExtension] ofType:[CACertificateFile_DigiCert pathExtension]];
    NSLog(@"certFilePath: %@", certFilePath);

    int returnValue = git_libgit2_opts(GIT_OPT_SET_SSL_CERT_LOCATIONS, [certFilePath UTF8String], NULL);
    if (returnValue != GITERR_NONE) {
        NSLog(@"git_libgit2_opts returned an error %ld", (long)returnValue);
    }

    NSURL *cloneURL = [NSURL URLWithString:@"https://github.com/phatblat/GitApp.git"];
    NSURL *workDirURL = [NSURL URLWithString:@"/tmp/GitApp"];

    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[workDirURL path]]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:[workDirURL path] error:&error]) {
            NSLog(@"Error removing directory at path %@", [workDirURL path]);
            return;
        }
    }

    NSDictionary *options = @{};
    GTRepository *repo = [GTRepository cloneFromURL:cloneURL toWorkingDirectory:workDirURL options:options error:&error
      transferProgressBlock:^(const git_transfer_progress * __nonnull progress, BOOL * __nonnull stop) {
        NSLog(@"transfer progress %ld/%ld", (long)progress->received_objects, (long)progress->total_objects);
    } checkoutProgressBlock:^(NSString * __nonnull path, NSUInteger completedSteps, NSUInteger totalSteps) {
        NSLog(@"clone progress %ld/%ld", (long)completedSteps, (long)totalSteps);
    }];

    if (!repo) {
        NSLog(@"Error cloning repo %@", error);
        return;
    }
    NSLog(@"Cloned repo: %@", repo.description);
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // Insert code here to tear down your application
}

@end
