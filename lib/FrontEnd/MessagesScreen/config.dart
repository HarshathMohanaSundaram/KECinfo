import 'package:flutter/material.dart';

const Color bodyColor = Color.fromRGBO(250, 250, 250, 1);
const Color fadedWhite = Color.fromRGBO(230, 230, 230, 1);
const Color royalBlue = Color.fromRGBO(8, 33, 198, 1);
const Color lightBlue = Color.fromRGBO(0, 180, 255, 1);
const Color royalPurple = Color.fromRGBO(85, 42, 110, 1);
const Color fadedPurple = Color.fromRGBO(85, 42, 110, .7);

class Department {
  String degree, department;
  int tabs;
  Department({required this.degree, required this.department,required this.tabs});
}
List departments = [
  Department(
      degree: 'UG',
      department: 'Civil',
      tabs: 4
  ),
  Department(
    degree: 'UG',
    department: 'Mechanical',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Mechatronics',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Automobile',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Electrical And Electronics',
    tabs:4,
  ),
  Department(
    degree: 'UG',
    department: 'Electronics And Instrumentation',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Electronics and Communication',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Computer Science',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Information Technology',
    tabs: 4,
  ),
  Department(
    degree: 'UG',
    department: 'Chemical',
    tabs: 4,
  ),
  Department(
      degree: 'UG',
      department: 'Food Technology',
      tabs: 4
  ),
  Department(
      degree: 'UG',
      department: 'Artificial Intelligence and Data Science',
      tabs: 4
  ),
  Department(
      degree: 'UG',
      department: 'Artificial Intelligence and Machine Learning',
      tabs: 4
  ),
  Department(
      degree: 'UG',
      department: 'Computer Science and Design',
      tabs: 4
  ),
  Department(
      degree: 'UG',
      department: 'B.Sc Computer Systems and Design',
      tabs: 3
  ),
  Department(
      degree: 'UG',
      department: 'B.Sc Information Systems',
      tabs: 3
  ),
  Department(
      degree: 'UG',
      department: 'B.Sc Software Systems',
      tabs: 3
  ),
  Department(
      degree: 'PG',
      department: 'M.Sc Software Systems',
      tabs: 5
  ),
  Department(
      degree: 'PG',
      department: 'Master of Business Administration',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Master of Computer Applications',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Construction Engineering and Management',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Structural Engineering',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Engineering Design',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Mechatronics',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Power Electronics and Drives',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Control and Instrumentation',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Embedded Systems',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'VLSI Design',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Computer Science',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Information Technology',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Chemical',
      tabs: 2
  ),
  Department(
      degree: 'PG',
      department: 'Food Technology',
      tabs: 2
  ),
];
