import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final int? id; // Optional for database primary key
  final String name;
  final String position;
  final String role;
  final DateTime joiningDate;
  final DateTime? endDate;

  const Employee({
    this.id,
    required this.name,
    required this.position,
    required this.role,
    required this.joiningDate,
    this.endDate,
  });

  // Convert Employee object to a Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'role': role,
      'joiningDate': joiningDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  // Create an Employee object from a Map (retrieved from the database)
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      role: map['role'],
      joiningDate: DateTime.parse(map['joiningDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }

  // Convert Employee object to JSON (for API integration if needed)
  Map<String, dynamic> toJson() => toMap();

  // Create an Employee object from JSON
  factory Employee.fromJson(Map<String, dynamic> json) => Employee.fromMap(json);

  // Copy method for updating an existing Employee
  Employee copyWith({
    int? id,
    String? name,
    String? position,
    String? role,
    DateTime? joiningDate,
    DateTime? endDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      role: role ?? this.role,
      joiningDate: joiningDate ?? this.joiningDate,
      endDate: endDate ?? this.endDate,
    );
  }

  // Ensures objects can be compared properly in BLoC
  @override
  List<Object?> get props => [id, name, position, role, joiningDate, endDate];
}
