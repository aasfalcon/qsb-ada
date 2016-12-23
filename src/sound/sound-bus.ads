with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;

with Sound.Constants;
with Sound.Object;
with Sound.Ring_Facet;
with Sound.Events;

package Sound.Bus is

   use Sound.Events;

   subtype Parent is Object.Instance;
   type Instance is new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   type Error is (Output_Underrun, Packet_Underrun, Signal_Underrun,
                  Unknown_Client, Input_Offload, Commands_Offload);
   function Error_Count (This : Instance; Err : Error) return Natural;
   function Has_Errors (This : Instance) return Boolean;

   function Get_Client (This : in out Instance; Id : Client_Id)
      return Event_Client.Handle;

   procedure Add_Client (This : in out Instance;
                         Client : Event_Client.Handle);
   procedure Add_Supervisor (This : in out Instance;
                             Supervisor : Event_Supervisor.Handle);
   procedure Remove_Client (This : in out Instance;
                            Client : Event_Client.Handle);
   procedure Remove_Supervisor (This : in out Instance;
                                Supervisor : Event_Supervisor.Handle);

   procedure Emit (This : in out Instance; Id : Client_Id;
                   Parameter : Parameter_Slot; Argument : Value);
   procedure Emit (This : in out Instance; Id : Client_Id;
                   Signal : Signal_Slot; Argument : Value := Empty_Value);
   procedure Emit (This : in out Instance; Id : Client_Id;
                   Packet : Packet_Slot; Argument : Data);

   procedure Send (This : in out Instance; Id : Client_Id;
                   Parameter : Parameter_Slot; Argument : Value);
   procedure Send (This : in out Instance; Id : Client_Id;
                   Command : Command_Slot; Argument : Value := Empty_Value);

   procedure Dispatch (This : in out Instance);
   procedure Watch (This : in out Instance);

private

   use Ada.Containers, Constants, Event_Client, Event_Supervisor;

   package Client_Maps is
      new Ordered_Maps (Client_Id, Event_Client.Handle);
   package Supervisor_Vectors is
      new Vectors (Natural, Event_Supervisor.Handle);

   package Event_Ring is new Ring_Facet (Event);
   package Packet_Ring is new Ring_Facet (Packet_Event);

   type Error_Counts is array (Error) of Natural;

   type Instance is new Parent with
      record
         Clients : Client_Maps.Map;
         Supervisors : Supervisor_Vectors.Vector;
         Errors : Error_Counts := (others => 0);

         --  event rings
         Input : Event_Ring.Instance (Input_Bus_Size);
         Output : Event_Ring.Instance (Output_Bus_Size);
         Packets : Packet_Ring.Instance (Packets_Bus_Size);
         Commands : Event_Ring.Instance (Commands_Bus_Size);
         Signals : Event_Ring.Instance (Signals_Bus_Size);
      end record;

   subtype Offload_Error is Error range Input_Offload .. Commands_Offload;
   procedure Offload (This : in out Instance; What : Offload_Error);

end Sound.Bus;
