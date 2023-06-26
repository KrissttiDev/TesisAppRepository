import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';

class ClientOrdersCreateController {

  BuildContext context;
  Function refresh;
  Product product;


  int counter=1;

  double total=0;
  SharedPref _sharedPrefCDB= new SharedPref();
  List<Product> selectedProducts =[];
  List<Product> PselectedProducts =[];

  Future init(BuildContext context,Function refresh)async{
    this.context= context;
    this.refresh=refresh;
    selectedProducts = Product.fromJsonList(await _sharedPrefCDB.readDB('order')).toList;

    refresh();
    getTotal();
  }

  void getTotal() {
    total = 0;
    selectedProducts.forEach((product) {
      total = total + (product.quantity * product.price);
    });
    refresh();
  }

  void addItem(Product product){
    int index =selectedProducts.indexWhere((p) => p.id==product.id);
    //que producto estmaos modificando
    selectedProducts[index].quantity=selectedProducts[index].quantity+1;
    _sharedPrefCDB.saveDB('order', selectedProducts);
    getTotal();


  }

  void removeItem(Product product){
    if(product.quantity>1){
      int index =selectedProducts.indexWhere((p) => p.id==product.id);
      //que producto estmaos modificando
      selectedProducts[index].quantity=selectedProducts[index].quantity-1;
      _sharedPrefCDB.saveDB('order', selectedProducts);
      getTotal();

    }


  }

  void goToAddress(){
    Navigator.pushNamed(context, 'client/address/list');
  }

  void deleteItem(Product product){
    selectedProducts.removeWhere((p) => p.id==product.id);
    _sharedPrefCDB.saveDB('order', selectedProducts);
    getTotal();
    

  }


















}