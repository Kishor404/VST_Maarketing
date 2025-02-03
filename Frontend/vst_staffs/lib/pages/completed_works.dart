import 'package:flutter/material.dart';

class CompletedWorks extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "service_id": 563,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 3.5
    },
    {
      "service_id": 268,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 4.0
    },
    {
      "service_id": 112,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 5.0
    },
    {
      "service_id": 563,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 3.5
    },
    {
      "service_id": 268,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 4.0
    },
    {
      "service_id": 112,
      "card_id": 235,
      "visit_type": "General Service",
      "date": "08/06/2025",
      "rating": 5.0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Completed Works",
            style: TextStyle(color: Color.fromRGBO(55, 99, 174, 1))),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: CompletedCard(service: service),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CompletedCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const CompletedCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color.fromRGBO(55, 99, 174, 1), width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(55, 99, 174, 1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                'Service ID : ${service["service_id"]}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Card ID : ${service["card_id"]}',
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                Text('Visit Type : ${service["visit_type"]}',
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                Text('Date : ${service["date"]}',
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                const SizedBox(height: 8),
                StarRating(rating: (service["rating"] as num).toDouble()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;

  const StarRating({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            color: Color.fromRGBO(55, 99, 174, 1),
          );
        } else if (index < rating) {
          return const Icon(
            Icons.star_half,
            color: Color.fromRGBO(55, 99, 174, 1),
          );
        } else {
          return const Icon(
            Icons.star,
            color: Color.fromARGB(255, 218, 217, 217),
          );
        }
      }),
    );
  }
}
