//
//  SecondViewController.m
//  SmartSecExample
//
//  Created by Olga Dalton on 09/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "SecondViewController.h"
#import <WebKit/WebKit.h>

@interface SecondViewController() <UIWebViewDelegate/*, WKNavigationDelegate*/>
{
    IBOutlet UIWebView *_webView;
}

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWebView];
}

- (void)setupWebView
{
    //WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    //[self.view addSubview:wkWebView];
    //wkWebView.configuration.preferences.javaScriptEnabled = YES;
    //wkWebView.navigationDelegate = self;
    
    NSString *testPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *data = [NSString stringWithContentsOfFile:testPath encoding:NSUTF8StringEncoding error:nil];
    //[wkWebView loadHTMLString:data baseURL:nil];
    
     [_webView loadHTMLString:data baseURL:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

/*
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
