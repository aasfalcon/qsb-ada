with AUnit.Assertions; use AUnit.Assertions;

with Common.Wave;
with Fixture.Sound_Bus_Test;

with Sound.Buffer;
with Sound.Bus;
with Sound.Events;
with Sound.Processor;

package body Sound_Processor_Test is

   use Fixture.Sound_Processor_Test;
   use Sound.Events, Sound.Processor;

   procedure Get_Id_Test (This : in out Instance) is
      New_Processor : Fixture_Processor;
   begin
      Assert (This.Processor.Get_Id /= Empty_Id,
              "Initialized with empty ID processor");
      Assert (New_Processor.Get_Id > This.Processor.Get_Id,
              "ID counter not working");
   end Get_Id_Test;

   procedure Get_Test (This : in out Instance) is
      Slot : constant Parameter_Slot := Parameters.Slot (Is_Muted);
   begin
      This.Processor.Set (Slot, (Bool, True));
      Assert (This.Processor.Get (Slot).Bool, "Wrong value, should be True");
      This.Processor.Set (Slot, (Bool, False));
      Assert (not This.Processor.Get (Slot).Bool,
              "Wrong value, should be False");
   end Get_Test;

   procedure Set_Test (This : in out Instance) is
   begin
      This.Get_Test;
   end Set_Test;

   procedure Run_Test (This : in out Instance) is
      Param : constant Parameter_Slot := Parameters.Slot (Is_Bypassed);
      E : Event;
   begin
      This.Processor.Run (Commands.Slot (Expose_One),
                          (Int, Integer (Param)));
      This.Bus.Watch;
      Assert (Natural (This.Received_Parameters.Length) = 1,
              "Wrong command test parameter count, expected: 1, actual:" &
              Natural'Image (Natural (This.Received_Parameters.Length)));

      E := This.Received_Parameters (0);
      Assert (E.Slot = Client_Slot (Param) and then
              E.Argument = This.Processor.Get (Param),
              "Wrong command result");
   end Run_Test;

   procedure Connect_Test (This : in out Instance) is
      New_Processor : Fixture_Processor;
      Slot : constant Parameter_Slot := Parameters.Slot (Is_Muted);
   begin
      New_Processor.Connect (This.Bus);
      This.Bus.Send (New_Processor.Get_Id, Slot, (Bool, True));
      This.Bus.Dispatch;
      Assert (Natural (New_Processor.Received_Parameters.Length) >= 1 and then
              New_Processor.Received_Parameters (0).Slot =
              Client_Slot (Slot),
              "Processor is not connected");
   end Connect_Test;

   procedure Disconnect_Test (This : in out Instance) is
      New_Processor : Fixture_Processor;
      Slot : constant Parameter_Slot := Parameters.Slot (Is_Muted);
   begin
      New_Processor.Connect (This.Bus);
      New_Processor.Disconnect;
      This.Bus.Send (New_Processor.Get_Id, Slot, (Bool, True));
      This.Bus.Dispatch;
      Assert (Natural (New_Processor.Received_Parameters.Length) < 1,
              "Processor is not disconnected");
   end Disconnect_Test;

   procedure Emit_Parameter_Test (This : in out Instance) is
      Slot : constant Parameter_Slot := 444;
      Val : constant Value := (Int, 333);
      E : Event;
   begin
      This.Processor.Emit (Slot, Val);
      This.Bus.Watch;
      Assert (Natural (This.Received_Parameters.Length) = 1,
              "Emitted parameter not received");
      E := This.Received_Parameters (0);
      Assert (E.Slot = Client_Slot (Slot) and then E.Argument = Val,
              "Wrong parameter received");
   end Emit_Parameter_Test;

   procedure Emit_Signal_Test (This : in out Instance) is
      Slot : constant Signal_Slot := 10_222;
      Val : constant Value := (Int, 16);
      E : Event;
   begin
      This.Processor.Emit (Slot, Val);
      This.Bus.Watch;
      Assert (Natural (This.Received_Signals.Length) = 1,
              "Emitted signal not received");
      E := This.Received_Signals (0);
      Assert (E.Slot = Client_Slot (Slot) and then E.Argument = Val,
              "Wrong signal received");
   end Emit_Signal_Test;

   procedure Emit_Packet_Test (This : in out Instance) is
      Slot : constant Packet_Slot := 2;
      Val : constant Data := (Real, 2, (4.5, 5.7));
      P : Packet_Event;
   begin
      This.Processor.Emit (Slot, Val);
      This.Bus.Watch;
      Assert (Natural (This.Received_Packets.Length) = 1,
              "Emitted packet not received");
      P := This.Received_Packets (0);
      Assert (P.Slot = Client_Slot (Slot) and then P.Argument = Val,
              "Wrong packet received");
   end Emit_Packet_Test;

   procedure Process_Test (This : in out Instance) is
      use Common.Wave, Sound.Buffer;
      Buf : Sound.Buffer.Instance (2048, 2);
   begin
      Fill (Buf, Sine'Access, 1);
      Fill (Buf, Square'Access, 2);
      This.Processor.Process (Buf);

      for I in 1 .. Buf.Frames loop
         Assert (Buf.Samples (I, 1) = Sine (I) / Sample (I) and then
                 Buf.Samples (I, 2) = Square (I) /
                 Sample (Buf.Frames - I + 1),
                 "Wrong process result");
      end loop;
   end Process_Test;

   procedure Process_Entry_Test (This : in out Instance) is
      use Common.Wave, Sound.Buffer;
      type Access_Processor is access all Fixture_Processor;
      Buf : Sound.Buffer.Instance (512, 2);
      Sub1, Sub2 : Fixture_Processor;
   begin
--       --  mute
--       Fill (Buf, Random'Access);
--       This.Processor.Set (Parameters.Slot (Is_Muted), (Bool, True));
--       This.Processor.Process_Entry (Buf);
--
--       for I in 1 .. Buf.Frames loop
--          Assert (Buf.Samples (I, 1) = 0.0 and then Buf.Samples (I, 2) = 0.0,
--                  "Mute test failed");
--       end loop;
--
--       This.Processor.Set (Parameters.Slot (Is_Muted), (Bool, False));
--       Assert (not This.Processor.Get (Parameters.Slot (Is_Muted)).Bool,
--               "Unable to turn off muted");
--
--       --  bypass
--       Fill (Buf, Sine'Access);
--       This.Processor.Set (Parameters.Slot (Is_Bypassed), (Bool, True));
--       This.Processor.Process_Entry (Buf);
--
--       for I in 1 .. Buf.Frames loop
--          Assert (Buf.Samples (I, 1) = Buf.Samples (I, 2) and then
--                  Buf.Samples (I, 1) = Sine (I),
--                  "Bypass test failed");
--       end loop;
--
--       This.Processor.Set (Parameters.Slot (Is_Bypassed), (Bool, False));
--       Assert (not This.Processor.Get (Parameters.Slot (Is_Bypassed)).Bool,
--               "Unable to turn off bypassed");

      --  serial
      Fill (Buf, Sine'Access);
      Sub1.Connect (This.Bus);
      Sub2.Connect (This.Bus);
      Sub1.Set (Parameters.Slot (Super_Id),
                (Int, Integer (This.Processor.Get_Id)));
      Sub2.Set (Parameters.Slot (Super_Id),
                (Int, Integer (This.Processor.Get_Id)));
      Sub1.Mode := Square_Wave;
      Sub2.Mode := Cross_Level;
      Access_Processor (This.Processor).Mode := Level;

      This.Processor.Process_Entry (Buf);

      for F in 1 .. Buf.Frames loop
         Assert (Buf.Samples (F, 1) = Square (F) / Sample (F) / 3.0 and then
                 Buf.Samples (F, 2) =
                 Sine (F) / Sample (Buf.Frames - F + 1) / 3.0,
                 "Serial test failed");
      end loop;

      --  parallel
      Fill (Buf, Sine'Access);
      This.Processor.Set (Parameters.Slot (Is_Parallel), (Bool, True));
      This.Processor.Process_Entry (Buf);

      for F in 1 .. Buf.Frames loop
         Assert (Buf.Samples (F, 1) =
                 (Square (F) + Sine (F) / Sample (F)) / 2.0 / 3.0 and then
                 Buf.Samples (F, 2) =
                 (Sine (F) + Sine (F) / Sample (Buf.Frames - F + 1)) /
                 2.0 / 3.0,
                 "Parallel test failed");
      end loop;
   end Process_Entry_Test;

end Sound_Processor_Test;
