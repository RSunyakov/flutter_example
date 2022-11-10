import 'package:teremok/domain/detailed_housing/detailed_housing.dart';
import 'package:teremok/ui/screens/booking/src/third_step/third_booking_step_controller.dart';

class BookingArguments {
  BookingArguments(
      {required this.details,
      required this.placeId,
      required this.startDate,
      required this.endDate,
      required this.beds});

  final int placeId;
  final DetailedHousing details;
  final DateTime startDate;
  final DateTime endDate;
  final List<BookingBed> beds;
}
