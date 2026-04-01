import 'package:puzzleforchild/l10n/app_localizations.dart';
import 'package:puzzleforchild/services/animal_name_keys.dart';

extension AnimalNameExtension on AppLocalizations {
  /// Получает перевод названия животного по ключу
  String getAnimalName(String fileName) {
    // Получаем ключ из маппинга
    final String? l10nKey = animalNameKeys[fileName];
    
    if (l10nKey == null) {
      // Если ключ не найден, возвращаем оригинальное название
      return fileName;
    }
    
    // Возвращаем перевод по ключу
    return _getTranslationByKey(l10nKey);
  }
  
  // Метод для получения перевода по ключу
  // Dart не поддерживает динамические вызовы методов, поэтому используем switch
  String _getTranslationByKey(String key) {
    switch (key) {
      // Pets
      case 'animal_canary': return animal_canary;
      case 'animal_kapibara': return animal_kapibara;
      case 'animal_dwarf_rabbit': return animal_dwarf_rabbit;
      case 'animal_cat': return animal_cat;
      case 'animal_frog': return animal_frog;
      case 'animal_guinea_pig': return animal_guinea_pig;
      case 'animal_tarantula': return animal_tarantula;
      case 'animal_parrot': return animal_parrot;
      case 'animal_fish': return animal_fish;
      case 'animal_dog': return animal_dog;
      case 'animal_snail': return animal_snail;
      case 'animal_hamster': return animal_hamster;
      case 'animal_ferret': return animal_ferret;
      case 'animal_turtle': return animal_turtle;
      case 'animal_chinchilla': return animal_chinchilla;
      case 'animal_lizard': return animal_lizard;
      // Farm Animals
      case 'animal_ram': return animal_ram;
      case 'animal_bull': return animal_bull;
      case 'animal_goose': return animal_goose;
      case 'animal_turkey': return animal_turkey;
      case 'animal_goat': return animal_goat;
      case 'animal_cow': return animal_cow;
      case 'animal_chicken': return animal_chicken;
      case 'animal_horse': return animal_horse;
      case 'animal_sheep': return animal_sheep;
      case 'animal_donkey': return animal_donkey;
      case 'animal_rooster': return animal_rooster;
      case 'animal_pig': return animal_pig;
      case 'animal_duck': return animal_duck;
      case 'animal_pheasant': return animal_pheasant;
      // Wild Animals Russia
      case 'animal_squirrel': return animal_squirrel;
      case 'animal_polar_bear': return animal_polar_bear;
      case 'animal_brown_bear': return animal_brown_bear;
      case 'animal_wolf': return animal_wolf;
      case 'animal_stoat': return animal_stoat;
      case 'animal_snowshoe_hare': return animal_snowshoe_hare;
      case 'animal_european_hare': return animal_european_hare;
      case 'animal_wild_boar': return animal_wild_boar;
      case 'animal_roe_deer': return animal_roe_deer;
      case 'animal_fox': return animal_fox;
      case 'animal_moose': return animal_moose;
      case 'animal_walrus': return animal_walrus;
      case 'animal_lynx': return animal_lynx;
      case 'animal_reindeer': return animal_reindeer;
      case 'animal_ground_squirrel': return animal_ground_squirrel;
      case 'animal_siberian_tiger': return animal_siberian_tiger;
      // African Animals
      case 'animal_hippo': return animal_hippo;
      case 'animal_buffalo': return animal_buffalo;
      case 'animal_camel': return animal_camel;
      case 'animal_cheetah': return animal_cheetah;
      case 'animal_hyena': return animal_hyena;
      case 'animal_gorilla': return animal_gorilla;
      case 'animal_zebra': return animal_zebra;
      case 'animal_crocodile': return animal_crocodile;
      case 'animal_lion': return animal_lion;
      case 'animal_lemur': return animal_lemur;
      case 'animal_leopard': return animal_leopard;
      case 'animal_rhino': return animal_rhino;
      case 'animal_elephant': return animal_elephant;
      case 'animal_ostrich': return animal_ostrich;
      case 'animal_meerkat': return animal_meerkat;
      case 'animal_chimpanzee': return animal_chimpanzee;
      default: return key;
    }
  }
}
