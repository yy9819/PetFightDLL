package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol250")]
   public dynamic class Item_Blood_Effect extends MovieClip
   {
      public function Item_Blood_Effect()
      {
         addFrameScript(71,frame72);
         super();
      }
      
      internal function frame72() : *
      {
         stop();
      }
   }
}

