with AUnit.Test_Fixtures; use AUnit.Test_Fixtures;

with Test_Facet;

with Sound.Bus;
with Sound.Processor;

package Sound_Processor_Test is

   type Instance is new Test_Fixture with record
      Bus : Sound.Bus.Instance;
      --  Root : Sound.Processor.Instance;
   end record;

   overriding
   procedure Set_Up (This : in out Instance);

   procedure Get_Bus_Test (This : in out Instance);
   procedure Set_Bus_Test (This : in out Instance);
   procedure Get_Id_Test (This : in out Instance);
   procedure Get_Index_Test (This : in out Instance);
   procedure Set_Index_Test (This : in out Instance);
   procedure Get_Sub_Test (This : in out Instance);
   procedure Get_Sub_Count_Test (This : in out Instance);
   procedure Get_Super_Test (This : in out Instance);
   procedure Set_Super_Test (This : in out Instance);
   procedure Set_Subs_Rules_Test (This : in out Instance);
   procedure Emit_Test (This : in out Instance);
   procedure Show_Test (This : in out Instance);
   procedure Perform_Test (This : in out Instance);
   procedure Insert_Test (This : in out Instance);
   procedure Process_Test (This : in out Instance);
   procedure Process_Entry_Test (This : in out Instance);

   package Test is new Test_Facet (Instance, "Sound.Buffer");

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

   Suite : Test.Handle := Test.Suite (Cases);

end Sound_Processor_Test;
