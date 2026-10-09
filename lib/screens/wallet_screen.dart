import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0.00;
  List<Map<String, dynamic>> transactions = [];

  void _showAddMoneyDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Add Money"),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "500", prefixText: "₹ ", border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () {
          double amt = double.tryParse(ctrl.text)?? 0;
          if (amt > 0) {
            setState(() {
              balance += amt;
              transactions.insert(0, {"title": "Money Added via UPI", "amount": "+₹$amt", "time": DateTime.now().toString().substring(0,16), "color": Colors.green});
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("₹$amt Added - UPI Success"), backgroundColor: Colors.green));
          }
        }, child: const Text("Add via UPI"))
      ],
    ));
  }

  void _showTransferDialog() {
    final accCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Transfer to Bank Account"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: accCtrl, decoration: const InputDecoration(labelText: "Account Number", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: ifscCtrl, decoration: const InputDecoration(labelText: "IFSC Code", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", prefixText: "₹ ", border: OutlineInputBorder())),
        const SizedBox(height: 8),
        const Text("IMPS - 2 Hours", style: TextStyle(fontSize: 11, color: Colors.grey)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () {
          double amt = double.tryParse(amtCtrl.text)?? 0;
          if (amt > 0 && amt <= balance) {
            setState(() {
              balance -= amt;
              transactions.insert(0, {"title": "To Bank ${accCtrl.text}", "amount": "-₹$amt", "time": DateTime.now().toString().substring(0,16), "color": Colors.red});
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("₹$amt Transfer to ${accCtrl.text}"), backgroundColor: Colors.blue));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient Balance"), backgroundColor: Colors.red));
          }
        }, child: const Text("Transfer"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("My Wallet"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF22C55E)]), borderRadius: BorderRadius.circular(20)), child: Column(children: [
          const Text("Available Balance", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("₹ ${balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _showAddMoneyDialog, icon: const Icon(Icons.add), label: const Text("Add Money"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: _showTransferDialog, icon: const Icon(Icons.account_balance), label: const Text("To Bank"), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white))),
          ])
        ])),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: Text("Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(height: 10),
        Expanded(child: transactions.isEmpty? const Center(child: Text("No transactions yet")) : ListView.builder(itemCount: transactions.length, itemBuilder: (ctx, i) {
          final t = transactions[i];
          return Card(child: ListTile(leading: CircleAvatar(backgroundColor: (t["color"] as Color).withOpacity(0.2), child: Icon(t["amount"].toString().startsWith("+")? Icons.arrow_downward : Icons.arrow_upward, color: t["color"])), title: Text(t["title"]), subtitle: Text(t["time"]), trailing: Text(t["amount"], style: TextStyle(fontWeight: FontWeight.bold, color: t["color"]))));
        }))
      ])),
    );
  }
}
