package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol20")]
   public dynamic class Effect_Trait_Down extends MovieClip
   {
      public function Effect_Trait_Down()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

