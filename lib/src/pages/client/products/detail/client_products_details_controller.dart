import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';

class ClientProductsDetailControler {

  BuildContext context;
  Function refresh;
  Product product;


  int counter=1;
  double productPrice;
  SharedPref _sharedPrefCDB= new SharedPref();
  List<Product> selectedProducts =[];

  Future init(BuildContext context,Function refresh, Product product)async{
    this.context= context;
    this.refresh=refresh;
    this.product=product;
    productPrice=product.price;

    //_sharedPrefCDB.removeDB('order');

    selectedProducts= Product.fromJsonList(await _sharedPrefCDB.readDB('order')).toList;
    selectedProducts.forEach((p) {
      print('Producto Seleccionado: ${p.toJson()}');
    });
    refresh();
  }

  void addItem(){
    counter++;
    productPrice=product.price*counter;
    product.quantity=counter;
    refresh();
  }
  void removeItem(){

    if(counter>1){
      counter--;
      productPrice=product.price*counter;
      product.quantity=counter;
      refresh();
    }

  }

  void addToBag(){
    int index =selectedProducts.indexWhere((p) => p.id==product.id);
    if(index== -1){ // Productos selleccionaods no existe ese producto
      if(product.quantity==null){
        product.quantity=1;
      }
      selectedProducts.add(product);

    }
    else{
      selectedProducts[index].quantity=counter;
    }

    _sharedPrefCDB.saveDB('order', selectedProducts);
    Fluttertoast.showToast(msg: 'Producto Agregado ');
  }




  void close(){
    Navigator.pop(context); //metodo para cerrar

  }





}