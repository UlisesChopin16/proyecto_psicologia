import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Constants/colors.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaCitaView extends StatefulWidget {
  final int prioridad;
  const AgendaCitaView({ 
    Key? key,
    required this.prioridad
  }) : super(key: key);

  @override
  _AgendaCitaViewState createState() => _AgendaCitaViewState();
}

class _AgendaCitaViewState extends State<AgendaCitaView> {

  final servicios = FirebaseServicesS();

  bool active = false;

  DateTime hoy = DateTime.now();
  DateTime selectedDayP = DateTime.now();
  DateTime firstDay = DateTime.now();

  String horario = '';

  Map<String,List<String>> horarios = {
    'Lunes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Martes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Miercoles': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
    ],
    'Jueves': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '1:00pm - 2:00pm',
    ],
    'Viernes': [
      '7:00am - 8:00am',
      '8:00am - 9:00am',
      '9:00am - 10:00am',
      '10:00am - 11:00am'
    ],
  };


  @override
  void initState() {
    super.initState();
    // día de hoy + 3 días
    if(hoy.add(Duration(days: widget.prioridad)).weekday == DateTime.saturday){
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad + 2));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad + 2));
    }else if(hoy.add( Duration(days: widget.prioridad)).weekday == DateTime.sunday){
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad + 1));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad + 1));
    }else{
      selectedDayP = DateTime.now().add(Duration(days: widget.prioridad));
      firstDay = DateTime.now().add(Duration(days: widget.prioridad));
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Header(),
            filaBotones(),
            body(),
          ],
        )
      )
    );
  }

  filaBotones(){
    return Center(
      child: SizedBox(
        width: 800,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BotonPsicologia(
              iconData: Icons.arrow_back_rounded,
              text: 'Volver',
              onTap: (){
                Navigator.pop(context);
              },
            ),
            BotonPsicologia(
              iconData: Icons.save_rounded,
              text: 'Guardar',
              width: 140,
              onTap: active ? (){
                
              } : null,
            ),
          ],
        ),
      ),
    );
  }


  body(){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: SizedBox(
              width: 950,
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    tableCalendar(),
                    const Gap(20),
                    listaHorarios(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  tableCalendar(){
    // dia de hoy mas widget.prioridad
    return FittedBox(
      fit: BoxFit.contain,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 500, 
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: Colors.grey,
                width: 4
              )
            ),
            child: TableCalendar(
              focusedDay: selectedDayP, 
              firstDay: firstDay,
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(selectedDayP, day),
              onDaySelected: (selectedDay, focusedDay){
                setState(() {
                  // si focusedDay es sabado o domingo entonces no se puede seleccionar
                  if(focusedDay.weekday == DateTime.saturday){
                    selectedDayP = selectedDay.add(const Duration(days: 2));
                  }else if(focusedDay.weekday == DateTime.sunday){
                    selectedDayP = selectedDay.add(const Duration(days: 1));
                  }else{
                    selectedDayP = selectedDay;
                  }

                });
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              calendarStyle:  CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Palette.colorBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  listaHorarios(){
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: <Widget>[
            const Text(
              'Horarios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold
              ),
            ),
            Expanded(
              child: checkList(),
            ),
          ],
        )
      ),
    );
  }

  checkList(){
    // Si el dia seleccionado es lunes entonces mostrar los horarios de lunes
    if(selectedDayP.weekday == DateTime.monday){
      return listaGenerada('Lunes');
    } else if(selectedDayP.weekday == DateTime.tuesday){
      return listaGenerada('Martes');
    } else if(selectedDayP.weekday == DateTime.wednesday){
      return listaGenerada('Miercoles');
    } else if(selectedDayP.weekday == DateTime.thursday){
      return listaGenerada('Jueves');
    } else if(selectedDayP.weekday == DateTime.friday){
      return listaGenerada('Viernes');
    }
  }

  listaGenerada(String dia){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: horarios[dia]!.map(
        (e) => Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: RadioListTile(
            title: Text(
             e.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            value:e.toString(), 
            groupValue: horario, 
            onChanged: (opcion) {
              setState(() {
                horario = opcion.toString();
                active = true;
              });
            },
          ),
        )
      ).toList(),
    );
  }

  

}