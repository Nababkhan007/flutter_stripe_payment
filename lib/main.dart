import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_TYooMQauvdEDq54NiTphI7jx";
  Stripe.merchantIdentifier = 'MerchantIdentifier';
  runApp(const StripePayment());
}

class StripePayment extends StatelessWidget {
  const StripePayment({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic> paymentIntent = {};

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();

      displayPaymentSheet();

      var gPay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "US",
        testEnv: true,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Khan",
          googlePay: gPay,
        ),
      );

      displayPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": "1000",
        "currency": "USD",
      };

      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer sk_test_4eC39HqLyjWDarjtT1zdp7dc",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stripe Payment",
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => makePayment(),
          child: const Text(
            "Pay now",
          ),
        ),
      ),
    );
  }
}
