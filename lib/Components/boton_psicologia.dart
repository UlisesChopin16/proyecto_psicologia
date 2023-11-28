import 'package:flutter/material.dart';

class BotonPsicologia extends StatefulWidget {

  final void Function()? onTap;

  final double? height;
  final double? width;

  final IconData iconData;
  final String text;

  const BotonPsicologia({ 
    Key? key,
    required this.iconData,
    required this.text,
    this.onTap,
    this.height,
    this.width
  }) : super(key: key);

  @override
  State<BotonPsicologia> createState() => _BotonPsicologiaState();
}

class _BotonPsicologiaState extends State<BotonPsicologia> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onDoubleTap: () {
        
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20)
        ),
        child: Card(
          color:widget.onTap != null  ? const Color(0xFF030D67) : Colors.grey[400],
          elevation: 3,
          child: SizedBox(
            width: widget.width ?? 130,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    widget.iconData,
                    color: Colors.white,
                    size: 40,
                  ),
                   Expanded(
                    child: Text(
                      widget.text, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 20
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}