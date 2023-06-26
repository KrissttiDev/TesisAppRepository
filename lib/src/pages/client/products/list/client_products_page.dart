import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/pages/client/products/list/client_products_controller.dart';
import 'package:mi_flutter/src/widgets/no_data_widget.dart';






class ClientProductsListPage extends StatefulWidget {


  @override
  _ClientProductsListPageState createState() => _ClientProductsListPageState();
}


class _ClientProductsListPageState extends State<ClientProductsListPage> {



  ClientProductsListController _con =new ClientProductsListController();
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
      length: _con.categories?.length,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(170),
          child: AppBar(
            titleSpacing: 0,




            iconTheme: IconThemeData(color: Colors.black),

            backgroundColor: Colors.white,
            title: Text('Client List'),
            actions: [
              _shoppingBag(),

            ],

            flexibleSpace: Column(
              children: [
                //SizedBox(height: 40),
                //_menuDrawer(),
                SizedBox(height: 80),
                _textFieldSearch(),


              ],
            ),
            bottom: TabBar(
              indicatorColor: Colors.red[500],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categories.length, (index) {
                return Tab(
                  child: Text(
                    _con.categories[index].name ?? ''
                  ),
                );
              })
            ),


          ),


        ),


        drawer: _drawer(),
        body: TabBarView(
          children: _con.categories.map((Category category) {
                return FutureBuilder(
                  future: _con.getProducts(category.id,_con.productName),
                    builder: (context,AsyncSnapshot<List<Product>> snapshot){

                    if(snapshot.hasData){
                      if(snapshot.data.length>0){

                        return GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7
                            ),
                            itemCount: snapshot.data?.length??0,
                            itemBuilder: (_, index){
                              return _cardProduct(snapshot.data[index]);
                            }
                        );

                      }else {
                        return NoDataWidget(text:'No hay productos');
                      }
                    }
                    else {
                      return NoDataWidget(text:'No hay productos');
                    }


                    }
                );
          }).toList(),
        ),


      ),
    );
  }

  Widget _cardProduct(Product product){
    return GestureDetector(
      onTap: (){
        _con.openBottomSheet(product);
      },
      child: Container(
        height: 250,

        child: Card(

          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -1.0,
                  right: -1.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red[500],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topRight: Radius.circular(20)
                      )
                    ),
                    child: Icon(Icons.add,color: Colors.white,),
                  )
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(

                    height: 150,
                    margin: EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width*0.45,
                    padding: EdgeInsets.all(20),
                    child: FadeInImage(
                      image: product.image1!=null
                          ? NetworkImage(product.image1)
                          :AssetImage('assets/img/no_image.jpg'),
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no_image.jpg'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 33,
                    child: Text(
                      product.name?? 'Nombre del producto ',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NimbusSans'
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
                    child: Text(
                        '${product.price??0}\$',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NimbusSans',
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _shoppingBag(){
   return GestureDetector(
     onTap: _con.goToCreatePage,
     child: Stack(
       children: [
         Container(
           margin: EdgeInsets.only(right:15,top: 13),
           child: Icon(
             Icons.shopping_bag_outlined,
             color: Colors.black,

           ),
         ),
         Positioned(
           right: 16,
             top: 15,

             child: Container(
               width: 9,
                 height: 9,
               decoration: BoxDecoration(
                 color: Colors.green,
                 borderRadius: BorderRadius.all(Radius.circular(30)),
               ),

             ),
         ),
       ],
     ),
   );
  }


  Widget _textFieldSearch(){
    return Container(
      margin:EdgeInsets.symmetric(horizontal: 20) ,
      child: TextField(
        onChanged: _con.onChangedText,
        decoration: InputDecoration(
          hintText: 'Buscar',
          suffixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          hintStyle: TextStyle(
            fontSize: 17,
            color: Colors.grey[500]
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[300],
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[300],
            ),
          ),
          contentPadding: EdgeInsets.all(15),

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
          ListTile(
            title: Text('Selecionar Rol'),
            trailing: Icon(Icons.person_outline),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToRolPages,
          ),
          ListTile(
            title: Text('Mis pedidos'),
            trailing: Icon(Icons.add_shopping_cart),
            //leading: Icon(Icons.cancel),
            onTap: _con.goToOrdersList,
          ),
          ListTile(
            title: Text('Cerrar Sesion'),
            trailing: Icon(Icons.power_settings_new),
            //leading: Icon(Icons.cancel),
            onTap: _con.singOut,
          ),

        ],
      ),
    );
  }






  Widget _menuDrawer() {
    return GestureDetector(
      onTap: _con.key.currentState.openDrawer,
      child: Container(
        margin: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Image.asset('assets/img/menu.png', width: 20, height: 20),
      ),
    );
  }




  void refresh(){
    setState(() {


    });
  }







}
