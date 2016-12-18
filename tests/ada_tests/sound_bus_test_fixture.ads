with Ada.Containers.Vectors;

with AUnit.Test_Fixtures; use AUnit.Test_Fixtures;

with Common.Random;

with Sound.Bus;
with Sound.Events;
with Sound.Processor;

package Sound_Bus_Test_Fixture is

   use Sound, Sound.Events;

   -----------------------
   -- Fixture_Processor --
   -----------------------

   package Event_Vectors is new Ada.Containers.Vectors (Natural, Event);
   package Data_Event_Vectors is
      new Ada.Containers.Vectors (Natural, Data_Event);

   type Fixture_Processor is new Processor.Instance with
      record
         Received_Commands : Event_Vectors.Vector;
      end record;

   overriding
   procedure Initialize (This : in out Fixture_Processor);

   overriding
   procedure Perform (This : in out Fixture_Processor; Command : Slot;
                      Argument : Value := Empty_Value);

   ------------------------
   -- Instance (Fixture) --
   ------------------------

   type Fixture_Reference is
      record
         Commands, Signals : Event_Vectors.Vector;
         Data : Data_Event_Vectors.Vector;
      end record;

   type Instance is new Test_Fixture and
      Event_Watcher.Instance and
      Data_Analyzer.Instance with
      record
         Bus : Sound.Bus.Instance;
         Processor : aliased Fixture_Processor;
         Watcher : Event_Watcher.Handle;
         Analyzer : Data_Analyzer.Handle;
         Received_Signals : Event_Vectors.Vector;
         Received_Data : Data_Event_Vectors.Vector;
         Reference : Fixture_Reference;
         Random : Common.Random.Instance;
      end record;

   procedure Set_Up (This : in out Instance);

   type Fill_Scope is (Fill_Commands, Fill_Signals, Fill_Data, Fill_All);
   procedure Random_Fill (This : in out Instance;
                          Scope : Fill_Scope := Fill_All);

private

   overriding
   procedure Watch_Event (This : in out Instance; E : Event);

   overriding
   procedure Analyze_Data (This : in out Instance; E : Data_Event);

end Sound_Bus_Test_Fixture;
