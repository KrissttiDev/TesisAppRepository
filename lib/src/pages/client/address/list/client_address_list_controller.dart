import 'package:flutter/material.dart';
import 'package:mi_flutter/src/models/address.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/address_provider.dart';
import 'package:mi_flutter/src/providers/orders_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';

class ClientAddressListController {
  BuildContext context;
  Function refresh;

  Client clientDB;
  SharedPref _sharedPrefDB= new SharedPref();

  List<Address> address = [];
  AddressProvider _addressProvider=new AddressProvider();
  int radioValue=0;

  bool isCreated;

  OrdersProvider _ordersProvider=new OrdersProvider();


  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh=refresh;
    clientDB= Client.fromJson(await _sharedPrefDB.readDB('userDB'));

    _addressProvider.init(context, clientDB);

    _ordersProvider.init(context, clientDB);
    refresh();

  }


  void handleRadioValueChange(int value)async{
    radioValue=value;
    _sharedPrefDB.saveDB('address', address[value]);

    
    refresh();
    print('Valor sellecionado:  ${radioValue }');
  }


  void createOrder() async{
    Address a =Address.fromJson(await _sharedPrefDB.readDB('address')??{});
    List<Product> selectedProducts = Product.fromJsonList(await _sharedPrefDB.readDB('order')).toList;

    Order order = new Order(
      idClient: clientDB.id,
      idAddress:a.id,
      products:selectedProducts,
    );

    ResponseApi responseApi = await _ordersProvider.createDB(order);

    Navigator.pushNamed(context, 'client/payments/create');


    print('Respuest orden: ${responseApi.message}');

  }


  Future<List<Address>> getAddress() async{
    address =await _addressProvider.getByUser(clientDB.id);
    Address a =Address.fromJson(await _sharedPrefDB.readDB('address')??{});
    print('SE GUARDO LA DIRECCION ${a.toJson()}');
    int index = address.indexWhere((ad)=>ad.id==a.id);
    if(index!=-1){
      radioValue=index;
    }
    return address;


  }

  void goToNewAddress()async{
     var result=await Navigator.pushNamed(context,'client/address/create');
     if(result!=null){
       if(result){
         refresh();
       }
     }

  }

}
