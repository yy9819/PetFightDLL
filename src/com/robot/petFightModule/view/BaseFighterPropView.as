package com.robot.petFightModule.view
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.petFightModule.PetFightMsgManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.getQualifiedClassName;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class BaseFighterPropView
   {
      protected var effectIconClsNames:Array = [];
      
      protected var iconMC:MovieClip;
      
      protected var effectIcons:Array = [];
      
      protected var _propWin:Sprite;
      
      protected var barMC:MovieClip;
      
      protected var hp_txt:TextField;
      
      protected var lv_txt:TextField;
      
      protected var name_txt:TextField;
      
      public function BaseFighterPropView(param1:Sprite)
      {
         super();
         _propWin = param1;
         barMC = param1["hpBar"]["barMC"];
         iconMC = param1["iconMC"];
         lv_txt = param1["level_txt"];
         hp_txt = param1["hp_txt"];
         name_txt = param1["name_txt"];
      }
      
      public function destroy() : void
      {
         _propWin = null;
         barMC = null;
         iconMC = null;
         lv_txt = null;
         hp_txt = null;
         name_txt = null;
      }
      
      public function resetBar(param1:BaseFighterMode, param2:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         if(param1.maxHP == 0)
         {
            _loc3_ = 1;
         }
         else
         {
            _loc3_ = 1 - param1.hp / param1.maxHP;
         }
         barMC.x = -barMC.width * _loc3_;
         if(hp_txt)
         {
            hp_txt.text = param1.hp.toString() + "/" + param1.maxHP.toString();
         }
         if(param1.hp == 0 && param2)
         {
         }
      }
      
      public function update(baseFighterMode:BaseFighterMode, param2:Boolean = false) : void
      {
         if(param2)
         {
            removeAllEffect();
         }
         DisplayUtil.removeAllChild(iconMC);
         if(baseFighterMode.level <= 100)
         {
            lv_txt.text = baseFighterMode.level.toString();
         }
         else
         {
            lv_txt.text = "??";
         }
         showName(baseFighterMode);
         resetBar(baseFighterMode);
         ResourceManager.getResource(ClientConfig.getPetSwfPath(baseFighterMode.skinId != 0 ? baseFighterMode.skinId : baseFighterMode.petID),onShowComplete,"pet");
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
            DisplayUtil.stopAllMovieClip(_showMc);
            iconMC.addChild(_showMc);
         }
      }
      
      public function addEffect(param1:Class, param2:uint) : void
      {
         var _loc3_:MovieClip = new param1() as MovieClip;
         var _loc4_:String = getQualifiedClassName(_loc3_);
         if(effectIconClsNames.indexOf(_loc4_) == -1)
         {
            addIcon(_loc3_);
            effectIconClsNames.push(_loc4_);
            effectIcons.push(_loc3_);
            _loc3_.buttonMode = true;
            ToolTipManager.add(_loc3_,PetFightMsgManager.STATUS_ARRAY[param2]);
         }
      }
      
      protected function showName(param1:BaseFighterMode) : void
      {
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
         {
            name_txt.htmlText = PetFightModel.enemyName;
         }
         else if(PetFightModel.status == PetFightModel.FIGHT_WITH_NPC)
         {
            name_txt.htmlText = "<font color=\'#ffff00\'>野生精灵</font>";
         }
         else if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS)
         {
            name_txt.htmlText = "<font color=\'#ffff00\'>" + PetFightModel.enemyName + "</font>";
         }
      }
      
      protected function initExp(param1:BaseFighterMode) : void
      {
      }
      
      public function removeAllEffect() : void
      {
         var _loc1_:MovieClip = null;
         effectIconClsNames = [];
         for each(_loc1_ in effectIcons)
         {
            ToolTipManager.remove(_loc1_);
            DisplayUtil.removeForParent(_loc1_);
         }
         effectIcons = [];
      }
      
      protected function addIcon(param1:MovieClip) : void
      {
         var _loc2_:Number = 200 - (param1.width + 4) * effectIcons.length;
         var _loc3_:Number = 62;
         var _loc4_:Point = _propWin.parent.globalToLocal(_propWin.localToGlobal(new Point(_loc2_,_loc3_)));
         param1.x = _loc4_.x;
         param1.y = _loc4_.y;
         _propWin.parent.addChild(param1);
      }
   }
}

