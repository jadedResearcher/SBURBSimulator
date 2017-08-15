import "SBURBClass.dart";
import "../../../SBURBSim.dart";

class Sylph extends SBURBClass {
  @override
  List<String> levels =["SERENE SCALLYWAG", "MYSTICAL RUGMUFFIN","FAE FLEDGLING"];
  @override
  List<String> quests =["restoring a consort city to its former glory","preserving the legacy of a doomed people","providing psychological counseling to homeless consorts"];
  @override
  List<String> postDenizenQuests =["beginning to heal the vast psychological damage their consorts have endured from the denizen’s ravages","setting up counseling booths around their land and staffing them with well trained consort professionals","bugging and fussing and meddling with the consorts, but now using their NEW FOUND POWERS","realizing that maybe their bugging and fussing and meddling isn’t always the best way to deal with things"];
  @override
  List<String> handles =["surly","sour","sweet","stylish","soaring", "serene", "salacious"];
  Sylph() : super("Sylph", 6, true);



  @override
  bool highHinit() {
    return true;
  }

  @override
  bool isActive() {
    return false;
  }


  @override
  num  modPowerBoostByClass(num powerBoost, AssociatedStat stat) {
    if (stat.multiplier > 0) {
      powerBoost = powerBoost * 0.5;
    } else {
      powerBoost = powerBoost * -0.5;
    }
    return powerBoost;
  }

  @override
  double getAttackerModifier() {
    return 1.0;
  }

  @override
  double getDefenderModifier() {
    return 1.0;
  }

  @override
  double getMurderousModifier() {
    return 1.5;
  }

  @override
  bool hasInteractionEffect() {
    return true;
  }

  @override
  void processStatInteractionEffect(Player p,GameEntity target, AssociatedStat stat) {
    num powerBoost = 2 * p.getStat("power") / 20;
    powerBoost = this.modPowerBoostByClass(powerBoost, stat);
    //modify other.
    target.modifyAssociatedStat(powerBoost, stat);
  }

}