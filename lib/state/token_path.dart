const blueTokenPath = [
  'B04',
  'B03',
  'B02',
  'B01',
  'B00',
  'R52',
  'R42',
  'R32',
  'R22',
  'R12',
  'R02',
  'R01',
  'R00',
  'R10',
  'R20',
  'R30',
  'R40',
  'R50',
  'G05',
  'G04',
  'G03',
  'G02',
  'G01',
  'G00',
  'G10',
  'G20',
  'G21',
  'G22',
  'G23',
  'G24',
  'G25',
  'Y00',
  'Y10',
  'Y20',
  'Y30',
  'Y40',
  'Y50',
  'Y51',
  'Y52',
  'Y42',
  'Y32',
  'Y22',
  'Y12',
  'Y02',
  'B20',
  'B21',
  'B22',
  'B23',
  'B24',
  'B25',
  'B15',
  'B14',
  'B13',
  'B12',
  'B11',
  'B10',
  'BF',
];

const greenTokenPath = [
  'G21',
  'G22',
  'G23',
  'G24',
  'G25',
  'Y00',
  'Y10',
  'Y20',
  'Y30',
  'Y40',
  'Y50',
  'Y51',
  'Y52',
  'Y42',
  'Y32',
  'Y22',
  'Y12',
  'Y02',
  'B20',
  'B21',
  'B22',
  'B23',
  'B24',
  'B25',
  'B15',
  'B05',
  'B04',
  'B03',
  'B02',
  'B01',
  'B00',
  'R52',
  'R42',
  'R32',
  'R22',
  'R12',
  'R02',
  'R01',
  'R00',
  'R10',
  'R20',
  'R30',
  'R40',
  'R50',
  'G05',
  'G04',
  'G03',
  'G02',
  'G01',
  'G00',
  'G10',
  'G11',
  'G12',
  'G13',
  'G14',
  'G15',
  'GF',
];

final Map<String, List<String>> tokenPaths = {
  'BP': blueTokenPath,
  'GP': greenTokenPath,
};

List<String> getTokenPath(String playerId) {
  return tokenPaths[playerId] ?? [];
}