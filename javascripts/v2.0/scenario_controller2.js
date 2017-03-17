var players = [];
var guardians = [];
var frogStatus = 0;
var kingStrength = 100; //can use this to extrapolate enemy strength.
var queenStrength = 100;
var jackStrength = 50;
var hardStrength = 250;  //what consititutes a  'hard' game.
var democracyStrength = 0;
var queenUncrowned = false;  //if she loses her ring, she doesn't get stronger with further prototypes
var reckoningStarted = false; //can't god tier if you are definitely on skaia.
var ectoBiologyStarted = false;
var doomedTimeline = false;
var scratched = false;
var debugMode = false;
var introScene;
var currentSceneNum = 0;
var spriteWidth = 400;
var spriteHeight = 300;
var canvasWidth = 1000;
var canvasHeight = 300;
var repeatTime = 500;
var version2 = true;
var timeTillReckoning = getRandomInt(10,30);
//have EVERYTHING be a scene, don't put any story in v2.0's controller
//every scene can update the narration, or the canvas.
//should there be only one canvas?  Can have player sprites be written to a virtual canvas first, then copied to main one.
//main canvas is either Leader + PesterChumWindow + 1 or more Players (in chat or group chat with leader)
//or Leader + 1 or more Players  (leader doing bullshit side quests with someone)
window.onload = function() {
   init();
	if(!debugMode){
		randomizeEntryOrder();
	}
	//easter egg ^_^
	if(window.location.search.substr(1) == "royalRumble=true"){
		debugRoyalRumble();
	}
	//authorMessage();
	makeGuardians(); //after entry order established
	load(players, guardians); //in loading.js

	//intro();  //~~~~~~LOADING SCRIPT WILL CALL THIS~~~~~~~~~


	//debugRelationshipDrama();
	//debugTriggerLevel();
	//debugGrimDark();
	//debugJackScheme();
	//debugLevelTheHellUp();
	//debugGodTierLevelTheHellUp();
	//debugCorpseLevelTheHellUp();
	//debugGodTierRevive();
	//debugCorpseSmooch();

	//make a new intro scene that has characters talk about their lands with their best friends/worst enemies.
	//refacor other scenario controller to use special scenes (not part of scene controller) rather than
	//have messy internal methods.
	//all other scenes are handled through the scene controller like normal, which will check if var version2 = true;
	//and if so will call "render" rather than "content"

	//tick();  dont tick here, tick after intro
}

function renderScratchButton(){
	//alert("scratch [possible]");
	//can't scratch if it was a a total party wipe. just a regular doomed timeline.
	var living = findLivingPlayers(players);
	if(living.length > 0){
		var timePlayer = findAspectPlayer(players, "Time");
		if(!scratched){
			alert(living.length  + " living players and the " + timePlayer.land + " makes a scratch available!");
			var html = '<button type="button" onclick="scratchConfirm()">Would You Like To Scratch Session?</button>';
			$("#story").append(html);
		}else{
			$("#story").append("<br>This session is already scratched. No further scratches available.");
		}
	}
}

function scratchConfirm(){
	var scratchConfirmed = confirm("This session is doomed. Scratching this session will erase it. A new session will be generated, but you will no longer be able to view this session. Is this okay?");
	if(scratchConfirmed){
		scratch();
	}
}

//TODO if i wanted to, I could have mixed sessions like in canon.
//not erasing the players, after all.
//or could have an afterlife where they meet guardian players???
function scratch(){
	timeTillReckoning = getRandomInt(10,30);
	frogStatus = 0;
	kingStrength = 100; //can use this to extrapolate enemy strength.
	queenStrength = 100;
	jackStrength = 50;
	hardStrength = 250;  //what consititutes a  'hard' game.
	democracyStrength = 0;
	queenUncrowned = false;  //if she loses her ring, she doesn't get stronger with further prototypes
	reckoningStarted = false; //can't god tier if you are definitely on skaia.
	//ectobiology not reset. if performed in previous session, it's done.
	//if not, it's not. like how the alpha session trolls didn't perform ectobiology, so Karkat did.
	doomedTimeline = false;
	scratched = true;
	var scratch = "The session has been scratched. The " + getPlayersTitlesBasic(players) + " will now be the beloved guardians.";
	scratch += " Their former guardians, the " + getPlayersTitlesBasic(guardians) + " will now be the players.";
	scratch += " The new players will be given stat boosts to give them a better chance than the previous generation."
	scratch += " What will happen?"
	var tmp = players;
	players = guardians;
	guardians = tmp;
	$("#story").html(scratch);
	window.scrollTo(0, 0);


	var guardianDiv = newScene();
	var guardianID = (guardianDiv.attr("id")) + "_guardians" ;
	var ch = canvasHeight;
	if(guardians.length > 6){
		ch = canvasHeight*1.5; //a little bigger than two rows, cause time clones
	}
	var canvasHTML = "<br><canvas id='canvas" + guardianID+"' width='" +canvasWidth + "' height="+ch + "'>  </canvas>";

	guardianDiv.append(canvasHTML);
	var canvasDiv = document.getElementById("canvas"+ guardianID);
	poseAsATeam(canvasDiv, guardians, 2000); //everybody, even corpses, pose as a team.


	var playerDiv = newScene();
	var playerID = (playerDiv.attr("id")) + "_players" ;
	var ch = canvasHeight;
	if(players.length > 6){
		ch = canvasHeight*1.5; //a little bigger than two rows, cause time clones
	}
	var canvasHTML = "<br><canvas id='canvas" + playerID+"' width='" +canvasWidth + "' height="+ch + "'>  </canvas>";

	playerDiv.append(canvasHTML);
	var canvasDiv = document.getElementById("canvas"+ playerID);
	poseAsATeam(canvasDiv, players, 2000); //everybody, even corpses, pose as a team.

	intro();

}

function tick(){
	if(timeTillReckoning > 0 && !doomedTimeline){
		setTimeout(function(){
			timeTillReckoning += -1;
			processScenes2(players);
			tick();
		},repeatTime); //or availablePlayers.length * *1000?
	}else{

		reckoning();
	}
}

function reckoning(){
	var s = new Reckoning();
	s.trigger(players)
	s.renderContent(newScene());
	if(!doomedTimeline){
		reckoningTick();
	}
}

function reckoningTick(){
	if(timeTillReckoning > -10){
		setTimeout(function(){
			timeTillReckoning += -1;
			processReckoning2(players)
			reckoningTick();
		},repeatTime);
	}else{
		var s = new Aftermath();
		s.trigger(players)
		s.renderContent(newScene());
	}

}



//scenes call this
function chatLine(start, player, line){
  if(player.grimDark == true){
    return start + line.trim()+"\n"; //no whimsy for grim dark players
  }else{
    return start + player.quirk.translate(line).trim()+"\n";
  }
}

function newScene(){
	currentSceneNum ++;
	var div = "<div id='scene"+currentSceneNum+"'></div>";
	$("#story").append(div);
	return $("#scene"+currentSceneNum);
}

function authorMessage(){
	makeAuthorAvatar();
	introScene = new AuthorMessage();
	introScene.trigger(players, players[0])
	introScene.renderContent(newScene(),0); //new scenes take care of displaying on their own.
}

function callNextIntroWithDelay(player_index){
	if(player_index >= players.length){
    tick();//NOW start ticking
		return;
	}
	setTimeout(function(){
		var s = new Intro();
		var p = players[player_index];
		var playersInMedium = players.slice(0, player_index+1); //anybody past me isn't in the medium, yet.
		s.trigger(playersInMedium, p)
		s.renderContent(newScene(),player_index); //new scenes take care of displaying on their own.
		processScenes2(playersInMedium);
		player_index += 1;
		callNextIntroWithDelay(player_index)
	},  repeatTime);  //want all players to be done with their setTimeOuts players.length*1000+2000
}


function intro(){
  //delay is needed here because this is when images are first loaded.
	callNextIntroWithDelay(0);
  /* //
	introScene = new Intro();

	for(var i = 0; i<players.length; i++){
		var playersInMedium = players.slice(0, i+1); //anybody past me isn't in the medium, yet.
		var p = players[i];
		introScene.trigger(players, p)
		//$("#story").append(introScene.content());
		introScene.renderContent(newScene(),i); //new scenes take care of displaying on their own.
		processScenes2(playersInMedium);
	}*/

}

function randomizeEntryOrder(){
	players = shuffle(players);
	players[0].leader = true;
}

function makeAuthorAvatar(){
	players[0].grimDark = false;
	players[0].aspect = "Mind"
	players[0].class_name = "Maid"
	players[0].hair = 13;
	players[0].hairColor = "#291200";
	players[0].quirk.punctuation = 3;
	players[0].quirk.capitalization = 1;
	players[0].quirk.favoriteNumber = 3;
	players[0].chatHandle = "jadedResearcher"
	players[0].isTroll = false
	players[0].bloodColor = "#ff0000"
	players[0].mylevels = ["INSTEAD","a CORPSE JUST RENDERS HERE","STILL CAN LEVEL UP.","OH, AND CORPSES.","SAME LEVELS","BUT STILL HAVE","IMAGE","THEY GET A DIFFERENT","BEFORE MAXING OUT","IF THEY GODTIER","AND GO UP THE LADDER","LEVELS NOW","16 PREDETERMINED","HAVE","PLAYERS","I FINISHED ECHELADDERS."];
}

function decideHemoCaste(player){
	if(player.aspect != "Blood"){  //sorry karkat
		player.bloodColor = getRandomElementFromArray(bloodColors);
	}
}

function decideLusus(player){
	if(player.bloodColor == "#610061" || player.bloodColor == "#99004d" || players.bloodColor == "#631db4" ){
		player.lusus = getRandomElementFromArray(seaLususTypes);
	}else{
		player.lusus = getRandomElementFromArray(landlususTypes);
	}
}

function decideTroll(player){
	if(Math.random() > 0.55 ){
		player.isTroll = true;
		player.triggerLevel ++;//trolls are less stable
		decideHemoCaste(player);
		decideLusus(player);
		player.kernel_sprite = player.lusus;
	}
}
//species, hair and blood color is the same, horns and favorite number. aspect.  Thats it.
//when scratch, get rid of story dif. make blank. scratch has to be button press.
function makeGuardians(){
	//console.log("Making guardians")
	available_classes = classes.slice(0);
	available_aspects = nonrequired_aspects.slice(0); //required_aspects
	available_aspects = available_aspects.concat(required_aspects.slice(0));
	for(var i = 0; i<players.length; i++){
		  var player = players[i];
			//console.log("guardian for " + player.titleBasic());
			var guardian = randomPlayer();
			guardian.isTroll = player.isTroll;
			if(guardian.isTroll){
				guardian.quirk = randomTrollSim(guardian)
			}else{
				guardian.quirk = randomHumanSim(guardian);
			}
			guardian.quirk.favoriteNumber = player.quirk.favoriteNumber;
			guardian.bloodColor = player.bloodColor;
			guardian.lusus = player.lusus;
			guardian.hairColor = player.hairColor;
			guardian.aspect = player.aspect;
			guardian.leftHorn = player.leftHorn;
			guardian.rightHorn = player.rightHorn;
			guardian.level_index = 5; //scratched kids start more leveled up
			guardian.power = 50;
			guardian.leader = player.leader;
			if(Math.random() >0.5){ //have SOMETHING in common with your ectorelative.
				guardian.interest1 = player.interest1;
			}else{
				guardian.interest2 = player.interest2;
			}
			guardian.reinit();//redo levels and land based on real aspect
			guardians.push(guardian);
	}

	for(var j = 0; j<guardians.length; j++){
		var g = guardians[j];
		g.generateRelationships(guardians);
	}
}

function init(){
	available_classes = classes.slice(0); //re-init available classes.
	available_aspects = nonrequired_aspects.slice(0);
	var numPlayers = getRandomInt(2,12);
	players.push(randomSpacePlayer());
	players.push(randomTimePlayer());

	for(var i = 2; i<numPlayers; i++){
		players.push(randomPlayer());
	}

	for(var j = 0; j<players.length; j++){
		var p = players[j];
		decideTroll(p);
		p.generateRelationships(players);
		if(p.isTroll){
			p.quirk = randomTrollSim(p)
		}else{
			p.quirk = randomHumanSim(p);
		}
	}

}
