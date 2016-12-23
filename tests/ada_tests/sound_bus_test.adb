with AUnit.Assertions; use AUnit.Assertions;

with Sound.Bus;
with Sound.Events;
with Sound.Constants;
with Sound.Processor;

package body Sound_Bus_Test is

   use Fixture.Sound_Bus_Test;
   use Sound.Constants, Sound.Bus, Sound.Events, Sound.Processor;

   procedure Error_Count_Test (This : in out Instance) is
      Underruns, Slot : Natural := 0;
      Planned_Output : constant Natural := 11;
      Planned_Signal : constant Natural := 5;
      Planned_Packet : constant Natural := 17;
      Output_Count : constant := Output_Bus_Size - 1 + Planned_Output;
      Signal_Count : constant := Signals_Bus_Size - 1 + Planned_Signal;
      Packet_Count : constant := Packets_Bus_Size - 1 + Planned_Packet;
      Unknown : constant Client_Id := This.Processor.Get_Id + 100;
   begin
      --  Output_Underrun
      for I in 1 .. Output_Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Parameter_Slot (I), Empty_Value);
      end loop;

      Underruns := This.Bus.Error_Count (Output_Underrun);
      Assert (Underruns = Planned_Output, "Wrong output underruns, expected:" &
              Natural'Image (Planned_Output) & ", actual:" &
              Natural'Image (Underruns));

      This.Bus.Watch;
      Assert (Positive (This.Received_Parameters.Length) = Output_Bus_Size - 1,
              "Wrong received parameter count:" &
              Positive'Image (Positive (This.Received_Parameters.Length)) &
              ", expected:" & Positive'Image (Output_Bus_Size - 1));

      for I in 1 .. Output_Bus_Size - 1 loop
         Slot := Natural (This.Received_Parameters.Element (I - 1).Slot);
         Assert (Slot = I + Underruns,
                 "Wrong received parameter after drops: expected slot" &
                 Integer'Image (I + Underruns) & ", received slot" &
                 Integer'Image (Slot));
      end loop;

      --  Signal_Underrun
      for I in 1 .. Signal_Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Signal_Slot (I), Empty_Value);
      end loop;

      Underruns := This.Bus.Error_Count (Signal_Underrun);
      Assert (Underruns = Planned_Signal, "Wrong signal underruns, expected:" &
              Natural'Image (Planned_Signal) & ", actual:" &
              Natural'Image (Underruns));

      This.Bus.Watch;
      Assert (Positive (This.Received_Signals.Length) = Signals_Bus_Size - 1,
              "Wrong received signal count:" &
              Positive'Image (Positive (This.Received_Signals.Length)) &
              ", expected:" & Positive'Image (Signals_Bus_Size - 1));

      for I in 1 .. Signals_Bus_Size - 1 loop
         Slot := Natural (This.Received_Signals.Element (I - 1).Slot);
         Assert (Slot = I + Underruns,
                 "Wrong received signal after drops: expected slot" &
                 Integer'Image (I + Underruns) & ", received slot" &
                 Integer'Image (Slot));
      end loop;

      --  Packet_Underrun
      for I in 1 .. Packet_Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Packet_Slot (I), Empty_Data);
      end loop;

      Underruns := This.Bus.Error_Count (Packet_Underrun);
      Assert (Underruns = Planned_Packet, "Wrong packet underruns, expected:" &
              Natural'Image (Planned_Packet) & ", actual:" &
              Natural'Image (Underruns));

      This.Bus.Watch;
      Assert (Positive (This.Received_Packets.Length) = Packets_Bus_Size - 1,
              "Wrong received packet count:" &
              Positive'Image (Positive (This.Received_Packets.Length)) &
              ", expected:" & Positive'Image (Packets_Bus_Size - 1));

      for I in 1 .. Packets_Bus_Size - 1 loop
         Slot := Natural (This.Received_Packets.Element (I - 1).Slot);
         Assert (Slot = I + Underruns,
                 "Wrong received packet after drops: expected slot" &
                 Integer'Image (I + Underruns) & ", received slot" &
                 Integer'Image (Slot));
      end loop;

      --  Unknown_Client
      This.Bus.Emit (Unknown, Signal_Slot (0));
      This.Bus.Emit (Unknown, Parameter_Slot (0), Empty_Value);
      This.Bus.Emit (Unknown, Packet_Slot (0), Empty_Data);
      This.Bus.Watch;

      This.Bus.Send (Unknown, Command_Slot (0));
      This.Bus.Send (Unknown, Parameter_Slot (0), Empty_Value);
      This.Bus.Dispatch;

      Underruns := This.Bus.Error_Count (Unknown_Client);
      Assert (Underruns = 2, "Expected 2 unknown clients, actual:" &
              Natural'Image (Underruns));

      --  TODO: offload tests
   end Error_Count_Test;

   procedure Has_Errors_Test (This : in out Instance) is
   begin
      Assert (not This.Bus.Has_Errors, "Has errors on set up");
      This.Error_Count_Test;
      Assert (This.Bus.Has_Errors, "Does not indicate existing errors");
   end Has_Errors_Test;

   procedure Get_Client_Test (This : in out Instance) is
      use Event_Client;
      Client : Event_Client.Handle :=
         This.Bus.Get_Client (This.Processor.Get_Id);
      Unknown_Id : constant Client_Id := This.Processor.Get_Id + 100;
   begin
      Assert (Client = Event_Client.Handle (This.Processor),
              "Wrong client pointer");
      Client := This.Bus.Get_Client (Unknown_Id);
      Assert (Client = null, "Not null returned when passed unknown id");
   end Get_Client_Test;

   procedure Add_Client_Test (This : in out Instance) is
      use Event_Client;
      Client : aliased Fixture_Processor;
      Client_Handle : constant Event_Client.Handle :=
         Client'Unchecked_Access;
   begin
      This.Bus.Add_Client (Client_Handle);
      Assert (Client_Handle = This.Bus.Get_Client (Client.Get_Id),
              "Error connecing client");
   end Add_Client_Test;

   procedure Add_Supervisor_Test (This : in out Instance) is
      Supervisor : aliased Instance;
      Supervisor_Handle : constant Event_Supervisor.Handle :=
         Supervisor'Unchecked_Access;
   begin
      This.Bus.Add_Supervisor (Supervisor_Handle);
      This.Bus.Emit (This.Processor.Get_Id, Signal_Slot (777));
      This.Bus.Watch;
      Assert (Integer (Supervisor.Received_Signals.Length) > 0 and then
              Supervisor.Received_Signals.Element (0).Slot =
              Client_Slot (777),
              "Unable to connect supervisor");
   end Add_Supervisor_Test;

   procedure Remove_Client_Test (This : in out Instance) is
      use Event_Client;
      Client_Handle : Event_Client.Handle;
   begin
      Client_Handle := This.Bus.Get_Client (This.Processor.Get_Id);
      Assert (Client_Handle = Event_Client.Handle (This.Processor),
              "Client is not connected before test");

      This.Bus.Remove_Client (Event_Client.Handle (This.Processor));
      Client_Handle := This.Bus.Get_Client (This.Processor.Get_Id);
      Assert (Client_Handle = null, "Cant disconnect client");
   end Remove_Client_Test;

   procedure Remove_Supervisor_Test (This : in out Instance) is
      Supervisor : aliased Instance;
      Supervisor_Handle : constant Event_Supervisor.Handle :=
         Supervisor'Unchecked_Access;
   begin
      This.Bus.Add_Supervisor (Supervisor_Handle);
      This.Bus.Remove_Supervisor (Supervisor_Handle);
      This.Bus.Emit (This.Processor.Get_Id, Signal_Slot (777));
      This.Bus.Watch;
      Assert (Integer (Supervisor.Received_Signals.Length) = 0,
              "Unable to disconnect supervisor");
   end Remove_Supervisor_Test;

   procedure Emit_Parameter_Test (This : in out Instance) is
      Count : constant Natural := 12;
      Received : Natural;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Parameter_Slot (I), (Int, I * 33));
      end loop;

      This.Bus.Watch;
      Received := Natural (This.Received_Parameters.Length);
      Assert (Received = Count,
              "Invalid parameter count: emited" & Natural'Image (Count) &
              ", watched" & Natural'Image (Received));

      for I in 1 .. Count loop
         E := This.Received_Parameters.Element (I - 1);
         Assert (E.Id = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = Client_Slot (I),
                 "Invalid slot, sent" & Natural'Image (I) &
                 ", received" & Client_Slot'Image (E.Slot));
         Assert (E.Argument.Int = I * 33, "Invalid value");
      end loop;
   end Emit_Parameter_Test;

   procedure Emit_Signal_Test (This : in out Instance) is
      Count : constant Natural := 17;
      Received : Natural;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Signal_Slot (I), (Int, I * 33));
      end loop;

      This.Bus.Watch;
      Received := Natural (This.Received_Signals.Length);
      Assert (Received = Count,
              "Invalid signal count: sent" & Natural'Image (Count) &
              ", received" & Natural'Image (Received));

      for I in 1 .. Count loop
         E := This.Received_Signals.Element (I - 1);
         Assert (E.Id = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = Client_Slot (I),
                 "Invalid slot, sent" & Natural'Image (I) &
                 ", received" & Client_Slot'Image (E.Slot));
         Assert (E.Argument.Int = I * 33, "Invalid value");
      end loop;
   end Emit_Signal_Test;

   procedure Emit_Packet_Test (This : in out Instance) is
      Count : constant Natural := 6;
      Received : Natural;
      P : Packet_Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Emit (This.Processor.Get_Id,
                        Packet_Slot (I), (Int, 1, (others => I * 33)));
      end loop;

      This.Bus.Watch;
      Received := Natural (This.Received_Packets.Length);
      Assert (Received = Count,
              "Invalid packet count: sent" & Natural'Image (Count) &
              ", received" & Natural'Image (Received));

      for I in 1 .. Count loop
         P := This.Received_Packets.Element (I - 1);
         Assert (P.Id = This.Processor.Get_Id, "Invalid tag");
         Assert (P.Slot = Client_Slot (I),
                 "Invalid slot, sent" & Natural'Image (I) &
                 ", received" & Client_Slot'Image (P.Slot));
         Assert (P.Argument.Count = 1 and P.Argument.Ints (1) = I * 33,
                 "Invalid data");
      end loop;
   end Emit_Packet_Test;

   procedure Send_Parameter_Test (This : in out Instance) is
      Count : constant := 331;
      Received : Natural;
      Slot : Client_Slot;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Send (This.Processor.Get_Id,
                        Parameters.Slot (Is_Muted), (Bool, True));
      end loop;

      This.Bus.Dispatch;
      Received := Natural (This.Processor.Received_Parameters.Length);
      Assert (Received = Count,
              "Invalid parameter count: sent" & Natural'Image (Count) &
              ", received" & Natural'Image (Received));

      Slot := Client_Slot (Parameters.Slot (Is_Muted));

      for I in 1 .. Count loop
         E := This.Processor.Received_Parameters.Element (I - 1);
         Assert (E.Id = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = Slot,
                 "Invalid slot, sent" & Client_Slot'Image (Slot) &
                 ", received" & Client_Slot'Image (E.Slot));
         Assert (E.Argument.Bool, "Invalid value");
      end loop;
   end Send_Parameter_Test;

   procedure Send_Command_Test (This : in out Instance) is
      Count : constant := 12;
      Received : Natural;
      Slot : Client_Slot;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Send (This.Processor.Get_Id, Commands.Slot (Expose_One),
                        (Int, Integer (Parameters.Slot (Is_Muted))));
      end loop;

      This.Bus.Dispatch;
      Received := Natural (This.Processor.Received_Commands.Length);
      Assert (Received = Count,
              "Invalid command count: sent" & Natural'Image (Count) &
              ", received" & Natural'Image (Received));

      Slot := Client_Slot (Commands.Slot (Expose_One));

      for I in 1 .. Count loop
         E := This.Processor.Received_Commands.Element (I - 1);
         Assert (E.Id = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = Slot,
                 "Invalid slot, sent" & Client_Slot'Image (Slot) &
                 ", received" & Client_Slot'Image (E.Slot));
         Assert (Parameter_Slot (E.Argument.Int) = Parameters.Slot (Is_Muted),
                 "Invalid value");
      end loop;
   end Send_Command_Test;

   procedure Watch_Test (This : in out Instance) is
      use Event_Vectors;
      Sent, Received : Natural;
      SC, RC : Cursor;
   begin
      This.Random_Fill (Fill_Output);
      This.Random_Fill (Fill_Signals);
      This.Random_Fill (Fill_Packets);
      This.Bus.Watch;

      --  parameters
      Sent := Natural (This.Reference.Output.Length);
      Received := Natural (This.Received_Parameters.Length);
      Assert (Sent = Received,
              "Parameter count mismatch: sent" & Natural'Image (Sent) &
              ", received" & Natural'Image (Received));

      SC := This.Reference.Output.First;
      RC := This.Received_Parameters.First;

      while SC /= No_Element loop
         Assert (Element (SC) = Element (RC),
                 "Sent/received parameters buffers differ");
         Next (SC);
         Next (RC);
      end loop;

      --  signals
      Sent := Natural (This.Reference.Signals.Length);
      Received := Natural (This.Received_Signals.Length);
      Assert (Sent = Received,
              "Signals count mismatch: sent" & Natural'Image (Sent) &
              ", received" & Natural'Image (Received));

      SC := This.Reference.Signals.First;
      RC := This.Received_Signals.First;

      while SC /= No_Element loop
         Assert (Element (SC) = Element (RC),
                 "Sent/received signals buffers differ");
         Next (SC);
         Next (RC);
      end loop;

      --  packets
      declare
         use Packet_Vectors;
         SPC, RPC : Packet_Vectors.Cursor;
      begin
         Sent := Natural (This.Reference.Packets.Length);
         Received := Natural (This.Received_Packets.Length);
         Assert (Sent = Received,
                 "Packets count mismatch: sent" & Natural'Image (Sent) &
                 ", received" & Natural'Image (Received));

         SPC := This.Reference.Packets.First;
         RPC := This.Received_Packets.First;

         while SPC /= Packet_Vectors.No_Element loop
            Assert (Element (SPC) = Element (RPC),
                    "Sent/received packets buffers differ");
            Next (SPC);
            Next (RPC);
         end loop;
      end;
   end Watch_Test;

   procedure Dispatch_Test (This : in out Instance) is
      use Event_Vectors;
      Sent, Received : Natural;
      SC, RC : Cursor;
   begin
      This.Random_Fill (Fill_Commands);
      This.Random_Fill (Fill_Input);
      This.Bus.Dispatch;

      Assert (not This.Bus.Has_Errors, "Unexpected bus errors - " &
              "Unknown_Client:" &
              Integer'Image (This.Bus.Error_Count (Unknown_Client)));

      --  commands
      Sent := Natural (This.Reference.Commands.Length);
      Received := Natural (This.Processor.Received_Commands.Length);
      Assert (Sent = Received,
              "Commands count mismatch: sent" & Natural'Image (Sent) &
              ", received" & Natural'Image (Received));

      SC := This.Reference.Commands.First;
      RC := This.Processor.Received_Commands.First;

      while SC /= No_Element loop
         Assert (Element (SC) = Element (RC),
                 "Sent/received commands buffers differ");
         Next (SC);
         Next (RC);
      end loop;

      --  parameters
      Sent := Natural (This.Reference.Input.Length);
      Received := Natural (This.Processor.Received_Parameters.Length);
      Assert (Sent = Received,
              "Parameters count mismatch: sent" & Natural'Image (Sent) &
              ", received" & Natural'Image (Received));

      SC := This.Reference.Input.First;
      RC := This.Processor.Received_Parameters.First;

      while SC /= No_Element loop
         Assert (Element (SC) = Element (RC),
                 "Sent/received paremeters buffers differ");
         Next (SC);
         Next (RC);
      end loop;
   end Dispatch_Test;

   procedure Offload_Test (This : in out Instance) is
      Command_Stress_Count : constant := 3;
      Parameter_Stress_Count : constant := 5;
      Command_Send_Count : constant := Command_Stress_Count *
                                       (Commands_Bus_Size - 1) + 1;
      Parameter_Send_Count : constant := Parameter_Stress_Count *
                                         (Input_Bus_Size - 1) + 1;
      Received, Value : Natural;
   begin
      --  commands
      for I in 1 .. Command_Send_Count loop
         This.Bus.Send (This.Processor.Get_Id,
                        Commands.Slot (Expose_One),
                        (Int, Integer (Parameters.Slot (Is_Muted))));
      end loop;

      Received := Natural (This.Processor.Received_Commands.Length);
      Assert (Received = Command_Send_Count - 1,
              "Wrong command count received: expected" &
              Integer'Image (Command_Send_Count - 1) & ", received" &
              Integer'Image (Received));

      This.Bus.Dispatch; --  single last

      for I in 1 .. Command_Send_Count loop
         Value := Integer (This.Processor.Received_Commands.
                           Element (I - 1).Slot);
         Assert (Command_Slot (Value) = Commands.Slot (Expose_One),
                 "Wrong received command");
      end loop;

      --  parameters
      for I in 1 .. Parameter_Send_Count loop
         This.Bus.Send (This.Processor.Get_Id,
                        Parameters.Slot (Is_Muted), (Bool, True));
      end loop;

      Received := Natural (This.Processor.Received_Parameters.Length);
      Assert (Received = Parameter_Send_Count - 1,
              "Wrong parameter count received: expected" &
              Integer'Image (Parameter_Send_Count - 1) & ", received" &
              Integer'Image (Received));

      This.Bus.Dispatch; --  single last

      for I in 1 .. Parameter_Send_Count loop
         Value := Integer (This.Processor.Received_Parameters.
                           Element (I - 1).Slot);
         Assert (Parameter_Slot (Value) = Parameters.Slot (Is_Muted),
                 "Wrong received parameter");
      end loop;
   end Offload_Test;

end Sound_Bus_Test;
