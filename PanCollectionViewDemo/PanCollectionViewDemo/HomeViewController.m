//
//  HomeViewController.m
//  PanCollectionViewDemo
//
//  Created by 宋志明 on 15-4-28.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

#import "HomeViewController.h"
#import "PhotoSelectCollectionViewCell.h"

@interface HomeViewController ()
@property (strong,nonatomic) NSMutableArray *assets;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.assets = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8", nil];
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"PhotoSelectCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PhotoSelectCollectionViewCell"];
//    self.photoCollectionView.allowsMultipleSelection = YES;
    UICollectionViewFlowLayout *categoryFlowLayout = (UICollectionViewFlowLayout *)self.photoCollectionView.collectionViewLayout;
    int width  = ([[UIScreen mainScreen] bounds].size.width-10)/4;
    int height = width;
    categoryFlowLayout.itemSize = CGSizeMake(width, height);
    categoryFlowLayout.minimumInteritemSpacing = 2 ;
    categoryFlowLayout.minimumLineSpacing = 2 ;
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.photoCollectionView addGestureRecognizer:longPress];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
}

//长按手势
- (IBAction)longPressGestureRecognized:(id)sender {
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    
    static UIView       *view ;
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:self.photoCollectionView];
    NSIndexPath *indexPath = [self.photoCollectionView indexPathForItemAtPoint:location];
    if (state  == UIGestureRecognizerStateBegan) {//begin fenzhi
        if (indexPath) {
            sourceIndexPath = indexPath;
            
            PhotoSelectCollectionViewCell *cell = (PhotoSelectCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:indexPath];
            
            // Take a snapshot of the selected row using helper method.
            snapshot = [self customSnapshotFromView:cell];
            
            // Add the snapshot as subview, centered at cell's center...
            __block CGPoint center = cell.center;
            snapshot.center = center;
            snapshot.alpha = 0.0;
            [self.photoCollectionView addSubview:snapshot];
            [UIView animateWithDuration:0.25 animations:^{
                
                // Offset for gesture location.
                center.y = location.y;
                snapshot.center = center;
                snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapshot.alpha = 0.98;
                view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                view.backgroundColor = [UIColor redColor];
                NSLog(@"11===%@",view);
                [cell addSubview:view];
                // Black out.
                
//                cell.backgroundColor = [UIColor redColor];
            } completion:nil];
        }
    }else if(state == UIGestureRecognizerStateChanged){

        CGPoint center = snapshot.center;
        center.y = location.y;
        center.x = location.x;
        snapshot.center = center;
        // Is destination valid and is it different from source?
        if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
            
            // ... update data source.
            [self.assets exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
            
            // ... move the rows.
            [self.photoCollectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
            
            // ... and update source so it is in sync with UI changes.
            sourceIndexPath = indexPath;
        }
    }else{
        // Clean up.
        PhotoSelectCollectionViewCell *cell = (PhotoSelectCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.25 animations:^{
            [view removeFromSuperview];
            snapshot.center = cell.center;
            snapshot.transform = CGAffineTransformIdentity;
            snapshot.alpha = 0.0;
            
            // Undo the black-out effect we did.
//            cell.backgroundColor = [UIColor whiteColor];
            
        } completion:^(BOOL finished) {
            
            [snapshot removeFromSuperview];
            snapshot = nil;
            
        }];
        sourceIndexPath = nil;
    }
    // More coming soon...
}

- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    snapshot.backgroundColor = [UIColor greenColor];
    return snapshot;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Collection View Data Source


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.assets.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoSelectCollectionViewCell *cell =(PhotoSelectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoSelectCollectionViewCell" forIndexPath:indexPath ];
    cell.label.text = [self.assets objectAtIndex:indexPath.row];
    return cell;
};

@end
