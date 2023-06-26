import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class ClientPaymentsCreateController{

  BuildContext context;
  Function refresh;
  GlobalKey<FormState> keyForm= new GlobalKey();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;


  Future init(BuildContext context, Function refresh){
    this.context=context;
    this.refresh=refresh;

  }

  void onCreditCardModelChange(CreditCardModel creditCardModel){

    cardNumber=creditCardModel.cardNumber;
    expiryDate=creditCardModel.expiryDate;
    cardHolderName=creditCardModel.cardHolderName;
    cvvCode=creditCardModel.cvvCode;
    isCvvFocused=creditCardModel.isCvvFocused;
    refresh();

  }





}