with AUnit.Assertions; use AUnit.Assertions;

with Sound.Events;
with Sound.Constants;

package body Sound_Bus_Test is

   use Sound, Sound.Events, Fixture.Sound_Bus_Test;

   procedure Has_Runner_Test (This : in out Instance) is
   begin
      Assert (This.Bus.Has_Runner (This.Processor.Get_Id),
              "Don't have default runner");
   end Has_Runner_Test;

   procedure Get_Data_Underruns_Test (This : in out Instance) is
      Actual_Underruns : Natural;
      Planned_Underruns : constant := 14;
      Bus_Size : constant := Constants.Data_Bus_Size - 1;
      Data : constant Data_Value := (0, None);
   begin
      for I in 1 .. Bus_Size + Planned_Underruns loop
         This.Bus.Show (This.Processor.Get_Id, 0, Data);
      end loop;

      Actual_Underruns := This.Bus.Get_Data_Underruns;
      Assert (Actual_Underruns = Planned_Underruns,
              "Wrong data underruns, expected:" &
              Natural'Image (Planned_Underruns) & ", actual:" &
              Natural'Image (Actual_Underruns));
   end Get_Data_Underruns_Test;

   procedure Get_Signal_Underruns_Test (This : in out Instance) is
      Actual_Underruns : Natural;
      Planned_Underruns : constant := 11;
      Bus_Size : constant := Constants.Signals_Bus_Size - 1;
   begin
      for I in 1 .. Bus_Size + Planned_Underruns loop
         This.Bus.Emit (This.Processor.Get_Id, 0);
      end loop;

      Actual_Underruns := This.Bus.Get_Signal_Underruns;
      Assert (Actual_Underruns = Planned_Underruns,
              "Wrong signal underruns, expected:" &
              Natural'Image (Planned_Underruns) & ", actual:" &
              Natural'Image (Actual_Underruns));
   end Get_Signal_Underruns_Test;

   procedure Add_Runner_Test (This : in out Instance) is
   begin
      This.Bus.Initialize; --  remove default
      This.Bus.Add_Runner (This.Processor'Unchecked_Access);
      Assert (This.Bus.Has_Runner (This.Processor.Get_Id),
              "Don't have runner after add");
   end Add_Runner_Test;

   procedure Emit_Test (This : in out Instance) is
      Count : constant := 10;
      Received : Integer;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Emit (This.Processor.Get_Id, I, (Int, I * 33));
      end loop;

      This.Bus.Watch;
      Received := Integer (This.Received_Signals.Length);
      Assert (Received = Count,
              "Invalid signal count: sent" & Integer'Image (Count) &
              ", received" & Integer'Image (Received));

      for I in 1 .. Count loop
         E := This.Received_Signals.Element (I - 1);
         Assert (E.Tag = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = I,
                 "Invalid slot, sent" & Integer'Image (I) &
                 ", received" & Integer'Image (E.Slot));
         Assert (E.Argument.Int = I * 33, "Invalid value");
      end loop;
   end Emit_Test;

   procedure Show_Test (This : in out Instance) is
      Count : constant := 10;
      Received : Integer;
      D : Data_Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Show (This.Processor.Get_Id, I, (1, Int,
                                                   (others => I * 33)));
      end loop;

      This.Bus.Analyze;
      Received := Integer (This.Received_Data.Length);
      Assert (Received = Count,
              "Invalid data item count: sent" & Integer'Image (Count) &
              ", received" & Integer'Image (Received));

      for I in 1 .. Count loop
         D := This.Received_Data.Element (I - 1);
         Assert (D.Tag = This.Processor.Get_Id, "Invalid tag");
         Assert (D.Slot = I,
                 "Invalid slot, sent" & Integer'Image (I) &
                 ", received" & Integer'Image (D.Slot));
         Assert (D.Argument.Ints (1) = I * 33, "Invalid value");
      end loop;
   end Show_Test;

   procedure Remove_Runner_Test (This : in out Instance) is
   begin
      This.Has_Runner_Test;
      This.Bus.Remove_Runner (This.Processor.Get_Id);
      Assert (not This.Bus.Has_Runner (This.Processor.Get_Id),
              "Still has runner after remove");
   end Remove_Runner_Test;

   procedure Send_Test (This : in out Instance) is
      Count : constant := 10;
      Received : Integer;
      E : Event;
   begin
      for I in 1 .. Count loop
         This.Bus.Send (This.Processor.Get_Id, I, (Int, I * 33));
      end loop;

      This.Bus.Dispatch;
      Received := Integer (This.Processor.Received_Commands.Length);
      Assert (Received = Count,
              "Invalid command count: sent" & Integer'Image (Count) &
              ", received" & Integer'Image (Received));

      for I in 1 .. Count loop
         E := This.Processor.Received_Commands.Element (I - 1);
         Assert (E.Tag = This.Processor.Get_Id, "Invalid tag");
         Assert (E.Slot = I,
                 "Invalid slot, sent" & Integer'Image (I) &
                 ", received" & Integer'Image (E.Slot));
         Assert (E.Argument.Int = I * 33, "Invalid value");
      end loop;
   end Send_Test;

   procedure Set_Watcher_Test (This : in out Instance) is
      E : constant Event := This.Random.Make_Event (This.Processor.Get_Id);
   begin
      This.Bus.Initialize; --  remove default
      This.Bus.Add_Runner (This.Processor'Unchecked_Access);
      This.Bus.Set_Watcher (This.Processor.Get_Id, This'Unchecked_Access);
      This.Bus.Emit (E.Tag, E.Slot, E.Argument);
      This.Bus.Watch;

      Assert (Integer (This.Received_Signals.Length) > 0,
              "No signals received");
      Assert (This.Received_Signals.First_Element = E,
              "Unable to set watcher");
   end Set_Watcher_Test;

   procedure Set_Analyzer_Test (This : in out Instance) is
      E : constant Data_Event :=
         This.Random.Make_Data_Event (This.Processor.Get_Id);
   begin
      This.Bus.Initialize; --  remove default
      This.Bus.Add_Runner (This.Processor'Unchecked_Access);
      This.Bus.Set_Analyzer (This.Processor.Get_Id, This'Unchecked_Access);
      This.Bus.Show (E.Tag, E.Slot, E.Argument);
      This.Bus.Analyze;

      Assert (Integer (This.Received_Data.Length) > 0, "No data received");
      Assert (This.Received_Data.First_Element = E, "Unable to set analyzer");
   end Set_Analyzer_Test;

   procedure Dispatch_Test (This : in out Instance) is
      use Event_Vectors;
      Sent, Received : Natural;
      SC, RC : Cursor;
   begin
      This.Random_Fill (Fill_Commands);
      This.Bus.Dispatch;

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
   end Dispatch_Test;

   procedure Watch_Test (This : in out Instance) is
      use Event_Vectors;
      Sent, Received : Natural;
      SC, RC : Cursor;
   begin
      This.Random_Fill (Fill_Signals);
      This.Bus.Watch;

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
   end Watch_Test;

   procedure Stress_Emit_Test (This : in out Instance) is
      Underruns_Planned : constant := 22;
      Underruns : Natural := 0;
   begin
      for I in 1 .. Constants.Signals_Bus_Size - 1 + Underruns_Planned loop
         This.Bus.Emit (This.Processor.Get_Id, I);
      end loop;

      Underruns := This.Bus.Get_Signal_Underruns;
      Assert (Underruns = Underruns_Planned,
              "Planned and actual signal drops do not match: planned" &
              Integer'Image (Underruns_Planned) & ", actual" &
              Integer'Image (Underruns));

      This.Bus.Watch;
      Assert (Integer (This.Received_Signals.Length) =
              Constants.Signals_Bus_Size - 1,
              "Wrong received signal count");

      for I in 1 .. Constants.Signals_Bus_Size - 1 loop
         Assert (This.Received_Signals.Element (I - 1).Slot = I + Underruns,
                 "Wrong received data after drops: expected" &
                 Integer'Image (I + Underruns) & ", received" &
                 Integer'Image (This.Received_Signals.Element (I - 1).Slot));
      end loop;
   end Stress_Emit_Test;

   procedure Stress_Show_Test (This : in out Instance) is
      Underruns_Planned : constant := 22;
      Underruns : Natural := 0;
   begin
      for I in 1 .. Constants.Data_Bus_Size - 1 + Underruns_Planned loop
         This.Bus.Show (This.Processor.Get_Id, I, (others => <>));
      end loop;

      Underruns := This.Bus.Get_Data_Underruns;
      Assert (Underruns = Underruns_Planned,
              "Planned and actual data drops do not match: planned" &
              Integer'Image (Underruns_Planned) & ", actual" &
              Integer'Image (Underruns));

      This.Bus.Analyze;
      Assert (Integer (This.Received_Data.Length) =
              Constants.Data_Bus_Size - 1,
              "Wrong received data count");

      for I in 1 .. Constants.Data_Bus_Size - 1 loop
         Assert (This.Received_Data.Element (I - 1).Slot = I + Underruns,
                 "Wrong received data value after drops: expected" &
                 Integer'Image (I + Underruns) & ", received" &
                 Integer'Image (This.Received_Data.Element (I - 1).Slot));
      end loop;
   end Stress_Show_Test;

   procedure Stress_Send_Test (This : in out Instance) is
      Stress_Dispatches_Planned : constant := 3;
      Send_Count : constant := Stress_Dispatches_Planned *
                               (Constants.Commands_Bus_Size - 1) + 1;
      Received, Value : Natural;
   begin
      for I in 1 .. Send_Count loop
         This.Bus.Send (This.Processor.Get_Id, I);
      end loop;

      Received := Natural (This.Processor.Received_Commands.Length);
      Assert (Received = Send_Count - 1,
              "Wrong command count received: expected" &
              Integer'Image (Send_Count - 1) & ", received" &
              Integer'Image (Received));

      This.Bus.Dispatch; --  last one

      for I in 1 .. Send_Count loop
         Value := This.Processor.Received_Commands.Element (I - 1).Slot;
         Assert (Value = I,
                 "Wrong received command order: expected value" &
                 Integer'Image (I) & ", actual value" &
                 Integer'Image (Value));
      end loop;
   end Stress_Send_Test;

end Sound_Bus_Test;
