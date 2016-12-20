package body Sound.Bus is

   function Error_Count (This : Instance; E : Error)
      return Natural is (This.Errors (E));

   function Has_Errors (This : Instance) return Boolean is
   begin
      for E in Error loop
         if This.Errors (E) > 0 then
            return True;
         end if;
      end loop;

      return False;
   end Has_Errors;

   function Get_Receiver (This : Instance; Id : Receiver_Tag)
      return Event_Receiver.Handle is
      use Receiver_Maps;
   begin
      if This.Receivers.Find (Id) = No_Element then
         return null;
      end if;

      return This.Receivers.Element (Id);
   end Get_Receiver;

   procedure Connect (This : in out Instance;
                      Receiver : Event_Receiver.Handle) is
   begin
      This.Receivers.Insert (Receiver.Get_Id, Receiver);
   end Connect;

   procedure Connect (This : in out Instance;
                      Supervisor : Event_Supervisor.Handle) is
   begin
      This.Supervisors.Append (Supervisor);
   end Connect;

   procedure Disconnect (This : in out Instance;
                         Receiver : Event_Receiver.Handle) is
   begin
      This.Receivers.Delete (Receiver.Get_Id);
   end Disconnect;

   procedure Disconnect (This : in out Instance;
                         Supervisor : Event_Supervisor.Handle) is
      use Supervisor_Vectors;
      C : Cursor := This.Supervisors.Find (Supervisor);
   begin
      This.Supervisors.Delete (C);
   end Disconnect;

   procedure Emit (This : in out Instance; Id : Receiver_Tag;
                   Parameter : Parameter_Slot; Argument : Value) is
      E : constant Event := (Id, Receiver_Slot (Parameter), Argument);
   begin
      This.Output.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Errors (Output_Underrun) := This.Errors (Output_Underrun) + 1;
         This.Output.Drop;
         This.Output.Push (E);
   end Emit;

   procedure Emit (This : in out Instance; Id : Receiver_Tag;
                   Signal : Signal_Slot; Argument : Value) is
      E : constant Event := (Id, Receiver_Slot (Signal), Argument);
   begin
      This.Signals.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Errors (Signal_Underrun) := This.Errors (Signal_Underrun) + 1;
         This.Signals.Drop;
         This.Signals.Push (E);
   end Emit;

   procedure Emit (This : in out Instance; Id : Receiver_Tag;
                   Packet : Packet_Slot; Argument : Data) is
      P : constant Events.Packet := (Id, Receiver_Slot (Packet), Argument);
   begin
      This.Packets.Push (P);
   exception
      when Packet_Ring.Overflow_Error =>
         This.Errors (Packet_Underrun) := This.Errors (Packet_Underrun) + 1;
         This.Packets.Drop;
         This.Packets.Push (P);
   end Emit;

   procedure Send (This : in out Instance; Id : Receiver_Tag;
                   Parameter : Parameter_Slot; Argument : Value) is
      E : constant Event := (Id, Receiver_Slot (Parameter), Argument);
   begin
      This.Input.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Offload (Input_Offload);
         This.Input.Push (E);
   end Send;

   procedure Send (This : in out Instance; Id : Receiver_Tag;
                   Command : Command_Slot; Argument : Value) is
      E : constant Event := (Id, Receiver_Slot (Command), Argument);
   begin
      This.Commands.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Offload (Commands_Offload);
         This.Commands.Push (E);
   end Send;

   procedure Dispatch (This : in out Instance) is
      use Receiver_Maps;
      E : Event;
   begin
      while not This.Input.Is_Empty loop
         begin
            This.Input.Pop (E);
            Element (This.Receivers.Find (E.Id)).
               Set (Parameter_Slot (E.Slot), E.Argument);
         exception
            when Constraint_Error =>
               This.Errors (Unknown_Receiver) :=
                  This.Errors (Unknown_Receiver) + 1;
         end;
      end loop;

      while not This.Commands.Is_Empty loop
         begin
            This.Commands.Pop (E);
            Element (This.Receivers.Find (E.Id)).
               Run (Command_Slot (E.Slot), E.Argument);
         exception
            when Constraint_Error =>
               This.Errors (Unknown_Receiver) :=
                  This.Errors (Unknown_Receiver) + 1;
         end;
      end loop;
   end Dispatch;

   procedure Watch (This : in out Instance) is
      use Supervisor_Vectors;
      procedure Propagate_Event (E : Event);
      procedure Propagate_Packet (P : Events.Packet);

      procedure Propagate_Event (E : Event) is
         C : Cursor := This.Supervisors.First;
      begin
         while C /= No_Element loop
            Element (C).Watch_Event (E);
            Next (C);
         end loop;
      end Propagate_Event;

      procedure Propagate_Packet (P : Events.Packet) is
         C : Cursor := This.Supervisors.First;
      begin
         while C /= No_Element loop
            Element (C).Analyze_Packet (P);
            Next (C);
         end loop;
      end Propagate_Packet;

      E : Event;
      P : Packet;
   begin
      if not This.Supervisors.Is_Empty then
         while not This.Output.Is_Empty loop
            This.Output.Pop (E);
            Propagate_Event (E);
         end loop;

         while not This.Signals.Is_Empty loop
            This.Signals.Pop (E);
            Propagate_Event (E);
         end loop;

         while not This.Packets.Is_Empty loop
            This.Packets.Pop (P);
            Propagate_Packet (P);
         end loop;
      end if;
   end Watch;

   procedure Offload (This : in out Instance; What : Offload_Error) is
   begin
      This.Errors (What) := This.Errors (What) + 1;
      This.Dispatch;
   end;

end Sound.Bus;
