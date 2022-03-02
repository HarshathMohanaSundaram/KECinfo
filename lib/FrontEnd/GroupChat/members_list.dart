import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:flutter/material.dart';

class MembersList extends StatefulWidget {
  final Image image;
  final String name;
  final bool isSelected;
  final Function onSelected;
  const MembersList({Key? key, required this.image, required this.name, this.isSelected=false, required this.onSelected}) : super(key: key);

  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onSelected();
      },
      style: TextButton.styleFrom(
          minimumSize: Size.zero, padding: const EdgeInsets.all(0)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.5, top: 2.5),
        child: Container(
            width: double.infinity,
            height: 80,
            color: fadedWhite,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Container(
                          width: 5,
                          height: constraints.maxHeight,
                          color:Colors.transparent
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color:Colors.transparent,
                                  width: .5))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, right: 15),
                        child: SizedBox(
                            width: constraints.maxHeight / 1.5,
                            height: constraints.maxHeight,
                            child: Stack(
                              children: [
                                Container(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: FittedBox(
                                        fit: BoxFit.cover, child: widget.image)),
                              ],
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.transparent,
                                    width: .5))),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                              height: constraints.maxHeight,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8, right: 8, bottom: 5),
                                    child: Text(
                                      widget.name,
                                      style: const TextStyle(
                                          fontFamily: 'MyRaidBold',
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 16,
                                          color: fadedPurple),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, right: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.transparent,
                                      width: 0.5)),
                              color: Colors.transparent,
                            ),
                            height: constraints.maxHeight,
                            child:  Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bodyColor,
                                  ),
                                  child: widget.isSelected
                                      ? Container(
                                      color: royalBlue,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      ))
                                      : Container()),
                            ),
                          ),
                        )
                    ),
                  ],
                );
              },
            )),
      ),
    );
  }
}
