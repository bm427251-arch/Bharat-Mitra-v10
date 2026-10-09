import 'package:flutter/material.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});
  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final pickupCtrl = TextEditingController();
  final dropCtrl = TextEditingController();
  final weightCtrl = TextEditingController(text: "1");
  final phoneCtrl = TextEditingController();
  double fare = 80;

  void calcFare() {
    double w = double.tryParse(weightCtrl.text) ?? 1;
    setState(() { fare = 50 + (w * 30); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Parcel Service"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.local_shipping_rounded, color: Colors.white, size: 36),
              SizedBox(height: 10),
              Text("Send Parcel Anywhere - 0% Commission", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Bike / Auto / Van - Same Day Delivery in Kolkata", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),
          TextField(controller: pickupCtrl, decoration: InputDecoration(labelText: "Pickup Location - e.g. Howrah", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.my_location))),
          const SizedBox(height: 12),
          TextField(controller: dropCtrl, decoration: InputDecoration(labelText: "Drop Location - e.g. Salt Lake", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.location_on))),
          const SizedBox(height: 12),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Receiver Phone Number", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.phone))),
          const SizedBox(height: 12),
          TextField(controller: weightCtrl, onChanged: (_) => calcFare(), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Weight (KG) - e.g. 1, 2, 5", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.scale))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Estimated Fare", style: TextStyle(fontWeight: FontWeight.bold)), Text("Bike Delivery", style: TextStyle(fontSize: 11, color: Colors.grey))]),
              Text("₹ ${fare.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Expanded(child: Text("0% Commission - Direct Pay to Rider - Cash/UPI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)))),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (pickupCtrl.text.isEmpty || dropCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Pickup & Drop location"), backgroundColor: Colors.red));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parcel Booking Confirmed - Rider Assigned - Fare ₹${fare.toStringAsFixed(0)} - ${pickupCtrl.text} to ${dropCtrl.text}"), backgroundColor: const Color(0xFF7C3AED)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Book Parcel Pickup (₹${fare.toStringAsFixed(0)})", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
