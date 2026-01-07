/// Constantes compartidas para provincias y ciudades/municipios
/// Ordenadas alfabéticamente para mejor experiencia de usuario
class LocationConstants {
  LocationConstants._();

  /// Mapa de provincias a sus ciudades/municipios (ordenado alfabéticamente)
  static const Map<String, List<String>> provinceToCities = {
    'A Coruña': ['A Coruña', 'Ferrol', 'Santiago de Compostela'],
    'Álava': ['Vitoria-Gasteiz'],
    'Albacete': ['Albacete'],
    'Alicante': [
      'Alcoy',
      'Alicante',
      'Altea',
      'Benidorm',
      'Calpe',
      'Dénia',
      'Elche',
      'Jávea',
      'Orihuela',
      'San Vicente del Raspeig',
      'Santa Pola',
      'Torrevieja',
    ],
    'Almería': ['Almería'],
    'Asturias': ['Avilés', 'Gijón', 'Mieres', 'Oviedo'],
    'Ávila': ['Ávila'],
    'Badajoz': ['Badajoz'],
    'Barcelona': [
      'Badalona',
      'Barcelona',
      'Castelldefels',
      'El Prat de Llobregat',
      'Granollers',
      'Hospitalet de Llobregat',
      'Manresa',
      'Mataró',
      'Rubí',
      'Sabadell',
      'Sant Cugat del Vallès',
      'Sitges',
      'Terrassa',
      'Vic',
      'Viladecans',
    ],
    'Burgos': ['Burgos'],
    'Cáceres': ['Cáceres'],
    'Cádiz': [
      'Algeciras',
      'Cádiz',
      'Chiclana de la Frontera',
      'El Puerto de Santa María',
      'Jerez de la Frontera',
      'San Fernando',
    ],
    'Cantabria': ['Castro Urdiales', 'Laredo', 'Santander', 'Torrelavega'],
    'Castellón': ['Castellón de la Plana'],
    'Ceuta': ['Ceuta'],
    'Ciudad Real': ['Ciudad Real'],
    'Córdoba': ['Córdoba'],
    'Cuenca': ['Cuenca'],
    'Girona': ['Blanes', 'Figueres', 'Girona', 'Lloret de Mar', 'Roses'],
    'Granada': ['Granada'],
    'Guadalajara': ['Guadalajara'],
    'Guipúzcoa': ['Eibar', 'Irún', 'San Sebastián', 'Zarautz'],
    'Huelva': ['Huelva'],
    'Huesca': ['Huesca'],
    'Illes Balears': ['Palma de Mallorca'],
    'Jaén': ['Jaén'],
    'La Rioja': ['Logroño'],
    'Las Palmas': [
      'Arrecife',
      'Las Palmas de Gran Canaria',
      'San Bartolomé de Tirajana',
      'Telde',
    ],
    'León': ['León', 'Ponferrada'],
    'Lleida': ['Lleida'],
    'Lugo': ['Lugo'],
    'Madrid': [
      'Alcalá de Henares',
      'Alcobendas',
      'Alcorcón',
      'Arganda del Rey',
      'Aranjuez',
      'Boadilla del Monte',
      'Collado Villalba',
      'Colmenar Viejo',
      'Coslada',
      'Fuenlabrada',
      'Getafe',
      'Las Rozas de Madrid',
      'Leganés',
      'Madrid',
      'Majadahonda',
      'Móstoles',
      'Parla',
      'Pinto',
      'Pozuelo de Alarcón',
      'Rivas-Vaciamadrid',
      'San Fernando de Henares',
      'San Sebastián de los Reyes',
      'Torrejón de Ardoz',
      'Tres Cantos',
      'Valdemoro',
    ],
    'Málaga': [
      'Benalmádena',
      'Estepona',
      'Fuengirola',
      'Málaga',
      'Marbella',
      'Mijas',
      'Ronda',
      'Torremolinos',
      'Vélez-Málaga',
    ],
    'Melilla': ['Melilla'],
    'Murcia': ['Cartagena', 'Lorca', 'Molina de Segura', 'Murcia'],
    'Navarra': ['Pamplona'],
    'Ourense': ['Ourense'],
    'Palencia': ['Palencia'],
    'Pontevedra': ['Pontevedra', 'Vigo'],
    'Salamanca': ['Salamanca'],
    'Santa Cruz de Tenerife': [
      'Adeje',
      'Arona',
      'San Cristóbal de La Laguna',
      'Santa Cruz de Tenerife',
    ],
    'Segovia': ['Segovia'],
    'Sevilla': [
      'Alcalá de Guadaíra',
      'Dos Hermanas',
      'Mairena del Aljarafe',
      'Sevilla',
      'Utrera',
    ],
    'Soria': ['Soria'],
    'Tarragona': ['Cambrils', 'Reus', 'Salou', 'Tarragona'],
    'Teruel': ['Teruel'],
    'Toledo': [
      'Consuegra',
      'Illescas',
      'Madridejos',
      'Mora',
      'Ocaña',
      'Quintanar de la Orden',
      'Seseña',
      'Sonseca',
      'Talavera de la Reina',
      'Toledo',
      'Torrijos',
      'Villacañas',
    ],
    'Valencia': ['Gandía', 'Paterna', 'Sagunto', 'Torrent', 'Valencia'],
    'Valladolid': ['Valladolid'],
    'Vizcaya': ['Barakaldo', 'Bilbao', 'Getxo', 'Portugalete'],
    'Zamora': ['Zamora'],
    'Zaragoza': ['Zaragoza'],
  };

  /// Lista de provincias ordenadas alfabéticamente
  static List<String> get provinces => provinceToCities.keys.toList();

  /// Obtiene las ciudades/municipios de una provincia (ya ordenadas)
  static List<String> getCitiesForProvince(String? province) {
    if (province == null) return [];
    return provinceToCities[province] ?? [];
  }

  /// Obtiene todas las ciudades de todas las provincias (ordenadas)
  static List<String> get allCities {
    final cities = <String>{};
    for (final citiesList in provinceToCities.values) {
      cities.addAll(citiesList);
    }
    final sortedCities = cities.toList()..sort();
    return sortedCities;
  }
}
