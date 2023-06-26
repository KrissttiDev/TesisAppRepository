import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mi_flutter/src/models/order.dart';
import 'package:mi_flutter/src/pages/delivery/orders/list/delivery_orders_list_controller.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/orders/list/restaurant_orders_list_controller.dart';

import 'package:mi_flutter/src/widgets/no_data_widget.dart';


class DeliveryOrdersListPage extends StatefulWidget {


  @override
  _DeliveryOrdersListPageState createState() => _DeliveryOrdersListPageState();
}


class _DeliveryOrdersListPageState extends State<DeliveryOrdersListPage> {



  DeliveryOrdersListController  _con =new DeliveryOrdersListController ();
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
            titleSpacing: 0,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Text('Client List'),


            flexibleSpace: Column(
              children: [
                //SizedBox(height: 40),
                //_menuDrawer(),




              ],
            ),
            bottom: TabBar(
                indicatorColor: Colors.red[500],
                labelColor: Colors.black,
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


        drawer: _drawer(),
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
                          'Cliente: ${order.client?.username??''} ${order.client?.lastname??''}',

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




  Widget _drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(

                  child: Text(
                    _con.clientDB?.username ?? 'Nombre de Usuario',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),


                Container(
                  child: Text(
                    _con.clientDB?.email?? 'Correo Electronico',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10,),
                CircleAvatar(
                  backgroundImage: _con.clientDB?.image!=null?
                  NetworkImage(_con.clientDB?.image)
                      :AssetImage('assets/img/uber_profile.jpg'),
                  radius: 40,
                ),

              ],
            ),
            decoration: BoxDecoration(
              color: Colors.red[600],
            ),
          ),
          ListTile(
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToEditPage,
          ),
          _con.clientDB!=null?
          _con.clientDB?.roles?.length!=1?
          ListTile(
            title: Text('Selecionar Rol'),
            trailing: Icon(Icons.person_outline),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToRoles,
          ):Container():Container(),

          ListTile(
            title: Text('Cerrar Sesion'),
            trailing: Icon(Icons.power_settings_new),
            //leading: Icon(Icons.cancel),
            onTap: _con.logout,
          ),

        ],
      ),
    );
  }






  Widget _buttonDrawer(){
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: Icon(Icons.menu,color: Colors.white,),

      ),
    );

  }



  void refresh(){
    setState(() {


    });
  }



}
