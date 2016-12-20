with AUnit.Test_Fixtures;

with Test_Facet;

with Sound.Buffer;

use Sound, Sound.Buffer;

package Sound_Buffer_Test is

   Buffer_Frames : constant := 1024;
   Test_Tone : constant Float := 440.0;
   Sample_Rate : constant Float := 44100.0;

   type Instance is new AUnit.Test_Fixtures.Test_Fixture with record
      Buffer_1 : Buffer.Instance (Buffer_Frames, 1);
      Buffer_2 : Buffer.Instance (Buffer_Frames, 2);
      Buffer_3 : Buffer.Instance (Buffer_Frames, 3);
      Buffer_4 : Buffer.Instance (Buffer_Frames, 4);
   end record;

   procedure Set_Up (This : in out Instance);

   procedure With_Channels_Test (This : in out Instance);
   procedure Add_Test (This : in out Instance);
   procedure Divide_Test (This : in out Instance);
   procedure Level_Test (This : in out Instance);
   procedure Silence_Test (This : in out Instance);

   package Test is new Test_Facet (Instance, "Sound.Buffer");
   Cases : Test.Cases :=
      (
         Test.Create ("With_Channels_Test", With_Channels_Test'Access),
         Test.Create ("Add_Test", Add_Test'Access),
         Test.Create ("Divide_Test", Divide_Test'Access),
         Test.Create ("Level_Test", Level_Test'Access),
         Test.Create ("Silence_Test", Silence_Test'Access)
      );
   Suite : Test.Handle := Test.Suite (Cases);

end Sound_Buffer_Test;
