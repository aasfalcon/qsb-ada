with Test_Facet;
with Fixture.Sound_Bus_Test;

package Sound_Bus_Test is

   type Instance is new Fixture.Sound_Bus_Test.Instance with null record;

   procedure Error_Count_Test (This : in out Instance);
   procedure Has_Errors_Test (This : in out Instance);
   procedure Get_Client_Test (This : in out Instance);
   procedure Add_Client_Test (This : in out Instance);
   procedure Add_Supervisor_Test (This : in out Instance);
   procedure Remove_Client_Test (This : in out Instance);
   procedure Remove_Supervisor_Test (This : in out Instance);
   procedure Emit_Parameter_Test (This : in out Instance);
   procedure Emit_Signal_Test (This : in out Instance);
   procedure Emit_Packet_Test (This : in out Instance);
   procedure Send_Parameter_Test (This : in out Instance);
   procedure Send_Command_Test (This : in out Instance);
   procedure Watch_Test (This : in out Instance);
   procedure Dispatch_Test (This : in out Instance);
   procedure Offload_Test (This : in out Instance);

   package Test is new Test_Facet (Instance, "Sound.Bus");
   Cases : Test.Cases :=
      (
         Test.Create ("Error_Count_Test", Error_Count_Test'Access),
         Test.Create ("Has_Errors_Test", Has_Errors_Test'Access),
         Test.Create ("Get_Client_Test", Get_Client_Test'Access),
         Test.Create ("Add_Client_Test", Add_Client_Test'Access),
         Test.Create ("Add_Supervisor_Test",
                      Add_Supervisor_Test'Access),
         Test.Create ("Remove_Client_Test",
                      Remove_Client_Test'Access),
         Test.Create ("Remove_Supervisor_Test",
                      Remove_Supervisor_Test'Access),
         Test.Create ("Emit_Parameter_Test", Emit_Parameter_Test'Access),
         Test.Create ("Emit_Signal_Test", Emit_Signal_Test'Access),
         Test.Create ("Emit_Packet_Test", Emit_Packet_Test'Access),
         Test.Create ("Send_Parameter_Test", Send_Parameter_Test'Access),
         Test.Create ("Send_Command_Test", Send_Command_Test'Access),
         Test.Create ("Dispatch_Test", Dispatch_Test'Access),
         Test.Create ("Watch_Test", Watch_Test'Access),
         Test.Create ("Offload_Test", Offload_Test'Access)
      );
   Suite : Test.Handle := Test.Suite (Cases);

end Sound_Bus_Test;
