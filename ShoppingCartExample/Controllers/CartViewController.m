//
//  CartViewController.m
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 6/1/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "CartViewController.h"
#import "CheckoutHeaderview.h"
#import "ProductCartCell.h"
#import "Cart.h"
#import "CartItem.h"
#import "AppDelegate.h"
#import "PayPalMobile.h"

@interface CartViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic, readwrite) PayPalConfiguration *payPalConfiguration;

-(void) deleteProduct:(UIButton *)button;
-(void) checkout:(UIButton *)button;
-(void) verifyCompletedPayment:(PayPalPayment *)completedPayment;
@end

@implementation CartViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView registerNib:[UINib nibWithNibName:@"ProductCartCell" bundle:nil] forCellReuseIdentifier:@"ProductCartCell"];

    self.navigationItem.title = @"Cart";

    [self loadItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [PayPalMobile initializeWithClientIdsForEnvironments:
            @{PayPalEnvironmentProduction : kPayPalEnvironmentProduction,
                    PayPalEnvironmentSandbox : kPayPalEnvironmentSandbox}];

    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCartCell";

    ProductCartCell *cell = (ProductCartCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    CartItem *item = [self.items objectAtIndex:[indexPath row]];
    
    // Configure the cell...
    cell.productImage.image = [UIImage imageNamed:item.product.image];
    cell.productImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.productTitle.text = item.product.name;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    cell.productPrice.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithDouble:item.product.price]]];

    cell.quantity.text = [NSString stringWithFormat:@"%d", item.quantity];

    [cell.deleteButton addTarget:self action:@selector(deleteProduct:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = [indexPath row];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CheckoutHeaderView" owner:self options:nil];
    CheckoutHeaderview *checkoutHeaderview = [nib objectAtIndex:0];

    checkoutHeaderview.subtotal.text = [NSString stringWithFormat:@"Subtotal (%d):", [Cart totalProducts]];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    checkoutHeaderview.total.text = [NSString stringWithFormat:@"$%@", [formatter stringFromNumber:[NSNumber numberWithDouble:[Cart totalAmount]]]];

    [checkoutHeaderview.checkoutButton addTarget:self action:@selector(checkout:) forControlEvents:UIControlEventTouchUpInside];

    return checkoutHeaderview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70.0f;
}

#pragma mark - Utilities methods

- (void)loadItems
{
    self.items = [Cart contents];
    [self.tableView reloadData];
}

- (void)deleteProduct:(UIButton *)button
{
    CartItem *item = [self.items objectAtIndex:button.tag];
    BOOL success = [Cart removeProduct:item.product];

    if(success)
    {
        [self.tableView beginUpdates];
        [self.items removeObjectAtIndex:button.tag];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

        [self.tableView reloadData];

        [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateCartTabBadge];
    }
}

- (void)checkout:(UIButton *)button
{
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];

    // Amount, currency, and description
    payment.amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[Cart totalAmount]] decimalValue]];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Cool T-Shirts";

    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture. To perform Authorization only,
    // and defer Capture to your server, use PayPalPaymentIntentAuthorize.
    payment.intent = PayPalPaymentIntentSale;

    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Payment not processable"
                                                            message:@"The payment is not processable"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

        return;
    }

    // Create a PayPalPaymentViewController.
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:self.payPalConfiguration
                                                                        delegate:self];

    // Present the PayPalPaymentViewController.
    [self.navigationController presentViewController:paymentViewController animated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment
{
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];

    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}


#pragma mark - PayPalPayment Delegate

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Payment cancelled" message:@"The payment was cancelled"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment
{
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];

    // clear cart
    [Cart clearCart];
    [self.items removeAllObjects];
    [self.tableView reloadData];

    [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateCartTabBadge];

    // Dismiss the PayPalPaymentViewController.
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Payment made" message:@"The payment was successfully made"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
