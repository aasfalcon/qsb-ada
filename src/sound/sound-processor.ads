with Ada.Containers.Vectors;

with Sound.Bus;
with Sound.Buffer;
with Sound.Object;
with Sound.Events;

package Sound.Processor is
   use Sound.Events;

   subtype Parent is Object.Instance;
   type Instance is abstract new Parent and Event_Client.Instance with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   ----------------------------------------------------------------------------
   --    Processor slot    --  Type    | Value description                   --
   ----------------------------------------------------------------------------

   type Parameter is
      (
         Id,               --  Int     | Processor ID tag (read-only)
         Index,            --  Int     | In super, set -1 to make last
         Is_Muted,         --  Bool    | Produce silence
         Is_Bypassed,      --  Bool    | Don't touch the buffer
         Is_Parallel,      --  Bool    | Process subs in parallel
         Super_Id          --  Int     | Super-processor ID
      );

   type Command is
      (
         Expose,           --  None    | (Emit all parameters in sequence)
         Expose_One,       --  Int     | One parameter slot to emit
         Destroy,          --  None    | (Destroy processor and all subs)
         Show_Subs         --  None    | (Emit direct subs' IDs in data)
      );

   type Signal is
      (
         Error,            --  Ints    | Error number (1)
         Connect,          --  None    | (Connected to bus)
         Disconnect        --  None    | (Disconnected from bus)
      );

   type Packet is
      (
         Subs              --  Ints    | Sub-processor IDs
      );

   package Parameters is new Slot_Enum (Parameter, Parameter_Slot);
   package Commands is new Slot_Enum (Command, Command_Slot);
   package Signals is new Slot_Enum (Signal, Signal_Slot);
   package Packets is new Slot_Enum (Packet, Packet_Slot);

   overriding
   function Get_Id (This : Instance) return Client_Id;

   function Get (This : Instance; Parameter : Parameter_Slot) return Value;

   overriding
   procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                  Argument : Value);

   overriding
   procedure Run (This : in out Instance; Command : Command_Slot;
                  Argument : Value := Empty_Value);

   overriding
   procedure Initialize (This : in out Instance);

   overriding
   procedure Finalize (This : in out Instance);

   procedure Connect (This : in out Instance; Bus : Sound.Bus.Handle);
   procedure Disconnect (This : in out Instance);

   procedure Emit (This : Instance; Parameter : Parameter_Slot;
                   Argument : Value := Empty_Value);
   procedure Emit (This : Instance; Signal : Signal_Slot;
                   Argument : Value := Empty_Value);
   procedure Emit (This : Instance; Packet : Packet_Slot;
                   Argument : Data := Empty_Data);

   procedure Process (This : Instance;
                      Buf : in out Buffer.Instance) is abstract;
   procedure Process_Entry (This : Instance; Buf : in out Buffer.Instance);

private

   package Subs_Vectors is new Ada.Containers.Vectors (Positive, Handle);

   type Instance is abstract new Parent and Event_Client.Instance with
      record
         Bus : Sound.Bus.Handle := null;
         Id : Client_Id := 0;
         Super : Handle := null;
         Subs : Subs_Vectors.Vector;

         --  parameters
         Index : Natural := 0;
         Is_Muted : Boolean := False;
         Is_Bypassed : Boolean := False;
         Is_Parallel : Boolean := False;
         Is_Subs_Before : Boolean := True;
      end record;

end Sound.Processor;
