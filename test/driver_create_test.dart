import 'package:flutter_test/flutter_test.dart';
import 'package:mi_flutter/src/models/driver.dart';
import 'package:mi_flutter/src/models/response_api.dart';

import 'package:mi_flutter/src/providers/driverD_provider.dart';

DriverDProvider _driverDProvider;

void main()async{
  _driverDProvider = new DriverDProvider();

  Driver driver = new Driver(

    email: 'poncio@gmail.com',
    username: 'poncio',
    lastname: 'Prueba',
    password: '123456',
    plate:'FRT-7832',
    phone: '23568978',
  );
  test('creacion del conductor', () async{
    ResponseApi responseApi = await _driverDProvider.createDB(driver);
    print(responseApi.message);
    expect(responseApi.message, 'El registro se realizo correctamente');
  });
}