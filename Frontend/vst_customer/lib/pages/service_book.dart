import 'package:flutter/material.dart';

class ServiceBook extends StatefulWidget {
  const ServiceBook({Key? key}) : super(key: key);

  @override
  ServiceBookState createState() => ServiceBookState();
}

class ServiceBookState extends State<ServiceBook> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedComplaint;
  TextEditingController otherComplaintController = TextEditingController();
  TextEditingController complaintDetailsController = TextEditingController();

  final List<String> complaints = ["General Visit", "Internet Issue", "Slow Speed", "No Connection", "Others"];

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Service Booking",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 70,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                  'https://cdn-lmaib.nitrocdn.com/ROdTzxXrreLgSXOSXKZjrLlbRYrVgDKb/assets/images/optimized/rev-66aa50b/openreferences.com/wp-content/uploads/2024/10/Control-horario-1024x1024.jpg',
                  height: 400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Available Period",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: fromDate == null
                                ? "From"
                                : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: toDate == null
                                ? "To"
                                : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Service Details",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Type of Complaint",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: selectedComplaint,
                items: complaints.map((String complaint) {
                  return DropdownMenuItem<String>(
                    value: complaint,
                    child: Text(complaint),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedComplaint = newValue;
                  });
                },
              ),
              if (selectedComplaint == "Others") ...[
                const SizedBox(height: 10),
                TextField(
                  controller: otherComplaintController,
                  decoration: InputDecoration(
                    labelText: "Enter your complaint",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
              if (selectedComplaint != null && selectedComplaint != "General Visit") ...[
                const SizedBox(height: 10),
                TextField(
                  controller: complaintDetailsController,
                  decoration: InputDecoration(
                    labelText: "Briefly describe your complaint",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle booking logic here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
