import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_flutter/src/models/client.dart';

import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/pages/client/orders/detail/client_orders_detail_controller.dart';
import 'package:mi_flutter/src/pages/delivery/orders/detail/delivery_orders_detail_controller.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/detail/restaurant_orders_detail_controller.dart';
import 'package:mi_flutter/src/utils/relative_time_util.dart';
import 'package:mi_flutter/src/widgets/no_data_widget.dart';

class ClientOrdersDetailPage extends StatefulWidget {

  Order order;


    // parametro obligatorio this.order
  ClientOrdersDetailPage({Key key, @required this.order}) : super(key: key);

  @override
  _ClientOrdersDetailPageState createState() => _ClientOrdersDetailPageState();
}

class _ClientOrdersDetailPageState extends State<ClientOrdersDetailPage> {


  ClientOrdersDetailController  _con= new ClientOrdersDetailController ();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh,widget.order);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text(
          'Orden #${_con.order?.id??''}',

        ),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 17,right: 15),
            child: Text(
              'Total: ${_con.total??''}\ Bs.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),

            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height*0.4,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color:  Colors.grey,
                endIndent: 30, //margen derecha
                indent: 30,
              ),
              SizedBox(height: 15,),
              _textData('Repartidor: ','${_con.order?.delivery?.username??''}' '${_con.order?.delivery?.lastname??''}'),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 1,),
                child: //Text('cleinte')
                _textData('Cliente:', '${_con.order?.client?.username??''} ${_con.order?.client?.lastname??''}'),

              ),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 5),

                child: //Text('cleinte')


                _textData('Entregar en: ', '${_con.order?.address?.address??''} - ${_con.order?.address?.neighborhood??''}'),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.only(top: 5),

                child: //Text('cleinte')
                _textData('Fecha de pedido: ', '${RelativeTimeUtil.getRelativeTime(_con.order?.timestamp??0)}'),
              ),

              //_con.order?.status == 'PAGADO' || _con.order?.status == 'POR COBRAR' ? _buttonNext():Container(),
              _con.order?.status=='EN CAMINO'?_buttonNext():Container(),



            ],
          ),
        ),
      ),

      body:  _con.order?.products?.length!=null
          ? ListView(
        children: _con.order?.products?.map((Product product) {
          return _cardProduct(product);
        }).toList(),
      )
          : NoDataWidget(text: 'Ningun producto agregado') ,

    );

  }








  Widget _textData(String title, String content){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
            content,
          maxLines: 2,
        ),
        minLeadingWidth : 1,
      )
    );
  }




  Widget _cardProduct(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(product),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.name ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Cantidad: ${product?.quantity??''}',
                style: TextStyle(
                    fontSize: 13
                ),
              ),

            ],
          ),

        ],
      ),

    );

  }








  Widget _buttonNext(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30,top:20, bottom: 20),
      child: ElevatedButton(
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary:Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: Stack(
          children: [
            Align(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(

                 'SEGUIR ENTREGA',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50,top:2),
                height: 30,
                child:  Icon(
                  Icons.directions_car,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }






  Widget _imageProduct(Product product) {
    return Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey[200]
      ),
      child: FadeInImage(
        image: product.image1 != null
            ? NetworkImage(product.image1)
            : AssetImage('assets/img/no_image.jpg'),
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 50),
        placeholder: AssetImage('assets/img/no_image.jpg'),
      ),
    );
  }


   void refresh(){
    setState(() {

    });
  }
}
