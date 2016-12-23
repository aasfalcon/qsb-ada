with Test_Facet;
with Fixture.Sound_Processor_Test;

package Sound_Processor_Test is

   type Instance is new Fixture.Sound_Processor_Test.Instance with null record;

   procedure Get_Id_Test (This : in out Instance);
   procedure Get_Test (This : in out Instance);
   procedure Set_Test (This : in out Instance);
   procedure Run_Test (This : in out Instance);
   procedure Connect_Test (This : in out Instance);
   procedure Disconnect_Test (This : in out Instance);
   procedure Emit_Parameter_Test (This : in out Instance);
   procedure Emit_Signal_Test (This : in out Instance);
   procedure Emit_Packet_Test (This : in out Instance);
   procedure Process_Test (This : in out Instance);
   procedure Process_Entry_Test (This : in out Instance);

   package Test is new Test_Facet (Instance, "Sound.Processor");

   Cases : Test.Cases :=
      (
         Test.Create ("Get_Id_Test", Get_Id_Test'Access),
         Test.Create ("Get_Test", Get_Test'Access),
         Test.Create ("Set_Test", Set_Test'Access),
         Test.Create ("Run_Test", Run_Test'Access),
         Test.Create ("Connect_Test", Connect_Test'Access),
         Test.Create ("Disconnect_Test", Disconnect_Test'Access),
         Test.Create ("Emit_Parameter_Test", Emit_Parameter_Test'Access),
         Test.Create ("Emit_Signal_Test", Emit_Signal_Test'Access),
         Test.Create ("Emit_Packet_Test", Emit_Packet_Test'Access),
         Test.Create ("Process_Test", Process_Test'Access),
         Test.Create ("Process_Entry_Test", Process_Entry_Test'Access)
      );

   Suite : Test.Handle := Test.Suite (Cases);

end Sound_Processor_Test;
