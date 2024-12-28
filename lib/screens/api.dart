const String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';
const String apiKey = '5b3ce3597851110001cf62487f8c922db5d2436299573b80d1d942c9';

getRouteUrl(String startPoint, String endPoint){
  return Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62487f8c922db5d2436299573b80d1d942c9&start=$startPoint&end=$endPoint');
}
