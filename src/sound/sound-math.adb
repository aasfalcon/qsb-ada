with Ada.Numerics.Elementary_Functions;

with Sound.Constants;

package body Sound.Math is

   use Ada.Numerics.Elementary_Functions;

   function Logarithmic_Level (X : Float) return Float is
      --  Source: https://www.dr-lex.be/info-stuff/volumecontrols.html
      R : constant Float := Constants.Leveler_Dynamic_Range;
      B : constant Float := Log (10.0**(R / 20.0));
      --  when x = 1, y should be 1, so: a = 1 / exp (b)
      A : constant Float := 1.0 / Exp (B);
      --  exponential curve: y = a * exp (b * x) + c, c = 0
      Y : constant Float := A * Exp (B * X);
   begin
      --  smooth linear scale near zero
      return (if X >= 0.1 then Y else Y * X * 10.0);
   end Logarithmic_Level;

end Sound.Math;
