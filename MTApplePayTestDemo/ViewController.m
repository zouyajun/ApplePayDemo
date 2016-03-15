//
//  ViewController.m
//  MTApplePayTestDemo
//
//  Created by Ryan on 16/2/23.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
}

@property (nonatomic, strong)   UIButton    *payBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.frame = CGRectMake(100, 100, 100, 50);
    payBtn.backgroundColor = [UIColor orangeColor];
    [payBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
    self.payBtn = payBtn;
}
#pragma mark - 购买事件
- (void)payBtnClick:(UIButton *)sender
{
    if([PKPaymentAuthorizationViewController canMakePayments]) {
        
        NSLog(@"Woo! Can make payments!");
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 1"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"0.99"]];
        
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"Widget 2"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
        
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total"
                                                                          amount:[NSDecimalNumber decimalNumberWithString:@"1.99"]];
        
        request.paymentSummaryItems = @[widget1, widget2, total];
        request.countryCode = @"US";
        request.currencyCode = @"USD";
        //  此属性限制支付卡，可以支付。PKPaymentNetworkChinaUnionPay支持中国的卡 9.2增加的
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
        request.merchantIdentifier = @"merchant.com.demo.crittercismdemo";
        /*
         *  PKMerchantCapabilityCredit NS_ENUM_AVAILABLE_IOS(9_0)   = 1UL << 2,   // 支持信用卡
         *  PKMerchantCapabilityDebit  NS_ENUM_AVAILABLE_IOS(9_0)   = 1UL << 3    // 支持借记卡
         */
        request.merchantCapabilities = PKMerchantCapabilityEMV;
        //  增加邮箱及地址信息
        request.requiredBillingAddressFields = PKAddressFieldEmail | PKAddressFieldPostalAddress;
        PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentPane.delegate = self;
        [self presentViewController:paymentPane animated:TRUE completion:nil];
        
    } else {
        NSLog(@"This device cannot make payments");
    }
}
#pragma mark - 支付状态、授权认证
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSLog(@"Payment was authorized: %@", payment);
    
    // do an async call to the server to complete the payment.
    // See PKPayment class reference for object parameters that can be passed
    BOOL asyncSuccessful = FALSE;
    
    // When the async call is done, send the callback.
    // Available cases are:
    //    PKPaymentAuthorizationStatusSuccess, // Merchant auth'd (or expects to auth) the transaction successfully.
    //    PKPaymentAuthorizationStatusFailure, // Merchant failed to auth the transaction.
    //
    //    PKPaymentAuthorizationStatusInvalidBillingPostalAddress,  // Merchant refuses service to this billing address.
    //    PKPaymentAuthorizationStatusInvalidShippingPostalAddress, // Merchant refuses service to this shipping address.
    //    PKPaymentAuthorizationStatusInvalidShippingContact        // Supplied contact information is insufficient.
    
    if(asyncSuccessful) {
        completion(PKPaymentAuthorizationStatusSuccess);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was successful");
        
        //        [Crittercism endTransaction:@"checkout"];
        
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was unsuccessful");
        
        //        [Crittercism failTransaction:@"checkout"];
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"Finishing payment view controller");
    
    // hide the payment window
    [controller dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
