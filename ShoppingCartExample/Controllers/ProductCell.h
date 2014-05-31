//
//  ProductCell.h
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/31/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "BButton.h"

@interface ProductCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productTitle;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet BButton *addToCartButton;

@end
