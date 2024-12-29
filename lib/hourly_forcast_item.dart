import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;


  const HourlyForecastItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,

    });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Card(
                        elevation: 6,
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                            
                              child: Column(
                                children: [
                                  Text(label,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                              
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8,),
                                  Icon(icon,
                                  size: 30,),
                                  const SizedBox(height: 8,),
                                  Text(value,style: const TextStyle(
                                    fontSize: 14,
                              
                                  ),
                                    maxLines: 1,
                                  )
                                ],
                              ),     
                        ),
                      ),
    );
  }
}