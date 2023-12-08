import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';
import 'package:proyecto_psicologia/Services/generar_pdf_services.dart';
import 'package:proyecto_psicologia/Views/pdf_cita_view.dart';

class PrioridadAltaView extends StatefulWidget {
  const PrioridadAltaView({ Key? key }) : super(key: key);

  @override
  _PrioridadAltaViewState createState() => _PrioridadAltaViewState();
}

class _PrioridadAltaViewState extends State<PrioridadAltaView> {

  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    // ponemos la mascara que queremos que tenga la fecha de nacimiento
    // en este caso es la fecha de nacimiento de  4 digitos, un guion, 2 digitos, otro guion y 2 digitos
    // y seguira este formato al momento de escribirlo
    mask: 'xxxxxxxxxx', 

    // con este parametro le decimos que el texto se escribira de manera automatica al momento de escribir el texto  
    type: MaskAutoCompletionType.eager,
    // con este filtro le decimos que solo acepte numeros
    // y que cambie los 8x por el numero que escribamos
    filter: { "x": RegExp(r'[0-9]') },
  );

  final servicios = Get.put(FirebaseServicesS());

  bool active = false;

  DateTime verificarFecha = DateTime.now();

  bool verificarDiaE = true;
  String fecha = '';
  String hora = '';
  String diaHora = '';

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

  List<String> meses = [
    'Enero', 
    'Febrero', 
    'Marzo', 
    'Abril', 
    'Mayo', 
    'Junio', 
    'Julio', 
    'Agosto', 
    'Septiembre', 
    'Octubre', 
    'Noviembre', 
    'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    // día de hoy + 3 días
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      // Tu código aquí se ejecutará después de que se haya construido el árbol de widgets.
      // await servicios.obtenerAlumno(
      //   collection: 'estudiantes',
      //   id: servicios.numeroControl.value,
      //   context: context
      // );
      await servicios.obtenerAlumno(
        collection: 'estudiantes',
        id: servicios.numeroControl.value,
        // id: 'c18090562',
        context: context
      );
      if(servicios.telefono.value.length == 10 ){
        active = true;
      }
    });
  }

  // metodo para checar días y verificar si hay horario disponible 
  Future<void> verificarDia() async {
    // Si el dia seleccionado es lunes entonces mostrar los horarios de lunes
    while(verificarDiaE){
      if(verificarFecha.weekday == DateTime.monday){
        await cicloChecarDia(dia: 'Lunes');
      } else if(verificarFecha.weekday == DateTime.tuesday){
        await cicloChecarDia(dia: 'Martes');
      } else if(verificarFecha.weekday == DateTime.wednesday){
        await cicloChecarDia(dia: 'Miercoles');
      } else if(verificarFecha.weekday == DateTime.thursday){
        await cicloChecarDia(dia: 'Jueves');
      } else if(verificarFecha.weekday == DateTime.friday){
        await cicloChecarDia(dia: 'Viernes');
      } else if(verificarFecha.weekday == DateTime.saturday){
        verificarFecha = verificarFecha.add(const Duration(days: 1));
      } else if(verificarFecha.weekday == DateTime.sunday){

      }

      if(!verificarDiaE){
        return;
      }else{
        verificarFecha = verificarFecha.add(const Duration(days: 1));
      }
      
    }
  }

  cicloChecarDia({required String dia})async{
    for(int i = 0; i < horarios[dia]!.length; i++){
      await servicios.verificarCita(
        collection: 'Citas',
        id: '${verificarFecha.toString().split(' ')[0]} ${horarios[dia]![i]}',
        context: context
      );
      if(!servicios.verificarCitaExistente.value){
        setState(() {
          verificarDiaE = false;
          fecha = verificarFecha.toString().split(' ')[0];
          hora = horarios[dia]![i];
          diaHora = '${verificarFecha.toString().split(' ')[0]} ${horarios[dia]![i]}';
        });
        return;
      }
    }
  }

  void onChangedTelefono(String value){
    setState(() {
      servicios.telefono.value = value;
      if(servicios.telefono.value.length == 10){
        active = true;
      }else{
        active = false;
      }
    });
  }

  // metodo para obtener la fecha compuesta por ejemplo si tengo 2021-10-10 este metodo me devuelve 10/Octubre/2021 o 01/Enero/2021
  String obtenerFecha(DateTime fecha){
    // obtenemos el día con formato de 2 digitos
    servicios.fechaNormal.value = fecha.toString().split(' ')[0];
    String dia = fecha.day.toString().padLeft(2, '0');
    String mes = meses[fecha.month - 1].toUpperCase();
    String year = fecha.year.toString();
    return '$dia/$mes/$year';
  }


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Center(
          child: Column(
            children: [
              const Header(),
              if(!servicios.verificar.value)
              filaBotones(),

              body(),
            ],
          )
        )
      ),
    );
  }

  filaBotones(){
    return Center(
      child: SizedBox(
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BotonPsicologia(
              iconData: Icons.arrow_back_rounded,
              text: 'Volver',
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  body(){
    return Obx(
      ()=> Expanded(
        child: !servicios.verificar.value ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ingresarTelefono(),
          ],
        ) : const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }


  ingresarTelefono(){
    return SizedBox(
      height: 400,
      width: 500,
      child: Card(
        color: const Color(0xFFD9D9D9),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const Text(
                'Tu prioridad es ALTA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20,),
              // verificamos si el usuario ya tiene un telefono registrado
              if(servicios.verificarTelefono.value)
              const Text(
                'Por favor, ingresa tu número de teléfono para que un psicólogo se comunique contigo',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              )
              else
              const Text(
                'Por favor, Haga clic en el botón para agendar una cita lo antes posible',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              if(servicios.verificarTelefono.value)
              TextFormField(
                onChanged: onChangedTelefono,
                inputFormatters: [maskFormatter],
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF030D67),
                      width: 2
                    ),
                  ),
                  labelText: 'Número de teléfono',
                ),
              ),
              const SizedBox(height: 20,),
              BotonPsicologia(
                iconData: Icons.check,
                width: 140,
                text: 'Agendar',
                onTap: active ? ()async{
                  await verificarDia();
                  servicios.fecha.value = obtenerFecha(verificarFecha);
                  servicios.hora.value = hora;
                  if(servicios.verificarTelefono.value){
                    if(!context.mounted) return;
                    await servicios.actualizarAlumno(
                      context: context,
                      collection: 'estudiantes', 
                      id: servicios.numeroControl.value, 
                      campo: 'celular', 
                      valor: servicios.telefono.value
                    );
                  }
                  if(!context.mounted) return;
                  await servicios.agregarCita(
                    context: context,
                    collection: 'Citas', 
                    id: diaHora,
                    data: {
                      'numeroControlCita': servicios.numeroControl.value, 
                      'carrera': servicios.carrera.value, 
                      'numeroTelCita': servicios.telefono.value,
                      'cicloEscolarCita': servicios.periodo.value,
                      'fechaCita': servicios.fecha.value,
                      'nombreCita': servicios.nombre.value,
                      'horaCita': servicios.hora.value,
                      'fechaNormal': servicios.fechaNormal.value,
                      // estampa de tiempo para ordenar las citas
                      'timestamp': DateTime.now().toString()
                    }
                  );

                  await GenerarPdfServices().initPDF();

                  if(!context.mounted) return;
                  await servicios.subirArchivo(data: servicios.pdf.value, nombre: '${servicios.fechaNormal.value} ${servicios.hora.value}.pdf', context: context);
                  if(!context.mounted) return;
                  servicios.snackBarSuccess(mensaje: 'Cita agendada con exito', context: context);

                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PdfCitaView()
                    )
                  );
                } : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

}