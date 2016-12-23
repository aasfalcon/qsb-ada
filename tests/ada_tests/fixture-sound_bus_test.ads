with Ada.Containers.Vectors;

with Common.Random;

with Sound.Buffer;
with Sound.Bus;
with Sound.Events;
with Sound.Processor;

package Fixture.Sound_Bus_Test is

   use Sound, Sound.Events;

   -----------------------
   -- Fixture_Processor --
   -----------------------

   package Event_Vectors is new Ada.Containers.Vectors (Natural, Event);
   package Packet_Vectors is
      new Ada.Containers.Vectors (Natural, Packet_Event);

   type Fixture_Processor is new Processor.Instance with
      record
         Received_Parameters, Received_Commands : Event_Vectors.Vector;
      end record;

   subtype Fixture_Processor_Class is Fixture_Processor'Class;
   type Fixture_Processor_Handle is access all Fixture_Processor_Class;

   overriding
   procedure Set (This : in out Fixture_Processor; Parameter : Parameter_Slot;
                  Argument : Value);

   overriding
   procedure Run (This : in out Fixture_Processor; Command : Command_Slot;
                  Argument : Value := Empty_Value);

   overriding
   procedure Process (This : Fixture_Processor;
                      Buf : in out Sound.Buffer.Instance);

   ------------------------
   -- Instance (Fixture) --
   ------------------------

   type Fixture_Reference is
      record
         Input, Output, Commands, Signals : Event_Vectors.Vector;
         Packets : Packet_Vectors.Vector;
      end record;

   type Instance is new Test_Fixture and
      Event_Supervisor.Instance with
      record
         Bus : Sound.Bus.Handle := null;
         Processor : Fixture_Processor_Handle := null;
         Reference : Fixture_Reference;
         Received_Parameters : Event_Vectors.Vector;
         Received_Signals : Event_Vectors.Vector;
         Received_Packets : Packet_Vectors.Vector;
         Random : Common.Random.Instance;
      end record;

   procedure Set_Up (This : in out Instance);

   type Fill_Scope is (Fill_Input, Fill_Output, Fill_Commands, Fill_Signals,
                       Fill_Packets, Fill_All);
   procedure Random_Fill (This : in out Instance;
                          Scope : Fill_Scope := Fill_All);

private

   overriding
   procedure Watch_Signal (This : in out Instance; E : Event);

   overriding
   procedure Watch_Packet (This : in out Instance; P : Packet_Event);

   overriding
   procedure Watch_Parameter (This : in out Instance; E : Event);

end Fixture.Sound_Bus_Test;
