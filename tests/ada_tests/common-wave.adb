with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;

package body Common.Wave is

   use Ada.Numerics, Ada.Numerics.Elementary_Functions;

   function Sine (Offset : Positive)
      return Sample is (Sample (Sin (Float (Offset) * 2.0 * Pi *
                                     Test_Tone / Sample_Rate)));

   function Square (Offset : Positive)
      return Sample is (if Sine (Offset + 10) >= 0.0 then 1.0 else -1.0);

   function Random (Offset : Positive) return Sample is
      pragma Unreferenced (Offset);
      package Real_Random renames Ada.Numerics.Float_Random;
      Gen : Real_Random.Generator;
   begin
      return Sample ((Real_Random.Random (Gen) - 0.5) * 2.0);
   end Random;

   procedure Fill (Buffer : in out Sound.Buffer.Instance; Wave : Wave_Function;
                   Channel : Natural := 0) is
      Sample : Sound.Buffer.Sample;
   begin
      if Channel = 0 then
         for F in 1 .. Buffer.Frames loop
            Sample := Wave (F);

            for C in 1 .. Buffer.Channels loop
               Buffer.Samples (F, C) := Sample;
            end loop;
         end loop;
      else
         for F in 1 .. Buffer.Frames loop
            Buffer.Samples (F, Channel) := Wave (F);
         end loop;
      end if;
   end Fill;

end Common.Wave;
