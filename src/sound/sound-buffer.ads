with Sound.Constants;
with Sound.Object;

use Sound;

package Sound.Buffer is

   subtype Sample is Short_Float;
   Silent : constant Sample := 0.0;

   subtype Channel_Count is Positive range 1 .. Constants.Channels_Max_Count;
   subtype Frame_Count is Positive;
   type Buffer_Data is
      array (Frame_Count range <>, Channel_Count range <>) of Sample;

   subtype Parent is Object.Instance;
   type Instance (Frames : Frame_Count; Channels : Channel_Count) is
      new Parent with
      record
         Samples : Buffer_Data (1 .. Frames, 1 .. Channels);
      end record;

   subtype Class is Instance'Class;
   type Handle is access all Class;

   function With_Channels (This : Instance;
                           Channels : Channel_Count) return Instance;

   procedure Add (This : in out Instance; That : Instance);
   procedure Divide (This : in out Instance; Divisor : Positive);
   procedure Level (This : in out Instance; Level : Float);
   procedure Silence (This : in out Instance);

end Sound.Buffer;
