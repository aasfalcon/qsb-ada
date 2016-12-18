with Sound.Buffer;

package Common.Wave is

   use Sound.Buffer;

   Test_Tone : constant Float := 440.0;
   Sample_Rate : constant Float := 44100.0;

   function Sine (Offset : Positive) return Sample;
   function Square (Offset : Positive) return Sample;
   function Random (Offset : Positive) return Sample;

   type Wave_Function is access function (Offset : Positive) return Sample;
   procedure Fill (Buffer : in out Sound.Buffer.Instance; Wave : Wave_Function;
                   Channel : Natural := 0);

end Common.Wave;
