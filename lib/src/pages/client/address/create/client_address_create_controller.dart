import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/models/address.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/pages/client/address/map/client_address_map_page.dart';
import 'package:mi_flutter/src/providers/address_provider.dart';
import 'package:mi_flutter/src/utils/share_pref.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientAddressCreateController {
  BuildContext context;
  Function refresh;
  Client clientDB;
  SharedPref _sharedPrefDB;

  AddressProvider _addressProvider= new AddressProvider();

  TextEditingController refPointController= new TextEditingController();
  TextEditingController addressController= new TextEditingController();
  TextEditingController neighborhoodController= new TextEditingController();

  Map<String,dynamic> refPoint;


  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh=refresh;
    _sharedPrefDB=new SharedPref();
    clientDB = Client.fromJson(await _sharedPrefDB.readDB('userDB'));
    _addressProvider.init(context, clientDB);

  }


  void createAddress()async{
    String addressName= addressController.text;
    String neighborhood= neighborhoodController.text;
    double lat= refPoint['lat']??0;
    double lng= refPoint['lng']??0;
    print('=================================');
    print(clientDB.id);

    if(addressName.isEmpty||neighborhood.isEmpty||lat==0||lng==0){
      Fluttertoast.showToast(msg: 'Completa todos los campos');
    }

    Address address= new Address(
      address: addressName,
      neighborhood: neighborhood,
      lat: lat,
      lng: lng,
      idUser: clientDB.id
    );

    ResponseApi responseApi = await _addressProvider.createDB(address);
    
    if(responseApi.success){

      address.id=responseApi.data;
      _sharedPrefDB.saveDB('address', address);

      Fluttertoast.showToast(msg: responseApi.message);
      Navigator.pop(context,true);
    }
    
    
  }

  void openMap() async{

    refPoint=await  showMaterialModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context)=>ClientAddressMapPage()
    );
    if(refPoint!=null){
      refPointController.text=refPoint['address'];
      refresh();
    }
  }
}
