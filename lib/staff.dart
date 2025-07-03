// staff.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Staff data model
class Staff {
  String name;
  String id;
  int age;

  Staff({required this.name, required this.id, required this.age});

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'age': age};
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      name: map['name'],
      id: map['id'],
      age:
          map['age'] is int
              ? map['age']
              : int.tryParse(map['age'].toString()) ?? 0,
    );
  }
}

// Staff input form page
class StaffFormPage extends StatefulWidget {
  const StaffFormPage({super.key});

  @override
  _StaffFormPageState createState() => _StaffFormPageState();
}

class _StaffFormPageState extends State<StaffFormPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _ageController = TextEditingController();

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _ageController.text.isEmpty) {
      return;
    }

    final newStaff = Staff(
      name: _nameController.text,
      id: _idController.text,
      age: int.tryParse(_ageController.text) ?? 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StaffListPage(staff: newStaff)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Profile Form'),
        backgroundColor: const Color.fromARGB(255, 250, 147, 181),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInputField(_nameController, 'Name', Icons.person),
            SizedBox(height: 16),
            _buildInputField(_idController, 'ID Staff', Icons.badge),
            SizedBox(height: 16),
            _buildInputField(_ageController, 'Age', Icons.cake, isNumber: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _submitForm,
              child: Text('Submit', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.pink),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Staff list page
class StaffListPage extends StatefulWidget {
  final Staff staff;
  const StaffListPage({super.key, required this.staff});

  @override
  _StaffListPageState createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final CollectionReference staffCollection = FirebaseFirestore.instance
      .collection('staff');

  @override
  void initState() {
    super.initState();
    _addStaffToFirestore(widget.staff);
  }

  Future<void> _addStaffToFirestore(Staff staff) async {
    await staffCollection.add(staff.toMap());
  }

  Future<void> _deleteStaff(String docId) async {
    await staffCollection.doc(docId).delete();
  }

  Future<void> _editStaff(String docId, Staff updatedStaff) async {
    await staffCollection.doc(docId).update(updatedStaff.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Staff'),
        backgroundColor: const Color.fromARGB(255, 250, 147, 181),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: staffCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs =
                snapshot.data!.docs..sort((a, b) {
                  final nameA =
                      (a.data() as Map<String, dynamic>)['name']
                          .toString()
                          .toLowerCase();
                  final nameB =
                      (b.data() as Map<String, dynamic>)['name']
                          .toString()
                          .toLowerCase();
                  return nameA.compareTo(nameB);
                });

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (_, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final staff = Staff.fromMap(data);
                final docId = docs[index].id;

                return Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      staff.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 250, 147, 181),
                      ),
                    ),
                    subtitle: Text(
                      'ID: ${staff.id}\nAge: ${staff.age}',
                      style: TextStyle(height: 1.5),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showEditDialog(docId, staff),
                          icon: Icon(
                            Icons.edit,
                            color: const Color.fromARGB(255, 253, 157, 189),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                      'Are you sure you want to delete this staff profile?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(
                                                  context,
                                                ).pop(), // cancel
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteStaff(docId);
                                          Navigator.of(
                                            context,
                                          ).pop(); // close dialog
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                            color: const Color.fromARGB(255, 22, 2, 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 250, 147, 181),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StaffFormPage()),
            ),
        label: Text('Add Staff'),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditDialog(String docId, Staff staff) {
    final nameController = TextEditingController(text: staff.name);
    final idController = TextEditingController(text: staff.id);
    final ageController = TextEditingController(text: staff.age.toString());

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit Staff'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(labelText: 'ID'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final updatedStaff = Staff(
                    name: nameController.text,
                    id: idController.text,
                    age: int.tryParse(ageController.text) ?? staff.age,
                  );
                  _editStaff(docId, updatedStaff);
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }
}
