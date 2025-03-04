package com.robot.petFightModule.ui.controlPanel.subui
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.pet.petWar.PetWarController;
   import com.robot.core.ui.skillBtn.SkillInfoTip;
   import com.robot.petFightModule.control.FighterModeFactory;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.taomee.effect.ColorFilter;
   import org.taomee.utils.DisplayUtil;
   
   public class SkillBtnView extends EventDispatcher
   {
      private var outTF:TextFormat;
      
      private var overTF:TextFormat;
      
      private var isOpen:Boolean = true;
      
      private var mc:MovieClip;
      
      private var _pp:uint;
      
      private var maxPP:uint;
      
      private var _skillID:uint;
      
      public function SkillBtnView(param1:PetSkillInfo)
      {
         super();
         outTF = new TextFormat();
         outTF.color = 11138559;
         overTF = new TextFormat();
         overTF.color = 16763904;
         mc = new ui_skillMC();
         _skillID = param1.id;
         _pp = param1.pp;
         maxPP = param1.maxPP;
         mc["pp_txt"].text = _pp + "/" + maxPP;
         mc["name_txt"].text = param1.name;
         var _loc2_:String = SkillXMLInfo.getTypeEN(_skillID);
         mc["iconMC"].gotoAndStop(_loc2_);
         mc.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
         mc.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
         mc.addEventListener(MouseEvent.CLICK,clickHandler);
         mc["pp_txt"].mouseEnabled = false;
         mc["name_txt"].mouseEnabled = false;
         mc.buttonMode = true;
         if(_pp == 0)
         {
            mc.mouseChildren = false;
            mc.mouseEnabled = false;
            mc.enabled = false;
            mc.buttonMode = false;
            mc.filters = [ColorFilter.setGrayscale()];
         }
      }
      
      private function openBtns() : void
      {
         isOpen = true;
         if(_pp > 0)
         {
            mc.mouseChildren = true;
            mc.mouseEnabled = true;
            mc.enabled = true;
            mc.buttonMode = true;
         }
      }
      
      public function get skillID() : uint
      {
         return _skillID;
      }
      
      public function clear() : void
      {
         DisplayUtil.removeForParent(mc);
         mc = null;
      }
      
      public function get pp() : uint
      {
         return _pp;
      }
      
      public function autoUse() : void
      {
         clickHandler(null);
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].alpha = 0;
         var _loc3_:TextField = _loc2_["name_txt"];
         _loc3_.setTextFormat(outTF);
         SkillInfoTip.hide();
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].alpha = 0.5;
         var _loc3_:TextField = _loc2_["name_txt"];
         _loc3_.setTextFormat(overTF);
         SkillInfoTip.show(_skillID);
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:PetInfo = null;
         var _loc3_:PetSkillInfo = null;
         if(_pp == 0)
         {
            _skillID = 0;
            dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL));
            return;
         }
         if(_pp > 0)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc2_ = PetWarController.getPetInfo(FighterModeFactory.playerMode.catchTime);
            }
            else
            {
               _loc2_ = PetManager.getPetInfo(FighterModeFactory.playerMode.catchTime);
            }
            _loc3_ = _loc2_.getSkillInfo(_skillID);
            if(_loc3_)
            {
               --_loc3_.pp;
            }
            --_pp;
            mc["pp_txt"].text = _pp + "/" + maxPP;
            dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL));
            if(pp == 0)
            {
               closeBtns();
            }
         }
      }
      
      private function closeBtns() : void
      {
         isOpen = false;
         mc.mouseChildren = false;
         mc.mouseEnabled = false;
         mc.enabled = false;
         mc.buttonMode = false;
      }
      
      public function changePP(param1:int) : void
      {
         _pp += param1;
         if(_pp > maxPP)
         {
            _pp = maxPP;
         }
         else if(_pp <= 0)
         {
            _pp = 0;
         }
         mc["pp_txt"].text = _pp + "/" + maxPP;
         if(_pp > 0)
         {
            mc.mouseChildren = true;
            mc.mouseEnabled = true;
            mc.enabled = true;
            mc.buttonMode = true;
         }
         else if(_pp == 0)
         {
            closeBtns();
         }
      }
      
      public function getMC() : MovieClip
      {
         return mc;
      }
   }
}

