import 'package:flutter/material.dart';
import 'package:loyalty/features/components/components.dart';

import '../../../../core/ui.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child:Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle
                    ),
                  )
              ),
              SizedBox(height: 15),
              Text("Emri"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Emri i plotë',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: secondBorderColor),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text("Numri"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: '04X XXX XXX',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: secondBorderColor),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text("Email"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: secondBorderColor),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text("Password"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: secondBorderColor),
                  ),
                ),
              ),
              SizedBox(height: 20),
              customButton(context, "Save")
            ],
          ),
        ),
      ),
    );
  }
}
