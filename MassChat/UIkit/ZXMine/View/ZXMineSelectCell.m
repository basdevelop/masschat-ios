#import "ZXMineSelectCell.h"

@interface ZXMineSelectCell()

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation ZXMineSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)cellWithIndexPath:(NSIndexPath*)indexpath
{
        if (indexpath.section == 1) {
                if (indexpath.row == 0) {
                        _image.image = [UIImage imageNamed:@"music_ic"];
                        _title.text = @"音乐";
                        self.tag = 10;
                }
        }
        if(indexpath.section == 2){
                if(indexpath.row == 0){
                        _title.text = @"职业信息";
                        _image.image = [UIImage imageNamed:@"Occupation_ic"];
                        self.tag = 20;
                }else if(indexpath.row == 1){
                        _title.text = @"关联微信";
                        _image.image = [UIImage imageNamed:@"wechat_ic"];
                        self.tag = 21;
                }
                else if(indexpath.row == 2){
                        _title.text = @"使用帮助";
                        _image.image = [UIImage imageNamed:@"help_ic"];
                        self.tag = 22;
                }
        }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
