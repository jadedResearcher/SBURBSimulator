import "dart:html";
import "../SBURBSim.dart";


class ChaosClone extends Scene {
  List<Player> playerList = []; //what players are already in the medium when i trigger?
  bool canRepeat = true; //todo: change such that this can repeat 2-3 times in
  Player original = null;
  Player other = null;

  ChaosClone(Session session) :super(session);

  @override
  bool trigger(List<Player> playerList){
    this.playerList = playerList;
    var living = findLivingPlayers(playerList);
    this.original = findAspectPlayer(living, Aspects.CHAOS);
    if (this.original == null) {
      return false;
    } else {
      //return (this.original != null && this.original.rollForLuck() >= 35);
      return (this.original != null && this.session.rand.nextIntRange(0, 100) >= 90);//yes, this is random. kill me.
    }
  }
  @override
  void renderContent(Element div) {
    appendHtml(div,"<br>");
    var divID = (div.id);
    String canvasHTML = "<br><canvas id='canvas" + divID+"' width='" +canvasWidth.toString() + "' height="+canvasHeight.toString() + "'>  </canvas>";
    appendHtml(div,canvasHTML);

    var canvas = querySelector("#canvas"+ divID);
    Drawing.drawGodSymbolBG(canvas, this.original);
    Drawing.drawSprite(canvas, this.original);
    Drawing.drawSpriteTurnways(canvas, this.original);

    String ret = "The " + this.original.htmlTitle() + " Just made a clone of themselves?";
    appendHtml(div, ret);

    //todo: make it hapen.
    Player chaosClone = new Player();
    chaosClone = this.original.clone();
    chaosClone.session = this.original.session;
    chaosClone.denizen = this.original.denizen;//clones don't get their own denizen. hopefully, this wont exile the Original's Denizen...
    chaosClone.relationships = this.original.relationships;//todo:


    Relationship.transferFeelingsToClones(this.original, [chaosClone]);
    for (int j = 0; j < this.session.players.length; j++) {
      this.other = this.session.players[j];
      this.other.generateRelationships([chaosClone]);
      chaosClone.generateRelationships([this.other]);
    } //should have neutral relationship with self.

    chaosClone.guardian = this.original.guardian;
    for (int i = 0; i < this.session.players.length; i++) {
      GameEntity g = this.session.players[i]; //could be a sprite, and they don't have classpects.
      if (g is Player) {
        Player p = this.session.players[i];
        if (p == this.original) {
          super.session.players.insert(i + 1, chaosClone);
          i = this.session.players.length + 1;
        }
      }
    }

    ret = "<br> Uh... what the fuck? " + "The clone looks a bit confused before wandering off. ";
    appendHtml(div, ret);
    session.logger.info("tried to clone Chaos player.");


  }
}