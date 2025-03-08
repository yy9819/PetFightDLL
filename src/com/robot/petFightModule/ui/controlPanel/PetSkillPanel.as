package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.pet.petWar.PetWarController;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.subui.SkillBtnView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import org.taomee.effect.ColorFilter;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import flash.filters.ColorMatrixFilter;
   import com.robot.core.config.xml.ShinyXMLInfo;
   import flash.filters.GlowFilter;

   public class PetSkillPanel extends BaseControlPanel implements IControlPanel, IAutoActionPanel
   {
      private var btnContainer:Sprite;
      
      private var petNameTxt:TextField;
      
      public var skillBtnArray:Array = [];
      
      private var petPrev:Sprite;
      private var _baseFighterMode:BaseFighterMode;
      protected var filte:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
      
      public function PetSkillPanel()
      {
         super();
         _panel = new ui_SkillPanel();
         petPrev = _panel["iconMC"];
         petNameTxt = _panel["nameTxt"];
         btnContainer = new Sprite();
         _panel.addChild(btnContainer);
         createSkillBtns();
      }
      
      public function openBtns() : void
      {
         btnContainer.mouseChildren = true;
         btnContainer.mouseEnabled = true;
         btnContainer.filters = [];
      }
      
      override public function get panel() : Sprite
      {
         return _panel;
      }
      
      public function closeBtns() : void
      {
         btnContainer.mouseChildren = false;
         btnContainer.mouseEnabled = false;
         btnContainer.filters = [ColorFilter.setGrayscale()];
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         var _showMc:MovieClip = null;
         var o:DisplayObject = param1;
         _showMc = o as MovieClip;
         if(_showMc)
         {
            _showMc.gotoAndStop("rightdown");
            _showMc.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
               if(_loc2_)
               {
                  _loc2_.gotoAndStop(1);
                  _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            _showMc.scaleX = 1.5;
            _showMc.scaleY = 1.5;
            if(_baseFighterMode.shiny == 1){
               var matrix:ColorMatrixFilter = null;
               var argArray:Array = ShinyXMLInfo.getShinyArray(_baseFighterMode.petID);
               matrix = new ColorMatrixFilter(argArray)
               var glowArray:Array = ShinyXMLInfo.getGlowArray(_baseFighterMode.petID);
               var glow:GlowFilter = new GlowFilter(uint(glowArray[0]),int(glowArray[1]),int(glowArray[2]),int(glowArray[3]),int(glowArray[4]));
               _showMc.filters = [ filte,glow,matrix]
            }
            petPrev.addChild(_showMc);
         }
      }
      
      private function clearOldBtns() : void
      {
         var _loc1_:SkillBtnView = null;
         for each(_loc1_ in skillBtnArray)
         {
            _loc1_.removeEventListener(PetFightEvent.USE_SKILL,onSendSkill);
            _loc1_.clear();
         }
         skillBtnArray = [];
      }
      
      private function onSendSkill(param1:PetFightEvent) : void
      {
         var _loc2_:SkillBtnView = param1.currentTarget as SkillBtnView;
         dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL,_loc2_.skillID));
      }
      
      override public function destroy() : void
      {
         clearOldBtns();
         petPrev = null;
         petNameTxt = null;
         btnContainer = null;
         skillBtnArray = [];
      }
      
      public function createSkillBtns() : void
      {
         var _loc3_:Array = null;
         var _loc5_:PetSkillInfo = null;
         var _loc6_:SkillBtnView = null;
         var _loc7_:MovieClip = null;
         var baseFighterMode:BaseFighterMode = PetFightEntry.fighterCon.getFighterMode(MainManager.actorID);
         DisplayUtil.removeAllChild(petPrev);
         var _loc2_:uint = baseFighterMode.catchTime;
         _baseFighterMode = baseFighterMode;
         ResourceManager.getResource(ClientConfig.getPetSwfPath((baseFighterMode.skinId != 0 && baseFighterMode.shiny != 1)?baseFighterMode.skinId : baseFighterMode.petID),onShowComplete,"pet");
         petNameTxt.text = baseFighterMode.petName;
         clearOldBtns();
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc3_ = PetWarController.getPetInfo(baseFighterMode.catchTime).skillArray;
         }
         else
         {
            _loc3_ = PetManager.getPetInfo(_loc2_).skillArray;
         }
         var _loc4_:uint = 0;
         for each(_loc5_ in _loc3_)
         {
            if(_loc5_.id != 0)
            {
               _loc6_ = new SkillBtnView(_loc5_);
               _loc6_.addEventListener(PetFightEvent.USE_SKILL,onSendSkill);
               _loc7_ = _loc6_.getMC();
               _loc7_.x = 132 + (_loc7_.width + 5) * (_loc4_ % 2);
               _loc7_.y = 14 + (_loc7_.height + 7) * Math.floor(_loc4_ / 2);
               btnContainer.addChild(_loc7_);
               skillBtnArray.push(_loc6_);
               _loc4_++;
            }
         }
      }
      
      public function auto() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:SkillBtnView = skillBtnArray[0];
         while(_loc2_.pp == 0 && _loc1_ < skillBtnArray.length - 1)
         {
            _loc1_++;
            _loc2_ = skillBtnArray[_loc1_];
         }
         trace("autoUse",_loc2_.skillID);
         _loc2_.autoUse();
      }
   }
}

