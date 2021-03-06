//
//  QYSettingsTableVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYSettingsTableVC.h"
#import "QYAccount.h"
#import "AppDelegate.h"
#import "QYNetworkManager.h"
#import "QYAgeRangeCell.h"
#import <Masonry.h>
#import <AVFile.h>

@interface QYSettingsTableVC ()
@property (strong, nonatomic) QYUserInfo *myInfo;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UISwitch *manSw;
@property (weak, nonatomic) IBOutlet UISwitch *womanSw;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSw;

@property (strong, nonatomic) UILabel *distanceRangeLabel;
@property (strong, nonatomic) UILabel *minAgeLabel;
@property (strong, nonatomic) UILabel *maxAgeLabel;

@end

@implementation QYSettingsTableVC

#pragma mark - Life Cycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    if ( revealViewController )
    {
        [self.leftBarButtonItem setTarget: revealViewController];
        [self.leftBarButtonItem setAction: @selector(revealToggle:)];
        
        [self.rightBarButtonItem setTarget: revealViewController];
        [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
    }
    
    _logoutBtn.layer.cornerRadius = 5;
    _logoutBtn.layer.borderColor = [UIColor redColor].CGColor;
    _logoutBtn.layer.borderWidth = .5f;
    
    
    [_manSw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kFilterKeySex]];
    [_womanSw setOn:!_manSw.on];
    _distanceSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:kFilterKeyDistance];
    [_vibrateSw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"vibrate"]];
}

-(void)dealloc{
    QYAgeRangeCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [cell removeObserver:self forKeyPath:@"minAge"];
    [cell removeObserver:self forKeyPath:@"maxAge"];
}

#pragma mark - Events

- (IBAction)logout:(UIButton *)sender {
    [[QYAccount currentAccount] logout];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app setRootViewControllerToEntrance];
}

- (IBAction)selectSexAction:(UISwitch *)sender {
    if (sender == _manSw) {
        [_womanSw setOn:!sender.isOn animated:YES];
    }else{
        [_manSw setOn:!sender.isOn animated:YES];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:_manSw.on forKey:kFilterKeySex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)distanceSliderValueChangedAction:(UISlider *)sender {
    _distanceRangeLabel.text = sender.value < sender.maximumValue ? [NSString stringWithFormat:@"%.fkm", sender.value] : [NSString stringWithFormat:@"%ldkm+", (NSInteger)sender.value];
    [[NSUserDefaults standardUserDefaults] setInteger:sender.value forKey:kFilterKeyDistance];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)vibrateAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"vibrate"];
}


#pragma mark - Custom Methods

//配置每组的头视图标题
-(UILabel *)titleForHeaderView:(UIView *)headerView{
    UILabel *title = [[UILabel alloc] init];
    title.textColor = [UIColor grayColor];
    title.font = [UIFont systemFontOfSize:18];
    [headerView addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headerView.mas_leading).offset(20);
        make.bottom.equalTo(headerView.mas_bottom).offset(-5);
    }];
    
    return title;
}

//配置“搜索年龄”的头视图
-(void)configSubviewsForHeaderViewOfAgeSection:(UIView *)headerView{
    [headerView addSubview:self.maxAgeLabel];
    [self.maxAgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(headerView.mas_trailing).offset(-20);
        make.bottom.equalTo(headerView.mas_bottom).offset(-5);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @" - ";
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.maxAgeLabel.mas_leading);
        make.bottom.equalTo(headerView.mas_bottom).offset(-5);
    }];
    
    [headerView addSubview:self.minAgeLabel];
    [self.minAgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(label.mas_leading);
        make.bottom.equalTo(headerView.mas_bottom).offset(-5);
    }];
}


#pragma mark - UITableView Delegate & Datasource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    UILabel *title = [self titleForHeaderView:headerView];
    
    switch (section) {
        case 0:
            title.text = @"向我显示：";
            break;
            
        case 1:{
            title.text = @"搜索范围：";
            
            [headerView addSubview:self.distanceRangeLabel];
            NSInteger distance = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterKeyDistance];
            self.distanceRangeLabel.text = [NSString stringWithFormat:@"%ldkm", distance];
            if (distance == 100) {
                self.distanceRangeLabel.text = @"100km+";
            }
            
            //布局
            [self.distanceRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(headerView.mas_trailing).offset(-20);
                make.bottom.equalTo(headerView.mas_bottom).offset(-5);
            }];
        }
            break;
            
        case 2:{
            title.text = @"显示年龄：";
            
            [self configSubviewsForHeaderViewOfAgeSection:headerView];
            
            QYAgeRangeCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            [cell addObserver:self forKeyPath:@"minAge" options:NSKeyValueObservingOptionNew context:NULL];
            [cell addObserver:self forKeyPath:@"maxAge" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.minAgeLabel.text = [NSString stringWithFormat:@"%ld", cell.minAge];
            self.maxAgeLabel.text = [NSString stringWithFormat:@"%ld", cell.maxAge];
            if (cell.maxAge == 50) {
                self.maxAgeLabel.text = @"50+";
            }
            
        }
            break;
            
        case 3:
            title.text = @"推送通知：";
            break;
            
        case 4:
            title.text = @"缓存：";
            break;
            
        case 5:
            title.text = @"账户信息：";
            break;
            
        default:
            break;
    }
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 4) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [SVProgressHUD showSuccessWithStatus:@"正在清理缓存..."];
            [AVFile clearAllCachedFiles];
            [SVProgressHUD showSuccessWithStatus:@"缓存已清除"];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.detailTextLabel.text = @"0MB";
        }];
        [controller addAction:action];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [controller addAction:action1];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"minAge"]) {
        NSInteger minAge = [change[@"new"] integerValue];
        self.minAgeLabel.text = [NSString stringWithFormat:@"%ld", minAge];
        
        [[NSUserDefaults standardUserDefaults] setInteger:minAge forKey:kFilterKeyMinAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if ([keyPath isEqualToString:@"maxAge"]) {
        NSInteger maxAge = [change[@"new"] integerValue];
        if (maxAge == 50) {
            self.maxAgeLabel.text = [NSString stringWithFormat:@"%ld+", maxAge];
        }else{
            self.maxAgeLabel.text = [NSString stringWithFormat:@"%ld", maxAge];
        }

        [[NSUserDefaults standardUserDefaults] setInteger:maxAge forKey:kFilterKeyMaxAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
}

#pragma mark - Getters
-(UILabel *)distanceRangeLabel{
    if (_distanceRangeLabel == nil) {
        UILabel *range = [[UILabel alloc] init];
        range.font = [UIFont boldSystemFontOfSize:14];
        _distanceRangeLabel = range;
    }
    return _distanceRangeLabel;
}

-(UILabel *)minAgeLabel{
    if (_minAgeLabel == nil) {
        UILabel *range = [[UILabel alloc] init];
        range.font = [UIFont boldSystemFontOfSize:14];
        _minAgeLabel = range;
    }
    return _minAgeLabel;
}

-(UILabel *)maxAgeLabel{
    if (_maxAgeLabel == nil) {
        UILabel *range = [[UILabel alloc] init];
        range.font = [UIFont boldSystemFontOfSize:14];
        _maxAgeLabel = range;
    }
    return _maxAgeLabel;
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
