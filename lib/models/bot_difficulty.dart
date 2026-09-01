enum BotDifficulty {
  beginner(800, 'Beginner Bot', 'Pemula yang baru belajar langkah-langkah dasar.'),
  novice(1000, 'Casual Bot', 'Pemain santai dengan sedikit pemahaman taktik.'),
  intermediate(1300, 'Intermediate Bot', 'Paham pola serang, pertahanan, & pembukaan.'),
  advanced(1600, 'Advanced Bot', 'Kombinasi taktis dan perhitungan mendalam.'),
  expert(2000, 'Master Bot', 'Sangat kuat, jarang melakukan blunder fatal.'),
  grandmaster(2400, 'Grandmaster Bot', 'AI engine maksimal dengan strategi mendalam.');

  final int rating;
  final String title;
  final String description;

  const BotDifficulty(this.rating, this.title, this.description);
}
