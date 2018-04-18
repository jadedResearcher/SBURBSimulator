import "../../SBURBSim.dart";
import 'dart:html';

//meant to be owned by the Black King, but anyone with the black King's scepter will get this scene as well.

class KillWhiteKing extends Scene {
    KillWhiteKing(Session session) : super(session);


    @override
    void renderContent(Element div) {
        session.logger.info("Time to kick the White King's Ass.");
        gameEntity.available = false;
        DivElement me = new DivElement();
        div.append(me);
        me.setInnerHtml(getText());
        GameEntity wkowner = session.prospitScepter == null  ?  null:session.prospitScepter.owner;

        Element container = new DivElement();
        me.append(container);
        GameEntity whiteKing = session.battlefield == null  ?  null:session.battlefield.whiteKing;
        startFight(div, wkowner, session.prospitScepter, whiteKing);
    }




    void startFight(Element container, GameEntity target, Scepter scepter, GameEntity whoSHOULDHaveIt) {
        DivElement div = new DivElement();
        container.append(div);
        String text = "";
        if(target == whoSHOULDHaveIt) {
            text = "<br><br>It is time for the The ${target.htmlTitle()}'s inevitable defeat. ";
        }else {
            text = "<br><br>Huh. Well. The ${target.htmlTitle()} is DEFINITELY not the WHITE KING. You are blown away by this stunning revelation.  Who knew that the Main Quest of SBURB could go off the rails like that???  Either way, the scepters require a strife.";
        }

        div.setInnerHtml(text);

        List<GameEntity> fighting = <GameEntity>[gameEntity];

        for(GameEntity g in fighting) {
            g.available = false;
        }

        Team pTeam = new Team.withName("The Owner of the ${session.derseScepter} ",this.session, fighting);
        pTeam.canAbscond = false;
        Team dTeam = new Team(this.session, [target]);
        dTeam.canAbscond = false;
        Strife strife = new Strife(this.session, [pTeam, dTeam]);
        strife.timeTillRocks = 10;
        strife.startTurn(div);

        DivElement div2 = new DivElement();
        container.append(div2);
        div2.setInnerHtml("The ${scepter.owner.htmlTitle()} is now the owner of the ${scepter}. ");

    }


    String getText() {
        //TODO check if you like the white scepter owner
        return("<br><br>It is time. The ${gameEntity.htmlTitle()} feels the inexporable pull of the ${session.derseScepter.baseName} to slay whosoever bears the ${session.prospitScepter.baseName}.");
    }

  @override
  bool trigger(List<Player> playerList) {
      /*
            When the first player get to the battlefield, anyone holding the Black King's Scepter
            will try to go kill whoever is holding the White King's Scepter.

            sucks if you were friends ten seconds ago, there's a REASON you'er not supposed to be holding
            this shit.
       */
      GameEntity bkowner = session.derseScepter == null  ?  null:session.derseScepter.owner;
      GameEntity wkowner = session.prospitScepter == null  ?  null:session.prospitScepter.owner;


      if(bkowner != gameEntity) return false;

      //please don't try to murder yourself. it's fine.
      if(bkowner == wkowner || wkowner == null) return false;
      if(session.canReckoning) return true;

      return false;
  }
}