//
//  ViewController.m
//  example
//
//  Created by xlL on 9/21/17.
//  Copyright © 2017 UED. All rights reserved.
//

#import "ViewController.h"
#import "UEDRefreshView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UEDRefreshView *refreshView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshView = [[UEDRefreshView alloc] initWithContentViewXibName:@"OrzRefreshView"];
    [self.refreshView addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshView];
}

- (void)refresh {
    [self performSelector:@selector(end) withObject:nil afterDelay:2.0];
    //    [self.refreshView endRefreshing];
}

- (void)end {
    [self.refreshView endRefreshing];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"111";
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}


@end
