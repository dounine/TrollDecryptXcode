#import "TDFileManagerViewController.h"
#import "TDRootViewController.h"
#import "TDUtils.h"

@implementation TDRootViewController

- (void)loadView {
    [super loadView];

    self.apps = appList();
    self.title = @"TrollDecrypt++";
    //    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"folder"] style:UIBarButtonItemStylePlain target:self action:@selector(openDocs:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(about:)];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshApps:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    //增加搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    searchBar.placeholder = @"输入包名或者应用名称";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;

    //创建搜索控制器
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    self.searchController.searchResultsUpdater = self;//设置代理对象
//    self.searchController.dimsBackgroundDuringPresentation = NO;//搜索时背景变暗
//    self.searchController.delegate = self;
//    [self.searchController.searchBar sizeToFit];
//    self.tableView.tableHeaderView = self.searchController.searchBar;
//    self.definesPresentationContext = YES;//设置搜索时，可以覆盖当前视图
}

// on search action
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar.text.length == 0) {
        return;
    }
    NSMutableArray *searchResult = [NSMutableArray array];
    NSArray *apps = appList();
    for (NSDictionary *app in apps) {
        NSString *searchText = [[searchBar.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([[app[@"name"] lowercaseString] containsString:searchText] || [app[@"bundleID"] containsString:searchText]) {
            [searchResult addObject:app];
        }
    }
//    [self alertDialog:[NSString stringWithFormat:@"搜索到%lu个结果", (unsigned long) searchResult.count]];
    self.apps = searchResult;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar afterDelay:0];
    }
}

// on cancel action
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.apps = appList();
    [self.tableView reloadData];
}

- (void)viewDidAppear:(bool)animated {
    [super viewDidAppear:animated];

//    fetchLatestTrollDecryptVersion(^(NSString *latestVersion) {
//        NSString *currentVersion = trollDecryptVersion();
//        NSComparisonResult result = [currentVersion compare:latestVersion options:NSNumericSearch];
//        NSLog(@"[trolldecrypter] Current version: %@, Latest version: %@", currentVersion, latestVersion);
//        if (result == NSOrderedAscending) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Available" message:@"An update for TrollDecrypt is available." preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//                UIAlertAction *update = [UIAlertAction actionWithTitle:@"Download"
//                                                                 style:UIAlertActionStyleDefault
//                                                               handler:^(UIAlertAction *action) {
//                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/donato-fiore/TrollDecrypt/releases/latest"]] options:@{} completionHandler:nil];
//                                                               }];
//
//                [alert addAction:update];
//                [alert addAction:cancel];
//                [self presentViewController:alert animated:YES completion:nil];
//            });
//        }
//    });
}

- (void)openDocs:(id)sender {
    TDFileManagerViewController *fmVC = [[TDFileManagerViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fmVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)about:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TrollDecrypt++" message:@"lake" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshApps:(UIRefreshControl *)refreshControl {
    self.apps = appList();
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AppCell";
    UITableViewCell *cell;
//    if (indexPath.row == 0) {
    //增加一个搜索框
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//        searchBar.placeholder = @"搜索";
//        [cell.contentView addSubview:searchBar];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//        cell.textLabel.text = @"手动";
//        cell.detailTextLabel.text = @"根据进程PID进行解密";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//
//    } else {
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    NSDictionary *app = self.apps[(NSUInteger) indexPath.row];

    cell.textLabel.text = app[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", app[@"version"], app[@"bundleID"]];
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:app[@"bundleID"] format:iconFormat() scale:[UIScreen mainScreen].scale];
//    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert;

//    if (indexPath.row == 0) {
//        alert = [UIAlertController alertControllerWithTitle:@"Decrypt" message:@"Enter PID to decrypt" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"PID";
//            textField.keyboardType = UIKeyboardTypeNumberPad;
//        }];
//
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//        UIAlertAction *decrypt = [UIAlertAction actionWithTitle:@"Decrypt"
//                                                          style:UIAlertActionStyleDefault
//                                                        handler:^(UIAlertAction *action) {
//                                                            NSString *pid = alert.textFields.firstObject.text;
//                                                            decryptAppWithPID([pid intValue]);
//                                                        }];
//
//        [alert addAction:decrypt];
//        [alert addAction:cancel];
//
//    } else {
    NSDictionary *app = self.apps[(NSUInteger) indexPath.row];

//    NSString *app_str = [NSString stringWithFormat:@"%@", app];
    alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"解密：%@?\n", app[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *decrypt = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        NSMutableDictionary *callback = [NSMutableDictionary dictionary];
                                                        decryptApp(app, callback);
                                                    }];

    [alert addAction:decrypt];
    [alert addAction:cancel];
//    }

    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertDialog:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                               }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    if (!searchController.active) {
//        return;
//    }
//    self.filterString = searchController.searchBar.text;
//}


@end
