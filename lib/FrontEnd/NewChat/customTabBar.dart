import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
PreferredSizeWidget CustomTabBar({var controller,var context,var tabs,var onTap}) {
  return TabBar(
      padding: const EdgeInsets.only(left: 30, bottom: 30, right: 30),
      isScrollable: true,
      controller: controller,
      unselectedLabelColor: Colors.black,
      onTap: onTap,
      indicatorPadding: const EdgeInsets.all(5),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color.fromRGBO(8, 33, 198, 1),
      ),
      tabs: [
        for (int i = 0; i < tabs.length; i++)
          Tab(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                          fontFamily:
                          controller.index == i ? 'MyRaidBold' : 'MyRaid',
                          color: controller.index == i
                              ? Colors.white
                              : Colors.black),
                    )),
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.transparent,
                ),
              ),
            ),
          )
      ]);
}
