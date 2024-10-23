import 'package:flutter/material.dart';

//main Colors & styles
const gpPrimaryColor = Color.fromARGB(255, 255, 255, 255);
const gpSecondaryColor = Color.fromARGB(255, 28, 63, 57);
const gpBottomNavigationColorDark = Color.fromARGB(255, 17, 117, 103);
const headerTitle = TextStyle(color: gpPrimaryColor,fontWeight: FontWeight.bold,fontSize: 16);

//Authentication Colors & styles
const contentTextAuth = TextStyle(fontSize: 14);

//login & signup
const gpBottomSheetColor = Color.fromARGB(255, 235, 227, 204);
const textStyleLS = TextStyle(color: gpSecondaryColor,fontSize: 14,fontWeight: FontWeight.bold);
const textButtonStyle = TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold);

//User Dashboard
const gpBottomNavigationColor = Color.fromARGB(255, 58, 155, 138);
const gpIconColor = Color.fromARGB(255, 15, 39, 35);
const textBoxStyle = TextStyle(color: Colors.white,fontSize: 14);
const textHeaderStyle = TextStyle(fontSize: 14);

//User Profile
const contentTextProfile = TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: gpIconColor);
const dialogTextColor = TextStyle(color: gpBottomNavigationColor);


//Loading Screen
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}



