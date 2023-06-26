import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/create/restaurant_categories_create_controller.dart';
import 'package:mi_flutter/src/widgets/button_app.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;

class RestaurantCategoriesCreatePage extends StatefulWidget {
  const RestaurantCategoriesCreatePage({Key key}) : super(key: key);

  @override
  _RestaurantCategoriesCreatePageState createState() => _RestaurantCategoriesCreatePageState();

}

class _RestaurantCategoriesCreatePageState extends State<RestaurantCategoriesCreatePage> {

 RestaurantCategoriesCreateController _con= new RestaurantCategoriesCreateController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context,refresh);
    });


  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_con.key,
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text('Nueva Categoria'),
      ),
        body: Column(
          children: [
            SizedBox(height: 30),
            _textFieldName(),
            _textFieldDescription()
          ],
        ),
        bottomNavigationBar: _buttonCreate(),


    );

  }



  Widget _buttonCreate(){
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.createCategory,
        text: 'Crear Categoria',
        color: Colors.red[600],
        textColor: Colors.white,
      ),
    );
  }



  Widget _textFieldName(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.nameController,
        decoration: InputDecoration(

            labelText: 'Nombre de la categoria',


            suffixIcon: Icon(
              Icons.list_alt,
              color: Colors.red[300],
            )

        ),
      ),
    );
  }


  Widget _textFieldDescription(){
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        maxLines: 3,
        maxLength: 255,
        controller: _con.descriptionController,
        decoration: InputDecoration(

            labelText: 'Descripción de la categoria',


            suffixIcon: Icon(
              Icons.description,
              color: Colors.red[300],
            )

        ),
      ),
    );
  }


  void refresh(){
    setState(() {});
  }

}
