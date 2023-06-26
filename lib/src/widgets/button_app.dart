import 'package:flutter/material.dart';
import 'package:mi_flutter/src/utils/colors.dart' as utils;

class ButtonApp extends StatelessWidget {
 // const ButtonApp({Key key}) : super(key: key);

  Color color;
  Color textColor;
  String text;
  IconData icon;
  Function onPressed;

  ButtonApp({

    this.color=Colors.red,
    this.textColor=Colors.amber,
    this.icon=Icons.arrow_forward_ios,
    this.onPressed,
    @required this.text,



});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        )
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(

                  text,
                  style: TextStyle(
                      color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 50,
              child: CircleAvatar(
                radius: 15,
                child: Icon(
                  icon,
                  color: utils.Colors.uberCloneColor,

                ),
                backgroundColor: Colors.white,
              ),
            ),
          )


        ],
      ),

      );


  }
}
