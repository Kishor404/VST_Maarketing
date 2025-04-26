import 'package:flutter/material.dart';
import 'package:vst_maarketing/pages/service_last.dart';
import 'service_details.dart';
import 'service_book.dart';
import 'data.dart';
import 'api.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import screenutil

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});
  @override
  ServicePageState createState() => ServicePageState();
}

class ServicePageState extends State<ServicePage> {
  API api = API();
  Map<String, dynamic> apiServiceData = {};
  Map<String, dynamic> apiNextServiceData = {};

  String lastServiceDate = "No Service Data";
  String nextService = "No Service Data";
  String nextServiceCard = "No Service Data";

  List<dynamic> services = [];
  List<dynamic> bookedServices = [];
  List<dynamic> cancelServices = [];
  bool isLoading = true;

  bool bookButton = true;
  bool lastButton = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    apiServiceData = await api.fetchServices();
    apiNextServiceData = await api.fetchNextService();
    if (apiServiceData["logout"] == 1 || apiNextServiceData["logout"] == 1) {
      _logout();
    } else {
      if(mounted){
        setState(() {
        services = apiServiceData["data"];
        nextService = apiNextServiceData["nextService"];
        nextServiceCard = apiNextServiceData["nextServiceCard"];
        isLoading = false;
      });}
    }
    fetchServiceDetails();
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void fetchServiceDetails() {
    if (services.isEmpty) return;

    List<dynamic> tempBookedServices = [];
    List<dynamic> tempCancelServices = [];
    String tempLastServiceDate = lastServiceDate;
    for (var service in services) {
      switch (service["status"]) {
        case "SD":
          tempLastServiceDate = service["available_date"];
          break;
        case "BD":
        case "SP":
          tempBookedServices.add(service);
          break;
        case "NS":
        case "CC":
        case "CW":
          tempCancelServices.add(service);
          break;
      }
    }

    setState(() {
      lastServiceDate = tempLastServiceDate;
      bookedServices = tempBookedServices;
      cancelServices = tempCancelServices;
      bookButton = bookedServices.isEmpty;
      lastButton = cancelServices.isNotEmpty;
    });
  }

  Widget buildServiceButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
    width: 250.w, // or any responsive width
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
        textStyle: TextStyle(fontSize: 14.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    ),
  );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        :Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:300.w,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).translate('service_title'),
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    '${AppLocalizations.of(context).translate('service_last_service')} $lastServiceDate',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate('service_next_service')} $nextServiceCard',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate('service_next_service_in')} $nextService ${AppLocalizations.of(context).translate('service_next_service_days')}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Image.network('${Data.baseUrl}/media/utils/Service_Illus.jpg', height: 400.h),
            ),
            SizedBox(height: 10.h),

            lastButton
                ? buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_cancelled_service'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceLast(serviceData: cancelServices.last))),
                  )
                : Container(),

            SizedBox(height: 15.h),

            bookButton
                ? buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_book_service'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceBook())),
                  )
                : buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_details'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetails(serviceData: bookedServices.last))),
                  ),
          ],
        ),
      ),
    );
  }
}
