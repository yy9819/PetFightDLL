package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.pet.petWar.PetWarController;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.mode.PlayerMode;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import gs.TweenLite;
   import gs.easing.Circ;
   import org.taomee.effect.ColorFilter;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class SelectPetPanel extends BaseControlPanel implements IControlPanel, IAutoActionPanel
   {
      private var petIconArray:Array = [];
      
      private var replaceBtn:SimpleButton;
      
      private var index:uint = 0;
      
      private var blueGlowFilter:GlowFilter = new GlowFilter(438748,1,3,3,20);
      
      private var mode:BaseFighterMode;
      
      private var currentTime:uint;
      
      private var dropShadow:DropShadowFilter = new DropShadowFilter(3,45,0,0.6);
      
      private var yellowGlowFilter:GlowFilter = new GlowFilter(16776960,1,8,8,20);
      
      public function SelectPetPanel()
      {
         super();
         _panel = new ui_PetChangePanel();
         replaceBtn = panel["okBtn"];
         replaceBtn.addEventListener(MouseEvent.CLICK,clickHandler);
         mode = FighterModeFactory.playerMode;
         currentTime = mode.catchTime;
         initPanel();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         replaceBtn = null;
         petIconArray = [];
      }
      
      private function tweenPetIcon(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in petIconArray)
         {
            if(_loc2_ == param1)
            {
               TweenLite.to(_loc2_,0.3,{
                  "scaleX":1.5,
                  "scaleY":1.5,
                  "ease":Circ.easeOut
               });
               _loc2_.filters = [yellowGlowFilter,dropShadow];
            }
            else
            {
               TweenLite.to(_loc2_,0.3,{
                  "scaleX":0.8,
                  "scaleY":0.8,
                  "ease":Circ.easeOut
               });
               _loc2_.filters = [blueGlowFilter,dropShadow];
            }
         }
      }
      
      private function initPanel() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Array = null;
         var _loc4_:uint = 0;
         var _loc5_:MovieClip = null;
         index = 0;
         for each(_loc1_ in petIconArray)
         {
            DisplayUtil.removeAllChild(_loc1_);
            DisplayUtil.removeForParent(_loc1_);
         }
         petIconArray = [];
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc2_ = PetWarController.myCapA;
         }
         else
         {
            _loc2_ = PetManager.catchTimes;
         }
         var _loc3_:uint = 0;
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = new PetIconMC();
            _loc5_.cacheAsBitmap = true;
            _loc5_.buttonMode = true;
            _loc5_.catchTime = _loc4_;
            _loc5_.x = 156 + 36 * _loc3_;
            _loc5_.y = 8;
            panel.addChild(_loc5_);
            petIconArray.push(_loc5_);
            if(_loc4_ == currentTime)
            {
               _loc5_.filters = [yellowGlowFilter,dropShadow];
               _loc5_.scaleX = _loc5_.scaleY = 1.2;
            }
            else
            {
               _loc5_.filters = [blueGlowFilter,dropShadow];
               _loc5_.scaleX = _loc5_.scaleY = 0.8;
            }
            _loc5_.addEventListener(MouseEvent.CLICK,showPet);
            _loc3_++;
         }
         loadPetIcon();
         showPet();
      }
      
      private function showPet(param1:MouseEvent = null) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:PetInfo = null;
         var _loc8_:PetSkillInfo = null;
         var _loc9_:MovieClip = null;
         var _loc10_:MovieClip = null;
         var _loc11_:String = null;
         clearSkillBtn();
         if(param1)
         {
            _loc9_ = param1.currentTarget as MovieClip;
            _loc2_ = uint(_loc9_.catchTime);
            tweenPetIcon(_loc9_);
         }
         else
         {
            _loc2_ = currentTime;
         }
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc4_ = PetWarController.getPetInfo(_loc2_);
         }
         else
         {
            _loc4_ = PetManager.getPetInfo(_loc2_);
         }
         currentTime = _loc2_;
         panel["name_txt"].text = PetXMLInfo.getName(_loc4_.id);
         panel["level_txt"].text = "LV：" + _loc4_.level;
         panel["hp_txt"].text = _loc4_.hp + "/" + _loc4_.maxHp;
         panel["hpMC"].width = 110 * (_loc4_.hp / _loc4_.maxHp);
         var _loc5_:uint = 0;
         if(_loc4_.hp <= 0 || _loc2_ == mode.catchTime)
         {
            replaceBtn.mouseEnabled = false;
            replaceBtn.alpha = 0.5;
            replaceBtn.filters = [ColorFilter.setGrayscale()];
         }
         else
         {
            replaceBtn.mouseEnabled = true;
            replaceBtn.alpha = 1;
            replaceBtn.filters = [];
         }
         var _loc6_:Array = _loc4_.skillArray;
         var _loc7_:uint = 0;
         for each(_loc8_ in _loc6_)
         {
            if(_loc8_.id != 0)
            {
               _loc10_ = panel["skillMc_" + _loc7_];
               _loc10_["nameTxt"].text = _loc8_.name;
               _loc10_["migTxt"].text = "威力" + _loc8_.damage;
               _loc10_["ppTxt"].text = "PP" + _loc8_.pp + "/" + _loc8_.maxPP;
               _loc11_ = SkillXMLInfo.getTypeEN(_loc8_.id);
               _loc10_["iconMC"].gotoAndStop(_loc11_);
               _loc7_++;
            }
         }
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         trace("换精灵====" + currentTime);
         SocketConnection.send(CommandID.CHANGE_PET,currentTime);
         (FighterModeFactory.playerMode as PlayerMode).subject.showFightPanel();
         FighterModeFactory.playerMode.catchTime = currentTime;
      }
      
      public function updateCurrent() : void
      {
         showPet();
      }
      
      private function loadPetIcon() : void
      {
         var url:String;
         var capT:uint = 0;
         var id:uint = 0;
         if(index == petIconArray.length)
         {
            return;
         }
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            capT = uint(PetWarController.myCapA[index]);
            id = uint(PetWarController.getPetInfo(capT).id);
         }
         else
         {
            capT = uint(PetManager.catchTimes[index]);
            id = uint(PetManager.getPetInfo(capT).id);
         }
         url = ClientConfig.getPetSwfPath(id);
         ResourceManager.getResource(url,function(param1:DisplayObject):void
         {
            var _showMc:MovieClip = null;
            var dis:DisplayObject = param1;
            _showMc = dis as MovieClip;
            if(_showMc)
            {
               _showMc.gotoAndStop("rightdown");
               var sacle:Number = _showMc.height > 50 ? 0.5 : 1;
               _showMc.scaleX = _showMc.scaleY = sacle;
               _showMc.addEventListener(Event.ENTER_FRAME,function():void
               {
                  var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
                  if(_loc2_)
                  {
                     _loc2_.gotoAndStop(1);
                     _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
            }
            Sprite(petIconArray[index]["iconMC"]).addChild(_showMc);
            ++index;
            loadPetIcon();
         },"pet");
      }
      
      private function clearSkillBtn() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:uint = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = panel["skillMc_" + _loc1_];
            _loc2_["nameTxt"].text = "";
            _loc2_["migTxt"].text = "";
            _loc2_["ppTxt"].text = "";
            _loc2_["iconMC"].gotoAndStop(1);
            _loc1_++;
         }
      }
      
      public function auto() : void
      {
         var time:uint = 0;
         var count:uint = 0;
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            time = uint(PetWarController.getMyPet(count).catchTime);
         }
         else
         {
            time = uint(PetManager.catchTimes[count]);
         }
         try
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               while(PetWarController.getPetInfo(time).hp == 0)
               {
                  count++;
                  time = uint(PetWarController.getMyPet(count).catchTime);
               }
               currentTime = PetWarController.getPetInfo(time).catchTime;
            }
            else
            {
               while(PetManager.getPetInfo(time).hp == 0)
               {
                  count++;
                  time = uint(PetManager.catchTimes[count]);
               }
               currentTime = PetManager.getPetInfo(time).catchTime;
            }
            clickHandler(null);
         }
         catch(e:Error)
         {
            SocketConnection.send(CommandID.USE_SKILL,0);
            TimerManager.start();
         }
      }
   }
}

