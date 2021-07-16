import 'dart:async';

import 'package:RehAssistant/constants.dart';
import 'package:RehAssistant/helper/dash_counter.dart';
import 'package:RehAssistant/model/purchasable_product.dart';
import 'package:RehAssistant/model/store_state.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:provider/provider.dart';

import '../main.dart';

class DashPurchases extends ChangeNotifier {
  DashCounter counter;
  StreamSubscription<List<PurchaseDetails>> _subscription;
 // final iapConnection = IAPConnection.instance;
  
  StoreState storeState = StoreState.loading;
List<PurchasableProduct> products = [];
  //
  DashPurchases(this.counter) {
    final purchaseUpdated =  InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    loadPurchases();
  }
   Future<void> loadPurchases() async {
   // final available = await iapConnection.isAvailable();
    final bool available = await InAppPurchase.instance.isAvailable();

    if (!available) {
      storeState = StoreState.notAvailable;
      notifyListeners();
      return;
    }
    const ids = <String>{
      storeKeyConsumable,
      storeKeySubscription,
      //storeKeyUpgrade,
    };
    

    const Set<String> _kIds = <String>{'personal','consume'};
final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(ids);
if (response.notFoundIDs.isNotEmpty) {
  // Handle the error.
}
//List<ProductDetails> products = response.productDetails;
    
    
    
    // final response = await InAppPurchase.instance.queryProductDetails(ids);
    
    products =
        response.productDetails.map((e) => PurchasableProduct(e)).toList();
    storeState = StoreState.available;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    switch (product.id) {
      case storeKeyConsumable:
        await  InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
        break;
      case storeKeySubscription:
        await  InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
        break;
      default:
        throw ArgumentError.value(
            product.productDetails, '${product.id} is not a known product');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach(_handlePurchase);
    notifyListeners();
  }

  void _handlePurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      switch (purchaseDetails.productID) {
        case storeKeySubscription:
          counter.applyPaidMultiplier();
          break;
        case storeKeyConsumable:
          counter.addBoughtDashes(2000);
          break;
        case storeKeyUpgrade:
          //_beautifiedDashUpgrade = true;
          break;
      }
    }

    if (purchaseDetails.pendingCompletePurchase) {
       InAppPurchase.instance.completePurchase(purchaseDetails);
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
  }

}
