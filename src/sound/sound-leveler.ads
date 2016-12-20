with Sound.Buffer;
with Sound.Events;
with Sound.Processor;

package Sound.Leveler is
--    use Sound, Sound.Events;
-- 
--    subtype Parent is Processor.Instance;
--    type Instance is new Parent with private;
--    subtype Class is Instance'Class;
--    type Handle is access all Class;
-- 
--    type Parameter is
--       (
--          Level         --  Float, level multiplier
--       );
-- 
--    package Parameters is new Slot_Enum (Parameter, Processor.Parameters.Tail);
-- 
--    overriding
--    procedure Initialize (This : in out Instance);
-- 
-- --    function Get (This : Instance; P : Parameter) return Value;
-- --    procedure Set (This : in out Instance; P : Parameter; V : Value);
-- 
--    overriding
--    procedure Process (This : Instance; Buf : in out Buffer.Instance);
-- 
--    overriding
--    procedure Process_Entry (This : Instance; Buf : in out Buffer.Instance);
-- 
-- private
-- 
--    type Instance is new Parent with
--       record
--          Divisor : Float := 1.0;
--          Is_Muted : Boolean := False;
--       end record;

end Sound.Leveler;
