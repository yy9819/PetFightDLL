package com.robot.petFightModule
{
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.manager.MainManager;
   import com.robot.core.uic.TextScrollBar;
   import com.robot.petFightModule.control.PetStautsEffect;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class PetFightMsgManager
   {
      private static var scrollBar:TextScrollBar;
      
      private static var txt:TextField;
      
      private static var msgMC:MovieClip;
      
      private static var critEffect:MovieClip = new attack_crit_effect();
      
      public static var STATUS_ARRAY:Array = ["麻痹","中毒","烧伤","吸取对方的体力","被对方吸取体力","冻伤","害怕","疲惫","睡眠",""];

      public static var TRAIT_STATUS_ARRAY:Array = ["攻击","防御","特攻","特防","速度","命中"];


      public function PetFightMsgManager()
      {
         super();
      }
      
      public static function showText(param1:AttackValue) : void
      {
         var _loc2_:uint = 0;
         var _loc5_:String = null;
         var _loc10_:uint = 0;
         var _loc11_:String = null;
         var _loc3_:* = MainManager.actorInfo.userID == param1.userID;
         _loc2_ = PetFightEntry.fighterCon.getFighterMode(param1.userID).petID;
         var _loc4_:String = PetXMLInfo.getName(_loc2_);
         if(_loc3_)
         {
            _loc5_ = "ffffff";
         }
         else
         {
            _loc5_ = "FF00FF";
         }
         var _loc6_:* = "<font color=\'#" + _loc5_ + "\'>【" + _loc4_ + "】";
         if(param1.skillID != 0)
         {
            _loc11_ = SkillXMLInfo.getName(param1.skillID);
            _loc6_ += "使用了<font color=\'#ffff00\'>" + _loc11_ + "，</font>";
         }
         if(param1.isCrit)
         {
            if(param1.userID == MainManager.actorID)
            {
               critEffect.scaleX = 1;
               critEffect.x = 0;
            }
            else
            {
               critEffect.scaleX = -1;
               critEffect.x = MainManager.getStageWidth();
            }
            critEffect["mc"].gotoAndPlay(2);
            MainManager.getStage().addChild(critEffect);
            _loc6_ += "打出了致命一击，";
         }
         if(param1.skillID != 0)
         {
            _loc6_ += SkillXMLInfo.getInfo(param1.skillID) + " ";
         }
         _loc6_ += "<font color=\'#66FF00\'>〖状态〗:";
         var _loc7_:BaseFighterMode = PetFightEntry.fighterCon.getFighterMode(param1.userID);
         _loc7_.propView.removeAllEffect();
         var _loc8_:uint = 0;
         var _loc9_:Boolean = false;
         for each(_loc10_ in param1.status)
         {
            if(_loc10_ != 0)
            {
               _loc6_ += STATUS_ARRAY[_loc8_] + ":"+ _loc10_.toString() + "回合 ";
               _loc9_ = true;
               PetStautsEffect.addEffect(param1.userID,_loc8_,_loc10_);
            }
            _loc8_++;
         }
         var count:uint = 0;
         var battleLvInt:int=0
         for each(battleLvInt in param1.battleLv)
         {
            if(battleLvInt != 0)
            {
               PetStautsEffect.addEffectTrait(param1.userID,count,battleLvInt);
            }
            count++;
         }
         if(!_loc9_)
         {
            _loc6_ += "正常";
         }
         txt.htmlText += _loc6_ + "</font>\r";
         scrollBar.checkScroll();
      }
      
      public static function setup(param1:MovieClip) : void
      {
         msgMC = param1;
         txt = msgMC["msg_txt"];
         txt.text = "";
         scrollBar = new TextScrollBar(msgMC,txt);
      }
   }
}

