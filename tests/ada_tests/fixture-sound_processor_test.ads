with Fixture.Sound_Bus_Test;

with Sound.Buffer;

package Fixture.Sound_Processor_Test is

   use Sound, Fixture.Sound_Bus_Test;

   -----------------------
   -- Fixture_Processor --
   -----------------------

   type Processor_Mode is (Cross_Level, Level, Cross_Mute, Square_Wave);

   type Fixture_Processor is new Fixture.Sound_Bus_Test.Fixture_Processor with
      record
         Mode : Processor_Mode := Cross_Level;
      end record;

   overriding
   procedure Process (This : Fixture_Processor; Buf : in out Buffer.Instance);

   -------------
   -- Fixture --
   -------------

   subtype Parent is Fixture.Sound_Bus_Test.Instance;
   type Instance is new Parent with null record;

   overriding
   procedure Set_Up (This : in out Instance);

end Fixture.Sound_Processor_Test;
