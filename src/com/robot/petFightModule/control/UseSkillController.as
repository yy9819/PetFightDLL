package com.robot.petFightModule.control
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.petFightModule.animatorCon.AbstractAnimatorCon;
   import com.robot.petFightModule.animatorCon.BaseAnimatorCon;
   import com.robot.petFightModule.assetManager.SkillAssetsManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import org.taomee.utils.DisplayUtil;
   
   public class UseSkillController extends EventDispatcher
   {
      public static const MOVIE_START:String = "movieStart";
      
      public static const MOVIE_OVER:String = "movieOver";
      
      private static const DECORATOR_PATH:String = "com.robot.petFight.animatorCon.decorator.AnimatorDecorator_";
      
      private var tf2:TextFormat;
      
      private var tf3:TextFormat;
      
      private var hpTxt:TextField;
      
      private var gainHpTxt:TextField;
      
      private var lostHp:Number;
      
      private var remainHp:Number;
      
      private var LABEL_ARRAY:Array = ["","attack","sa","","cp"];
      
      private var subMC:MovieClip;
      
      private var attackMC:MovieClip;
      
      public var isDispatchByChangeTxt:Boolean;
      
      private var defenceMC:MovieClip;
      
      private var gainHp:Number;
      
      private var playerMode:BaseFighterMode;
      
      private var useSkillID:int;
      
      private var animator:AbstractAnimatorCon;
      
      private var value:AttackValue;
      
      private var tf:TextFormat;
      
      private var changeHpTxt:TextField;
      
      public function UseSkillController(param1:BaseFighterMode)
      {
         super();
         this.playerMode = param1;
         tf = new TextFormat();
         tf.font = "Arial";
         tf.color = 10027008;
         tf.size = 45;
         tf.bold = true;
         tf.align = TextFormatAlign.CENTER;
         tf2 = new TextFormat();
         tf2.font = "Arial";
         tf2.color = 52224;
         tf2.size = 45;
         tf2.bold = true;
         tf2.align = TextFormatAlign.CENTER;
         tf3 = new TextFormat();
         tf3.font = "Arial";
         tf3.color = 16724735;
         tf3.size = 45;
         tf3.bold = true;
         tf3.align = TextFormatAlign.CENTER;
         hpTxt = new TextField();
         hpTxt.autoSize = TextFieldAutoSize.CENTER;
         hpTxt.filters = [new GlowFilter(16776960,1,6,6,5)];
         hpTxt.width = 150;
         hpTxt.height = 50;
         hpTxt.x = 15;
         gainHpTxt = new TextField();
         gainHpTxt.autoSize = TextFieldAutoSize.CENTER;
         gainHpTxt.filters = [new GlowFilter(16776960,1,6,6,5)];
         gainHpTxt.width = 150;
         gainHpTxt.height = 50;
         gainHpTxt.x = 15;
         changeHpTxt = new TextField();
         changeHpTxt.autoSize = TextFieldAutoSize.CENTER;
         changeHpTxt.filters = [new GlowFilter(16777215,1,6,6,5)];
         changeHpTxt.width = 150;
         changeHpTxt.height = 50;
         changeHpTxt.x = 15;
      }
      
      private function defencePetPlay() : void
      {
         var _loc1_:MovieClip = defenceMC.getChildAt(0) as MovieClip;
         _loc1_.gotoAndPlay(2);
      }
      
      private function onMovieOver(param1:Event) : void
      {
         var timer:Timer;
         var event:Event = param1;
         animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_OVER,onMovieOver);
         animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_HIT,onMovieHit);
         animator.destroy();
         animator = null;
         defenceMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var _loc3_:MovieClip = defenceMC.getChildAt(0) as MovieClip;
            if(_loc3_)
            {
               defenceMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               _loc3_.gotoAndStop(1);
            }
         });
         if(hpTxt)
         {
            hpTxt.y = 0;
         }
         if(SkillXMLInfo.getCategory(useSkillID) != 4)
         {
            defenceMC.parent.addChild(hpTxt);
            if(value.atkTimes == 0)
            {
               hpTxt.text = "MISS";
            }
            else
            {
               hpTxt.text = "-" + lostHp;
            }
            hpTxt.setTextFormat(tf);
         }
         if(gainHp != 0)
         {
            if(!gainHpTxt)
            {
               return;
            }
            gainHpTxt.y = 0;
            if(gainHp > 0)
            {
               gainHpTxt.text = "+" + gainHp.toString();
               gainHpTxt.setTextFormat(tf2);
            }
            else
            {
               gainHpTxt.text = gainHp.toString();
               gainHpTxt.setTextFormat(tf);
            }
            attackMC.parent.addChild(gainHpTxt);
         }
         TweenLite.to(hpTxt,0.5,{"y":-30});
         TweenLite.to(gainHpTxt,0.5,{"y":-30});
         timer = new Timer(1500,1);
         timer.addEventListener(TimerEvent.TIMER,closeTxt);
         timer.start();
         dispatchEvent(new PetFightEvent(PetFightEvent.LOST_HP,lostHp));
         dispatchEvent(new PetFightEvent(PetFightEvent.GAIN_HP,gainHp,dispatchRemainHp));
      }
      
      private function skillMoviePlay() : void
      {
         attackMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            subMC = attackMC.getChildAt(0) as MovieClip;
            if(subMC)
            {
               attackMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               subMC.gotoAndPlay(2);
               attackMC.addEventListener(Event.ENTER_FRAME,petPlay);
               dispatchEvent(new Event(MOVIE_START));
            }
         });
      }
      
      private function closeChangeTxt(param1:TimerEvent) : void
      {
         DisplayUtil.removeForParent(changeHpTxt);
      }
      
      private function onMovieHit(param1:Event) : void
      {
         trace("打到对方");
         defenceMC.gotoAndStop("hited");
         setTimeout(defencePetPlay,200);
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         dispatchEvent(new Event(MOVIE_OVER));
         if(hpTxt)
         {
            DisplayUtil.removeForParent(hpTxt);
         }
         if(gainHpTxt)
         {
            DisplayUtil.removeForParent(gainHpTxt);
         }
      }
      
      private function petPlay(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:MovieClip = null;
         var _loc4_:Point = null;
         if(subMC.hit == 1)
         {
            attackMC.removeEventListener(Event.ENTER_FRAME,petPlay);
            _loc2_ = [];
            _loc3_ = SkillAssetsManager.getInstance().getAssetsByID(useSkillID);
            _loc4_ = attackMC.localToGlobal(new Point());
            _loc3_.x = _loc4_.x;
            _loc3_.y = _loc4_.y;
            _loc3_.scaleX = attackMC.scaleX;
            attackMC.parent.parent.addChild(_loc3_);
            animator = new BaseAnimatorCon(useSkillID,_loc3_);
            animator.addEventListener(BaseAnimatorCon.ON_MOVIE_OVER,onMovieOver);
            animator.addEventListener(BaseAnimatorCon.ON_MOVIE_HIT,onMovieHit);
            animator.playMovie();
            subMC.hit = 0;
         }
      }
      
      public function showChangeTxt(param1:int) : void
      {
         var _loc2_:Timer = null;
         trace("最后的时候血改变：",param1);
         if(param1 != 0)
         {
            changeHpTxt.y = 0;
            if(param1 > 0)
            {
               changeHpTxt.text = "+" + param1.toString();
            }
            else
            {
               changeHpTxt.text = param1.toString();
            }
            changeHpTxt.setTextFormat(tf3);
            attackMC.parent.addChild(changeHpTxt);
            TweenLite.to(changeHpTxt,0.3,{"y":-30});
            _loc2_ = new Timer(1500,1);
            _loc2_.addEventListener(TimerEvent.TIMER,closeChangeTxt);
            _loc2_.start();
         }
      }
      
      public function destroy() : void
      {
         subMC = null;
         attackMC = null;
         defenceMC = null;
         DisplayUtil.removeForParent(hpTxt);
         hpTxt = null;
         DisplayUtil.removeForParent(gainHpTxt);
         gainHpTxt = null;
         DisplayUtil.removeForParent(changeHpTxt);
         changeHpTxt = null;
         if(animator)
         {
            animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_OVER,onMovieOver);
            animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_HIT,onMovieHit);
            animator.destroy();
         }
         animator = null;
      }
      
      private function dispatchRemainHp() : void
      {
         dispatchEvent(new PetFightEvent(PetFightEvent.REMAIN_HP,remainHp));
      }
      
      public function action(param1:AttackValue) : void
      {
         this.value = param1;
         attackMC = playerMode.petWin.petMC;
         defenceMC = playerMode.enemyMode.petWin.petMC;
         this.lostHp = param1.lostHP;
         this.gainHp = param1.gainHP;
         this.remainHp = param1.remainHP;
         if(param1.skillID == 0)
         {
            dispatchRemainHp();
            return;
         }
         useSkillID = param1.skillID;
         var _loc2_:String = LABEL_ARRAY[SkillXMLInfo.getCategory(useSkillID)];
         attackMC.gotoAndStop(_loc2_);
         skillMoviePlay();
      }
   }
}

