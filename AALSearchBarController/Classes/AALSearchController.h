//
//  AALSearchController.h
//  AALSearchBarController
//
//  Created by Aalen on 15/11/27.
//  Copyright © 2015年 Aalen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AALSearchController;

@protocol AALSearchControllerDelegate <NSObject>
@optional
// These methods are called when automatic presentation or dismissal occurs. They will not be called if you present or dismiss the search controller yourself.
- (void)willPresentSearchController:(AALSearchController *)searchController;
- (void)didPresentSearchController:(AALSearchController *)searchController;
- (void)willDismissSearchController:(AALSearchController *)searchController;
- (void)didDismissSearchController:(AALSearchController *)searchController;

// Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
//- (void)presentSearchController:(AALSearchController *)searchController;
@end

@protocol AALSearchResultsUpdating <NSObject>
@required
// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
- (void)updateSearchResultsForSearchController:(AALSearchController *)searchController;
@end

@interface AALSearchController : UIViewController

@property (weak, nonatomic) id<AALSearchControllerDelegate> delegate;
@property (weak, nonatomic) id<AALSearchResultsUpdating> searchResultsUpdater;
@property (nonatomic, assign, getter = isActive) BOOL active;
@property (strong, readonly, nonatomic) UISearchBar *searchBar;
@property (strong, readonly, nonatomic) UIViewController *searchResultsController;

- (instancetype)initWithSearchResultsController: (UIViewController *)viewController;
//- (instancetype)initWithViewController: (UIViewController *)viewController;

@end
