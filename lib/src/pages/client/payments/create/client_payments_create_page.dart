import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:mi_flutter/src/models/client.dart';


import 'package:mi_flutter/src/pages/client/payments/create/client_payments_create_controller.dart';

class ClientPaymentsCreatePage extends StatefulWidget {
  const ClientPaymentsCreatePage({Key key}) : super(key: key);

  @override
  _ClientPaymentsCreatePageState createState() => _ClientPaymentsCreatePageState();
}

class _ClientPaymentsCreatePageState extends State<ClientPaymentsCreatePage> {

  ClientPaymentsCreateController _con = new ClientPaymentsCreateController();
  
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos'),
      ),
      body: ListView(
        children: [

          CreditCardWidget(
                glassmorphismConfig: Glassmorphism(
                          blurX: 10.0,
                          blurY: 10.0,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [

                              Colors.redAccent,
                              Colors.lightBlueAccent
                            ],


    ),
                        ),
              cardNumber: _con.cardNumber,
              expiryDate: _con.expiryDate,
              cardHolderName: _con.cardHolderName,
              cvvCode: _con.cvvCode,
              showBackView: _con.isCvvFocused,
              height: 200,
              obscureCardCvv: true,
              obscureCardNumber: true,
              isHolderNameVisible: true,
              cardBgColor: Colors.green,
              isSwipeGestureEnabled: true,
              labelCardHolder: 'NOMBRE Y APELLIDO',
              animationDuration: Duration(milliseconds: 500),

              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
      ),


          CreditCardForm(
            formKey: _con.keyForm, // Required
            onCreditCardModelChange: _con.onCreditCardModelChange, // Required
            themeColor: Colors.red,
            obscureCvv: true,
            obscureNumber: true,
            isHolderNameVisible: true,
            isCardNumberVisible: true,
            isExpiryDateVisible: true,
            cardNumberDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Númeor de la tarjeta',
              hintText: 'XXXX XXXX XXXX XXXX',
            ),
            expiryDateDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Fecha de expiracion',
              hintText: 'XX/XX',
            ),
            cvvCodeDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'CVV',
              hintText: 'XXX',
            ),
            cardHolderDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre del titular',
            ),
          ),
          _documentInfo(),
          _buttonNext(),




            


        ],
      ),
    );
  }

  Widget _documentInfo(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Material(
              elevation: 2.0,
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Column(
                  children: [

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
                          'C.C',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16
                          ),
                        ),
                        items: _dropDownItems([]),
                        value: '',
                        onChanged: (option){
                          setState(() {
                            print('Repartidor Seleccionado: $option');
                            //_con.idDelivery=option; //estableciedno el valor sellecionado a la categoria
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 15,),
          Flexible(
            flex: 4,
            child: TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Número de documento'
              ),
            ),
          )
        ],
      ),
    );

  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Client> clients){
    List<DropdownMenuItem<String>> list =[];
    clients.forEach((clientd) {
      list.add(DropdownMenuItem(
        child: Row(
          children: [
            Container(

              height: 40,
              width: 40,

              child: FadeInImage(
                image: clientd.image!=null
                    ? NetworkImage(clientd.image)
                    :AssetImage('assets/img/no_image.jpg'),
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 50),
                placeholder: AssetImage('assets/img/no_image.jpg'),
              ),
            ),
            SizedBox(width: 5,),
            Text(clientd.username),
          ],
        ),
        value: clientd.id,

      ));
    });
    return list;
  }


  Widget _buttonNext(){
    return Container(
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: (){},
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
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'CONTINUAR',
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
                child:  Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }



  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      _con.cardNumber = creditCardModel.cardNumber;
      _con.expiryDate = creditCardModel.expiryDate;
      _con.cardHolderName = creditCardModel.cardHolderName;
      _con.cvvCode = creditCardModel.cvvCode;
      _con.isCvvFocused = creditCardModel.isCvvFocused;
    });
  }


  void refresh(){
    setState(() {

    });
  }
}
