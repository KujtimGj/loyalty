import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/components/components.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

const _categories = [
  ("assets/categories/clothes.svg", "Clothes"),
  ("assets/categories/groceries.svg", "Groceries"),
  ("assets/categories/gas.svg", "Gas Stations"),
  ("assets/categories/food.svg", "Food"),
];


class _SearchState extends State<Search> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 55,
              width: getWidth(context) * 0.75,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F6),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(8),
              child: Center(
                child: TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Kërko...",
                    hintStyle: TextStyle(color: greyText),
                    suffixIcon: Icon(Icons.search, size: 35),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF6F6F6),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(child: SvgPicture.asset("assets/arrow_down.svg")),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                "Eksploro",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: getWidth(context),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final (iconPath, label) = _categories[index];
                    return categoryBox(context, iconPath, label);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ofertat e fundit",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Text("Shiko të gjitha",
                    style: TextStyle(fontSize: 15, color: greyText),
                  )
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 270,
                width: getWidth(context),
                child: ListView.builder(
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context,index){
                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(right: 10),
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Image.asset("assets/kfc2.png",height: 150,)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Sach Attack",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        " 5,99€",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text("Sach Pizza"),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Reward",style: TextStyle(fontSize: 10,)),
                                  Text("Free Meal",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),)
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(8, (_) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: unfilledStamp
                                  ),
                                ),
                              )),
                              Text("8 vula"),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
