import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';


customButton(context,text){
  return Container(
    height: 65,
    width: getWidth(context)*0.75,
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
        child: Text(text,style: TextStyle(fontSize: 18,color: primaryTextColor),)
    ),
  );
}

categoryBox(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: SvgPicture.asset("assets/clothes.svg"),
        ),
      ),
      SizedBox(height: 8),
      Text("Clothes"),
    ],
  );
}