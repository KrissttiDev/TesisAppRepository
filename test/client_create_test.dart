import 'package:flutter_test/flutter_test.dart';
import 'package:mi_flutter/src/models/client.dart';
import 'package:mi_flutter/src/models/response_api.dart';
import 'package:mi_flutter/src/providers/clientD_provider.dart';

ClientDProvider _clientProvider;
void main()async{
  _clientProvider = new ClientDProvider();
  Client client = new Client(

    email: 'pedro@gmail.com',
    username: 'Pedro',
    lastname: 'Prueba',
    password: '123456',
    phone: '12457889',
  );
  test('creacion del cliente', () async{
    ResponseApi responseApi =await _clientProvider.createDB(client);
    print(responseApi.message);
    expect(responseApi.message, 'El registro se realizo correctamente');
  });
}