import 'package:roadsos/l10n/app_localizations.dart';

class VehicleRescueData {
  final String vehicleType;
  final String icon;
  final String description;
  final List<String> dangers;
  final List<RescueStep> extractionSteps;
  final List<String> firstAidTips;
  final String fuelType;

  const VehicleRescueData({
    required this.vehicleType,
    required this.icon,
    required this.description,
    required this.dangers,
    required this.extractionSteps,
    required this.firstAidTips,
    required this.fuelType,
  });
}

class RescueStep {
  final int stepNumber;
  final String title;
  final String detail;
  final bool isCritical; // Show in red if true

  const RescueStep({
    required this.stepNumber,
    required this.title,
    required this.detail,
    this.isCritical = false,
  });
}

// ─────────────────────────────────────────────
// LOCALIZED OFFLINE RESCUE DATA
// ─────────────────────────────────────────────
Map<String, VehicleRescueData> getLocalizedVehicleRescueDatabase(AppLocalizations l10n) {
  return {
    'car': VehicleRescueData(
      vehicleType: l10n.rescue_car_type,
      icon: '🚗',
      fuelType: l10n.fuel_petrol_diesel,
      description: l10n.rescue_car_desc,
      dangers: [
        l10n.rescue_car_danger_1,
        l10n.rescue_car_danger_2,
        l10n.rescue_car_danger_3,
        l10n.rescue_car_danger_4,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_car_step_1_title,
          detail: l10n.rescue_car_step_1_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_car_step_2_title,
          detail: l10n.rescue_car_step_2_detail,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_car_step_3_title,
          detail: l10n.rescue_car_step_3_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_car_step_4_title,
          detail: l10n.rescue_car_step_4_detail,
        ),
        RescueStep(
          stepNumber: 5,
          title: l10n.rescue_car_step_5_title,
          detail: l10n.rescue_car_step_5_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 6,
          title: l10n.rescue_car_step_6_title,
          detail: l10n.rescue_car_step_6_detail,
        ),
        RescueStep(
          stepNumber: 7,
          title: l10n.rescue_car_step_7_title,
          detail: l10n.rescue_car_step_7_detail,
        ),
      ],
      firstAidTips: [
        l10n.rescue_car_firstaid_1,
        l10n.rescue_car_firstaid_2,
        l10n.rescue_car_firstaid_3,
        l10n.rescue_car_firstaid_4,
      ],
    ),

    'truck': VehicleRescueData(
      vehicleType: l10n.rescue_truck_type,
      icon: '🚛',
      fuelType: l10n.fuel_diesel,
      description: l10n.rescue_truck_desc,
      dangers: [
        l10n.rescue_truck_danger_1,
        l10n.rescue_truck_danger_2,
        l10n.rescue_truck_danger_3,
        l10n.rescue_truck_danger_4,
        l10n.rescue_truck_danger_5,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_truck_step_1_title,
          detail: l10n.rescue_truck_step_1_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_truck_step_2_title,
          detail: l10n.rescue_truck_step_2_detail,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_truck_step_3_title,
          detail: l10n.rescue_truck_step_3_detail,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_truck_step_4_title,
          detail: l10n.rescue_truck_step_4_detail,
        ),
        RescueStep(
          stepNumber: 5,
          title: l10n.rescue_truck_step_5_title,
          detail: l10n.rescue_truck_step_5_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 6,
          title: l10n.rescue_truck_step_6_title,
          detail: l10n.rescue_truck_step_6_detail,
          isCritical: true,
        ),
      ],
      firstAidTips: [
        l10n.rescue_truck_firstaid_1,
        l10n.rescue_truck_firstaid_2,
        l10n.rescue_truck_firstaid_3,
        l10n.rescue_truck_firstaid_4,
      ],
    ),

    'bike': VehicleRescueData(
      vehicleType: l10n.rescue_bike_type,
      icon: '🏍️',
      fuelType: l10n.fuel_petrol,
      description: l10n.rescue_bike_desc,
      dangers: [
        l10n.rescue_bike_danger_1,
        l10n.rescue_bike_danger_2,
        l10n.rescue_bike_danger_3,
        l10n.rescue_bike_danger_4,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_bike_step_1_title,
          detail: l10n.rescue_bike_step_1_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_bike_step_2_title,
          detail: l10n.rescue_bike_step_2_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_bike_step_3_title,
          detail: l10n.rescue_bike_step_3_detail,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_bike_step_4_title,
          detail: l10n.rescue_bike_step_4_detail,
        ),
        RescueStep(
          stepNumber: 5,
          title: l10n.rescue_bike_step_5_title,
          detail: l10n.rescue_bike_step_5_detail,
        ),
        RescueStep(
          stepNumber: 6,
          title: l10n.rescue_bike_step_6_title,
          detail: l10n.rescue_bike_step_6_detail,
        ),
      ],
      firstAidTips: [
        l10n.rescue_bike_firstaid_1,
        l10n.rescue_bike_firstaid_2,
        l10n.rescue_bike_firstaid_3,
        l10n.rescue_bike_firstaid_4,
      ],
    ),

    'ev_car': VehicleRescueData(
      vehicleType: l10n.rescue_ev_car_type,
      icon: '⚡',
      fuelType: l10n.fuel_electric,
      description: l10n.rescue_ev_car_desc,
      dangers: [
        l10n.rescue_ev_car_danger_1,
        l10n.rescue_ev_car_danger_2,
        l10n.rescue_ev_car_danger_3,
        l10n.rescue_ev_car_danger_4,
        l10n.rescue_ev_car_danger_5,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_ev_car_step_1_title,
          detail: l10n.rescue_ev_car_step_1_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_ev_car_step_2_title,
          detail: l10n.rescue_ev_car_step_2_detail,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_ev_car_step_3_title,
          detail: l10n.rescue_ev_car_step_3_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_ev_car_step_4_title,
          detail: l10n.rescue_ev_car_step_4_detail,
        ),
        RescueStep(
          stepNumber: 5,
          title: l10n.rescue_ev_car_step_5_title,
          detail: l10n.rescue_ev_car_step_5_detail,
          isCritical: true,
        ),
      ],
      firstAidTips: [
        l10n.rescue_ev_car_firstaid_1,
        l10n.rescue_ev_car_firstaid_2,
        l10n.rescue_ev_car_firstaid_3,
        l10n.rescue_ev_car_firstaid_4,
      ],
    ),

    'bus': VehicleRescueData(
      vehicleType: l10n.rescue_bus_type,
      icon: '🚌',
      fuelType: l10n.fuel_diesel_cng,
      description: l10n.rescue_bus_desc,
      dangers: [
        l10n.rescue_bus_danger_1,
        l10n.rescue_bus_danger_2,
        l10n.rescue_bus_danger_3,
        l10n.rescue_bus_danger_4,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_bus_step_1_title,
          detail: l10n.rescue_bus_step_1_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_bus_step_2_title,
          detail: l10n.rescue_bus_step_2_detail,
          isCritical: true,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_bus_step_3_title,
          detail: l10n.rescue_bus_step_3_detail,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_bus_step_4_title,
          detail: l10n.rescue_bus_step_4_detail,
        ),
        RescueStep(
          stepNumber: 5,
          title: l10n.rescue_bus_step_5_title,
          detail: l10n.rescue_bus_step_5_detail,
        ),
      ],
      firstAidTips: [
        l10n.rescue_bus_firstaid_1,
        l10n.rescue_bus_firstaid_2,
        l10n.rescue_bus_firstaid_3,
        l10n.rescue_bus_firstaid_4,
      ],
    ),

    'auto': VehicleRescueData(
      vehicleType: l10n.rescue_auto_type,
      icon: '🛺',
      fuelType: l10n.fuel_multi,
      description: l10n.rescue_auto_desc,
      dangers: [
        l10n.rescue_auto_danger_1,
        l10n.rescue_auto_danger_2,
        l10n.rescue_auto_danger_3,
        l10n.rescue_auto_danger_4,
      ],
      extractionSteps: [
        RescueStep(
          stepNumber: 1,
          title: l10n.rescue_auto_step_1_title,
          detail: l10n.rescue_auto_step_1_detail,
        ),
        RescueStep(
          stepNumber: 2,
          title: l10n.rescue_auto_step_2_title,
          detail: l10n.rescue_auto_step_2_detail,
        ),
        RescueStep(
          stepNumber: 3,
          title: l10n.rescue_auto_step_3_title,
          detail: l10n.rescue_auto_step_3_detail,
        ),
        RescueStep(
          stepNumber: 4,
          title: l10n.rescue_auto_step_4_title,
          detail: l10n.rescue_auto_step_4_detail,
        ),
      ],
      firstAidTips: [
        l10n.rescue_auto_firstaid_1,
        l10n.rescue_auto_firstaid_2,
        l10n.rescue_auto_firstaid_3,
        l10n.rescue_auto_firstaid_4,
      ],
    ),
  };
}

// Helper to get localized vehicle types for selection UI
List<Map<String, String>> getLocalizedVehicleTypes(AppLocalizations l10n) {
  return [
    {'key': 'car',     'label': l10n.rescue_car_type,    'icon': '🚗'},
    {'key': 'bike',    'label': l10n.rescue_bike_type,   'icon': '🏍️'},
    {'key': 'truck',   'label': l10n.rescue_truck_type,  'icon': '🚛'},
    {'key': 'bus',     'label': l10n.rescue_bus_type,    'icon': '🚌'},
    {'key': 'ev_car',  'label': l10n.rescue_ev_car_type, 'icon': '⚡'},
    {'key': 'auto',    'label': l10n.rescue_auto_type,   'icon': '🛺'},
  ];
}