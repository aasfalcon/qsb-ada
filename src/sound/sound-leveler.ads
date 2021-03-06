with Sound.Buffer;
with Sound.Events;
with Sound.Processor;

package Sound.Leveler is
   use Sound, Events;

   subtype Parent is Processor.Instance;
   type Instance is new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   ----------------------------------------------------------------------------
   --    Processor slot    --  Type    | Value description                   --
   ----------------------------------------------------------------------------

   type Parameter is
      (
         Level             --  Float, linear level coefficient (0.0 .. 1.0+)
      );

   package Parameters is
      new Slot_Enum (Parameter, Parameter_Slot, Processor.Parameters.Tail);

   overriding
   function Get (This : Instance; Parameter : Parameter_Slot) return Value;

   overriding
   procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                  Argument : Value);
   overriding
   procedure Process (This : Instance;
                      Buf : in out Buffer.Instance);

private

   type Instance is new Parent with
      record
         Log_Level : Float := 1.0;

         --  parameters
         Level : Float := 1.0;
      end record;

end Sound.Leveler;
