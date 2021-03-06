import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_turtle_v2/dbHelper/delData.dart';
import 'package:fast_turtle_v2/dbHelper/updateData.dart';
import 'package:fast_turtle_v2/models/activeAppointmentModel.dart';
import 'package:fast_turtle_v2/models/userModel.dart';
import 'package:flutter/material.dart';

class BuildAppointmentList extends StatefulWidget {
  final User user;
  BuildAppointmentList(this.user);
  @override
  _BuildAppointmentListState createState() => _BuildAppointmentListState(user);
}

class _BuildAppointmentListState extends State<BuildAppointmentList> {
  User user;
  _BuildAppointmentListState(this.user);

  String gonder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aktif Appointmentsınız"),
      ),
      body: _buildStremBuilder(context),
    );
  }

  _buildStremBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("tbleActiveAppointments")
          .where('patientToken', isEqualTo: user.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return _buildBody(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 15.0),
      children: snapshot
          .map<Widget>((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  _buildListItem(BuildContext context, DocumentSnapshot data) {
    final randevu = ActiveAppointment.fromSnapshot(data);

    return Padding(
      key: ValueKey(randevu.reference),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.greenAccent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0)),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.healing),
          ),
          title: Row(
            children: <Widget>[
              Text(
                randevu.doctorName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(
                width: 3.0,
              ),
              Text(
                randevu.doctorLastName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ],
          ),
          subtitle: Text(randevu.appointmentDate),
          trailing: Text("İptal Et",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),
          onTap: () {
            alrtAppointmentIptalEt(context, randevu);
          },
        ),
      ),
    );
  }

  void alrtAppointmentIptalEt(BuildContext context, ActiveAppointment rand) {
    var alrtAppointment = AlertDialog(
      title: Text(
        "Appointment iptal etmek istediğinize emin misiniz?",
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Hayır"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(
          width: 5.0,
        ),
        FlatButton(
          child: Text(
            "Yes",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            UpdateService()
                .updateDoctorAppointments(rand.doctorToken, rand.appointmentDate);
            DelService().deleteActiveAppointment(rand);
            Navigator.pop(context);
            Navigator.pop(context,true);
          },
        )
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alrtAppointment;
        });
  }
}
