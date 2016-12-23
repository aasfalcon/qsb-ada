package body Sound.Bus is

   function Error_Count (This : Instance; Err : Error)
      return Natural is (This.Errors (Err));

   function Has_Errors (This : Instance) return Boolean is
   begin
      for E in Error loop
         if This.Errors (E) > 0 then
            return True;
         end if;
      end loop;

      return False;
   end Has_Errors;

   function Get_Client (This : in out Instance; Id : Client_Id)
      return Event_Client.Handle is
   begin
      return This.Clients.Element (Id);
   exception
      when Constraint_Error =>
         This.Errors (Unknown_Client) :=
            This.Errors (Unknown_Client) + 1;
      return null;
   end Get_Client;

   procedure Add_Client (This : in out Instance;
                         Client : Event_Client.Handle) is
   begin
      This.Clients.Insert (Client.Get_Id, Client);
   end Add_Client;

   procedure Add_Supervisor (This : in out Instance;
                             Supervisor : Event_Supervisor.Handle) is
   begin
      This.Supervisors.Append (Supervisor);
   end Add_Supervisor;

   procedure Remove_Client (This : in out Instance;
                            Client : Event_Client.Handle) is
   begin
      This.Clients.Delete (Client.Get_Id);
   end Remove_Client;

   procedure Remove_Supervisor (This : in out Instance;
                                Supervisor : Event_Supervisor.Handle) is
      use Supervisor_Vectors;
      C : Cursor := This.Supervisors.Find (Supervisor);
   begin
      This.Supervisors.Delete (C);
   end Remove_Supervisor;

   procedure Emit (This : in out Instance; Id : Client_Id;
                   Parameter : Parameter_Slot; Argument : Value) is
      E : constant Event := (Id, Client_Slot (Parameter), Argument);
   begin
      This.Output.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Errors (Output_Underrun) := This.Errors (Output_Underrun) + 1;
         This.Output.Drop;
         This.Output.Push (E);
   end Emit;

   procedure Emit (This : in out Instance; Id : Client_Id;
                   Signal : Signal_Slot; Argument : Value := Empty_Value) is
      E : constant Event := (Id, Client_Slot (Signal), Argument);
   begin
      This.Signals.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Errors (Signal_Underrun) := This.Errors (Signal_Underrun) + 1;
         This.Signals.Drop;
         This.Signals.Push (E);
   end Emit;

   procedure Emit (This : in out Instance; Id : Client_Id;
                   Packet : Packet_Slot; Argument : Data) is
      P : constant Packet_Event := (Id, Client_Slot (Packet), Argument);
   begin
      This.Packets.Push (P);
   exception
      when Packet_Ring.Overflow_Error =>
         This.Errors (Packet_Underrun) := This.Errors (Packet_Underrun) + 1;
         This.Packets.Drop;
         This.Packets.Push (P);
   end Emit;

   procedure Send (This : in out Instance; Id : Client_Id;
                   Parameter : Parameter_Slot; Argument : Value) is
      E : constant Event := (Id, Client_Slot (Parameter), Argument);
   begin
      This.Input.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Offload (Input_Offload);
         This.Input.Push (E);
   end Send;

   procedure Send (This : in out Instance; Id : Client_Id;
                   Command : Command_Slot; Argument : Value := Empty_Value) is
      E : constant Event := (Id, Client_Slot (Command), Argument);
   begin
      This.Commands.Push (E);
   exception
      when Event_Ring.Overflow_Error =>
         This.Offload (Commands_Offload);
         This.Commands.Push (E);
   end Send;

   procedure Dispatch (This : in out Instance) is
      use Client_Maps;
      E : Event;
      Client : Event_Client.Handle;
   begin
      while not This.Input.Is_Empty loop
         This.Input.Pop (E);
         Client := This.Get_Client (E.Id);

         if Client /= null then
            Client.Set (Parameter_Slot (E.Slot), E.Argument);
         end if;
      end loop;

      while not This.Commands.Is_Empty loop
         This.Commands.Pop (E);
         Client := This.Get_Client (E.Id);

         if Client /= null then
            Client.Run (Command_Slot (E.Slot), E.Argument);
         end if;
      end loop;
   end Dispatch;

   procedure Watch (This : in out Instance) is
      use Supervisor_Vectors;
      C : Cursor;
      E : Event;
      P : Packet_Event;
   begin
      if This.Supervisors.Is_Empty then
         This.Output.Clear;
         This.Signals.Clear;
         This.Packets.Clear;
      else
         while not This.Output.Is_Empty loop
            This.Output.Pop (E);
            C := This.Supervisors.First;

            while C /= No_Element loop
               Element (C).Watch_Parameter (E);
               Next (C);
            end loop;
         end loop;

         while not This.Signals.Is_Empty loop
            This.Signals.Pop (E);
            C := This.Supervisors.First;

            while C /= No_Element loop
               Element (C).Watch_Signal (E);
               Next (C);
            end loop;
         end loop;

         while not This.Packets.Is_Empty loop
            This.Packets.Pop (P);
            C := This.Supervisors.First;

            while C /= No_Element loop
               Element (C).Watch_Packet (P);
               Next (C);
            end loop;
         end loop;
      end if;
   end Watch;

   procedure Offload (This : in out Instance; What : Offload_Error) is
   begin
      This.Errors (What) := This.Errors (What) + 1;
      This.Dispatch;
   end Offload;

end Sound.Bus;
