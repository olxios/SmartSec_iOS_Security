//
//  ViewController.m
//  SmartSecExample
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(showSecondViewController)
               withObject:nil
               afterDelay:3.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showSecondViewController
{
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor greenColor];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
