import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:asm_wt/app/my_account/my_account_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/account_list_weidget.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class MyAccountView extends StatefulWidget {
  String userId;
  ConnectivityResult? connectivityResult;
  MyAccountView({Key? key, required this.userId, this.connectivityResult})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends StateMVC<MyAccountView> {
  late MyAccountController con;

  _MyAccountViewState() : super(MyAccountController()) {
    con = controller as MyAccountController;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.all(StaticDataConfig.app_padding - 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: con.userModel != null
                        ? Column(
                            children: [
                              SizedBox(
                                height: height * 0.12,
                                width: height * 0.12,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  fit: StackFit.expand,
                                  children: [
                                    con.connectivityResult !=
                                            ConnectivityResult.none
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(con
                                                    .userModel?.profileURL ??
                                                'https://firebasestorage.googleapis.com/v0/b/wingspan-449f4.appspot.com/o/dafault_profile%2Fprofile.png?alt=media&token=d4cba450-fcff-467c-9ec7-9aca8e48a7bc'),
                                            backgroundColor: Colors.transparent
                                            // backgroundImage: AssetImage(
                                            //     "lib/assets/images/profile.png"),
                                            )
                                        : CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: AssetImage(
                                                "lib/assets/images/profile.png"),
                                          ),
                                    Positioned(
                                        bottom: -5,
                                        right: -30,
                                        child: RawMaterialButton(
                                          onPressed: () => con.getFromGallery(
                                              context,
                                              widget.userId,
                                              con.userModel?.profileFileName),
                                          elevation: 4.0,
                                          fillColor: theme.colorScheme.tertiary,
                                          shape: const CircleBorder(),
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                con.userModel?.username ?? '',
                                style: theme.textTheme.headlineMedium,
                              ),
                              Text(con.userModel?.email ?? 'example@mail.com',
                                  style: theme.textTheme.bodySmall?.merge(
                                      const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Text.rich(
                                TextSpan(
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                          text:
                                              "${translate("text_header.staff_id")} : ",
                                          style: theme.textTheme.bodySmall),
                                      TextSpan(
                                          text: con.userModel?.userId,
                                          style: theme.textTheme.bodySmall)
                                    ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    con.onStatusPressed(
                                        context,
                                        con.userModel?.userStatus,
                                        widget.userId);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: con.userModel?.userStatus ==
                                                  UserStatus.Available
                                              ? theme.colorScheme.background
                                              : con.userModel?.userStatus ==
                                                      UserStatus.UnAvalibale
                                                  ? theme
                                                      .colorScheme.onBackground
                                                  : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          con.userModel?.userStatus ??
                                              translate("text_header.unknow"),
                                          style: theme.textTheme.headlineSmall
                                              ?.merge(TextStyle(
                                                  color: con.userModel
                                                              ?.userStatus ==
                                                          UserStatus.Available
                                                      ? theme.colorScheme
                                                          .background
                                                      : con.userModel
                                                                  ?.userStatus ==
                                                              UserStatus
                                                                  .UnAvalibale
                                                          ? theme.colorScheme
                                                              .onBackground
                                                          : Colors.grey,
                                                  fontWeight: FontWeight.bold)))
                                    ],
                                  )),
                            ],
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Center(
                        child: CustomPaint(
                          size: Size.square(height * 0.20),
                          painter: QrPainter(
                            data: con.userModel?.userId ?? '',
                            version: QrVersions.auto,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    controller: con.scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(translate("my_account.management"),
                        //     style: theme.textTheme.headlineSmall?.merge(
                        //         TextStyle(color: theme.colorScheme.onTertiary))),
                        // accountListWidget(
                        //   context,
                        //   tital: translate("my_account.my_vehicle"),
                        //   // tital: "My Booking", //for passenger
                        //   // icon: Icons.date_range,
                        //   icon: Icons.local_shipping,
                        //   onTap: () {
                        //     context.pushNamed(RouteNames.myVehicle,
                        //         params: {'vehicleId': "12345"});
                        //   },
                        // ),
                        // accountListWidget(
                        //   context,
                        //   tital: translate("my_account.location"),
                        //   icon: Icons.location_on,
                        //   hasArrow: false,
                        //   switchBtn: Transform.scale(
                        //     scale: 0.7,
                        //     child: CupertinoSwitch(
                        //       activeColor: theme.colorScheme.secondary,
                        //       value: con.locatoinSwitchBtn,
                        //       onChanged: (val) async {
                        //         setState(() {
                        //           con.locatoinSwitchBtn = val;
                        //         });
                        //       },
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(translate("my_account.term_condition"),
                            style: theme.textTheme.headlineSmall?.merge(
                                TextStyle(
                                    color: theme.colorScheme.onTertiary))),
                        accountListWidget(
                          context,
                          tital: translate("my_account.contact_us"),
                          icon: Icons.contact_page,
                          onTap: () {
                            modelTextContrainerFunc(
                                context,
                                translate("my_account.contact_us"),
                                translate("contents.contact_us_content"),
                                null);
                          },
                        ),
                        // accountListWidget(
                        //   context,
                        //   tital: translate("my_account.privacy_policy"),
                        //   icon: Icons.policy,
                        //   onTap: () {
                        //     modelTextContrainerFunc(
                        //         context,
                        //         translate("my_account.privacy_policy"),
                        //         translate("contents.contact_us_content"),
                        //         "Tel: 0647018205");
                        //   },
                        // ),
                        accountListWidget(
                          context,
                          tital: translate("my_account.terms&condition"),
                          icon: Icons.import_contacts,
                          onTap: () {
                            modelTextContrainerFunc(
                                context,
                                translate("my_account.terms&condition"),
                                translate("contents.contact_us_content"),
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Introduction:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "ASM Services Co., Ltd. ('ASM, or 'we') collects personal data to provide services through the ASM WT App, including all associated websites ('ASM WT' or 'the Service'). We appreciate your use of the ASM W service, and we require access to your device's location services. Your privacy and data security are important to us, and we are committed to handling your information responsibly.",
                                          style: theme.textTheme.bodyMedium),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Location Tracking:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "To provide the best possible service and accurate recording of your clock-in and clock-out times, and for the purposes specified below, we require access to and use of your device's location data while the application is in use. By using ASM W, you consent to our access to and use of your device's location data while the application is in use. This data will be used solely for the following purposes:",
                                          style: theme.textTheme.bodyMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '1. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Clock-in and Clock-out:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To accurately record your work hours and locations.'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '2. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Geofencing:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To define locations or areas where clock-in or clock-out is permitted.'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '3. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Quality Analysis:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To improve the performance and user experience of our application.'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Your Data Privacy:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "We understand the importance of your data privacy, and we are committed to managing your data efficiently. The data you provide to us will be used for the following purposes:",
                                          style: theme.textTheme.bodyMedium),
                                      RichText(
                                        text: TextSpan(
                                          text: '1. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Timekeeping Data:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To record and display your work hours.'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '2. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Personal Data:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To identify users and manage their accounts.'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '3. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Usage Data:',
                                                style: theme
                                                    .textTheme.headlineSmall),
                                            TextSpan(
                                                text:
                                                    ' To enhance the performance and user experience of our application.'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Protection of Your Data Privacy:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '1. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    ' We do not share your data with third parties unless required by law.'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '2. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    ' Your data is securely stored and protected'),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '3. ',
                                          style: theme.textTheme.bodyMedium,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    ' You can request the deletion of your data or withdraw your consent at any time.'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Opt-Out:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "You can withdraw your consent for location tracking or data usage at any time by disabling location services in your device settings or within the app. However, please note that this may affect the functionality of ASM WT for clock-in and clock-out and other features.",
                                          style: theme.textTheme.bodyMedium),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Agreement:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "By clicking 'Agree' or using ASM WT, you indicate that you have read and understood the consent statements for location tracking and data privacy and agree to our access and use of your location and data as specified above.",
                                          style: theme.textTheme.bodyMedium),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          "If you do not agree with these consent statements, please do not use ASM WT.",
                                          style: theme.textTheme.bodyMedium),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Contact Information:",
                                          style:
                                              theme.textTheme.headlineMedium),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "If you have any questions or concerns about these consent statements or how we handle your data, please contact us at WT@ASM.co.th..",
                                          style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ));
                          },
                        ),
                        accountListWidget(
                          context,
                          tital: translate("my_account.faq"),
                          icon: Icons.quiz,
                          onTap: () {
                            modelTextContrainerFunc(
                                context,
                                translate("my_account.faq"),
                                translate("contents.contact_us_content"),
                                null);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(translate("my_account.account_setting"),
                            style: theme.textTheme.headlineSmall?.merge(
                                TextStyle(
                                    color: theme.colorScheme.onTertiary))),
                        accountListWidget(context,
                            tital: translate("my_account.delete_account"),
                            icon: Icons.delete_forever, onTap: () {
                          con.showActionConfirmDelAccFunc(
                              context, con.prefs.getString("username") ?? '');
                          // con.showModelCofirmDelFunc(
                          //     context,
                          //     translate("text_header.confirm_delete"),
                          //     translate("contents.confirm_delete_content"));
                        }, hasArrow: false),
                        accountListWidget(
                          context,
                          tital: translate("my_account.settings"),
                          icon: Icons.settings,
                          onTap: () {
                            context.pushNamed(RouteNames.accountSetting);
                          },
                        ),
                        accountListWidget(context,
                            tital: translate('authentication.log_out'),
                            icon: Icons.logout, onTap: () {
                          showActionConfirmFunc(
                              context,
                              translate("text_header.log_out_title"),
                              translate("contents.log_out_content"),
                              () => con.onSignOutPressed(context));
                        }, hasArrow: false),
                      ],
                    ),
                  )),
            ],
          )),
    );
  }
}
