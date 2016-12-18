with AUnit.Test_Suites; use AUnit.Test_Suites;
with AUnit.Test_Fixtures; use AUnit.Test_Fixtures;

with Test_Facet;

package Sound_Processor_Test is

   Buffer_Frames : constant := 1024;
   Test_Tone : constant Float := 440.0;
   Sample_Rate : constant Float := 44100.0;

   type Fixture is new Test_Fixture with record
      Buffer_1 : Buffer.Instance (Buffer_Frames, 1);
      Buffer_2 : Buffer.Instance (Buffer_Frames, 2);
      Buffer_3 : Buffer.Instance (Buffer_Frames, 3);
      Buffer_4 : Buffer.Instance (Buffer_Frames, 4);
   end record;

   function Sine_Wave (Offset : Positive) return Sample;
   function Square_Wave (Offset : Positive) return Sample;
   function Random_Wave (Offset : Positive) return Sample;

   type Wave_Function is access function (Offset : Positive) return Sample;
   procedure Fill (Buffer : in out Sound.Buffer.Instance; Wave : Wave_Function;
                   Channel : Natural := 0);

   procedure Set_Up (This : in out Fixture);

   procedure Get_Bus_Test (This : in out Fixture);
   procedure Set_Bus_Test (This : in out Fixture);
   procedure Get_Id_Test (This : in out Fixture);
   procedure Get_Index_Test (This : in out Fixture);
   procedure Set_Index_Test (This : in out Fixture);
   procedure Get_Sub_Test (This : in out Fixture);
   procedure Get_Sub_Count_Test (This : in out Fixture);
   procedure Get_Super_Test (This : in out Fixture);
   procedure Set_Super_Test (This : in out Fixture);
   procedure Set_Subs_Rules_Test (This : in out Fixture);
   procedure Emit_Test (This : in out Fixture);
   procedure Show_Test (This : in out Fixture);
   procedure Perform_Test (This : in out Fixture);
   procedure Insert_Test (This : in out Fixture);
   procedure Process_Test (This : in out Fixture);
   procedure Process_Entry_Test (This : in out Fixture);

   package Test is new Test_Facet (Fixture, "Sound.Buffer");
   Cases : Test.Cases :=
      (
         Test.Create ("Get_Bus_Test", Get_Bus_Test'Access),
         Test.Create ("Set_Bus_Test", Set_Bus_Test'Access),
         Test.Create ("Get_Id_Test", Get_Id_Test'Access),
         Test.Create ("Get_Index_Test", Get_Index_Test'Access),
         Test.Create ("Set_Index_Test", Set_Index_Test'Access),
         Test.Create ("Get_Sub_Test", Get_Sub_Test'Access),
         Test.Create ("Get_Sub_Count_Test", Get_Sub_Count_Test'Access),
         Test.Create ("Get_Super_Test", Get_Super_Test'Access),
         Test.Create ("Set_Super_Test", Set_Super_Test'Access),
         Test.Create ("Set_Subs_Rules_Test", Set_Subs_Rules_Test'Access),
         Test.Create ("Emit_Test", Emit_Test'Access),
         Test.Create ("Show_Test", Show_Test'Access),
         Test.Create ("Perform_Test", Perform_Test'Access),
         Test.Create ("Insert_Test", Insert_Test'Access),
         Test.Create ("Process_Test", Process_Test'Access),
         Test.Create ("Process_Entry_Test", Process_Entry_Test'Access)
      );
   Suite : Access_Test_Suite := Test.Suite (Cases);

end Sound_Buffer_Test;
