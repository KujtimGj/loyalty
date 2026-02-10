import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';


customButton(context,text){
  return Container(
    height: 55,
    width: getWidth(context),
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
        child: Text(text,style: TextStyle(fontSize: 18,color: primaryTextColor),)
    ),
  );
}

outlinedButton(context,text){
  return Container(
    width: getWidth(context),
    height: 55,
    decoration: BoxDecoration(
      border: Border.all(width: 1, color:secondBorderColor)
    ),
    child: Center(
      child: Text(text),
    ),
  );
}

categoryBox(BuildContext context, String assetPath, String label) {
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
          child: SvgPicture.asset(assetPath),
        ),
      ),
      SizedBox(height: 8),
      Text(label),
    ],
  );
}