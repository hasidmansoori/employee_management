import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_cubit.dart';
import '../models/employee_model.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;
  final int? index;

  const EmployeeFormScreen({Key? key, this.employee, this.index}) : super(key: key);

  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole;
  DateTime? _joiningDate;
  DateTime? _endDate;

  final List<String> _roles = ["Product Designer", "Flutter Developer", "QA Tester", "Product Owner"];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _selectedRole = widget.employee!.role;
      _joiningDate = widget.employee!.joiningDate;
      _endDate = widget.employee!.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // 🔵 Blue AppBar
        title: const Text(
          "Add Employee",
          style: TextStyle(color: Colors.white), // ⚪ White Title
        ),
        iconTheme: const IconThemeData(color: Colors.white), // ⚪ White Back Button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Employee Name", _nameController, Icons.person),
              const SizedBox(height: 16),

              _buildRoleSelector(),
              const SizedBox(height: 16),

              _buildDateSelectorRow(), // Joining Date & End Date in one row
              const Spacer(),

              _buildBottomButtons(), // Save & Cancel at bottom-right
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Reusable Text Field with Right Icon**
  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Please enter $label";
        return null;
      },
    );
  }

  /// ✅ **Role Selector Dropdown with Bottom Sheet**
  Widget _buildRoleSelector() {
    return GestureDetector(
      onTap: _showRoleSelectionSheet,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Select Role",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(_selectedRole ?? "Tap to select"),
      ),
    );
  }

  void _showRoleSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: _roles.map((role) {
            return ListTile(
              title: Text(role),
              onTap: () {
                setState(() => _selectedRole = role);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// ✅ **Joining Date & End Date in One Row (With Right Arrow)**
  Widget _buildDateSelectorRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            date: _joiningDate,
            label: "Today",
            onDateSelected: (date) => setState(() => _joiningDate = date),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.arrow_forward, color: Colors.blue), // 🛠 Right Arrow Icon
        ),
        Expanded(
          child: _buildDatePicker(
            date: _endDate,
            label: "No Date",
            onDateSelected: (date) => setState(() => _endDate = date),
          ),
        ),
      ],
    );
  }

  /// ✅ **Date Picker Dialog (Themed as per 5165.png)**
  Widget _buildDatePicker({
    required DateTime? date,
    required String label,
    required Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context, date, onDateSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            Text(
              date == null ? label : "${date.day}/${date.month}/${date.year}", // 🛠 Format date
              style: TextStyle(fontSize: 16, color: date == null ? Colors.grey : Colors.black),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime? currentDate, Function(DateTime) onDateSelected) async {
    DateTime selectedDate = currentDate ?? DateTime.now();
    int selectedTabIndex = -1; // Track which tab is selected

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity, // Full width of the screen
            padding: const EdgeInsets.all(12.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                // Update the date when a tab is clicked
                void updateSelectedDate(DateTime date, int index) {
                  setState(() {
                    selectedDate = date;
                    selectedTabIndex = index;
                  });
                  onDateSelected(date);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        'Select Date',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Tabs (2 per row)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _dateOptionButton("Today", DateTime.now(), 0, selectedTabIndex, updateSelectedDate),
                        _dateOptionButton("Next Monday", _getNextMonday(), 1, selectedTabIndex, updateSelectedDate),
                        _dateOptionButton("Next Tuesday", _getNextTuesday(), 2, selectedTabIndex, updateSelectedDate),
                        _dateOptionButton("After 1 Week", _getAfterOneWeek(), 3, selectedTabIndex, updateSelectedDate),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Calendar Picker
                    SizedBox(
                      height: 200,
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        currentDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                            selectedTabIndex = -1; // Deselect tabs when manually choosing
                          });
                          onDateSelected(date);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel & Save Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            onDateSelected(selectedDate);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }




  DateTime _getNextMonday() {
    DateTime now = DateTime.now();
    int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    return now.add(Duration(days: daysUntilMonday));
  }

  DateTime _getNextTuesday() {
    DateTime now = DateTime.now();
    int daysUntilTuesday = (DateTime.tuesday - now.weekday + 7) % 7;
    return now.add(Duration(days: daysUntilTuesday));
  }

  DateTime _getAfterOneWeek() {
    return DateTime.now().add(const Duration(days: 7));
  }

  Widget _dateOptionButton(
      String label,
      DateTime date,
      int index,
      int selectedIndex,
      Function(DateTime, int) updateDate,
      ) {
    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        updateDate(date, index); // Update the selected date and call onDateChanged
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45, // Two per row
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }







  void _showDatePickerDialog(String title, DateTime? initialDate, ValueChanged<DateTime> onSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // 🔵 Blue Theme (as in 5165.png)
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) onSelected(picked);
  }

  /// ✅ **Save & Cancel Buttons (Bottom Right)**
  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _saveEmployee,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /// ✅ **Save Employee Data**
  void _saveEmployee() {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        name: _nameController.text,
        position: _selectedRole ?? "Not Specified", // 🛠 FIX: Added 'position'
        role: _selectedRole ?? "Not Specified",
        joiningDate: _joiningDate ?? DateTime.now(),
        endDate: _endDate,
      );

      if (widget.index != null) {
        context.read<EmployeeCubit>().updateEmployee(widget.index!, employee);
      } else {
        context.read<EmployeeCubit>().addEmployee(employee);
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
    }
  }


  /// ✅ **Date Formatting (DD/MM/YYYY)**
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
