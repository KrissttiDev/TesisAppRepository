import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mi_flutter/src/models/product.dart';
import 'package:mi_flutter/src/pages/client/products/detail/client_products_details_controller.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
class ClientProductsDetailPage extends StatefulWidget {

  Product product;


   ClientProductsDetailPage({Key key, @required this.product}) : super(key: key);

  @override
  _ClientProductsDetailPageState createState() => _ClientProductsDetailPageState();
}

class _ClientProductsDetailPageState extends State<ClientProductsDetailPage> {

  ClientProductsDetailControler _con = new ClientProductsDetailControler();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh,widget.product);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          _imageSlidershow(),
          _textName(),
          _textDescription(),
          Spacer(),
          _addOrRemoveItem(),
          _standarDelivery(),
          _buttonShoppingBag(),
        ],
      ),
    );
  }
  Widget _textName(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(right: 30,left: 30, top: 30),
      child:Text(
        _con.product?.name ?? '',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ) ,
    );
  }

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(right: 30,left: 30,top: 15),
      child:Text(
        _con.product?.description ?? '',
        style: TextStyle(
            fontSize: 20,
            color: Colors.grey
        ),
      ) ,
    );
  }


  Widget _addOrRemoveItem(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          IconButton(
              onPressed: _con.addItem,
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.grey,
                size: 30,
              ),
          ),
          Text(
            '${_con.counter}',
            style:TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: _con.removeItem,
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 30,
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(
              '${_con.productPrice ?? 0}\$',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,

              ),
            ),
          )

        ],
      ),
    );
  }
  
  Widget _buttonShoppingBag(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30,top:30, bottom: 30),
      child: ElevatedButton(
        onPressed: _con.addToBag,
        style: ElevatedButton.styleFrom(
          primary: Colors.red[600],
          padding: EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        child: Stack(
          children: [
            Align(
              child: Container(

                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'AGREGAR A LA BOLSA',
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
                margin: EdgeInsets.only(left: 50,top:6),
                height: 30,
                child: Image.asset('assets/img/bag.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  
  Widget _standarDelivery(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: Row(
        children: [
          Image.asset(
              'assets/img/delivery.png',
            height: 17,
          ),
          SizedBox(width: 7),
          Text(
            'Envío estandar',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green
            ),
          ),
        ],
      ),
    );
  }


  Widget _imageSlidershow(){
    return Stack(
      children: [
        ImageSlideshow(
          width: double.infinity,
          height: MediaQuery.of(context).size.height*0.4,
          initialPage: 0,
          indicatorColor: Colors.red[400],
          indicatorBackgroundColor: Colors.grey,
          onPageChanged: (value) {
            debugPrint('Page changed: $value');
          },
          autoPlayInterval: 10000,
          isLoop: true,
          children: [
            FadeInImage(
              image: _con.product?.image1!=null
                  ? NetworkImage(_con.product.image1)
                  :AssetImage('assets/img/no_image.jpg'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no_image.jpg'),
            ),
            FadeInImage(
              image: _con.product?.image2!=null
                  ? NetworkImage(_con.product.image2)
                  :AssetImage('assets/img/no_image.jpg'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no_image.jpg'),
            ),
            FadeInImage(
              image: _con.product?.image3!=null
                  ? NetworkImage(_con.product.image3)
                  :AssetImage('assets/img/no_image.jpg'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no_image.jpg'),
            ),
            FadeInImage(
              image: _con.product?.image4!=null
                  ? NetworkImage(_con.product.image4)
                  :AssetImage('assets/img/no_image.jpg'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no_image.jpg'),
            ),
            FadeInImage(
              image: _con.product?.image5!=null
                  ? NetworkImage(_con.product.image5)
                  :AssetImage('assets/img/no_image.jpg'),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no_image.jpg'),
            ),
          ],
        ),
        Positioned(
          left: 10,
            top: 5,
            child: IconButton(
              onPressed: _con.close,
              icon: Icon(
                  Icons.arrow_back_ios,
                color: Colors.red[400],
              ),
            )
        )
      ],
    );

  }




  void refresh(){
    setState(() {

    });
  }

}
