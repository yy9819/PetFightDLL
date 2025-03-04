package com.robot.petFightModule.animatorCon
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.taomee.utils.DisplayUtil;
   
   public class BaseAnimatorCon extends AbstractAnimatorCon
   {
      public static var ON_MOVIE_OVER:String = "onMovieOver";
      
      public static var ON_MOVIE_HIT:String = "onMovieHit";
      
      private var skillMC:MovieClip;
      
      private var skillID:int;
      
      public function BaseAnimatorCon(param1:int, param2:MovieClip)
      {
         super();
         this.skillID = param1;
         skillMC = param2;
      }
      
      override public function getDescription() : String
      {
         return SkillXMLInfo.getName(skillID);
      }
      
      override public function destroy() : void
      {
         DisplayUtil.removeForParent(skillMC);
         skillMC.removeEventListener(Event.ENTER_FRAME,check);
         skillMC = null;
      }
      
      override public function playMovie() : void
      {
         trace("播放ID为",skillID,"的法术动画");
         skillMC.gotoAndPlay(2);
         skillMC.addEventListener(Event.ENTER_FRAME,check);
      }
      
      private function check(param1:Event) : void
      {
         if(skillMC.hit == 1)
         {
            dispatchEvent(new Event(ON_MOVIE_HIT));
            skillMC.hit = 0;
         }
         if(skillMC.isEnd == 1)
         {
            skillMC.removeEventListener(Event.ENTER_FRAME,check);
            skillMC.isEnd = 0;
            dispatchEvent(new Event(ON_MOVIE_OVER));
         }
      }
   }
}

