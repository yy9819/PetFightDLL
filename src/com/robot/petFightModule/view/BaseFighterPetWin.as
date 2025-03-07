package com.robot.petFightModule.view
{
   import com.robot.app.task.control.TaskController_90;
   import com.robot.core.CommandID;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.CatchPetInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.assetManager.PetAssetsManager;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.AbstractPetItemCategory;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.utils.setTimeout;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   import flash.filters.ColorMatrixFilter;
   import com.robot.core.config.xml.ShinyXMLInfo;

   public class BaseFighterPetWin extends Sprite
   {
      public static const WIN_WIDTH:uint = 180;
      
      public static const WIN_HEIGHT:uint = 280;
      
      public var petContainer:Sprite;
      
      protected var petID:uint;
      
      private var isBagFull:Boolean;
      
      private var catchMC:MovieClip;
      
      protected var openningMovie:MovieClip;
      
      protected var _petMC:MovieClip;
      
      protected var filte:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
      protected var glow:GlowFilter = new GlowFilter(0xFFFFFF, 1, 10, 10, 10, 1, false, false);
      public function BaseFighterPetWin()
      {
         super();
         petContainer = new Sprite();
         petContainer.graphics.beginFill(16777215,0);
         petContainer.graphics.drawRect(0,0,WIN_WIDTH,WIN_HEIGHT);
         addChild(petContainer);
         initContainerPos();
      }
      
      protected function setPetMC(param1:MovieClip,shiny:uint) : void
      {
         DisplayUtil.removeAllChild(petContainer);
         param1.scaleX = -1;
         param1.x = WIN_WIDTH / 2;
         param1.y = 145;
         param1.gotoAndStop(1);
         var matrix:ColorMatrixFilter = null;
         if(shiny == 1)
         {
            var argArray:Array = ShinyXMLInfo.getShinyArray(petID);
            matrix = new ColorMatrixFilter(argArray)
            param1.filters = [filte , glow , matrix]
         }else{
            param1.filters = [filte];
         }
         this._petMC = param1;
         if(PetFightModel.defaultNpcID != FighterModeFactory.enemyMode.petID && PetFightModel.status == PetFightModel.FIGHT_WITH_NPC && PetFightModel.defaultNpcID != 0)
         {
            createOpenning();
         }
         else
         {
            petContainer.addChild(_petMC);
            dispatchEvent(new PetFightEvent(PetFightEvent.ON_OPENNING));
         }
      }

      protected function initContainerPos() : void
      {
         petContainer.x = MainManager.getStageWidth() - WIN_WIDTH - 90;
         petContainer.y = 90 + 25;
      }
      
      public function destroy() : void
      {
         _petMC = null;
         petContainer = null;
      }
      
      public function catchSuccess(param1:CatchPetInfo) : void
      {
         var mode:BaseFighterMode;
         var data:CatchPetInfo = param1;
         trace("BaseFighterPetWin::catchSuccess");
         EventManager.dispatchEvent(new DynamicEvent(PetFightEvent.CATCH_SUCCESS,FighterModeFactory.enemyMode.petID));
         if(!catchMC)
         {
            catchMC = new CatchMovie_mc();
            catchMC.x = 40;
            catchMC.y = -14;
         }
         catchMC.gotoAndPlay(2);
         mode = FighterModeFactory.enemyMode;
         mode.petWin.petContainer.addChild(catchMC);
         PetFightEntry.fighterCon.isCatch = true;
         setTimeout(function():void
         {
            if(PetManager.length < 6)
            {
               SocketConnection.send(CommandID.PET_RELEASE,data.catchTime,1);
               SocketConnection.send(CommandID.GET_PET_INFO,data.catchTime);
               isBagFull = false;
            }
            else
            {
               isBagFull = true;
               PetManager.addStorage(data.petID,data.catchTime);
            }
         },1500);
         setTimeout(afterCatchSuccess,4000);
         catchMC.addFrameScript(34,function():void
         {
            catchMC.addFrameScript(34,null);
            DisplayUtil.removeForParent(FighterModeFactory.enemyMode.petWin.petMC);
         });
      }
      
      private function checkIsCatchMovieOver() : void
      {
         catchMC.addFrameScript(109,function():void
         {
            catchMC.gotoAndStop(1);
            catchMC.addFrameScript(109,null);
            DisplayUtil.removeForParent(catchMC);
            if(PetFightEntry.fighterCon.alarmSprite)
            {
               DisplayUtil.removeForParent(PetFightEntry.fighterCon.alarmSprite);
            }
            AbstractPetItemCategory.dispatchOnUsePetItem();
         });
      }
      
      private function createOpenning() : void
      {
         var mc:MovieClip = null;
         mc = PetAssetsManager.getInstance().getAssetsByID(PetFightModel.defaultNpcID);
         mc.x = BaseFighterPetWin.WIN_WIDTH / 2;
         mc.y = 145;
         mc.scaleX = -1;
         mc.gotoAndStop(1);
         mc.filters = [filte];
         petContainer.addChild(mc);
         if(!openningMovie)
         {
            openningMovie = new SpecialOpenningMovie();
            openningMovie.x = 0;
            openningMovie.y = 15;
         }
         petContainer.addChild(openningMovie);
         openningMovie.addEventListener(Event.ENTER_FRAME,function():void
         {
            if(!openningMovie)
            {
               return;
            }
            if(openningMovie.currentFrame == 22)
            {
               DisplayUtil.removeForParent(mc);
               petContainer.addChild(_petMC);
               petContainer.addChild(openningMovie);
            }
            else if(openningMovie.currentFrame == 52)
            {
               openningMovie.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(openningMovie);
               openningMovie = null;
               dispatchEvent(new PetFightEvent(PetFightEvent.ON_OPENNING));
            }
         });
      }
      
      public function update(param1:uint,shiny:uint) : void
      {
         this.petID = param1;
         var _loc2_:MovieClip = PetAssetsManager.getInstance().getAssetsByID(param1);
         setPetMC(_loc2_,shiny);
      }
      
      public function get petMC() : MovieClip
      {
         return _petMC;
      }
      
      public function catchFail() : void
      {
         var mode:BaseFighterMode;
         trace("BaseFighterPetWin::catchFail");
         if(!catchMC)
         {
            catchMC = new CatchMovie_mc();
            catchMC.x = 40;
            catchMC.y = -14;
         }
         catchMC.gotoAndPlay(2);
         mode = FighterModeFactory.enemyMode;
         mode.petWin.petContainer.addChild(catchMC);
         catchMC.addFrameScript(34,function():void
         {
            catchMC.gotoAndStop(1);
            catchMC.addFrameScript(34,null);
            catchMC.gotoAndPlay("fail");
            checkIsCatchMovieOver();
         });
      }
      
      private function afterCatchSuccess() : void
      {
         var sprite:Sprite = null;
         PetFightEntry.clear(null,true);
         if(!isBagFull)
         {
            sprite = Alarm.show("恭喜你，捕捉成功",function():void
            {
               TaskController_90.catchPetEnd();
            });
         }
         else
         {
            sprite = Alarm.show("恭喜！捕捉成功，你可以在精灵仓库中找到它哦！",function():void
            {
               TaskController_90.catchPetEnd();
            });
         }
         MainManager.getStage().addChild(sprite);
      }
   }
}

