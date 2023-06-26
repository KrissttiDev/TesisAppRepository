
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mi_flutter/src/models/category.dart';
import 'package:mi_flutter/src/pages/restaurant/categories/products/create/restaurant_products_create_controller.dart';

import 'package:mi_flutter/src/widgets/button_app.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;

class RestaurantProductsCreatePage extends StatefulWidget {
  const RestaurantProductsCreatePage({Key key}) : super(key: key);

  @override
  _RestaurantProductsCreatePageState createState() => _RestaurantProductsCreatePageState();

}

class _RestaurantProductsCreatePageState extends State<RestaurantProductsCreatePage> {

  RestaurantProductsCreateController _con= new RestaurantProductsCreateController();
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
        title: Text('Nuevo Producto'),
      ),
      body: ListView(

         
          children: [
            SizedBox(height: 30),
            _textFieldName(),
            _textFieldDescription(),
            _textFieldPrice(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardImage(_con.imageFile1, 1),
                    _cardImage(_con.imageFile2, 2),
                    _cardImage(_con.imageFile3, 3),
                    _cardImage(_con.imageFile4, 4),
                    _cardImage(_con.imageFile5, 5)

                  ],
                ),
              ),
            ),
            _dropDownCategories(_con.categories),
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
        onPressed: _con.createProduct,
        text: 'Crear Producto',
        color: Colors.red[600],
        textColor: Colors.white,
      ),
    );
  }



  Widget _textFieldName(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.nameController,
        maxLines: 1,
        maxLength: 180,
        decoration: InputDecoration(
            labelText: 'Nombre del producto',
            contentPadding: EdgeInsets.all(15),
            suffixIcon: Icon(
              Icons.local_pizza,
              color: Colors.red[300],
            )
        ),
      ),
    );
  }

  Widget _dropDownCategories(List<Category> categories){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 33),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.red[300],
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Categorias',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton(
                  underline: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colors.red[300],
                    ),
                  ),
                  elevation: 3,
                  isExpanded: true,
                  hint: Text(
                    'Selecionar Categoria',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                    ),
                  ),
                  items: _dropDonwItems(categories),
                  value: _con.idCategory,
                  onChanged: (option){
                    setState(() {
                      print('Categoria Seleccionada: $option');
                      _con.idCategory=option; //estableciedno el valor sellecionado a la categoria
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
    
  }

  List<DropdownMenuItem<String>> _dropDonwItems(List<Category> categories){
    List<DropdownMenuItem<String>> list =[];
    categories.forEach((category) {
      list.add(DropdownMenuItem(
          child: Text(category.name),
        value: category.id,

      ));
    });
    return list;
  }


  Widget _textFieldDescription(){
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        maxLines: 3,
        maxLength: 255,
        controller: _con.descriptionController,
        decoration: InputDecoration(
            labelText: 'Descripción del producto',
            contentPadding: EdgeInsets.all(15),
            suffixIcon: Icon(
              Icons.description,
              color: Colors.red[300],
            )
        ),
      ),
    );
  }


  Widget _textFieldPrice(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.priceController,
        keyboardType: TextInputType.phone, //para que solo pueda escribir numeros
        maxLines: 1,
        decoration: InputDecoration(
            labelText: 'Precio del producto',
            contentPadding: EdgeInsets.all(15),
            suffixIcon: Icon(
              Icons.monetization_on,
              color: Colors.red[300],
            )
        ),
      ),
    );
  }

  Widget _cardImage(File imageFile, int numberFile){
    return GestureDetector(
      onTap: (){
        _con.showAlertDialog(numberFile);
      },
      child: imageFile!=null
          ? Card(
              elevation: 3.0,
              child: Container(
                height: 100,
                  width: MediaQuery.of(context).size.width*0.26,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
      )
      : Card(
        elevation: 3.0,
        child: Container(
          height: 140,
          width: MediaQuery.of(context).size.width*0.26,
          child: Image(
            image:AssetImage('assets/img/add_image.png'),

            fit: BoxFit.cover,
          ),
        ),
      ),
    )

    ;

  }



  void refresh(){
    setState(() {});
  }

}
