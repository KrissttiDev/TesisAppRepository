import 'package:flutter_test/flutter_test.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/clientD_provider.dart';


ClientDProvider _clientProvider;

void main()async{

  _clientProvider = new ClientDProvider();

  test('login del cliente', () async{
    ResponseApi responseApi =await _clientProvider.loginDB('doni@gmail.com', '123456');
   print(responseApi.message);
   expect(responseApi.message, 'El usuario ha sido autenticado');
    });
}