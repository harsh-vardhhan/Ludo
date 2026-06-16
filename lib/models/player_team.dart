enum PlayerTeam {
  green,
  blue,
  red,
  yellow;

  String get id => name[0].toUpperCase();
  String get playerKey => '${name[0].toUpperCase()}P';
}
