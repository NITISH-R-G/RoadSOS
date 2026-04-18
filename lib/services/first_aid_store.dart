/// A grounded store of verified medical advice.
/// 
/// In a production app, this would be a local JSON file or a small 
/// vector DB synced from a verified medical source (e.g. Red Cross, WHO).
class FirstAidStore {
  static const Map<String, String> advice = {
    'severe bleeding wound management tourniquet': 
      '1. Apply direct pressure to the wound with a clean cloth.\n'
      '2. If bleeding is life-threatening, apply a tourniquet 2-3 inches above the wound.\n'
      '3. Do not remove the tourniquet until medical help arrives.',
    
    'burn wound first aid cool water': 
      '1. Run cool (not cold) water over the burn for 10-20 minutes.\n'
      '2. Cover the burn loosely with a sterile bandage or clean plastic wrap.\n'
      '3. Do not apply ice, butter, or ointments.',
      
    'CPR rescue breathing': 
      '1. Check for breathing and pulse.\n'
      '2. If absent, start chest compressions: 30 compressions followed by 2 breaths.\n'
      '3. Push hard and fast in the center of the chest.',
      
    'fracture immobilization splint': 
      '1. Do not try to realign the bone.\n'
      '2. Immobilize the limb using a splint or padding.\n'
      '3. Check for circulation below the injury site.',
      
    'general road accident first aid emergency response': 
      '1. Ensure the scene is safe for you and the victim.\n'
      '2. Call emergency services immediately.\n'
      '3. Do not move the victim unless they are in immediate danger.'
  };

  static String getVerifiedAdvice(String query) {
    return advice[query] ?? advice['general road accident first aid emergency response']!;
  }
}
