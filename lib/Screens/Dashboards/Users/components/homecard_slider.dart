import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Dashboards/Users/components/vanpage.dart';

class CardItem {
  final String urlImage;
  final String title;
  final String subtitle;

  const CardItem(
      {required this.urlImage, required this.title, required this.subtitle});
}

class HomeCardSlider extends StatefulWidget {
  const HomeCardSlider({super.key});

  @override
  State<HomeCardSlider> createState() => _HomeCardSliderState();
}

class _HomeCardSliderState extends State<HomeCardSlider> {
  List<CardItem> items = [
    const CardItem(
      urlImage: 'https://thumbs.dreamstime.com/b/pasay-ph-may-toyota-hiace-van-group-philippines-car-meet-event-held-282460592.jpg',
      title: 'Driver 1',
      subtitle: '₱500',
    ),
    const CardItem(
      urlImage: 'https://i0.wp.com/realbreezedavaotours.com/wp-content/uploads/2023/09/IMG_20230715_145538.jpg?ssl=1',
      title: 'Driver 2',
      subtitle: '₱700',
    ),
    const CardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6OQe1sTbR8vigzhfOJMVXE8Fsg0a903VBVpkrBUZyCcAIK1U2VR8NC_oYE3idfQjClMw&usqp=CAU',
      title: 'Driver 3',
      subtitle: '₱750',
    ),
    const CardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQM_LGfQzgklVV41GRJtw5nH6ZUARrPJGOhxFUOAtPIxKhZQb0m4hFJ0hjbnQv7o7nVsn0&usqp=CAU',
      title: 'Driver 4',
      subtitle: '₱800',
    ),
    const CardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsiABvx4X9TJP-fU2RzeW-OJh0f4EWFhGQxT5cvK_GOVqMWJ0gIWDd7mKKpQquOlnyLHs&usqp=CAU',
      title: 'Driver 5',
      subtitle: '₱750',
    ),
    const CardItem(
      urlImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtYtnlZNDvUucaL0sR4i0n6sUi6Zdu7KKcg9TU3WGS3SoE8FbO0gCixAG7ydJWVq-o6rw&usqp=CAU',
      title: 'Driver 6',
      subtitle: '₱800',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, _) => const SizedBox(
          width: 8,
        ),
        itemBuilder: (context, index) => buildCard(item: items[index]),
      ),
    );
  }

  Widget buildCard({
    required CardItem item,
  }) =>
      SizedBox(
          width: 160,
          child: Column(
            children: [
              Expanded(
                  child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Material(
                            child: Ink.image(
                              image: NetworkImage(item.urlImage),
                              fit: BoxFit.cover,
                              child: InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VanPage(item: item))),
                              ),
                            ),
                          )))),
              const SizedBox(
                height: 4,
              ),
              Text(item.title,style: const TextStyle(fontWeight: FontWeight.bold),),
              Text(item.subtitle)
            ],
          ));
}
