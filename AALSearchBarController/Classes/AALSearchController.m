//
//  AALSearchController.m
//  AALSearchBarController
//
//  Created by Aalen on 15/11/27.
//  Copyright © 2015年 Aalen. All rights reserved.
//

#import "AALSearchController.h"

#import <objc/runtime.h>

@interface AALSearchController () <UISearchBarDelegate, UIBarPositioningDelegate, UITableViewDelegate>

@property (weak, nonatomic) UIView *searchBarSuperView;
@property (strong, nonatomic) UIViewController *searchResultsController;
//@property (weak, nonatomic) UIViewController *viewController;
//@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISearchBar *searchBar;
//@property (strong, nonatomic) UITableView *tableView;
//@property (strong, nonatomic) UIView *maskView;
//@property (assign, nonatomic) CGPoint originOffset;

@end

@implementation AALSearchController

- (void)dealloc
{
	[_searchBar removeObserver: self forKeyPath: @"delegate" context: nil];
//	dispatch_release(_signal);
//	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (instancetype)initWithSearchResultsController:(UIViewController *)viewController
{
	if(self = [super init])
	{
		_searchResultsController = viewController;
	}
	return self;
}

/*
- (instancetype)initWithViewController:(UIViewController *)viewController
{
	if(self = [super init])
	{
		_viewController = viewController;
		
		unsigned int outCount;
		Method *methods = class_copyMethodList([UISearchBar class], &outCount);
		for(int i = 0;i < outCount;i++)
		{
			SEL name = method_getName(methods[i]);
			NSLog(@"method: %s", sel_getName(name));
		}
		free(methods);
	}
	return self;
}
*/

- (instancetype)init
{
	//self.view是lazy load...在init中调用...会有意想不到的可能...
	if(self = [super init])
	{
		//先走textfielddidbeginediting再走willshowkeyboard...
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onKeyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onKeyboardWillHide:) name: UIKeyboardWillHideNotification object: nil];
		
		//kvo...
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onTextFieldDidBeginEditing:) name: UITextFieldTextDidBeginEditingNotification object: nil];
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onTextFieldDidEndEditing:) name: UITextFieldTextDidEndEditingNotification object: nil];
		
		//runtime...
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onTextFieldDidBeginEditing:) name: kSearchBarBeginEditingNotification object: nil];
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onTextFieldDidEndEditing:) name: kSearchBarEndEditingNotification object: nil];
		//		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onSearchBarCancelButtonPressed:) name: kSearchBarCancelButtonPressedNotification object: nil];
		
		/*
		unsigned int outCount;
		
		objc_property_t *properties = class_copyPropertyList([_searchBar class], &outCount);
		for(int i = 0;i < outCount;i++)
		{
			objc_property_t property = properties[i];
			NSLog(@"property[%d]: %s", i, property_getName(property));
		}
		free(properties);
		
		Method *methods = class_copyMethodList([_searchBar class], &outCount);
		for(int i = 0;i < outCount;i++)
		{
			SEL name = method_getName(methods[i]);
			NSLog(@"method: %s", sel_getName(name));
		}
		free(methods);
		*/
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor colorWithWhite: 1 alpha: 0.9];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapView:)];
	[self.view addGestureRecognizer: tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISearchBar *)searchBar
{
	@synchronized(self)
	{
		if(nil == _searchBar)
		{
			_searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(8.0, 20.0, self.view.bounds.size.width - 16.0, 44.0)];
			_searchBar.translucent = NO;
			_searchBar.delegate = self;
			[_searchBar addObserver: self forKeyPath: @"delegate" options: NSKeyValueObservingOptionNew context: nil];
		}
	}
	return _searchBar;
}

- (void)setActive:(BOOL)active
{
	if(active)
	{
		[self setSearchControllerActive];
	}
	else
	{
		[self setSearchControllerNotActive];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//	[_searchBar resignFirstResponder];
}

#pragma mark search bar notification...

- (void)onTextFieldDidBeginEditing: (NSNotification *)notification
{
	//先走textfielddidbeginediting再走willshowkeyboard...
	/*
	id object = [_searchBar valueForKey: @"searchBarTextField"];
	if([object isEqual: notification.object])
	{
		if(!_searchBar.showsCancelButton)
		{
			[_searchBar setShowsCancelButton: YES animated: YES];
		}
	}
	*/
	if(!_searchBar.showsCancelButton)
	{
		[_searchBar setShowsCancelButton: YES animated: YES];
	}
}

- (void)onTextFieldDidEndEditing: (NSNotification *)notification
{
	/*
	id object = [_searchBar valueForKey: @"searchBarTextField"];
	if([object isEqual: notification.object])
	{
		if(_searchBar.showsCancelButton)
		{
			[_searchBar setShowsCancelButton: NO animated: YES];
		}
	}
	*/
	if(_searchBar.showsCancelButton)
	{
		[_searchBar setShowsCancelButton: NO animated: YES];
	}
}

- (void)onSearchBarCancelButtonPressed: (NSNotification *)notification
{
//	[_searchBar resignFirstResponder];
	[self searchBarResignFirstResponder: _searchBar];
}

#pragma mark controller func...

- (void)setSearchControllerActive
{
	if(!_active)
	{
		_active = YES;
		//查找search bar所属view controller...把navigationbar隐藏...
		self.searchBarSuperView = _searchBar.superview;
		UIViewController * __weak viewController = nil;
		for(UIView *next = _searchBarSuperView;next;next = next.superview)
		{
			UIResponder *nextResponder = [next nextResponder];
			if([nextResponder isKindOfClass: [UIViewController class]])
			{
				viewController = (UIViewController *)nextResponder;
				[((UIViewController *)nextResponder).navigationController setNavigationBarHidden: YES animated: YES];
				break;
			}
		}
		
		//把searchbar显示到新位置...
//		CGRect searchBarFrame = _searchBar.frame;
//		NSLog(@"y: %lf", searchBarFrame.origin.y);
//		searchBarFrame.origin.y = 0;
//		_searchBar.frame = searchBarFrame;
//		NSLog(@"%@", ((UITableView *)_searchBarSuperView).tableHeaderView);		search bar...
//		NSLog(@"%@", _searchBar.superview);										tableview...
		
		if([_searchBarSuperView isKindOfClass: [UITableView class]])
		{
			[((UITableView *)_searchBarSuperView) setScrollEnabled: NO];
			if([_searchBar isEqual: ((UITableView *)_searchBarSuperView).tableHeaderView])
			{
				((UITableView *)_searchBarSuperView).tableHeaderView = nil;
			}
			else if([_searchBar isEqual: ((UITableView *)_searchBarSuperView).tableFooterView])
			{
				((UITableView *)_searchBarSuperView).tableFooterView = nil;
			}
		}
		else
		{
			//可能不用...
		}
		
//		_searchBar.barPosition = UIBarPositionTopAttached;
		CGRect searchBarFrame = _searchBar.frame;
		searchBarFrame.origin.y = 20.0;
		_searchBar.frame = searchBarFrame;
		[self.view addSubview: _searchBar];
		
		if(nil != viewController.navigationController)
		{
			[viewController.navigationController.view addSubview: self.view];
		}
		else
		{
			[viewController.view addSubview: self.view];
		}
//		[_searchBar becomeFirstResponder];
		
		[self searchBarShowCancelButton: _searchBar];
		
		[_searchBar becomeFirstResponder];
	}
}

- (void)setSearchControllerNotActive
{
	if(_active)
	{
		_active = NO;
		UIViewController * __weak viewController = nil;
		for(UIView *next = _searchBarSuperView;next;next = next.superview)
		{
			UIResponder *nextResponder = [next nextResponder];
			if([nextResponder isKindOfClass: [UIViewController class]])
			{
				viewController = (UIViewController *)nextResponder;
				[((UIViewController *)nextResponder).navigationController setNavigationBarHidden: NO animated: YES];
				break;
			}
		}
		NSLog(@"%@", _searchBar.superview);
		
		//从self.view 去除...
		[_searchBar removeFromSuperview];
		[self.view removeFromSuperview];
		
		if([_searchBarSuperView isKindOfClass: [UITableView class]])
		{
			[((UITableView *)_searchBarSuperView) setScrollEnabled: YES];
			((UITableView *)_searchBarSuperView).tableHeaderView = _searchBar;
		}
		else
		{
			[_searchBarSuperView addSubview: _searchBar];
		}
		
//		_searchBar.text = nil;
		[self searchBarHideCancelButton: _searchBar];
		_searchBar.text = @"";
		
		/*
		[self.tableView removeFromSuperview];
		*/
		
//		[_searchBar resignFirstResponder];
	}
}

- (void)onTapView: (UITapGestureRecognizer *)gesture
{
	if(0 < _searchBar.text.length)
	{
		return;
	}
	[self setSearchControllerNotActive];
}

#pragma mark other...

- (void)searchBarShowCancelButton: (UISearchBar *)searchBar
{
	if(!searchBar.showsCancelButton)
	{
		[searchBar setShowsCancelButton: YES animated: YES];
	}
}

- (void)searchBarHideCancelButton: (UISearchBar *)searchBar
{
	if(searchBar.showsCancelButton)
	{
		[searchBar setShowsCancelButton: NO animated: YES];
	}
}

- (void)searchBarResignFirstResponder: (UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark kvo...

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if([object isEqual: _searchBar] && [@"delegate" isEqualToString: keyPath])
	{
		if(![change[@"new"] isEqual: self])
		{
			_searchBar.delegate = self;
		}
	}
}

#pragma mark search bar delegate...

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarShouldBeginEditing:)])
	{
		return [(id<UISearchBarDelegate>)_delegate searchBarShouldBeginEditing: searchBar];
	}
	//内部逻辑...
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	//内部逻辑...
	[self setSearchControllerActive];
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarTextDidBeginEditing:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarTextDidBeginEditing: searchBar];
	}
}// called when text starts editing

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarShouldEndEditing:)])
	{
		return [(id<UISearchBarDelegate>)_delegate searchBarShouldEndEditing: searchBar];
	}
	//内部逻辑...
	return YES;
}// return NO to not resign first responder

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	//内部逻辑...
	if(0 == searchBar.text.length)
	{
		[self setSearchControllerNotActive];
	}
	
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarTextDidEndEditing:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarTextDidEndEditing: searchBar];
	}
}// called when text ends editing

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	//内部逻辑...
	if(0 < searchBar.text.length)
	{
		if(nil == _searchResultsController.view.superview)
		{
			[self.view addSubview: _searchResultsController.view];
			[self.view bringSubviewToFront: _searchBar];
		}
	}
	else
	{
		[_searchResultsController.view removeFromSuperview];
	}
	
	//回调...
	//updater delegate...
	if(_searchResultsUpdater && [_searchResultsUpdater respondsToSelector: @selector(updateSearchResultsForSearchController:)])
	{
		[_searchResultsUpdater updateSearchResultsForSearchController: self];
	}
	if(_delegate && [_delegate respondsToSelector: @selector(searchBar:textDidChange:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBar: searchBar textDidChange: searchText];
	}
}// called when text changes (including clear)

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0)
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBar:shouldChangeTextInRange:replacementText:)])
	{
		return [(id<UISearchBarDelegate>)_delegate searchBar: searchBar shouldChangeTextInRange: range replacementText: text];
	}
	//内部逻辑...
	return YES;
}// called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	//内部逻辑...
	[self searchBarResignFirstResponder: searchBar];
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarSearchButtonClicked:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarSearchButtonClicked: searchBar];
	}
}// called when keyboard search button pressed

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarBookmarkButtonClicked:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarBookmarkButtonClicked: searchBar];
	}
}// called when bookmark button pressed

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	//内部逻辑...
	[self setSearchControllerNotActive];
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarCancelButtonClicked:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarCancelButtonClicked: searchBar];
	}
}// called when cancel button pressed

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2)
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBarResultsListButtonClicked:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBarResultsListButtonClicked: searchBar];
	}
}// called when search results button pressed

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0)
{
	//内部逻辑...
	//回调...
	if(_delegate && [_delegate respondsToSelector: @selector(searchBar:selectedScopeButtonIndexDidChange:)])
	{
		[(id<UISearchBarDelegate>)_delegate searchBar: searchBar selectedScopeButtonIndexDidChange: selectedScope];
	}
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	if(_active)
	{
		return UIBarPositionTopAttached;
	}
	else
	{
		return UIBarPositionAny;
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
