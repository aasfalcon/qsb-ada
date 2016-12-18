with AUnit.Test_Suites; use AUnit.Test_Suites;

with Test_Facet;
with Sound_Bus_Test_Fixture;

package Sound_Bus_Test is

   type Fixture is new Sound_Bus_Test_Fixture.Instance with null record;

   procedure Has_Runner_Test (This : in out Fixture);
   procedure Get_Data_Underruns_Test (This : in out Fixture);
   procedure Get_Signal_Underruns_Test (This : in out Fixture);
   procedure Add_Runner_Test (This : in out Fixture);
   procedure Dispatch_Test (This : in out Fixture);
   procedure Emit_Test (This : in out Fixture);
   procedure Show_Test (This : in out Fixture);
   procedure Remove_Runner_Test (This : in out Fixture);
   procedure Send_Test (This : in out Fixture);
   procedure Set_Watcher_Test (This : in out Fixture);
   procedure Set_Analyzer_Test (This : in out Fixture);
   procedure Watch_Test (This : in out Fixture);

   procedure Stress_Emit_Test (This : in out Fixture);
   procedure Stress_Show_Test (This : in out Fixture);
   procedure Stress_Send_Test (This : in out Fixture);

   package Test is new Test_Facet (Fixture, "Sound.Bus");
   Cases : Test.Cases :=
      (
         Test.Create ("Has_Runner_Test", Has_Runner_Test'Access),
         Test.Create ("Get_Data_Underruns_Test",
                      Get_Data_Underruns_Test'Access),
         Test.Create ("Get_Signal_Underruns_Test",
                      Get_Signal_Underruns_Test'Access),
         Test.Create ("Add_Runner_Test", Add_Runner_Test'Access),
         Test.Create ("Dispatch_Test", Dispatch_Test'Access),
         Test.Create ("Emit_Test", Emit_Test'Access),
         Test.Create ("Show_Test", Show_Test'Access),
         Test.Create ("Remove_Runner_Test", Remove_Runner_Test'Access),
         Test.Create ("Send_Test", Send_Test'Access),
         Test.Create ("Set_Watcher_Test", Set_Watcher_Test'Access),
         Test.Create ("Set_Analyzer_Test", Set_Analyzer_Test'Access),
         Test.Create ("Watch_Test", Watch_Test'Access),

         Test.Create ("Stress_Emit_Test", Stress_Emit_Test'Access),
         Test.Create ("Stress_Show_Test", Stress_Show_Test'Access),
         Test.Create ("Stress_Send_Test", Stress_Send_Test'Access)
      );
   Suite : Access_Test_Suite := Test.Suite (Cases);

end Sound_Bus_Test;
