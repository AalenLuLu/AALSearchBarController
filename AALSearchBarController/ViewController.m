//
//  ViewController.m
//  AALSearchBarController
//
//  Created by Aalen on 15/11/27.
//  Copyright © 2015年 Aalen. All rights reserved.
//

#import "ViewController.h"

#import "AALSearchController.h"
#import "SearchResultsTableViewController.h"

@interface ViewController ()

//@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) AALSearchController *searchController;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	_searchController = [[AALSearchController alloc] initWithViewController: self];
	SearchResultsTableViewController *viewController = [[SearchResultsTableViewController alloc] initWithStyle: UITableViewStylePlain];
	_searchController = [[AALSearchController alloc] initWithSearchResultsController: viewController];
	[self initTableView];
	
//	_searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
//	[self.view addSubview: _searchController.searchBar];
//	NSLog(@"%@", _searchController.searchBar);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)initTableView
{
	self.tableView.tableHeaderView = _searchController.searchBar;
	[self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
	cell.textLabel.text = @"AAAAbb";
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	[_searchController.searchBar resignFirstResponder];
}

@end
