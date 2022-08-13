import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/text_app.dart';

mixin showDialogHelper {
  void showAlertDialog(
      {required BuildContext context,
      required String title,
       String? body,
      Widget? content}) {
    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(

          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.green ,
              width: 5.sp
            ),
              borderRadius: BorderRadius.circular(25.sp)
          ),
          scrollable: true,
          content: content,
          title: TextApp(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 25.sp,
            fontColor: Colors.green,
          ),
        );
      },
    );
  }
}
