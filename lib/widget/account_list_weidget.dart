import 'package:flutter/material.dart';
import 'package:asm_wt/assets/static_data.dart';

accountListWidget(BuildContext context,
    {Function()? onTap,
    String? tital,
    IconData? icon,
    Widget? widget,
    bool hasArrow = true}) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  var theme = Theme.of(context);

  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.only(top: 5),
      child: Container(
        height: height * 0.06,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            // boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
            borderRadius:
                BorderRadius.circular(StaticDataConfig.border_radius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      backgroundColor: theme.colorScheme.tertiary,
                      radius: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          icon,
                          color: theme.colorScheme.primary,
                        ),
                      )),
                  SizedBox(width: width * 0.02),
                  Text(
                    tital!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              hasArrow
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.grey.withOpacity(0.4),
                    )
                  : widget ?? Container()
            ],
          ),
        ),
      ),
    ),
  );
}
