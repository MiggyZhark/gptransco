import 'package:flutter/material.dart';

class RentalCardItem {
  final String urlImage;
  final String driverName;
  final String price;
  final int seats;

  const RentalCardItem(
      {required this.urlImage, required this.driverName, required this.price,required this.seats});
}

class RentalCardSlider extends StatefulWidget {
  const RentalCardSlider({super.key});

  @override
  State<RentalCardSlider> createState() => _RentalCardSliderState();
}

class _RentalCardSliderState extends State<RentalCardSlider> {
  List<RentalCardItem> items = [
    RentalCardItem(
      urlImage: 'https://thumbs.dreamstime.com/b/pasay-ph-may-toyota-hiace-van-group-philippines-car-meet-event-held-282460592.jpg',
      driverName: 'Driver 1',
      seats: 50,
      price: '₱500',
    ),
    RentalCardItem(
      urlImage: 'https://i0.wp.com/realbreezedavaotours.com/wp-content/uploads/2023/09/IMG_20230715_145538.jpg?ssl=1',
      driverName: 'Driver 2',
      seats: 50,
      price: '₱700',
    ),
    RentalCardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6OQe1sTbR8vigzhfOJMVXE8Fsg0a903VBVpkrBUZyCcAIK1U2VR8NC_oYE3idfQjClMw&usqp=CAU',
      driverName: 'Driver 3',
      seats: 50,
      price: '₱750',
    ),
    RentalCardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQM_LGfQzgklVV41GRJtw5nH6ZUARrPJGOhxFUOAtPIxKhZQb0m4hFJ0hjbnQv7o7nVsn0&usqp=CAU',
      driverName: 'Driver 4',
      seats: 50,
      price: '₱800',
    ),
    RentalCardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsiABvx4X9TJP-fU2RzeW-OJh0f4EWFhGQxT5cvK_GOVqMWJ0gIWDd7mKKpQquOlnyLHs&usqp=CAU',
      driverName: 'Driver 5',
      seats: 50,
      price: '₱750',
    ),
    RentalCardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtYtnlZNDvUucaL0sR4i0n6sUi6Zdu7KKcg9TU3WGS3SoE8FbO0gCixAG7ydJWVq-o6rw&usqp=CAU',
      driverName: 'Driver 6',
      seats: 50,
      price: '₱800',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget buildCard({
    required RentalCardItem item,
  }) =>
      Container(
          width: 160,
          child: Column(
            children: [

            ],
          ));
}
