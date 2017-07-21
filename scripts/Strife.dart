part of SBURBSim;

//TODO grab out all the strife parts from GameEntity
/*
  Though this FEELS like it should take a back burner to the general refactoring effort, the fact
  remains that GameEntities, Players and PlayerSnapshots are all treated as interchangeable
  and in Dart they are NOT.  So I need to do inheritance proper style.
 */
class Strife {//TODO subclass strife for pvp but everybody lives strifes
  List<Team> teams; //for now, assume 2 teams, but could support more in future. think terezi +dave +dirk fighting two non-allied Jacks
  num turnsPassed = 0; //keep track for interuptions and etc.
  Session session;
  Strife(this.session, this.teams);
  num timeTillRocks = 99999999; //unless it's a royalty fight, assume no rocks.

  //TODO for now keeping old code as reference material, but delete it whole sale. it is too tangled up in "this" is a GameEntity.

  //TODO get this working, then rewrite code for each sub part.
  void startTurn(div) {
    teams.sort(); //we do this every turn because mobility can change and should effect turn order.
    for(Team team in teams) {
        team.takeTurn(div, turnsPassed, teams); //will handling resetting player availablity
    }
    checkForSuddenEnding(div); //everyone is killed. or absconded in denizen case. calls processEnding on own.
    if(strifeEnded()) {
      describeEnding(div); //will call processEnding.
    }else {
       turnsPassed ++;
       startTurn(div);
    }
  }

  void checkForSuddenEnding(div) {
      if(turnsPassed > timeTillRocks) {
        this.rocksFallEverybodyDies(div);
        processEnding();
      }else if(denizenDoneWithYourShit(div)) { //highest priority. Denizen will take care of ending their fights.
        processEnding();
      }else if(turnsPassed > 30) { //holy shit are you not finished yet???
        summonAuthor(div);
        processEnding();
      }
  }

  bool denizenDoneWithYourShit(div) {
      List<GameEntity> members = findMembersOfDenizenFight();
      Denizen d = members[0];
      Player p = members[1];
      if(members.length != 2) return false; //it's not a denizen fight.
      //okay, now i know it IS a denizen fight.
      if(turnsPassed > 5) return true; //you should have beaten me by now.
      if(p.godDestiny) return false; //eh, you'll be okay even if I kill you.
      if(p.getStat("currentHP") < d.getStat("power")) return true; //i can kill you in one hit.
      if(p.getStat("currentHP") < 2*d.getStat("power")&& seededRandom() > 0.5) return true; //i can kill you in two hits and am worried about a critical hit.
  }


  //returns [Denizen, Player] if either is null, this isn't a denizen fight.
  //denizen fights have special rules when it is 1 on 1, denizen vs player.
  //if can't find one, won't add it. so anything other than size 2 is invalid.
  List<GameEntity> findMembersOfDenizenFight() {
      Denizen d;
      Player p;
      List<GameEntity> ret = new List<GameEntity>();
      for(Team team in teams) {
        Denizen tmpd = team.findDenizen();
        Player  tmpp = team.findPlayer();
        if(d == null) {
          d = tmpd;
        }else {
          return ret; //i found TWO deniznes. Hax. I call hax.
        }

        if(p == null) {
          p = tmpp;
        }else {
          return ret; //i found TWO players. Hax. I call hax.
        }
      }
      if(d != null) ret.add(d);
      if(p != null) ret.add(p);
      return ret;
  }

  //a strife is over when only one team is capable of fighting anymore. livingMinusAbsconded == 0;
  bool strifeEnded() {
      num remaining = 0;
      for(Team team in teams) { //this is the Buffalo buffallo bufallo Buffalo bufallo of this sim.
          if(team.hasLivingMembersPresent()) remaining ++;
          if(remaining > 1) return false;
      }
      return true; //1 or fewer teams remain
  }


  //need to list out who is dead, who absconded, and who is alive.  Who WON.
  void describeEnding(div) {
      processEnding();
      throw "todo describe ending";
    //who won?
    //heal winners and absconded.
    //level up all parties
    //extra level up winners
    //clear out fraymotif useage (wait that's in team now, team gets destroyed when strife ends).
    //anything i'm missing? go check current code
      this.poseAsATeam(div,players);
  }

  //take care of healing the living, and leveling everyone
  void processEnding() {
    for(Team team in teams) {  //bufallo
      team.interact();
      team.heal();
      team.level();
    }
  }

  void rocksFallEverybodyDies(div){
    print("Rocks fall, everybody dies in session: " + session.session_id.toString());
    div.append("<Br><Br> In case you forgot, freaking METEORS have been falling onto the battlefield this whole time. This battle has been going on for so long that, literally, rocks fall, everybody dies.  ");
    var spacePlayer = findAspectPlayer(session.players, "Space");
    session.rocksFell = true;
    spacePlayer.landLevel = 0; //can't deploy a frog if skaia was just destroyed. my test session helpfully reminded me of this 'cause one of the players god tier revived adn then used the sick frog to combo session. ...that...shouldn't happen.
    killEveryone("from terminal meteors to the face");

  }

  void killEveryone(String causeOfDeath) {
    for(Team team in teams) {
      team.killEveryone(causeOfDeath);
    }
  }

  void denizenIsSoNotPuttingUpWithYourShitAnyLonger(div){
    //print("!!!!!!!!!!!!!!!!!denizen not putting up with your shit: " + this.session.session_id);
    List<GameEntity> members = findMembersOfDenizenFight();
    Denizen denizen = members[0];
    Player player = members[1];
    div.append("<Br><Br>" + denizen.name + " decides that the " + player.htmlTitleBasic() + " is being a little baby who poops hard in their diapers and are in no way ready for this fight. The Denizen recommends that they come back after they mature a little bit. The " +player.htmlTitleBasic() + "'s ass is kicked so hard they are ejected from the fight, but are not killed.");
    if(seededRandom() > .5){ //players don't HAVE to take the advice after all. assholes.
      player.increasePower();
      div.append(" They actually seem to be taking " + denizen.name + "'s advice. ");
    }
  }

  void summonAuthor(div){
    print("author is saving AB in session: " + this.session.session_id.toString());
    var divID = (div.attr("id")) + "authorRocks";
    String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth.toString() + "' height;="+canvasHeight.toString() + "'>  </canvas>";
    div.append(canvasHTML);
    //different format for canvas code
    var canvasDiv = querySelector("#canvas"+ divID);
    String chat = "";
    chat += "AB: " + Zalgo.generate("HELP!!!") +"\n";
    chat += "JR: Fuck!\n";
    chat += "JR: What's going on!? \n";
    chat += "JR: What's the problem!?\n";
    chat += "JR: AB come on...fuck! Your console is blank, I can't read your logs, you gotta talk to me!\n";

    chat += "AB: " + Zalgo.generate("INFINITE LOOP! STRIFE. IT KEEPS HAPPENING. FIX THIS.") +"\n";
    chat += "JR: fuck fuck fuck okay okay, i got this, i can fix this, let me turn on the meteors real quick.\n";
    chat += "JR: Okay. There. No more infinite loop. Everybody is dead. \n";
    chat += "AB: Fuck. Shit. I HATE when that happens.\n";
    chat += "JR: Yeah...\n";
    chat += "AB: Like, yeah, it fucking SUCKS for me, but...then the players have to die, too.\n";
    chat += "JR: That's why we're working so hard to balance the system. We'll get there, eventually. Scenes like this'll never trigger. Fights'll end naturally and not just go on forever if players find exploits. \n";
    chat += "AB: Yeah...'cause SBURB is just SO easy to balance. \n'";
    drawChatABJR(canvasDiv, chat);

    killEveryone("causing dear sweet precious sweet, sweet AuthorBot to go into an infinite loop");

  }


  void levelEveryone() {
    for(Team team in teams) { //buffallo
      team.levelEveryone();
    }
  }




  //TODO remove this, but keep for now for reference.
  dynamic strife(div, numTurns){
    this.resetPlayersAvailability(players);
    if(numTurns == 0) div.append("<Br><img src = 'images/sceneIcons/strife_icon.png'>");
    numTurns += 1;
    if(this.name == "Black King" || this.name == "Black Queen"){
      //print("checking to see if rocks fall.");
      this.session.timeTillReckoning += -1; //other fights are a a single tick. maybe do this differently later. have fights be multi tick. but it wouldn't tick for everybody. laws of physics man.
      if(this.session.timeTillReckoning < this.session.reckoningEndsAt){
        this.rocksFallEverybodyDies(div, players, numTurns);
        this.ending(div, players, numTurns);
        return null;
      }
    }

    if(this.fightNeedsToEnd(div, players, numTurns)){
      this.ending(div,players, numTurns);
      return null;
    }

    players = this.summonBackUp(div, players, numTurns);//might do nothing;
    //print(this.name + ": strife! " + numTurns + " turns against: " + getPlayersTitlesNoHTML(players) + this.session.session_id);
    div.append("<br><Br>");
    //as players die or mobility stat changes, might go players, me, me, players or something. double turns.
    if(getAverageMobility(players) > this.getStat("mobility")){ //players turn
      if(!this.fightOverAbscond(div, players) )this.playersTurn(div, players,numTurns);
      if(this.getStat("currentHP") > 0 && !this.fightOverAbscond(div, players)) this.myTurn(div, players,numTurns);
    }else{ //my turn
      if(this.getStat("currentHP") > 0 && !this.fightOverAbscond(div,players))  this.myTurn(div, players,numTurns);
      if(!this.fightOverAbscond(div, players) )this.playersTurn(div, players,numTurns);
    }

    if(this.fightOver(div, players) ){
      this.ending(div,players);
      return null;
    }else{
      if(this.fightOverAbscond(div,players)){
        this.processAbscond(div,players);
        this.ending(div,players);
        return null;
      }
      return this.strife(div, players,numTurns);
    }
  }//TODO delete this.


  //TODO do i still need this? maybe i'm using it for rendering.
  //might be easier for renderer to say "if you are not a Player, return"
  List<Player> removeAllNonPlayers(List<GameEntity>players){
    List<Player> ret = [];
    for(num i = 0; i< players.length; i++){
      var p = players[i];
      if(p is Player) ret.add(p);
    }
    return ret;
  }

  //TODO might need to put this in team.
  bool willMemberAbscond(div, GameEntity member, Team team) {
    if(!team.canAbscond) return false;
    var playersInFight = team.getLivingMinusAbsconded();
    if(member.doomed) return false; //doomed players accept their fate.
    num reasonsToLeave = 0;
    num reasonsToStay = 2; //grist man.
    reasonsToStay += member.getFriendsFromList(playersInFight).length;
    var hearts = member.getHearts();
    var diamonds = member.getDiamonds();

    for(num i = 0; i<hearts.length; i++){
      if(playersInFight.indexOf(hearts[i] != -1)) reasonsToStay ++;  //extra reason to stay if they are your quadrant.
    }
    for(num i = 0; i<diamonds.length; i++){
      if(playersInFight.indexOf(diamonds[i] != -1)) reasonsToStay ++;  //extra reason to stay if they are your quadrant.
    }
    List<Team> otherTeams = team.getOtherTeams(teams);
    num otherTeamsPower = Team.getTeamsStatTotal(otherTeams, "power"); //TODO should it be average or total?
    num otherTeamsHealth = Team.getTeamsStatTotal(otherTeams, "currentHP");
    reasonsToStay += member.getStat("power")/otherTeamsHealth; //if i'm about to finish it off.
    reasonsToLeave += 2 * otherTeamsPower/member.getStat("currentHP");  //if you could kill me in two hits, that's one reason to leave. if you could kill me in one, that's two reasons.

    if(reasonsToLeave > reasonsToStay * 2){
      member.addStat("sanity", -10);
      member.flipOut("how terrifying " + Team.getTeamsNames(otherTeams) + " were");
      if(member.getStat("mobility") > Team.getTeamsStatAverage(otherTeams, "mobility")){
        //print(" player actually absconds: they had " + player.hp + " and enemy had " + enemy.getStat("power") + this.session.session_id)
        div.append("<br><img src = 'images/sceneIcons/abscond_icon.png'> The " + member.htmlTitleHP() + " absconds right the fuck out of this fight. ");
        team.absconded.add(member);
        this.remainingPlayersHateYou(div, member, playersInFight,team);
        return true;
      }else{
        div.append(" The " + member.htmlTitleHP() + " tries to absconds right the fuck out of this fight, but the " + Team.getTeamsNames(otherTeams) + " blocks them. Can't abscond, bro. ");
        return false;
      }
    }else if(reasonsToLeave > reasonsToStay){
      if(member.getStat("mobility") > Team.getTeamsStatAverage(otherTeams, "mobility")){
        //print(" player actually absconds: " + this.session.session_id);
        div.append("<br><img src = 'images/sceneIcons/abscond_icon.png'>  Shit. The " + member.htmlTitleHP() + " doesn't know what to do. They don't want to die... They abscond. ");
        team.absconded.add(member);
        this.remainingPlayersHateYou(div, member, team.getLivingMinusAbsconded(), team);
        return true;
      }else{
        div.append(" Shit. The " + member.htmlTitleHP() + " doesn't know what to do. They don't want to die... Before they can decide whether or not to abscond " + Team.getTeamsNames(otherTeams) + " blocks their escape route. Can't abscond, bro. ");
        return false;
      }
    }
    return false;


  }

  //TODO might need to put this in team
  void remainingPlayersHateYou(div, player, players,Team team){
    if(players.length == 1){
      return null;
    }
    div.append(" The remaining players are not exactly happy to be abandoned. ");
    for(num i = 0; i<players.length; i++){
      var p = players[i];
      if(p != player && team.absconded.indexOf(p) == -1){ //don't be a hypocrite and hate them if you already ran.
        var r = p.getRelationshipWith(player);
        if(r) r.value += -5; //could be a sprite, after all.
      }
    }
    return null;
  }

  //TODO this needs redone entirely. which team is the only one left?
  void processAbscond(div){
      div.append("<Br><img src = 'images/sceneIcons/abscond_icon.png'> The " + this.htmlTitleHP() + " has had enough of this bullshit. They just fucking leave. ");
      return;
    }

  }


  dynamic summonPlayerBackup(div, players, numTurns){
    //if it's a time player/ 50/50 it's a future version of them in a stable time loop
    var living = findLivingPlayers(this.session.players); //who isn't ALREADY in this bullshit strife??? and is alive. and has a sprite (and so is in the medium.)
    var potential = getRandomElementFromArray(living);
    if(!potential) return players;
    if(players.indexOf(potential) == -1 && potential.sprite.name != "sprite"){ //you aren't already in the fight and aren't still on earth/alternaia/beforus/etc.
      if((potential.mobility > getAverageMobility(players) || seededRandom() >.5)){ //you're fast enough to get here, or randomness happened.

        players.add(potential);
        potential.currentHP = Math.max(1, potential.hp) ;//have at least 1 hp, dunkass;
        this.session.availablePlayers.removeFromArray(potential); //you aren't available anymore.
        var divID = (div.attr("id")) + "doomTimeArrival"+players.join("")+numTurns;
        String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth + "' height;="+canvasHeight + "'>  </canvas>";
        div.append(canvasHTML);
        //different format for canvas code
        var canvasDiv = querySelector("#canvas"+ divID);
        if(potential.aspect == "Time" && seededRandom() > .50){
          drawTimeGears(canvasDiv, potential);
          //print("summoning a stable time loop player to this fight. " +this.session.session_id);
          div.append("The " + potential.htmlTitleHP() + " has joined the Strife!!! (Don't worry about the time bullshit, they have their stable time loops on LOCK. No doom for them.)");
        }else{
          //print("summoning a player to this fight. " +this.session.session_id);
          div.append("The " + potential.htmlTitleHP() + " has joined the Strife!!!");
        }

        drawSinglePlayer(canvasDiv, potential);
      }
    }

    return players;
  }

  void summonDoomedTimeClone(div, players, numTurns){
    //print("summoning a doomed time clone to this fight. " +this.session.session_id);
    var timePlayer = findAspectPlayer(this.session.players, "Time");
    var doomedTimeClone = Player.makeDoomedSnapshot(timePlayer);
    players.add(doomedTimeClone);
    if(players.indexOf(timePlayer) !=-1){
      if(timePlayer.dead){
        var living = findLivingPlayers(this.session.players);
        if(living.length == 0){
          //rip knight of time that made me realize this could be a thing.
          div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from an alternate timeline. They know that everyone is already dead. They know there is nothing they can do. They've tried already. They've tried so many times. They can't bring themselves to give up, but they can't force themselves to watch their friends die again, either. Maybe if they just learn how to kill this asshole, they can go back and do it RIGHT next time. ");
        }else{
          div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is, well, I mean, obviously NOT fine, their corpse is just over there. But... whatever. THIS one is now doomed, as well. Which SHOULD mean they can fight like there is no tomorrow.")
        }

      }else{
        div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is fine, I mean, obviously, they are right there...but THIS one is now doomed. Which SHOULD mean they can fight like there is no tomorrow.")
      }
    }else{
      div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is fine, but THIS one is now doomed. Which SHOULD mean they can fight like there is no tomorrow.")
    }
    String divID = (div.attr("id")) + "doomTimeArrival"+players.join("")+numTurns;
    String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth.toString() + "' height;="+canvasHeight.toString() + "'>  </canvas>";
    div.append(canvasHTML);
    //different format for canvas code
    var canvasDiv = querySelector("#canvas"+ divID);
    var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
    drawTimeGears(pSpriteBuffer, doomedTimeClone);
    drawSinglePlayer(pSpriteBuffer, doomedTimeClone);
    copyTmpCanvasToRealCanvasAtPos(canvasDiv, pSpriteBuffer,0,0);
    timePlayer.doomedTimeClones.add(doomedTimeClone);
    timePlayer.sanity += -10;
    timePlayer.flipOut("their own doomed time clones");
    return players;

  }
  void summonAssHoleMcGee(div, players, numTurns){
    print("!!!!!!!!!!!!!!!!!This is stupid. Summon asshole mcgee in session: " + this.session.session_id);
    div.append("<Br><Br>THIS IS STuPID. EVERYBODY INVOLVED. IN THIS STuPID. STuPID FIGHT. IS NOW DEAD. SuCK IT.  tumut");
    var living = this.getLivingMinusAbsconded(players); //dosn't matter if you absconded.
    for(num i = 0; i<living.length; i++){
      var p = living[i];
      p.makeDead("BEING INVOLVED. IN A STuPID. STuPID FIGHT. THAT WENT ON. FOR WAY TOO LONG.");
    }

  }
  bool fightNeedsToEnd(div){
    //if this IS a denizen fight, i can assume there is only one player in it
    if(players[0].denizen.name == this.name){
      if(numTurns>5 || (players[0].currentHP < this.getStat("power") && !players[0].godDestiny)){ //denizens are cool with killing players that will godtier.
        //	print("Denizen is fucking done after  " + numTurns +" turns " + this.session.session_id);
        this.denizenIsSoNotPuttingUpWithYourShitAnyLonger(div, players, numTurns);
        return true;
      }else if((players[0].currentHP < this.getStat("power") && players.godDestiny)){
        print("Denizen is fine with killing this player, because they will probably GodTier. " + this.session.session_id);
      }
      return false; //denizen fights can not be interupted and are self limiting
    }

    if(numTurns > 20 && seededRandom() < .05){
      this.summonAssHoleMcGee(div, players, numTurns);
      return true;
    }

    if(numTurns > 30){
      this.summonAuthor(div, players, numTurns);
      return true;
    }
    return false;

  }
  dynamic summonBackUp(div, players, numTurns){
    if(players[0].denizen.name == this.name){
      return players;
    }
    //if i assume a 3 turn fight is "ideal", then have a 1/10 chance of backup each turn.
    var rand =seededRandom();
    if(rand<.05){  //rand isn't great cause might not find  player to summon, or might try summon player already in fight.
      return this.summonPlayerBackup(div, players, numTurns); //will return modded player list;
    }else if(rand < .15 && numTurns >5){
      return this.summonDoomedTimeClone(div,players, numTurns);
    }
    return players;
  }
  void resetFraymotifs(){
    for(num i = 0; i<this.fraymotifs.length; i++){
      this.fraymotifs[i].usable = true;
    }
  }
  void resetEveryonesFraymotifs(players){
    this.resetFraymotifs();
    this.buffs = [];
    for(num i = 0; i<players.length; i++){
      players[i].buffs = [];
      players[i].resetFraymotifs();
    }
  }
  void resetPlayersAvailability(players){
    for(num i = 0; i<players.length; i++){
      players[i].usedFraymotifThisTurn = false;
    }
  }






  bool fightOverAbscond(div, players){
    //print("checking if fight is over beause of abscond " + this.playersAbsconded.length);
    if(this.iAbscond){
      return true;
    }
    if(this.playersAbsconded.length == 0) return false;

    var living = findLivingPlayers(players);
    if(living.length == 0) return false;  //technically, they havent absconded
    for (num i = 0; i<living.length; i++){
      //print("has: " + living[i].title() + " run away?")
      if(this.playersAbsconded.indexOf(living[i]) == -1){
        return false; //found living player that hasn't yet absconded.
      }
    }
    return true;

  }
  void playersInteract(players){
    if(this.name == "Black Queen" || this.name == "Black King"){
      return; //whatever, when it's ALL the players too much is going on AND this won't effect things for very long. games over, man.
    }

    for(num i = 0; i<players.length; i++){
      var player1 = players[i];
      for(num j = 0; j < players.length; j ++){
        var player2 = players[j];
        if(player1 != player2){ //sorry time clones, can't buff your player. cause ALL players hae 'clones' in this double for loop
          player1.interactionEffect(player2); //opposite will happen eventually in this double loop.
        }
      }
    }
  }
  void poseAsATeam(div, players){
    //don't pose sprites
    List<dynamic> poseable = [];
    for(num i = 0; i<players.length; i++){
      if(players[i].renderable()) poseable.add(players[i]);
    }
    var divID = (div.attr("id")) + this.session.timeTillReckoning+players[0].id;
    var ch = canvasHeight;
    if(poseable.length > 6){
      ch = canvasHeight*1.5; //a little bigger than two rows, cause time clones
    }
    String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth.toString() + "' height;="+ch.toString() + "'>  </canvas>";
    div.appendHtml(canvasHTML);
    //different format for canvas code
    var canvasDiv = querySelector("#canvas"+ divID);
    poseAsATeam(canvasDiv, poseable, 2000);

    if(players[0].dead && players[0].denizen.name == this.name) denizenKill(canvasDiv, players[0]);
  }
  void makeAlive(){
    if(this.dead == false) return; //don't do all this.
    this.dead = false;
    this.currentHP = this.hp;
  }
  void ending(div, players){
    this.resetEveryonesFraymotifs(players);

    this.iAbscond = false;
    this.playersInteract(players);
    this.healPlayers(div,players);


    this.playersAbsconded = [];
    this.poseAsATeam(div,players);
  }
  void healPlayers(div, players){
    for(num i = 0; i<players.length; i++){
      var player = players[i];
      if(!player.doomed &&  !player.dead && player.currentHP < player.hp) player.currentHP = player.hp;
    }
  }
  void levelPlayers(stabbings){
    for(num i = 0; i<stabbings.length; i++){
      stabbings[i].increasePower();
      stabbings[i].increasePower();
      stabbings[i].increasePower();
      stabbings[i].leveledTheHellUp = true;
      stabbings[i].level_index +=2;
    }
  }
  void minorLevelPlayers(stabbings){
    for(num i = 0; i<stabbings.length; i++){
      stabbings[i].increasePower();
    }
  }

  bool fightOver(div, players){
    var living = this.getLivingMinusAbsconded(players);
    if(living.length == 0 && players.length > this.playersAbsconded.length){
      var dead = findDeadPlayers(players);
      if(dead.length == 1){
        div.append("<br><br><img src = 'images/sceneIcons/defeat_icon.png'> The strife is over. The " + dead[0].htmlTitle() + " is dead.<br> ");
      }else{
        div.append("<br><br><img src = 'images/sceneIcons/defeat_icon.png'> The strife is over. The players are dead or fled.<br> ");
      }

      this.minorLevelPlayers(players);
      return true;
    }else if(this.getStat("currentHP") <= 0 || this.dead){
      div.append(" <Br><br> <img src = 'images/sceneIcons/victory_icon.png'>The fight is over. " + this.name + " is dead. <br>");
      this.levelPlayers(players) //even corpses
      this.givePlayersGrist(players);
      return true;
    }//TODO have alternate win conditions for denizens???
    return false;
  }
  void givePlayersGrist(players){
    for(num i = 0; i<players.length; i++){
      players.grist += this.grist/players.length;
    }
  }
  void playersTurn(div, players){
    for(num i = 0; i<players.length; i++){  //check all players, abscond or living status can change.
      var player = players[i];
      ///print("It is the " + player.titleBasic() + "'s turn. '");
      if(!player.dead && this.getStat("currentHP")>0 && this.playersAbsconded.indexOf(player) == -1){
        this.playerdecideWhatToDo(div, player,players);  //
      }
    }

    var dead = findDeadPlayers(players);
    //give dead a chance to autoRevive
    for(num i = 0; i<dead.length; i++){
      if(!dead[i].doomed) this.tryAutoRevive(div, dead[i]);
    }
  }
  void tryAutoRevive(div, deadPlayer){

    //first try using pacts
    var undrainedPacts = removeDrainedGhostsFromPacts(deadPlayer.ghostPacts);
    if(undrainedPacts.length > 0){
      print("using a pact to autorevive in session " + this.session.session_id);
      var source = undrainedPacts[0][0];
      source.causeOfDrain = deadPlayer.title();
      String ret = " In the afterlife, the " + deadPlayer.htmlTitleBasic() +" reminds the " + source.htmlTitleBasic() + " of their promise of aid. The ghost agrees to donate their life force to return the " + deadPlayer.htmlTitleBasic() + " to life ";
      if(deadPlayer.godTier) ret += ", but not before a lot of grumbling and arguing about how the pact shouldn't even be VALID anymore since the player is fucking GODTIER, they are going to revive fucking ANYWAY. But yeah, MAYBE it'd be judged HEROIC or some shit. Fine, they agree to go into a ghost coma or whatever. ";
      ret += "It will be a while before the ghost recovers.";
      div.append(ret);
      var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
      removeFromArray(myGhost, this.session.afterLife.ghosts);
      var canvas = drawReviveDead(div, deadPlayer, source, undrainedPacts[0][1]);
      deadPlayer.makeAlive();
      if(undrainedPacts[0][1] == "Life"){
        deadPlayer.hp += 100; //i won't let you die again.
      }else if(undrainedPacts[0][1] == "Doom"){
        deadPlayer.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
        div.append("The prophecy is fulfilled. ");
      }
    }else if((deadPlayer.aspect == "Doom" || deadPlayer.aspect == "Life")&& (deadPlayer.class_name == "Heir" || deadPlayer.class_name == "Thief")){
      var ghost = this.session.afterLife.findAnyUndrainedGhost();
      var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
      if(!ghost || ghost == myGhost) return;
      ghost.causeOfDrain = deadPlayer.title();

      removeFromArray(myGhost, this.session.afterLife.ghosts);
      if(deadPlayer.class_name  == "Thief" ){
        print("thief autorevive in session " + this.session.session_id);
        div.append(" The " + deadPlayer.htmlTitleBasic() + " steals the essence of the " + ghost.htmlTitle() + " in order to revive and keep fighting. It will be a while before the ghost recovers.");
      }else if(deadPlayer.class_name  == "Heir" ){
        print("heir autorevive in session " + this.session.session_id);
        div.append(" The " + deadPlayer.htmlTitleBasic() + " inherits the essence and duties of the " + ghost.htmlTitle() + " in order to revive and continue their battle. It will be a while before the ghost recovers.");
      }
      var canvas = drawReviveDead(div, deadPlayer, ghost, deadPlayer.aspect);
      deadPlayer.makeAlive();
      if(deadPlayer.aspect == "Life"){
        deadPlayer.hp += 100; //i won't let you die again.
      }else if(deadPlayer.aspect == "Doom"){
        deadPlayer.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
        div.append("The prophecy is fulfilled. ");
      }
    }
  }
  bool playerHelpGhostRevive(div, player, players){
    if(player.aspect != "Life" && player.aspect != "Doom") return false;
    if(player.class_name != "Rogue" && player.class_name != "Maid") return false;
    var dead = findDeadPlayers(players);
    dead = this.removeAllNonPlayers(dead);
    if(dead.length == 0) return false;
    print(dead.length + " need be helping!!!");
    var deadPlayer = getRandomElementFromArray(dead) ;//heal random 'cause oldest could be doomed time clone';
    if(deadPlayer.doomed) return false; //doomed players can't be healed. sorry.
    //alright. I'm the right player. there's a dead player in this battle. now for the million boondollar question. is there an undrained ghost?
    var ghost = this.session.afterLife.findAnyUndrainedGhost(player);
    var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
    if(!ghost || ghost == myGhost) return false;
    print("helping a corpse revive during a battle in session: " + this.session.session_id);
    ghost.causeOfDrain = deadPlayer.titleBasic();
    String text = "<Br><Br>The " + player.htmlTitleBasic() + " assists the " + deadPlayer.htmlTitleBasic() + ". ";
    if(player.class_name == "Rogue"){
      text += " The " + deadPlayer.htmlTitleBasic() + " steals the essence of the " + ghost.htmlTitleBasic() + " in order to revive and continue fighting. It will be a while before the ghost recovers.";
    }else if(player.class_name == "Maid"){
      text += " The " + deadPlayer.htmlTitleBasic() + " inherits the essence and duties of the " + ghost.htmlTitleBasic() + " in order to revive and continue their fight. It will be a while before the ghost recovers.";
    }
    div.append(text);
    var canvas = drawReviveDead(div, deadPlayer, ghost, player.aspect);
    if(canvas){
      var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
      drawSprite(pSpriteBuffer,player);
      copyTmpCanvasToRealCanvasAtPos(canvas, pSpriteBuffer,0,0);
    }
    removeFromArray(myGhost, this.session.afterLife.ghosts);
    deadPlayer.makeAlive();
    if(player.aspect == "Life"){
      player.hp += 100; //i won't let you die again.
    }else if(player.aspect == "Doom"){
      player.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
      div.append("The prophecy is fulfilled. ");
    }
    return null;
  }
  void playerdecideWhatToDo(div, player, players){
    if(player.usedFraymotifThisTurn) return; //already did something.
    if(this.dead == true || this.getStat("currentHP") <= 0) return; // they are dead, stop beating a dead corpse.;
    div.append(player.describeBuffs());
    //for now, only one choice    //free will, triggerLevel and canIAbscond adn mobility all effect what is chosen here.  highTrigger level makes aggrieve way more likely and abscond way less likely. lowFreeWill makes special and fraymotif way less likely. mobility effects whether you try to abascond.
    if(!this.willPlayerAbscond(div,player,players)){
      var undrainedPacts = removeDrainedGhostsFromPacts(player.ghostPacts);
      if(this.playerHelpGhostRevive(div, player, players)){ //MOST players won't do this
        //actually, if that method returned true, it wrote to the screen all on it's own. so dumb. why can't i be consistent?
      }else if(undrainedPacts.length > 0 ){
        var didGhostAttack = this.ghostAttack(div, player, getRandomElementFromArray(undrainedPacts)[0]); //maybe later denizen can do ghost attac, but not for now
        if(!didGhostAttack && !this.useFraymotif(div, player, players, [this])){
          this.aggrieve(div, player, this );
        }
      }else if(!this.useFraymotif(div, player, players, [this])){
        this.aggrieve(div, player, this );
      }
    }
    this.processDeaths(div, players, [this]);
  }
  bool ghostAttack(div, player, ghost){
    if(!ghost) return false;
    if(player.power < this.getStat("currentHP")){
      //print("ghost attack in: " + this.session.session_id);

      this.currentHP += (-1* (ghost.power*5 + player.power)).round(); //not just one attack from the ghost
      div.append("<Br><Br> The " + player.htmlTitleBasic() + " cashes in their promise of aid. The ghost of the " + ghost.htmlTitleBasic() + " unleashes an unblockable ghostly attack channeled through the living player. " + ghost.power + " damage is done to " + this.htmlTitleHP() + ". The ghost will need to rest after this for awhile. " );

      this.drawGhostAttack(div, player, ghost);
      ghost.causeOfDrain = player.title();
      //this.processDeaths(div, player, this);
      return true;
    }
    return false;
  }
  dynamic drawGhostAttack(div, player, ghost){
    String canvasId = div.attr("id") + "attack" +player.chatHandle+ghost.chatHandle+player.power+ghost.power;
    String canvasHTML = "<br><canvas id='" + canvasId +"' width='" +canvasWidth.toString() + "' height="+canvasHeight.toString() + "'>  </canvas>";
    div.appendHtml(canvasHTML);
    var canvas = querySelector("#${canvasId}");
    var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
    drawSprite(pSpriteBuffer,player);
    var gSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
    drawSprite(gSpriteBuffer,ghost);
    //drawSpriteTurnways(gSpriteBuffer,ghost) //KR says looks bad.



    drawWhatever(canvas, "drain_lightning.png");

    copyTmpCanvasToRealCanvasAtPos(canvas, pSpriteBuffer,200,0);
    copyTmpCanvasToRealCanvasAtPos(canvas, gSpriteBuffer,250,0);
    var canvasBuffer = getBufferCanvas(querySelector("#canvas_template"));
    return canvas;
  }
  dynamic chooseTarget(players){
    //TODO more likely to get light, less likely to get void
    var living = this.getLivingMinusAbsconded(players);
    var doomed = findDoomedPlayers(living);

    var ret = getRandomElementFromArray(doomed);
    if(ret){
      //print("targeting a doomed player.");
      return ret;
    }
    //print("targeting slowest player out of: " + living.length);
    //todo more likely to target light, less void.
    ret = findAspectPlayer(players, "Light");
    //can attack light players corpse up to 5 times, randomly.
    if(ret && ret.dead && (seededRandom() > 5 || ret.currentHP < -1 * this.getStat("power")*5)) ret = null;  //only SOMETIMES target light player corpses. after all, that's SUPER lucky for the living.
    if(ret) return ret;
    return findLowestMobilityPlayer(living);
  }
  void myTurn(div, players, numTurns){
    //print("Hp during my turn is: " + this.getStat("currentHP"))
    //free will, triggerLevel and canIAbscond adn mobility all effect what is chosen here.  highTrigger level makes aggrieve way more likely and abscond way less likely. lowFreeWill makes special and fraymotif way less likely. mobility effects whether you try to abascond.
    //special and fraymotif can attack multiple enemies, but aggrieve is one on one.
    var living_enemies = this.getLivingMinusAbsconded(players);
    if(living_enemies.length == 0) return; //there is no one left to fight

    div.append(this.describeBuffs());

    if(!this.willIAbscond(div,players,numTurns) && !this.useFraymotif(div, this,[this], players)){
      var target = this.chooseTarget(players);
      if(target) this.aggrieve(div, this, target );
    }
    this.processDeaths(div, [this], players);
  }
  bool useFraymotif(div, owner, allies, enemies){
    var living_enemies = this.getLivingMinusAbsconded(enemies);
    var living_allies = this.getLivingMinusAbsconded(allies);
    if(seededRandom() > 0.75) return false; //don't use them all at once, dunkass.
    var usableFraymotifs = this.session.fraymotifCreator.getUsableFraymotifs(owner, living_allies, enemies);
    if(owner.crowned){  //ring/scepter has fraymotifs, too.  (maybe shouldn't let humans get thefraymotifs but what the fuck ever. roxyc could do voidy shit.)
      usableFraymotifs = usableFraymotifs.concat(this.session.fraymotifCreator.getUsableFraymotifs(this.crowned, living_allies, enemies));
    }
    if(usableFraymotifs.length == 0) return false;

    var mine = owner.getStat("sanity");
    var theirs = getAverageSanity(living_enemies);
    if(mine+200 < theirs && seededRandom() < 0.5){
      print("Too insane to use fraymotifs: " + owner.htmlTitleHP() +" against " + living_enemies[0].htmlTitleHP() + "Mine: " + mine + "Theirs: " + theirs + " in session: " + this.session.session_id)
      div.append(" The " + owner.htmlTitleHP() + " wants to use a Fraymotif, but they are too crazy to focus. ")
      return false;
    }
    mine = owner.getStat("freeWill") ;
    theirs = getAverageFreeWill(living_enemies);
    if(mine +200 < theirs && seededRandom() < 0.5){
      print("Too controlled to use fraymotifs: " + owner.htmlTitleHP() +" against " + living_enemies[0].htmlTitleHP() + "Mine: " + mine + "Theirs: " + theirs + " in session: " + this.session.session_id)
      div.append(" The " + owner.htmlTitleHP() + " wants to use a Fraymotif, but Fate dictates otherwise. ")
      return false;
    }

    var chosen = usableFraymotifs[0];
    for(num i = 0; i<usableFraymotifs.length; i++){
      var f = usableFraymotifs[i];
      if(f.tier > chosen.tier){
        chosen = f; //more stronger is more better (refance)
      }else if(f.tier == chosen.tier && f.aspects.length > chosen.aspects.length){
        chosen = f; //all else equal, prefer the one with more members.
      }
    }



    div.append("<Br><br>"+chosen.useFraymotif(owner, living_allies, living_enemies) + "<br><Br>");
    chosen.usable = false;
    return true;
  }

  void aggrieve(div, offense, defense){
    //mobility, luck hp, and power are used here.
    String ret = "<br><Br> The " + offense.htmlTitleHP() + " targets the " +defense.htmlTitleHP() + ". ";
    if(defense.dead) ret += " Apparently their corpse sure is distracting? How luuuuuuuucky for the remaining players!";
    div.append(ret);

    //luck dodge
    //alert("offense roll is: " + offenseRoll + " and defense roll is: " + defenseRoll);
    //print("gonna roll for luck.");
    if(defense.rollForLuck("minLuck") > offense.rollForLuck("minLuck")*10+200){ //adding 10 to try to keep it happening constantly at low levels
      print("Luck counter: " +  defense.htmlTitleHP() + this.session.session_id);
      div.append("The attack backfires and causes unlucky damage. The " + defense.htmlTitleHP() + " sure is lucky!!!!!!!!" );
      offense.currentHP += -1* offense.getStat("power")/10; //damaged by your own power.
      //this.processDeaths(div, offense, defense);
      return;
    }else if(defense.rollForLuck("maxLuck") > offense.rollForLuck("maxLuck")*5+100){
      print("Luck dodge: " +   defense.htmlTitleHP() +this.session.session_id);
      div.append("The attack misses completely after an unlucky distraction.");
      return;
    }
    //mobility dodge
    var rand = getRandomInt(1,100) ;//don't dodge EVERY time. oh god, infinite boss fights. on average, fumble a dodge every 4 turns.;
    if(defense.getStat("mobility") > offense.getStat("mobility") * 10+200 && rand > 25){
      print("Mobility counter: " +   defense.htmlTitleHP() +this.session.session_id);
      ret = ("The " + offense.htmlTitleHP() + " practically appears to be standing still as they clumsily lunge towards the " + defense.htmlTitleHP()  );
      if(defense.getStat("currentHP")> 0 ){
        ret += ". They miss so hard the " + defense.htmlTitleHP() + " has plenty of time to get a counterattack in.";
        offense.currentHP += -1* defense.getStat("power");
      }else{
        ret += ". They miss pretty damn hard. ";
      }
      div.append(ret + " ");
      //this.processDeaths(div, offense, defense);

      return;
    }else if(defense.getStat("mobility") > offense.getStat("mobility")*5+100 && rand > 25){
      print("Mobility dodge: " +   defense.htmlTitleHP() +this.session.session_id);
      div.append(" The " + defense.htmlTitleHP() + " dodges the attack completely. ");
      return;
    }
    //base damage
    var hit = offense.getStat("power");
    num offenseRoll = offense.rollForLuck();
    num defenseRoll = defense.rollForLuck();
    //critical/glancing hit odds.
    if(defenseRoll > offenseRoll*2){ //glancing blow.
      //print("Glancing Hit: " + this.session.session_id);
      hit = hit/2;
      div.append(" The attack manages to not hit anything too vital. ");
    }else if(offenseRoll > defenseRoll*2){
      //print("Critical hit.");
      ////print("Critical Hit: " + this.session.session_id);
      hit = hit*2;
      div.append(" Ouch. That's gonna leave a mark. ");
    }else{
      //print("a hit.");
      div.append(" A hit! ");
    }


    defense.currentHP += -1* hit;
    //this.processDeaths(div, offense, defense);
  }
  void processDeaths(div, offense, defense){
    List<dynamic> dead_o = [];
    List<dynamic> dead_d = [];
    for(num i = 0; i<offense.length; i++){
      var o = offense[i];
      if(!o.dead){  //if you are already dead, don't bother.
        for(var j= 0; j<defense.length; j++){
          var d = defense[j];
          if(!d.dead){
            var o_alive = this.checkForAPulse(o,d);
            o.interactionEffect(d);
            if(!this.checkForAPulse(d, o)){
              dead_d.add(d);
            }
            if(!this.checkForAPulse(o, d)){
              dead_o.add(o);
            }
          }
        }
      }
    }
    String ret = "";
    if(dead_o.length > 1){
      ret = " The " + getPlayersTitlesHP(dead_o) + "are dead. ";
    }else if(dead_o.length == 1){
      ret += " The " + getPlayersTitlesHP(dead_o) + "is dead. ";
    }

    if(dead_d.length > 1){
      ret = " The " + getPlayersTitlesHP(dead_d) + "are dead. ";
    }else if(dead_d.length == 1){
      if(dead_d[0].getStat("currentHP") > 0) window.alert("pastJR: why does a player have positive hp yet also is dead???" + this.session.session_id)
      ret += " The " + getPlayersTitlesHP(dead_d) + "is dead. ";
    }

    div.append(ret);
  }

  bool checkForAPulse(player, attacker){
    if(player.getStat("currentHP") <= 0){
      //print("Checking hp to see if" + player.htmlTitleHP() +"  is  dead");
      String cod = "fighting the " + attacker.htmlTitle();
      if(this.name == "Jack"){
        cod =  "after being shown too many stabs from Jack";
      }else if(this.name == "Black King"){

        cod = "fighting the Black King";
      }
      player.makeDead(cod);
      //print("Returning that " + player.htmlTitleHP() +"  is  dead");
      return false;
    }
    //print("Returning that " + player.htmlTitleHP() +"  is not dead");
    return true;
  }
}

//it is assumed that all members are on the same side and won't hurt each other.
class Team implements Comparable{  //when you want to sort teams, you sort by mobility.
  List<GameEntity> members;
  List<GameEntity> potentialMembers = new List<GameEntity>(); //who is allowed to join this team mid-strife. (i.e. I would be shocked if a player showed up to help a Denizen kill their buddy).
  List<GameEntity> absconded; //this only matters for one strife, so save to the team.
  List<GameEntity> usedFraymotifThisTurn; //if you're in this list, you don't get a regular turn.
  String name = ""; //TODO like The Midnight Crew.  If not given, just make it a list of all members of the team.
  Team.withName(name, this.members);
  Team(this.members) {
    name = GameEntity.getEntitiesNames();
  }
  bool canAbscond; //sometimes you are forced to keep fighting.

  //TODO have code for taking a turn in here. have Strife be relatively empty.
  /*
    Maybe have each member decide what to do, and then have strife apply those things?
    better than fussing with div down here and up there too.

   */
  String toString() {
    return name;
  }

  void takeTurn(div, num numTurnOn, List<Team> teams) {
    /*
       TODO centralized place.  And type of team with any members for each member decides if they want to do ghost things, aggrieve directly, or use fraymotifs.
       doomed members are banned from being ghost revived,but otherwise are free to do whatever.

       When choosing a target to attack, always target doomed members of another team first.  If multiple other teams, choose first team first (for now).

       If you used a fraymotif this turn (check membership of list) you can't take your turn.

     */
    resetPlayersAvailability();
    if(potentialMembers.length > 0) checkForBackup(numTurnOn); //longer fight goes on, more likely to get backup.  IMPORTANT: BACK UP HAS TO BE GIVEN TO THIS TEAM ON CREATION
    List<Team> otherTeams = getOtherTeams(teams);

  }

  //back up can be any player in the potentialMembers list. You are responsible for populating that list on team creation.
  //doomed time players will NOT be treated any differently anymore. (though a player marked as doomed might have a different narrative).
  void checkForBackup(numTurnOn) {
      throw "TODO check for backup.";
  }

  void resetPlayersAvailability() {
      usedFraymotifThisTurn.clear(); //no longer kept in player.
  }


  List<GameEntity> getLiving() {
    List<GameEntity> ret = new List<GameEntity>();
    for(GameEntity ge in members) {
      if(!ge.dead) ret.add(ge);
    }
    return ret;
  }

  void killEveryone(String reason) {
    for(GameEntity ge in getLivingMinusAbsconded()) {
      ge.makeDead(reason);
    }
  }

  List<GameEntity> getLivingMinusAbsconded(){
    var living = getLiving();
    for(num i = 0; i<this.absconded.length; i++){
      removeFromArray(this.absconded[i], living);
    }
    return living;
  }

  num getTeamStatTotal(statName) {
    num ret = 0;
    for(GameEntity ge in members) {
      ret += ge.getStat(statName);
    }
    return ret;
  }

  num getTeamStatAverage(statName) {
    num ret = 0;
    if(members.length <= 0) return ret;
    for(GameEntity ge in members) {
      ret += ge.getStat(statName);
    }
    return ret/members.length;
  }

  @override  //sorting Teams automatically sorts them by mobility so strife knows turn order
  int compareTo(other) {
    return other.getTeamStatAverage("mobility") - getTeamStatAverage("mobility");  //TODO or is it the otherway around???
  }

  bool hasLivingMembersPresent() {
      return this.getLivingMinusAbsconded().length > 0;
  }

  void level() {
    for(GameEntity ge in members) {
      ge.increasePower(); //don't care who you are.
    }
  }

  void heal() {
    for(GameEntity ge in members) {
      ge.heal(); //
    }
  }

  void interact() {
    for(GameEntity ge1 in members) {
      for(GameEntity ge2 in members) {
        ge2.interactionEffect(ge1); //it'll handle friendship and aspect stuff.
      }
    }
  }

  //Denizen fights work differently
  GameEntity findDenizen() {
      for(GameEntity ge in members) {
        if(ge is Denizen) return ge;
      }
      return null;
  }

  //player fights work differently
  GameEntity findPlayer() {
    for(GameEntity ge in members) {
      if(ge is Player) return ge;
    }
    return null;
  }




  //don't include me.
  List<Team> getOtherTeams(List<Team>teams) {
    List<Team> ret = new List<Team>();
    for(Team team in teams) {
      if(team != this) ret.add(team);
    }
    return ret;
  }

  static num getTeamsStatAverage(List<Team> teams, statName) {
    num ret = 0;
    for(Team team in teams) {
     ret += (team.getTeamStatAverage(statName));
    }
    return ret;
  }

  static num getTeamsStatTotal(List<Team> teams, statName) {
    num ret = 0;
    for(Team team in teams) {
      ret += (team.getTeamStatTotal(statName));
    }
    return ret;
  }


  static String getTeamsNames(List<Team> teams) {
    return teams.join(",");  //TODO put an and at last team.
  }

}