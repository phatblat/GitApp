//
//  AppDelegate.m
//  GitAppObjc-Mac
//
//  Created by Ben Chatelain on 8/7/15.
//  Copyright (c) 2015 phatblat. All rights reserved.
//

#import "AppDelegate.h"

#import <ObjectiveGit/ObjectiveGit.h>
#import <ObjectiveGit/git2.h>
#import <ObjectiveGit/git2/types.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

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
    NSDictionary *options = @{};
    NSError *error = nil;
    GTRepository *repo = [GTRepository cloneFromURL:cloneURL toWorkingDirectory:workDirURL options:options error:&error
      transferProgressBlock:^(const git_transfer_progress * _Nonnull progress, BOOL * _Nonnull stop) {
        NSLog(@"transfer progress %ld", (long)progress->received_objects);
    } checkoutProgressBlock:^(NSString * _Nonnull path, NSUInteger completedSteps, NSUInteger totalSteps) {
        NSLog(@"clone progress %ld/%ld", (long)completedSteps, (long)totalSteps);
    }];

    if (!repo) {
        NSLog(@"Error cloning repo %@", error);
        return;
    }
    NSLog(@"Cloned repo: %@", repo.description);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
