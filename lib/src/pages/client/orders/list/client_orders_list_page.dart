import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/pages/client/orders/list/client_orders_list_controller.dart';
import 'package:mi_flutter/src/pages/delivery/orders/list/delivery_orders_list_controller.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/list/restaurant_orders_list_controller.dart';

import 'package:mi_flutter/src/widgets/no_data_widget.dart';


class ClientOrdersListPage extends StatefulWidget {


  @override
  _ClientOrdersListPageState createState() => _ClientOrdersListPageState();
}


class _ClientOrdersListPageState extends State<ClientOrdersListPage> {



  ClientOrdersListController  _con =new ClientOrdersListController ();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);


    });
  }


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: _con.status?.length?? 0,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(

            title: Text('Mis pedidos'),
            //automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.red[600],
            bottom: TabBar(
                indicatorColor: Colors.red[500],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[400],
                isScrollable: true,
                tabs: List<Widget>.generate(_con.status.length, (index) {
                  return Tab(
                    child: Text(
                        _con.status[index] ?? ''
                    ),
                  );
                })
            ),


          ),


        ),


        body: TabBarView(
          children: _con.status.map((String status) {

            return FutureBuilder(
                future: _con.getOrders(status),
                builder: (context,AsyncSnapshot<List<Order>> snapshot){

                  if(snapshot.hasData){
                    if(snapshot.data?.length>0){

                      return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),

                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index){
                            return _cardOrder(snapshot.data[index]);
                          }
                      );

                    }else {
                      return NoDataWidget(text:'No hay ordenes');
                    }
                  }
                  else {
                    return NoDataWidget(text:'No hay ordenes');
                  }


                }
            );
          }).toList(),
        ),


      ),
    );


  }

  Widget _cardOrder(Order order){
    return GestureDetector(
      onTap: (){
        _con.openBottomSheet(order);
      },
      child: Container(
        height: 160,
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(15),

          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width*1,
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Orden #${order?.id??''}',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Nimbus Sans'
                        ),
                      ),
                    ),
                  )
              ),
              Container(
                  margin: EdgeInsets.only(top: 40,left: 20,right: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Pedido: 2022-07-30 ',
                          style: TextStyle(
                              fontSize: 13
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Repartidor: ${order.delivery?.username??'No asignado'} ${order.delivery?.lastname??''}',

                          style: TextStyle(
                              fontSize: 13
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Entregar en: ${order.address?.address??''} - ${order.address?.neighborhood??''}',

                          style: TextStyle(
                              fontSize: 13
                          ),
                          maxLines: 2,
                        ),
                      ),

                    ],

                  )

              )
            ],
          ),
        ),
      ),
    );
  }



  void refresh(){
    setState(() {


    });
  }



}
