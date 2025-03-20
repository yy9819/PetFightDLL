package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol11")]
   public dynamic class Effect_Trait_Up extends MovieClip
   {
      public function Effect_Trait_Up()
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

