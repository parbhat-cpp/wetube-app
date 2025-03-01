import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:wetube/controllers/auth_controller.dart';
import 'package:wetube/main.dart';
import 'package:wetube/screens/about.dart';
import 'package:wetube/screens/auth.dart';
import 'package:wetube/services/user_service.dart';
import 'package:wetube/screens/edit_profile.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    _razorpay.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController =
        Get.put<AuthController>(AuthController());
    final UserService userService = Get.find<UserService>();

    void handleLogOut() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Auth()));
      }
    }

    void handleAccountDelete() async {
      String userId = authController.userProfile.value!.id;
      String token = authController.userProfile.value!.token;

      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Do you really want to delete this account?',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await userService.deleteAccount(userId, token);

                        handleLogOut();
                      },
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              ),
            );
          });
    }

    void handlePayment() {
      if (authController.userProfile.value!.premiumAccount.isNotEmpty) {
        Fluttertoast.showToast(msg: 'Already a premium member');
        return;
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SettingsGroup(
                  title: 'General',
                  children: <Widget>[
                    SimpleSettingsTile(
                      title: 'Edit Profile',
                      leading: Icon(Icons.manage_accounts_outlined),
                      showDivider: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfile(),
                          ),
                        );
                      },
                    ),
                    SimpleSettingsTile(
                      title: 'About us',
                      leading: Icon(Icons.info),
                      showDivider: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => About(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SettingsGroup(
                  title: 'Buy Premium',
                  children: <Widget>[
                    SimpleSettingsTile(
                      title: 'Become a premium member',
                      leading: Icon(Icons.payment),
                      showDivider: false,
                      onTap: handlePayment,
                    ),
                  ],
                ),
                SettingsGroup(
                  title: 'Delete account',
                  children: <Widget>[
                    SimpleSettingsTile(
                      title: 'Leave WeTube forever',
                      leading: Icon(
                        Icons.person_remove,
                        color: Colors.red,
                      ),
                      showDivider: false,
                      titleTextStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 15.0,
                      ),
                      onTap: handleAccountDelete,
                    ),
                  ],
                ),
                SettingsGroup(
                  title: 'Log out',
                  children: <Widget>[
                    SimpleSettingsTile(
                      title: 'Log out',
                      leading: Icon(
                        Icons.logout,
                      ),
                      showDivider: false,
                      onTap: handleLogOut,
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: const Text('Built by Parbhat Sharma'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
